param(
  [string]$runNumber = "999"
)

$combinations = [ordered]@{
  azuredevops_bicep = [ordered]@{
    infrastructureAsCode = @("bicep")
    versionControlSystem = @("azuredevops")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    staterModule = @("test")
    regions = @("multi")
    terraformVersion = @("latest")
    deployAzureResources = @("true")
  }
  azuredevops_terraform = [ordered]@{
    infrastructureAsCode = @("terraform")
    versionControlSystem = @("azuredevops")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    staterModule = @("test_nested")
    regions = @("multi")
    terraformVersion = @("latest")
    deployAzureResources = @("true")
  }
  github_bicep = [ordered]@{
    infrastructureAsCode = @("bicep")
    versionControlSystem = @("github")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    staterModule = @("test")    
    regions = @("multi")    
    terraformVersion = @("latest")
    deployAzureResources = @("true")
  }
  github_terraform = [ordered]@{
    infrastructureAsCode = @("terraform")
    versionControlSystem = @("github")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    staterModule = @("test_nested")
    regions = @("multi")
    terraformVersion = @("latest")
    deployAzureResources = @("true")
  }
  local_deploy_azure_resources_tests = [ordered]@{
    infrastructureAsCode = @("terraform")
    versionControlSystem = @("local")
    agentType = @("none")
    operatingSystem = @("ubuntu", "windows", "macos")
    staterModule = @("test")    
    regions = @("multi")    
    terraformVersion = @("latest")
    deployAzureResources = @("true")
  }
  local_cross_os_terraform_version_tests = [ordered]@{
    infrastructureAsCode = @("terraform")
    versionControlSystem = @("local")
    agentType = @("none")
    operatingSystem = @("ubuntu", "windows", "macos")
    staterModule = @("test")    
    regions = @("multi")    
    terraformVersion = @("1.5.0")
    deployAzureResources = @("false")
  }
  local_single_region_tests = [ordered]@{
    infrastructureAsCode = @("terraform")
    versionControlSystem = @("local")
    agentType = @("none")
    operatingSystem = @("ubuntu")
    staterModule = @("test")    
    regions = @("single")    
    terraformVersion = @("latest")
    deployAzureResources = @("false")
  }
  local_starter_module_terraform_tests = [ordered]@{
    infrastructureAsCode = @("terraform")
    versionControlSystem = @("local")
    agentType = @("none")
    operatingSystem = @("ubuntu")
    staterModule = @("complete", "complete_multi_region", "sovereign_landing_zone", "basic", "hubnetworking")
    regions = @("single")
    terraformVersion = @("latest")
    deployAzureResources = @("false")
  }
  local_starter_module_bicep_tests = [ordered]@{
    infrastructureAsCode = @("terraform")
    versionControlSystem = @("local")
    agentType = @("none")
    operatingSystem = @("ubuntu")
    staterModule = @("complete")    
    regions = @("single")    
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
