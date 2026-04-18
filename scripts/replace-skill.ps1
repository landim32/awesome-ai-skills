# =============================================================================
# Replace-Skill.ps1
# Replaces an old skill with a new skill in all repos under the scan root
# that have .claude\skills directories containing the old skill.
#
# Usage:
#   powershell -File replace-skill.ps1 -OldSkillName old-skill -NewSkillName new-skill
#
# Example:
#   powershell -File replace-skill.ps1 -OldSkillName dotnet-arch -NewSkillName dotnet-architecture
# =============================================================================

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$OldSkillName,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$NewSkillName
)

# ----- Configuration ---------------------------------------------------------
$ScanRoot  = "C:\repos"
$SourceDir = Join-Path $PSScriptRoot "skills"
# -----------------------------------------------------------------------------

$newSkillSourcePath = Join-Path $SourceDir $NewSkillName

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Skill Replacer - Awesome AI Skills"          -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Old skill       : $OldSkillName"
Write-Host "New skill       : $NewSkillName"
Write-Host "New skill source: $newSkillSourcePath"
Write-Host "Scan root       : $ScanRoot"
Write-Host ""

# Validate that the new skill exists in this project
if (-not (Test-Path $newSkillSourcePath)) {
    Write-Host "[ERROR] New skill '$NewSkillName' not found in $SourceDir" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available skills:" -ForegroundColor Yellow
    Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor Gray
    }
    exit 1
}

# Statistics
$replacedCount = 0
$skippedCount  = 0
$notFoundCount = 0
$scannedCount  = 0

Write-Host "Scanning for .claude\skills\$OldSkillName in repos..." -ForegroundColor Yellow
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

    $oldSkillPath = Join-Path $skillsPath $OldSkillName

    # Skip repos that don't have the old skill
    if (-not (Test-Path $oldSkillPath)) {
        return
    }

    $scannedCount++
    $repoName = (Split-Path (Split-Path (Split-Path $claudeDir -Parent) -Parent) -Leaf)
    $newSkillPath = Join-Path $skillsPath $NewSkillName

    Write-Host "---------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[FOUND] $oldSkillPath" -ForegroundColor Blue
    Write-Host "  Repo: $repoName" -ForegroundColor Gray

    # Check if the new skill already exists in this repo
    if (Test-Path $newSkillPath) {
        Write-Host "  [WARN] '$NewSkillName' already exists in this repo" -ForegroundColor DarkYellow
    }

    # Show what will happen
    Write-Host "  [PLAN] Remove '$OldSkillName' and copy '$NewSkillName'" -ForegroundColor Yellow

    # Ask user
    Write-Host ""
    $answer = Read-Host "  Replace '$OldSkillName' with '$NewSkillName' in $repoName? (y/N)"

    if ($answer -eq 'y' -or $answer -eq 'Y') {
        # Remove old skill
        Remove-Item -Path $oldSkillPath -Recurse -Force
        Write-Host "  [REMOVED] '$OldSkillName'" -ForegroundColor DarkGray

        # Copy new skill
        Copy-Item -Path $newSkillSourcePath -Destination $newSkillPath -Recurse -Force
        Write-Host "  [COPIED]  '$NewSkillName'" -ForegroundColor Green
        Write-Host "  [DONE]    Replacement complete." -ForegroundColor Green
        $replacedCount++
    }
    else {
        Write-Host "  [SKIPPED] No changes made." -ForegroundColor DarkYellow
        $skippedCount++
    }
}

# Summary
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Summary"                                      -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Repos with old skill : $scannedCount"
Write-Host "  Replaced             : $replacedCount"         -ForegroundColor Green
Write-Host "  Skipped              : $skippedCount"          -ForegroundColor DarkYellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
