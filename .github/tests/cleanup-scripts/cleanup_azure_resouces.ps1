# This file can be used to clean up Resource Groups if there has been an issue with the End to End tests.
# CAUTION: Make sure you are connected to the correct subscription before running this script!

# Check for and install the resource-graph extension if not already installed
$installedExtensions = az extension list --query "[].name" -o tsv
if ($installedExtensions -notcontains "resource-graph") {
    Write-Host "Installing Azure CLI resource-graph extension..."
    az extension add --name resource-graph
} else {
    Write-Host "Azure CLI resource-graph extension is already installed."
}

$managementGroupFilter = "alz-r"
if($managementGroupFilter -eq "")
{
    throw "Please set a management group filter to avoid disaster!"
}
$subscriptionFilter = ""

$managementGroups = @(
    "dac8feee-8768-4fbd-9cf9-9d96d4718018",
    "alz-accelerator-parent-test"
)

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

$roleDefinitionsFilter = "Azure Landing Zones"

$subscriptions | ForEach-Object -Parallel {
    $subscription = $_
    $subscriptionDetails = az account show --subscription $subscription | ConvertFrom-Json
    Write-Host "Processing subscription: $subscription - $($subscriptionDetails.name)"

    $resourceGroups = @("")
    while ($resourceGroups.Count -gt 0) {
        if($subscriptionFilter -eq "")
        {
            $resourceGroups = az group list --subscription $subscription | ConvertFrom-Json
        }
        else
        {
            $resourceGroups = az group list --subscription $subscription --query "[?contains(name, '$subscriptionFilter')]" | ConvertFrom-Json
        }

        $resourceGroups | ForEach-Object -Parallel {
            $subscription = $using:subscription
            $subscriptionDetails = $using:subscriptionDetails
            Write-Host "Deleting resource group: $($_.name) in subscription: $subscription - $($subscriptionDetails.name)"
            az group delete --subscription $subscription --name $_.name --yes
        } -ThrottleLimit 10
    }
} -ThrottleLimit 10

$managementGroups | ForEach-Object -Parallel {
    $managementGroupFilter = $using:managementGroupFilter
    $managementGroup = $_
    Write-Host "Processing management group: $managementGroup"

    $managementGroupDetails = az account management-group show --name $managementGroup --expand | ConvertFrom-Json
    $childManagementGroups = $managementGroupDetails.children | Where-Object { $_.type -eq "Microsoft.Management/managementGroups" }
    if($managementGroupFilter -ne "") {
        $childManagementGroups = $childManagementGroups | Where-Object { $_.name -like "*$managementGroupFilter*" }
    }

    $childManagementGroups | ForEach-Object -Parallel {
        $managementGroup = $using:managementGroup
        $childManagementGroup = $_
        Write-Host "Deleting management group: $($childManagementGroup.name) under parent: $managementGroup"
        az account management-group delete --name $childManagementGroup.name
    } -ThrottleLimit 10

    $roleDefinitionsFilter = $using:roleDefinitionsFilter

    $roleDefinitions = az role definition list --custom-role-only true --scope "/providers/Microsoft.Management/managementGroups/$managementGroup" --query "[].{name:name,roleName:roleName,id:id,assignableScopes:assignableScopes}" -o json  | ConvertFrom-Json | Where-Object { $_.roleName -like "*$roleDefinitionsFilter*" -and $_.assignableScopes -contains "/providers/Microsoft.Management/managementGroups/$managementGroup" }
    $roleDefinitions | ForEach-Object -Parallel {
        $managementGroup = $using:managementGroup
        $roleDefinition = $_

        Write-Host "$($roleDefinition.roleName) - $($managementGroup): Querying role assignments using Resource Graph for role definition $($roleDefinition.name)"
        $query = "authorizationresources | where type == 'microsoft.authorization/roleassignments' | where properties.roleDefinitionId == '/providers/Microsoft.Authorization/RoleDefinitions/$($roleDefinition.name)' | order by ['name'] asc"
        $roleAssignments = az graph query -q $query --query "data[].{id:id,principalId:properties.principalId}" -o json | ConvertFrom-Json
        $roleAssignments | ForEach-Object -Parallel {
            $managementGroup = $using:managementGroup
            $roleDefinition = $using:roleDefinition
            $roleAssignment = $_
            Write-Host "Deleting role assignment: $($roleAssignment.id) for role definition: $($roleDefinition.roleName) in management group: $managementGroup"
            az role assignment delete --ids $roleAssignment.id
        } -ThrottleLimit 10

        Write-Host "Deleting custom role definition: $($roleDefinition.roleName) in management group: $managementGroup"
        $result = az role definition delete --name $roleDefinition.name --scope "/providers/Microsoft.Management/managementGroups/$managementGroup" 2>&1
        if($result -like "*ERROR*")
        {
            Write-Warning "Role definition $($roleDefinition.roleName) in management group: $managementGroup could not be deleted...$([Environment]::NewLine)$result"
        } else {
            Write-Host "Role definition $($roleDefinition.roleName) in management group: $managementGroup deleted successfully."
        }

    } -ThrottleLimit 10
} -ThrottleLimit 10

Write-Host "Cleanup complete. :)"
