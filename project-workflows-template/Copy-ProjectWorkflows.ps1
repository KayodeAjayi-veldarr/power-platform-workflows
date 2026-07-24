[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DestinationRepositoryPath
)

$ErrorActionPreference = "Stop"

$templateRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$templateGitHub = Join-Path $templateRoot ".github"

if (-not (Test-Path -LiteralPath $templateGitHub -PathType Container)) {
    throw "The template .github folder was not found: $templateGitHub"
}

$destination = (Resolve-Path -LiteralPath $DestinationRepositoryPath).Path
$destinationGitHub = Join-Path $destination ".github"

if (Test-Path -LiteralPath $destinationGitHub) {
    throw @"
The destination already contains a .github folder:

$destinationGitHub

Move, rename or remove it before copying the template.
"@
}

Copy-Item `
    -LiteralPath $templateGitHub `
    -Destination $destinationGitHub `
    -Recurse `
    -Force

Write-Host ""
Write-Host "Project workflows copied to:"
Write-Host $destinationGitHub
Write-Host ""
Write-Host "Next:"
Write-Host "1. Configure the repository variables."
Write-Host "2. Add the Power Platform secrets."
Write-Host "3. Commit .github to main."
