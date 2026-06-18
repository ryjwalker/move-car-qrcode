# GitHub Pages deploy script for move-car QR page
# Usage:
#   Option A (recommended): gh auth login, then run .\deploy.ps1
#   Option B: set GH_TOKEN to a GitHub Personal Access Token, then run .\deploy.ps1

$ErrorActionPreference = "Stop"
$RepoName = "move-car-qrcode"
$GhExe = Join-Path $env:TEMP "gh-cli\bin\gh.exe"

if (-not (Test-Path $GhExe)) {
    Write-Host "Downloading GitHub CLI..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $zip = Join-Path $env:TEMP "gh.zip"
    Invoke-WebRequest -Uri "https://github.com/cli/cli/releases/download/v2.63.2/gh_2.63.2_windows_amd64.zip" -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath (Join-Path $env:TEMP "gh-cli") -Force
}

Set-Location $PSScriptRoot

& $GhExe auth status 2>$null
if ($LASTEXITCODE -ne 0 -and -not $env:GH_TOKEN) {
    Write-Host ""
    Write-Host "Not logged in. Run one of:"
    Write-Host "  1. gh auth login --web"
    Write-Host "  2. `$env:GH_TOKEN = 'your_github_token'; .\deploy.ps1"
    Write-Host ""
    & $GhExe auth login --hostname github.com --git-protocol https --web --skip-ssh-key
}

$owner = (& $GhExe api user -q .login).Trim()
Write-Host "GitHub user: $owner"

$repoExists = $false
try {
    & $GhExe repo view "$owner/$RepoName" 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { $repoExists = $true }
} catch {}

if (-not $repoExists) {
    Write-Host "Creating repository $owner/$RepoName ..."
    & $GhExe repo create $RepoName --public --source=. --remote=origin --description "Move-car QR contact page"
} else {
    Write-Host "Repository exists, setting remote..."
    git remote remove origin 2>$null
    git remote add origin "https://github.com/$owner/$RepoName.git"
}

Write-Host "Pushing to GitHub..."
git push -u origin master

Write-Host "Enabling GitHub Pages..."
& $GhExe api -X POST "repos/$owner/$RepoName/pages" -f "build_type=legacy" -f "source[branch]=master" -f "source[path]=/" 2>$null

Start-Sleep -Seconds 3
$pages = & $GhExe api "repos/$owner/$RepoName/pages" 2>$null | ConvertFrom-Json
$url = if ($pages.html_url) { $pages.html_url } else { "https://$owner.github.io/$RepoName/" }

Write-Host ""
Write-Host "Deploy complete!"
Write-Host "Page URL: $url"
Write-Host "QR code on the page will point to this URL after you open it once."
