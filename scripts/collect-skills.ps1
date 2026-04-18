# =============================================================================
# Collect-Skills.ps1
# Scans all directories and subdirectories under a configurable root path,
# finds .claude\skills folders, and copies any skill directories that don't
# already exist into this project's skills folder.
# =============================================================================

# ----- Configuration ---------------------------------------------------------
$ScanRoot       = "C:\repos"
$DestinationDir = Join-Path $PSScriptRoot "skills"
# -----------------------------------------------------------------------------

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Skill Collector - Awesome AI Skills"         -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Scan root       : $ScanRoot"
Write-Host "Destination     : $DestinationDir"
Write-Host ""

# Ensure destination directory exists
if (-not (Test-Path $DestinationDir)) {
    Write-Host "[CREATE] Destination directory does not exist. Creating..." -ForegroundColor Yellow
    New-Item -Path $DestinationDir -ItemType Directory -Force | Out-Null
}

# Collect existing skill names in destination
$existingSkills = @()
if (Test-Path $DestinationDir) {
    $existingSkills = Get-ChildItem -Path $DestinationDir -Directory | Select-Object -ExpandProperty Name
}

Write-Host "Existing skills : $($existingSkills.Count)" -ForegroundColor Gray
if ($existingSkills.Count -gt 0) {
    $existingSkills | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
}
Write-Host ""

# Statistics
$copiedCount  = 0
$skippedCount = 0
$scannedCount = 0

Write-Host "Scanning for .claude\skills directories..." -ForegroundColor Yellow
Write-Host ""

# Find all .claude directories recursively
Get-ChildItem -Path $ScanRoot -Recurse -Directory -Filter ".claude" -ErrorAction SilentlyContinue | ForEach-Object {
    $claudeDir  = $_.FullName
    $skillsPath = Join-Path $claudeDir "skills"

    # Skip if this .claude directory has no skills subfolder
    if (-not (Test-Path $skillsPath)) {
        return
    }

    # Skip our own project's .claude\skills directory
    if ($skillsPath -like "$PSScriptRoot*") {
        return
    }

    $scannedCount++
    Write-Host "[FOUND] Skills source: $skillsPath" -ForegroundColor Blue

    # Iterate over each skill directory inside .claude\skills
    Get-ChildItem -Path $skillsPath -Directory | ForEach-Object {
        $skillName   = $_.Name
        $sourcePath  = $_.FullName
        $targetPath  = Join-Path $DestinationDir $skillName

        if (Test-Path $targetPath) {
            Write-Host "  [SKIP] '$skillName' already exists in destination." -ForegroundColor DarkYellow
            $skippedCount++
        }
        else {
            Write-Host "  [COPY] '$skillName' -> $targetPath" -ForegroundColor Green
            Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
            $copiedCount++
        }
    }
}

# Summary
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Summary"                                      -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Sources scanned : $scannedCount"
Write-Host "  Skills copied   : $copiedCount"               -ForegroundColor Green
Write-Host "  Skills skipped  : $skippedCount"               -ForegroundColor DarkYellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
