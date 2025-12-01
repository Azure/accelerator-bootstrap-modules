# This file can be used to clean up Resource Groups if there has been an issue with the End to End tests.
# CAUTION: Make sure you are connected to the correct subscription before running this script!
$filter = ""
$subscriptions = @(
    "6be58818-3390-4c43-a3bb-2666110eeb66",
    "5331601a-985a-4f45-87d1-6b4156c8acf5",
    "bceedecb-9f0b-4aa3-9778-1d1fa92f289e",
    "9ebf45b8-555d-49c6-81fb-d27ca08f7c28",
    "eac9acf5-0a34-4db8-ae56-cdbcc7e2cf4c",
    "3a6bdc35-0830-41ac-b323-37a5a030e241",
    "c4332eb2-f966-47db-aa47-5d71e239d8aa",
    "0aeefd1c-62c7-4071-91ad-925899603976",
    "0d754f66-65b4-4f64-97f5-221f0174ad48"
)

$subscriptions | ForEach-Object -Parallel {
    $subscription = $_
    $subscriptionDetails = az account show --subscription $subscription | ConvertFrom-Json
    Write-Host "Processing subscription: $subscription - $($subscriptionDetails.name)"

    $resourceGroups = @("")
    while ($resourceGroups.Count -gt 0) {
        if($filter -eq "")
        {
            $resourceGroups = az group list --subscription $subscription | ConvertFrom-Json
        }
        else
        {
            $resourceGroups = az group list --subscription $subscription --query "[?contains(name, '$filter')]" | ConvertFrom-Json
        }

        $resourceGroups | ForEach-Object -Parallel {
            $subscription = $using:subscription
            $subscriptionDetails = $using:subscriptionDetails
            Write-Host "Deleting resource group: $($_.name) in subscription: $subscription - $($subscriptionDetails.name)"
            az group delete --subscription $subscription --name $_.name --yes
        } -ThrottleLimit 10
    }
} -ThrottleLimit 10
