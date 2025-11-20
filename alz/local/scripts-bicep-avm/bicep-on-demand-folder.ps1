param(
    [string]$repository,
    [string]$releaseArtifactName,
    [string]$releaseVersion,
    [string]$sourcePath,
    [string]$targetPath
)

Write-Host "Repository: $repository"
Write-Host "Release Artifact Name: $releaseArtifactName"
Write-Host "Release Version: $releaseVersion"
Write-Host "Source Path: $sourcePath"
Write-Host "Target Path: $targetPath"

$targetFolderPath = "./$targetPath"

if(Test-Path $targetFolderPath) {
    Write-Host "Deleting the existing target path $targetFolderPath..."
    Remove-Item -Path $targetFolderPath -Force -Recurse
}

$repoOrgPlusRepo = $repository.Split("/")[-2..-1] -join "/"

$repoReleaseUrl = "https://api.github.com/repos/$repoOrgPlusRepo/releases/tags/$releaseVersion"
if($releaseVersion -eq "latest") {
    $repoReleaseUrl = "https://api.github.com/repos/$repoOrgPlusRepo/releases/latest"
}
$releaseData = Invoke-RestMethod $repoReleaseUrl -SkipHttpErrorCheck -StatusCodeVariable "statusCode"
Write-Verbose "Status code: $statusCode"

if($statusCode -eq 404) {
    Write-Error "The release $releaseVersion does not exist in the GitHub repository $repository - $repoReleaseUrl"
    throw "The release $releaseVersion does not exist in the GitHub repository $repository - $repoReleaseUrl"
}

# Handle transient errors like throttling
if($statusCode -ge 400 -and $statusCode -le 599) {
    Write-Host "Retrying as got the Status Code $statusCode, which may be a tranisent error." -ForegroundColor Yellow
    $releaseData = Invoke-RestMethod $repoReleaseUrl -RetryIntervalSec 3 -MaximumRetryCount 100
}

if($statusCode -ne 200) {
    throw "Unable to query repository version, please check your internet connection and try again..."
}

$releaseArtifactUrl = $releaseData.assets | Where-Object { $_.name -eq $releaseArtifactName } | Select-Object -ExpandProperty browser_download_url

$tempFolder = "./download"

New-Item -ItemType Directory -Path $tempFolder | Out-String | Write-Verbose
$targetPathForZip = "$tempFolder/$releaseArtifactName"
Invoke-WebRequest -Uri $releaseArtifactUrl -OutFile $targetPathForZip -RetryIntervalSec 3 -MaximumRetryCount 100 | Out-String | Write-Verbose

$targetPathForExtractedZip = "$tempFolder/extracted"

Expand-Archive -Path $targetPathForZip -DestinationPath $targetPathForExtractedZip | Out-String | Write-Verbose

$sourceFolderPath = "$($targetPathForExtractedZip)/$sourcePath/*"

Write-Host "Copying extracted files from $sourceFolderPath to $targetFolderPath"
New-Item -ItemType Directory -Path $targetFolderPath | Out-String | Write-Verbose
Copy-Item -Path $sourceFolderPath -Destination $targetFolderPath -Recurse -Force | Out-String | Write-Verbose

Remove-Item -Path $tempFolder -Force -Recurse
Write-Host "Successfully copied the files from the release artifact to the target path $targetPath..."
