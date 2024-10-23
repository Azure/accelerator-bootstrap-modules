$combinations = @{
  azuredevops_bicep = @{
    versionControlSystem = @("azuredevops")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    terraformVersion = @("latest")
    infrastructureAsCode = @("bicep")
    regions = @("multi")
    staterModule = @("test")
  }
  azuredevops_terraform = @{
    versionControlSystem = @("azuredevops")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    terraformVersion = @("latest")
    infrastructureAsCode = @("terraform")
    regions = @("multi")
    staterModule = @("test_nested")
  }
  github_bicep = @{
    versionControlSystem = @("github")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    terraformVersion = @("latest")
    infrastructureAsCode = @("bicep")
    regions = @("multi")
    staterModule = @("test")
  }
  github_terraform = @{
    versionControlSystem = @("github")
    agentType = @("public", "private", "none")
    operatingSystem = @("ubuntu")
    terraformVersion = @("latest")
    infrastructureAsCode = @("terraform")
    regions = @("multi")
    staterModule = @("test_nested")
  }
  local_cross_os_tests = @{
    versionControlSystem = @("local")
    agentType = @("none")
    operatingSystem = @("ubuntu", "windows", "macos")
    terraformVersion = @("latest", "1.5.0")
    infrastructureAsCode = @("terraform")
    regions = @("multi")
    staterModule = @("test")
  }
  local_single_region_tests = @{
    versionControlSystem = @("local")
    agentType = @("none")
    operatingSystem = @("ubuntu")
    terraformVersion = @("latest")
    infrastructureAsCode = @("terraform")
    regions = @("single")
    staterModule = @("test")
  }
  local_starter_module_terraform_tests = @{
    versionControlSystem = @("local")
    agentType = @("none")
    operatingSystem = @("ubuntu")
    terraformVersion = @("latest")
    infrastructureAsCode = @("terraform")
    regions = @("single")
    staterModule = @("complete", "complete_multi_region", "sovereign_landing_zone", "basic", "hubnetworking")
  }
  local_starter_module_bicep_tests = @{
    versionControlSystem = @("local")
    agentType = @("none")
    operatingSystem = @("ubuntu")
    terraformVersion = @("latest")
    infrastructureAsCode = @("terraform")
    regions = @("single")
    staterModule = @("complete")
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
    [hashtable]$indexes = @{},
    [hashtable]$definition
  )

  if($indexes.Count -eq 0) {
    foreach($key in $definition.Keys) {
      $indexes[$key] = @{
        current = 0
        max = $definition[$key].Length - 1
      }
    }
  }

  $combination = @{}
  
  $name = ""
  
  foreach($key in $indexes.Keys) {
    $combinationValue = $definition[$key][$indexes[$key].current]
    $combination[$key] = $combinationValue
    $name = "$name-$combinationValue"
  }

  $combination.Name = $name.Trim("-")
  $combination.Hash = Get-Hash $name
  $combination.ShortName = $combination.Hash.Substring(0,5)

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
    $calculatedCombinations = Get-MatrixRecursively -calculatedCombinations $calculatedCombinations -indexes $indexes -definition $definition
  }

  return $calculatedCombinations
}

$finalMatrix = @()

foreach($key in $combinations.Keys) {
  $finalMatrix += Get-MatrixRecursively -definition $combinations[$key]
}

return $finalMatrix