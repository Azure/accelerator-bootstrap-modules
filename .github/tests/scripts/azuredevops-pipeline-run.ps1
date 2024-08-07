param (
    [string]$organizationName,
    [string]$projectName,
    [string]$personalAccessToken,
    [string]$pipelineNamePart = "Continuous Delivery",
    [switch]$skipDestroy = $false,
    [int]$maximumRetries = 10,
    [int]$retryCount = 0,
    [int]$retryDelay = 10000,
    [string]$iac
)

function Invoke-Pipeline {
    param (
        [string]$organizationName,
        [string]$projectName,
        [int]$pipelineId,
        [string]$pipelineAction = "",
        [string]$iac,
        [hashtable]$headers
    )
    $pipelineDispatchUrl = "https://dev.azure.com/$organizationName/$projectName/_apis/pipelines/$pipelineId/runs?api-version=7.2-preview.1"
    Write-Host "Pipeline Dispatch URL: $pipelineDispatchUrl"

    $pipelineDispatchBody = @{}
    if($pipelineAction -eq "") {
        $pipelineDispatchBody = @{
            "resources" = @{
                "repositories" = @{
                    "self" = @{
                        "refName" = "refs/heads/main"
                    }
                }
            }
        } | ConvertTo-Json -Depth 100
    } else {
        if($iac -eq "terraform") {
            $pipelineDispatchBody = @{
                "resources" = @{
                    "repositories" = @{
                        "self" = @{
                            "refName" = "refs/heads/main"
                        }
                    }
                }
                "templateParameters" = @{
                    "terraform_action" = $pipelineAction
                }
            } | ConvertTo-Json -Depth 100
        }

        if($iac -eq "bicep") {
            $pipelineDispatchBody = @{
                "resources" = @{
                    "repositories" = @{
                        "self" = @{
                            "refName" = "refs/heads/main"
                        }
                    }
                }
                "templateParameters" = @{
                    "destroy" = ($pipelineAction -eq "destroy").ToString().ToLower()
                }
            } | ConvertTo-Json -Depth 100
        }
    }

    $result = Invoke-RestMethod -Method POST -Uri $pipelineDispatchUrl -Headers $headers -Body $pipelineDispatchBody -StatusCodeVariable statusCode -ContentType "application/json"
    if ($statusCode -ne 200) {
        throw "Failed to dispatch the pipeline."
    }

    # Get the pipeline run id
    $pipelineRunId = $result.id
    Write-Host "Pipeline Run ID: $pipelineRunId"
    return [int]$pipelineRunId
}

function Wait-ForPipelineRunToComplete {
    param (
        [string]$organizationName,
        [string]$projectName,
        [int]$pipelineId,
        [int]$pipelineRunId,
        [hashtable]$headers
    )

    $pipelineRunUrl = "https://dev.azure.com/$organizationName/$projectName/_apis/pipelines/$pipelineId/runs/$($pipelineRunId)?api-version=7.2-preview.1"
    Write-Host "Pipeline Run URL: $pipelineRunUrl"

    $pipelineRun = $null
    $pipelineRunStatus = ""
    $pipelineRunResult = ""
    while($pipelineRunStatus -ne "completed") {
        Start-Sleep -Seconds 10
        $pipelineRun = Invoke-RestMethod -Method GET -Uri $pipelineRunUrl -Headers $headers -StatusCodeVariable statusCode
        if ($statusCode -lt 300) {
            $pipelineRunStatus = $pipelineRun.state
            $pipelineRunResult = $pipelineRun.result
            Write-Host "Pipeline Run Status: $pipelineRunStatus - Conclusion: $pipelineRunResult"
        } else {
            Write-Host "Failed to find the pipeline run. Status Code: $statusCode"
            throw "Failed to find the pipeline run."
        }
    }

    if($pipelineRunResult -ne "succeeded") {
        # TODO: Get pipeline run logs
        #$pipelineRunLogsUrl = $pipelineRun.logs_url
        #$pipelineRunLogs = Invoke-RestMethod -Method GET -Uri $pipelineRunLogsUrl -Headers $headers -StatusCodeVariable statusCode
        #$pipelineRunLogsString = $pipelineRunLogs | ConvertTo-Json -Depth 100
        #Write-Host "Pipeline Run Logs:"
        #Write-Host $pipelineRunLogsString
        throw "The pipeline run did not complete successfully. Conclusion: $pipelineRunResult"
    }
}

# Setup Variables
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
$headers = @{
    "Authorization" = "Basic $token"
    "Accept" = "application/json"
}

# Run the Module in a retry loop
$success = $false

do {
$retryCount++
try {
    # Get the pipeline id
    Write-Host "Getting the pipeline id"
    $pipelinesUrl = "https://dev.azure.com/$organizationName/$projectName/_apis/pipelines?api-version=7.2-preview.1"
    Write-Host "Pipelines URL: $pipelinesUrl"
    $pipelines = Invoke-RestMethod -Method GET -Uri $pipelinesUrl -Headers $headers -StatusCodeVariable statusCode
    if ($statusCode -ne 200) {
        throw "Failed to find the pipelines."
    }
    $pipeline = $pipelines.value | Where-Object { $_.name -like "*$pipelineNamePart*" }

    $pipelineId = $pipeline.id
    Write-Host "Pipeline ID: $pipelineId"

    $pipelineAction = ""
    if(!($skipDestroy)) {
        $pipelineAction = "apply"
    }

    # Trigger the apply pipeline
    Write-Host "Triggering the $pipelineAction pipeline"
    $pipelineRunId = Invoke-Pipeline -organizationName $organizationName -projectName $projectName -pipelineId $pipelineId -pipelineAction $pipelineAction -iac $iac -headers $headers
    Write-Host "$pipelineAction pipeline triggered successfully"

    # Wait for the apply pipeline to complete
    Write-Host "Waiting for the $pipelineAction pipeline to complete"
    Wait-ForPipelineRunToComplete -organizationName $organizationName -projectName $projectName -pipelineId $pipelineId -pipelineRunId $pipelineRunId -headers $headers
    Write-Host "$pipelineAction pipeline completed successfully"

    if($skipDestroy) {
        $success = $true
        break
    }

    $pipelineAction = "destroy"

    # Trigger the destroy pipeline
    Write-Host "Triggering the $pipelineAction pipeline"
    $pipelineRunId = Invoke-Pipeline -organizationName $organizationName -projectName $projectName -pipelineId $pipelineId -pipelineAction "destroy" -iac $iac -headers $headers
    Write-Host "$pipelineAction pipeline triggered successfully"

    # Wait for the apply pipeline to complete
    Write-Host "Waiting for the $pipelineAction pipeline to complete"
    Wait-ForPipelineRunToComplete -organizationName $organizationName -projectName $projectName -pipelineId $pipelineId -pipelineRunId $pipelineRunId -headers $headers
    Write-Host "$pipelineAction pipeline completed successfully"

    $success = $true
} catch {
    Write-Host $_
    Write-Host "Failed to trigger the pipeline successfully, trying again..."
}
} while ($success -eq $false -and $retryCount -lt $maximumRetries)

if ($success -eq $false) {
    throw "Failed to trigger the pipeline after $maximumRetries attempts."
}
