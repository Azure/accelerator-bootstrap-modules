# This file can be used to clean up GitHub repositories if there has been an issue with the End to End tests.
# CAUTION: Make sure you are connected to the correct organization before running this script!
$filter = ""

$repos = @("")
while ($repos.Count -gt 0) {
    $repos = gh repo list microsoft-azure-landing-zones-cd-tests --json name,owner | ConvertFrom-Json
    if($filter -ne "")
    {
        $repos = $repos | Where-Object { $_.name -like "*$filter*" }
    }

    $repos | ForEach-Object -Parallel {
        $repoName = "$($_.owner.login)/$($_.name)"

        Write-Host "Deleting repo: $repoName"
        gh repo delete $repoName --yes
    } -ThrottleLimit 10
}
