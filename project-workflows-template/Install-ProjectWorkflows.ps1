[CmdletBinding()]
param(
    [string]$ConfigurationFile = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$templateRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$templateWorkflows = Join-Path $templateRoot ".github\workflows"

if ([string]::IsNullOrWhiteSpace($ConfigurationFile)) {
    $ConfigurationFile = Join-Path $templateRoot "PROJECT-DETAILS.txt"
}

if (-not (Test-Path -LiteralPath $ConfigurationFile -PathType Leaf)) {
    throw "The project details file was not found: $ConfigurationFile"
}

if (-not (Test-Path -LiteralPath $templateWorkflows -PathType Container)) {
    throw "The template workflow folder was not found: $templateWorkflows"
}

function Get-NormalisedLabel {
    param([string]$Label)
    return (($Label.Trim().ToLowerInvariant()) -replace '\s+', ' ')
}

function Get-RequiredSetting {
    param(
        [hashtable]$Settings,
        [string]$Label
    )

    $key = Get-NormalisedLabel $Label
    if (-not $Settings.ContainsKey($key)) {
        throw "Missing setting in PROJECT-DETAILS.txt: $Label"
    }

    $value = [string]$Settings[$key]
    if ([string]::IsNullOrWhiteSpace($value) -or $value.Trim().StartsWith('<')) {
        throw "Replace the placeholder for '$Label' in PROJECT-DETAILS.txt."
    }

    return $value.Trim()
}

function Get-OptionalSetting {
    param(
        [hashtable]$Settings,
        [string]$Label,
        [string]$DefaultValue = ""
    )

    $key = Get-NormalisedLabel $Label
    if (-not $Settings.ContainsKey($key)) {
        return $DefaultValue
    }

    $value = [string]$Settings[$key]
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $DefaultValue
    }

    if ($value.Trim().StartsWith('<')) {
        throw "Replace or remove the placeholder for '$Label' in PROJECT-DETAILS.txt."
    }

    return $value.Trim()
}

function Assert-Pattern {
    param(
        [string]$Label,
        [string]$Value,
        [string]$Pattern,
        [string]$Example
    )

    if ($Value -notmatch $Pattern) {
        throw "Invalid value for '$Label': '$Value'. Example: $Example"
    }
}

function Escape-YamlDoubleQuotedValue {
    param([string]$Value)
    return $Value.Replace('\', '\\').Replace('"', '\"')
}

$settings = @{}
$lineNumber = 0
foreach ($line in Get-Content -LiteralPath $ConfigurationFile) {
    $lineNumber++
    $trimmed = $line.Trim()

    if ([string]::IsNullOrWhiteSpace($trimmed) -or
        $trimmed.StartsWith('#') -or
        $trimmed -match '^[=-]+$') {
        continue
    }

    if ($line -match '^\s*([^:]+?)\s*:\s*(.*)\s*$') {
        $label = Get-NormalisedLabel $Matches[1]
        $settings[$label] = $Matches[2].Trim()
    }
}

$destinationRepositoryPath = Get-RequiredSetting $settings 'Destination repository'
$projectKey = Get-RequiredSetting $settings 'Project key'
$solutionName = Get-RequiredSetting $settings 'Solution'
$defaultDeveloperAlias = Get-RequiredSetting $settings 'Default developer alias'
$defaultDeveloperUpn = Get-RequiredSetting $settings 'Default developer UPN'

$defaultSolutionFolder = Get-OptionalSetting $settings 'Default solution folder'
$baseBranch = Get-OptionalSetting $settings 'Base branch' 'main'
$targetRegion = Get-OptionalSetting $settings 'Target region' 'europe'
$targetCurrency = Get-OptionalSetting $settings 'Target currency' 'GBP'
$targetLanguage = Get-OptionalSetting $settings 'Target language' 'English'
$checkerGeo = Get-OptionalSetting $settings 'Solution Checker geography' 'UnitedKingdom'
$developerEnvironmentSuffix = Get-OptionalSetting $settings 'Developer environment suffix' 'DEV'
$checkerRuleSet = Get-OptionalSetting $settings 'Solution Checker rule set' 'Solution Checker'
$defaultBuildEnvironment = Get-OptionalSetting $settings 'Default build environment'
$targetTemplates = Get-OptionalSetting $settings 'Target environment templates'
$targetSecurityGroupId = Get-OptionalSetting $settings 'Target security group ID'
$validationTemplates = Get-OptionalSetting $settings 'Validation environment templates'
$validationSecurityGroupId = Get-OptionalSetting $settings 'Validation security group ID'
$automationRole = Get-OptionalSetting $settings 'Automation role' 'System Administrator'
$developerRole = Get-OptionalSetting $settings 'Developer role' 'System Administrator'
$reusableWorkflowRepository = Get-OptionalSetting $settings 'Reusable workflow repository' 'KayodeAjayi-Veldarr/power-platform-workflows'
$reusableWorkflowRef = Get-OptionalSetting $settings 'Reusable workflow ref' 'main'

Assert-Pattern 'Project key' $projectKey '^[A-Za-z0-9][A-Za-z0-9_-]*$' 'INVENTORY'
Assert-Pattern 'Solution' $solutionName '^[A-Za-z0-9_]+$' 'InventoryManagement'
Assert-Pattern 'Base branch' $baseBranch '^[A-Za-z0-9._/-]+$' 'main'
Assert-Pattern 'Reusable workflow repository' $reusableWorkflowRepository '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$' 'organisation/power-platform-workflows'
Assert-Pattern 'Reusable workflow ref' $reusableWorkflowRef '^[A-Za-z0-9._/-]+$' 'main'
Assert-Pattern 'Default developer UPN' $defaultDeveloperUpn '^[^\s@]+@[^\s@]+\.[^\s@]+$' 'developer@company.com'

if (-not (Test-Path -LiteralPath $destinationRepositoryPath -PathType Container)) {
    throw "The destination repository folder does not exist: $destinationRepositoryPath"
}

$destination = (Resolve-Path -LiteralPath $destinationRepositoryPath).Path
$destinationWorkflows = Join-Path $destination ".github\workflows"
New-Item -ItemType Directory -Path $destinationWorkflows -Force | Out-Null

if ([string]::IsNullOrWhiteSpace($defaultSolutionFolder)) {
    $defaultSolutionFolder = "power-platform/$solutionName"
}

$defaultSolutionFolder = $defaultSolutionFolder.Replace('\', '/')

if (
    $defaultSolutionFolder.StartsWith('/') -or
    $defaultSolutionFolder -match '^[A-Za-z]:'
) {
    throw "Default solution folder must be relative to the repository root."
}

$defaultSolutionFolder = $defaultSolutionFolder.Trim('/')
$solutionFolderSegments = @(
    $defaultSolutionFolder.Split('/') |
        Where-Object { $_ -ne '' }
)

if (
    [string]::IsNullOrWhiteSpace($defaultSolutionFolder) -or
    $solutionFolderSegments -contains '..'
) {
    throw "Default solution folder is empty or contains an unsafe path segment."
}

$quotedValues = @(
    $projectKey,
    $solutionName,
    $defaultSolutionFolder,
    $defaultDeveloperAlias,
    $defaultDeveloperUpn,
    $targetRegion,
    $targetCurrency,
    $targetLanguage,
    $checkerGeo,
    $developerEnvironmentSuffix,
    $checkerRuleSet,
    $defaultBuildEnvironment,
    $targetTemplates,
    $targetSecurityGroupId,
    $validationTemplates,
    $validationSecurityGroupId,
    $automationRole,
    $developerRole
)

foreach ($value in $quotedValues) {
    if ($value.Contains("`r") -or $value.Contains("`n")) {
        throw "Project detail values cannot contain line breaks."
    }
}

$replacements = [ordered]@{
    "__PROJECT_KEY__" = Escape-YamlDoubleQuotedValue $projectKey
    "__SOLUTION_NAME__" = Escape-YamlDoubleQuotedValue $solutionName
    "__DEFAULT_SOLUTION_FOLDER__" = Escape-YamlDoubleQuotedValue $defaultSolutionFolder
    "__DEFAULT_DEVELOPER_ALIAS__" = Escape-YamlDoubleQuotedValue $defaultDeveloperAlias
    "__DEFAULT_DEVELOPER_UPN__" = Escape-YamlDoubleQuotedValue $defaultDeveloperUpn
    "__BASE_BRANCH__" = $baseBranch
    "__TARGET_REGION__" = Escape-YamlDoubleQuotedValue $targetRegion
    "__TARGET_CURRENCY__" = Escape-YamlDoubleQuotedValue $targetCurrency
    "__TARGET_LANGUAGE__" = Escape-YamlDoubleQuotedValue $targetLanguage
    "__CHECKER_GEO__" = Escape-YamlDoubleQuotedValue $checkerGeo
    "__DEVELOPER_ENVIRONMENT_SUFFIX__" = Escape-YamlDoubleQuotedValue $developerEnvironmentSuffix
    "__CHECKER_RULE_SET__" = Escape-YamlDoubleQuotedValue $checkerRuleSet
    "__DEFAULT_BUILD_ENVIRONMENT__" = Escape-YamlDoubleQuotedValue $defaultBuildEnvironment
    "__TARGET_TEMPLATES__" = Escape-YamlDoubleQuotedValue $targetTemplates
    "__TARGET_SECURITY_GROUP_ID__" = Escape-YamlDoubleQuotedValue $targetSecurityGroupId
    "__VALIDATION_TEMPLATES__" = Escape-YamlDoubleQuotedValue $validationTemplates
    "__VALIDATION_SECURITY_GROUP_ID__" = Escape-YamlDoubleQuotedValue $validationSecurityGroupId
    "__AUTOMATION_ROLE__" = Escape-YamlDoubleQuotedValue $automationRole
    "__DEVELOPER_ROLE__" = Escape-YamlDoubleQuotedValue $developerRole
    "__REUSABLE_WORKFLOW_REPOSITORY__" = $reusableWorkflowRepository
    "__REUSABLE_WORKFLOW_REF__" = $reusableWorkflowRef
}

$workflowFiles = Get-ChildItem -LiteralPath $templateWorkflows -Filter "*.yml" -File

foreach ($sourceFile in $workflowFiles) {
    $destinationFile = Join-Path $destinationWorkflows $sourceFile.Name

    if ((Test-Path -LiteralPath $destinationFile) -and -not $Force) {
        throw @"
The workflow already exists:
$destinationFile

Run again with -Force only when you intend to replace the existing caller workflow files.
"@
    }

    $content = Get-Content -LiteralPath $sourceFile.FullName -Raw
    foreach ($entry in $replacements.GetEnumerator()) {
        $content = $content.Replace($entry.Key, $entry.Value)
    }

    $remainingTokens = [regex]::Matches($content, '__[A-Z0-9_]+__') |
        ForEach-Object { $_.Value } |
        Sort-Object -Unique

    if ($remainingTokens.Count -gt 0) {
        throw "Unresolved template tokens in $($sourceFile.Name): $($remainingTokens -join ', ')"
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($destinationFile, $content, $utf8NoBom)
}

Write-Host ""
Write-Host "Installed the four caller workflows in:"
Write-Host $destinationWorkflows
Write-Host ""
Write-Host "Project: $projectKey"
Write-Host "Solution: $solutionName"
Write-Host "Default solution folder: $defaultSolutionFolder"
Write-Host "Each manual workflow run can use a different solution folder."
Write-Host "Default build environment: $defaultBuildEnvironment"
Write-Host ""
Write-Host "No project-level GitHub Actions variables are required."
Write-Host ""
Write-Host "Next:"
Write-Host "1. Confirm the project repository can access the organisation secrets PP_TENANT_ID, PP_APP_ID and PP_CLIENT_SECRET."
Write-Host "2. Apply the central repository settings checklist from the power-platform-workflows repository."
Write-Host "3. Confirm a clean build environment is available for managed deployments."
Write-Host "4. Review the generated workflow defaults."
Write-Host "5. Commit .github/workflows to $baseBranch."
