[CmdletBinding()]
param(
    [string]$billingScope,
    [string]$subscriptionNamePrefix = "accelerator-bootstrap-modules",
    [string[]]$subscriptionTypes = @("connectivity", "management", "identity", "security"),
    [int]$maxRetries = 5,
    [int]$throttleLimit = 2,
    [switch]$planOnly
)

# Get current Azure account information
$accountInfo = az account show --output json | ConvertFrom-Json

# Look up tenant name from Graph API domains
$domains = az rest --method get --url "https://graph.microsoft.com/v1.0/domains" --output json | ConvertFrom-Json
$defaultDomain = $domains.value | Where-Object { $_.isDefault -eq $true }
$tenantName = if ($defaultDomain.id) { $defaultDomain.id } else { "(unknown)" }

Write-Host ""
Write-Host "=== Azure Connection Information ===" -ForegroundColor Cyan
Write-Host "Tenant ID:    $($accountInfo.tenantId)" -ForegroundColor Yellow
Write-Host "Tenant Name:  $tenantName" -ForegroundColor Yellow
Write-Host "Account:      $($accountInfo.user.name)" -ForegroundColor Yellow
Write-Host "Subscription: $($accountInfo.name)" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

$confirmation = Read-Host "Do you want to continue with this account? (y/n)"
if ($confirmation -ine 'y') {
    Write-Host "Operation cancelled by user." -ForegroundColor Red
    exit 0
}

Write-Host ""

$tests = ./.github/tests/scripts/generate-matrix.ps1

# Get all existing aliases once using REST API with paging (more efficient than checking each one individually)
Write-Host "Fetching existing subscription aliases..." -ForegroundColor Cyan
$existingAliasNames = @()
$aliasUrl = "https://management.azure.com/providers/Microsoft.Subscription/aliases?api-version=2021-10-01"

do {
    $response = az rest --method get --url "`"$aliasUrl`"" | ConvertFrom-Json
    if ($response.value) {
        $existingAliasNames += $response.value | ForEach-Object { $_.name }
    }
    $aliasUrl = $response.nextLink
} while ($aliasUrl)

Write-Host "Fetched $($existingAliasNames.Count) existing aliases." -ForegroundColor Green

# Build list of subscriptions to create
$subscriptionsToCreate = @()
$existingSubscriptions = @()
$skippedTests = @()

foreach ($test in $tests) {
    # Only create subscriptions for tests that deploy Azure resources
    if ($test.deployAzureResources -ne "true") {
        $skippedTests += $test.Name
        continue
    }

    foreach ($subscriptionType in $subscriptionTypes) {
        $subscriptionName = "$subscriptionNamePrefix-$($test.ShortNamePrefix)-$subscriptionType"

        if ($existingAliasNames -notcontains $subscriptionName) {
            $subscriptionsToCreate += $subscriptionName
        } else {
            $existingSubscriptions += $subscriptionName
        }
    }
}

# Display skipped tests
if ($skippedTests.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Tests Skipped (deployAzureResources=false) ===" -ForegroundColor Cyan
    foreach ($test in $skippedTests) {
        Write-Host "  - $test" -ForegroundColor Gray
    }
}

# Display existing subscriptions
if ($existingSubscriptions.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Existing Subscription Aliases (will be skipped) ===" -ForegroundColor Cyan
    foreach ($sub in $existingSubscriptions) {
        Write-Host "  - $sub" -ForegroundColor Gray
    }
}

# Display subscriptions to create
Write-Host ""
if ($subscriptionsToCreate.Count -eq 0) {
    Write-Host "No new subscriptions to create. All aliases already exist." -ForegroundColor Green
    return
}

Write-Host "=== Subscriptions to Create ===" -ForegroundColor Cyan
foreach ($sub in $subscriptionsToCreate) {
    Write-Host "  - $sub" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Total: $($subscriptionsToCreate.Count) subscription(s) to create" -ForegroundColor Cyan
Write-Host ""

if ($planOnly) {
    Write-Host "Plan only mode - no subscriptions will be created." -ForegroundColor Magenta
    return
}

# Prompt for confirmation before creating
$createConfirmation = Read-Host "Do you want to create these $($subscriptionsToCreate.Count) subscription(s)? (y/n)"
if ($createConfirmation -ine 'y') {
    Write-Host "Operation cancelled by user." -ForegroundColor Red
    return
}

Write-Host ""

# Create a thread-safe hashtable to track rate limiting across parallel tasks
$rateLimitState = [hashtable]::Synchronized(@{
    WaitUntil = [DateTime]::MinValue
})

# Create the subscriptions in parallel with retry logic
Write-Host "Creating subscriptions (throttle: $throttleLimit)..." -ForegroundColor Cyan

$results = $subscriptionsToCreate | ForEach-Object -Parallel {
    $subscriptionName = $_
    $scope = $using:billingScope
    $retries = $using:maxRetries
    $state = $using:rateLimitState
    $VerbosePreference = $using:VerbosePreference
    $retryCount = 0
    $success = $false

    while (-not $success -and $retryCount -lt $retries) {
        # Check if we're in a rate limit wait period
        $waitUntil = $state.WaitUntil
        if ($waitUntil -gt [DateTime]::Now) {
            $waitSeconds = [math]::Ceiling(($waitUntil - [DateTime]::Now).TotalSeconds)
            Write-Host "Rate limit active. $subscriptionName waiting $waitSeconds seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds $waitSeconds
        }

        Write-Host "Creating subscription: $subscriptionName (Attempt $($retryCount + 1) of $retries)" -ForegroundColor Yellow
        $result = az account alias create --name "$subscriptionName" --billing-scope "$scope" --display-name "$subscriptionName" --workload "Production" 2>&1

        if ($LASTEXITCODE -eq 0) {
            $success = $true
            Write-Host "Successfully created: $subscriptionName" -ForegroundColor Green
        } else {
            $errorMessage = $result | Out-String
            if ($errorMessage -match "TooManyRequests.*Retry in (\d{2}):(\d{2}):(\d{2})") {
                $hours = [int]$Matches[1]
                $minutes = [int]$Matches[2]
                $seconds = [int]$Matches[3]
                $waitSeconds = ($hours * 3600) + ($minutes * 60) + $seconds + (1 * 60)  # Add 60 second buffer
                Write-Verbose $errorMessage

                # Set the shared rate limit wait time
                $newWaitUntil = [DateTime]::Now.AddSeconds($waitSeconds)
                if ($newWaitUntil -gt $state.WaitUntil) {
                    $state.WaitUntil = $newWaitUntil
                    Write-Host "Rate limit hit! All tasks will wait until $($newWaitUntil.ToString('HH:mm:ss'))" -ForegroundColor Red
                }

                Write-Host "Rate limited for $subscriptionName. Waiting $waitSeconds seconds before retry..." -ForegroundColor Yellow
                Start-Sleep -Seconds $waitSeconds
                $retryCount++
            } else {
                Write-Host "Failed to create $subscriptionName : $errorMessage" -ForegroundColor Red
                break
            }
        }
    }

    [PSCustomObject]@{
        Name = $subscriptionName
        Success = $success
    }
} -ThrottleLimit $throttleLimit

$successCount = ($results | Where-Object { $_.Success }).Count
$failCount = ($results | Where-Object { -not $_.Success }).Count

Write-Host ""
Write-Host "Subscription creation complete." -ForegroundColor Green
Write-Host "  Successful: $successCount" -ForegroundColor Green
if ($failCount -gt 0) {
    Write-Host "  Failed: $failCount" -ForegroundColor Red
}
