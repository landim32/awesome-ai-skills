# =============================================================================
# Copy-Dependency.ps1
# Finds all repos that have a given skill and copies a dependency skill to them
# if it doesn't already exist.
#
# Usage:
#   powershell -File copy-dependency.ps1 -SkillName readme-generator -DependencyName mermaid-chart
#
# This will find all repos that have "readme-generator" in .claude\skills and
# copy "mermaid-chart" into their .claude\skills if it's not already there.
# =============================================================================

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$SkillName,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$DependencyName
)

# ----- Configuration ---------------------------------------------------------
$ScanRoot  = "C:\repos"
$SourceDir = Join-Path $PSScriptRoot "skills"
# -----------------------------------------------------------------------------

$skillSourcePath      = Join-Path $SourceDir $SkillName
$dependencySourcePath = Join-Path $SourceDir $DependencyName

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Dependency Copier - Awesome AI Skills"      -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Skill           : $SkillName"
Write-Host "Dependency      : $DependencyName"
Write-Host "Dependency src  : $dependencySourcePath"
Write-Host "Scan root       : $ScanRoot"
Write-Host ""

# Validate that the skill exists in this project
if (-not (Test-Path $skillSourcePath)) {
    Write-Host "[ERROR] Skill '$SkillName' not found in $SourceDir" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available skills:" -ForegroundColor Yellow
    Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor Gray
    }
    exit 1
}

# Validate that the dependency skill exists in this project
if (-not (Test-Path $dependencySourcePath)) {
    Write-Host "[ERROR] Dependency skill '$DependencyName' not found in $SourceDir" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available skills:" -ForegroundColor Yellow
    Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor Gray
    }
    exit 1
}

# Prevent copying a skill as its own dependency
if ($SkillName -eq $DependencyName) {
    Write-Host "[ERROR] Skill and dependency cannot be the same." -ForegroundColor Red
    exit 1
}

# Statistics
$copiedCount    = 0
$existingCount  = 0
$scannedCount   = 0

Write-Host "Scanning for repos with '$SkillName' that are missing '$DependencyName'..." -ForegroundColor Yellow
Write-Host ""

# Find all .claude directories recursively
Get-ChildItem -Path $ScanRoot -Recurse -Directory -Filter ".claude" -ErrorAction SilentlyContinue | ForEach-Object {
    $claudeDir  = $_.FullName
    $skillsPath = Join-Path $claudeDir "skills"

    # Skip if no skills subfolder
    if (-not (Test-Path $skillsPath)) {
        return
    }

    # Skip our own project
    if ($skillsPath -like "$PSScriptRoot*") {
        return
    }

    $targetSkillPath      = Join-Path $skillsPath $SkillName
    $targetDependencyPath = Join-Path $skillsPath $DependencyName

    # Skip repos that don't have the target skill
    if (-not (Test-Path $targetSkillPath)) {
        return
    }

    $scannedCount++
    $repoName = (Split-Path (Split-Path (Split-Path $claudeDir -Parent) -Parent) -Leaf)

    Write-Host "---------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[FOUND] $repoName" -ForegroundColor Blue
    Write-Host "  Has skill : $SkillName" -ForegroundColor Gray

    # Check if dependency already exists
    if (Test-Path $targetDependencyPath) {
        Write-Host "  [EXISTS] '$DependencyName' already present -- skipping." -ForegroundColor Green
        $existingCount++
        return
    }

    Write-Host "  [MISSING] '$DependencyName' not found -- copying..." -ForegroundColor Yellow
    Copy-Item -Path $dependencySourcePath -Destination $targetDependencyPath -Recurse -Force
    Write-Host "  [COPIED] '$DependencyName' -> $targetDependencyPath" -ForegroundColor Green
    $copiedCount++
}

# Summary
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Summary"                                      -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Repos with '$SkillName' : $scannedCount"
Write-Host "  Already had dependency  : $existingCount"     -ForegroundColor Green
Write-Host "  Copied dependency       : $copiedCount"       -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
