param(
  [string]$runNumber = "999"
)

$combinations = [ordered]@{
  azuredevops_bicep = [ordered]@{
    versionControlSystem = @("azuredevops")
    infrastructureAsCode = @("bicep")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    starterModule = @("test")
    regions = @("multi")
    terraformVersion = @("latest")
    deployAzureResources = @("true")
  }
  github_bicep = [ordered]@{
    versionControlSystem = @("github")
    infrastructureAsCode = @("bicep")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    starterModule = @("test")
    regions = @("multi")
    terraformVersion = @("latest")
    deployAzureResources = @("true")
  }
  azuredevops_terraform = [ordered]@{
    versionControlSystem = @("azuredevops")
    infrastructureAsCode = @("terraform")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    starterModule = @("test_nested")
    regions = @("multi")
    terraformVersion = @("latest")
    deployAzureResources = @("true")
  }
  github_terraform = [ordered]@{
    versionControlSystem = @("github")
    infrastructureAsCode = @("terraform")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    starterModule = @("test_nested")
    regions = @("multi")
    terraformVersion = @("latest")
    deployAzureResources = @("true")
  }
  local_deploy_azure_resources_tests = [ordered]@{
    versionControlSystem = @("local")
    infrastructureAsCode = @("terraform")
    agentType = @("none")
    operatingSystem = @("ubuntu", "windows", "macos")
    starterModule = @("test")
    regions = @("multi")
    terraformVersion = @("latest")
    deployAzureResources = @("true")
  }
  local_cross_os_terraform_version_tests = [ordered]@{
    versionControlSystem = @("local")
    infrastructureAsCode = @("terraform")
    agentType = @("none")
    operatingSystem = @("ubuntu", "windows", "macos")
    starterModule = @("test")
    regions = @("multi")
    terraformVersion = @("1.5.0")
    deployAzureResources = @("false")
  }
  local_single_region_tests = [ordered]@{
    versionControlSystem = @("local")
    infrastructureAsCode = @("terraform")
    agentType = @("none")
    operatingSystem = @("ubuntu")
    starterModule = @("test")
    regions = @("single")
    terraformVersion = @("latest")
    deployAzureResources = @("false")
  }
  local_starter_module_terraform_tests = [ordered]@{
    versionControlSystem = @("local")
    infrastructureAsCode = @("terraform")
    agentType = @("none")
    operatingSystem = @("ubuntu")
    starterModule = @("platform_landing_zone", "sovereign_landing_zone", "financial_services_landing_zone")
    regions = @("multi")
    terraformVersion = @("latest")
    deployAzureResources = @("false")
  }
  local_starter_module_bicep_tests = [ordered]@{
    versionControlSystem = @("local")
    infrastructureAsCode = @("bicep")
    agentType = @("none")
    operatingSystem = @("ubuntu")
    starterModule = @("complete")
    regions = @("multi")
    terraformVersion = @("latest")
    deployAzureResources = @("false")
  }
}

function Get-Hash([string]$textToHash) {
  $hasher = new-object System.Security.Cryptography.MD5CryptoServiceProvider
  $toHash = [System.Text.Encoding]::UTF8.GetBytes($textToHash)
  $hashByteArray = $hasher.ComputeHash($toHash)
  foreach($byte in $hashByteArray)
  {
    $result += "{0:X2}" -f $byte
  }
  return $result;
}

function Get-MatrixRecursively {
  param(
    $calculatedCombinations = @(),
    $indexes = [ordered]@{},
    $definition,
    $runNumber
  )

  if($indexes.Count -eq 0) {
    foreach($key in $definition.Keys) {
      $indexes.Add($key, @{
        current = 0
        max = $definition[$key].Length - 1
      })
    }
  }

  $combination = [ordered]@{}

  $name = ""

  foreach($key in $indexes.Keys) {
    $combinationValue = $definition[$key][$indexes[$key].current]
    $combination[$key] = $combinationValue
    $name = "$name-$combinationValue"
  }

  $combination.Name = $name.Trim("-")
  $combination.Hash = Get-Hash $name
  $combination.ShortName = "r" + $combination.Hash.Substring(0,5).ToLower() + "r" + $runNumber

  $calculatedCombinations += $combination

  $hasMore = $false
  foreach($key in $indexes.Keys) {
    if($indexes[$key].current -lt $indexes[$key].max) {
      $indexes[$key].current++
      $hasMore = $true
      break
    }
  }

  if($hasMore) {
    $calculatedCombinations = Get-MatrixRecursively -calculatedCombinations $calculatedCombinations -indexes $indexes -definition $definition -runNumber $runNumber
  }

  return $calculatedCombinations
}

$finalMatrix = @()

foreach($key in $combinations.Keys) {
  $finalMatrix += Get-MatrixRecursively -definition $combinations[$key] -runNumber $runNumber
}

return $finalMatrix
