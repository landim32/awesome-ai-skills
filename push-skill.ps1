# =============================================================================
# Push-Skill.ps1
# Pushes a specific skill from this project's skills folder to all repos
# under the scan root that have .claude\skills directories.
# Compares files, shows diffs and dates, and asks before updating.
#
# Usage:
#   powershell -File push-skill.ps1 -SkillName my-skill
# =============================================================================

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$SkillName
)

# ----- Configuration ---------------------------------------------------------
$ScanRoot  = "C:\repos"
$SourceDir = Join-Path $PSScriptRoot "skills"
# -----------------------------------------------------------------------------

$skillSourcePath = Join-Path $SourceDir $SkillName

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Skill Pusher - Awesome AI Skills"            -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Skill           : $SkillName"
Write-Host "Source          : $skillSourcePath"
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

# Get all source files relative paths
$sourceFiles = Get-ChildItem -Path $skillSourcePath -Recurse -File |
    ForEach-Object { @{ Relative = $_.FullName.Substring($skillSourcePath.Length + 1); Full = $_.FullName } }

# Statistics
$updatedCount   = 0
$skippedCount   = 0
$identicalCount = 0
$scannedCount   = 0

Write-Host "Scanning for .claude\skills\$SkillName in repos..." -ForegroundColor Yellow
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

    $targetSkillPath = Join-Path $skillsPath $SkillName

    # Skip repos that don't have this skill
    if (-not (Test-Path $targetSkillPath)) {
        return
    }

    $scannedCount++
    $repoName = (Split-Path (Split-Path (Split-Path $claudeDir -Parent) -Parent) -Leaf)
    Write-Host "---------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[FOUND] $targetSkillPath" -ForegroundColor Blue
    Write-Host "  Repo: $repoName" -ForegroundColor Gray

    $hasDifferences = $false

    foreach ($file in $sourceFiles) {
        $srcFile = $file.Full
        $tgtFile = Join-Path $targetSkillPath $file.Relative

        if (-not (Test-Path $tgtFile)) {
            Write-Host ""
            Write-Host "  [NEW] $($file.Relative) -- file does not exist in target" -ForegroundColor Yellow
            $hasDifferences = $true
            continue
        }

        # Compare content
        $srcContent = Get-Content -Path $srcFile -Raw -ErrorAction SilentlyContinue
        $tgtContent = Get-Content -Path $tgtFile -Raw -ErrorAction SilentlyContinue

        if ($srcContent -eq $tgtContent) {
            continue
        }

        $hasDifferences = $true

        # Show file dates
        $srcDate = (Get-Item $srcFile).LastWriteTime
        $tgtDate = (Get-Item $tgtFile).LastWriteTime

        Write-Host ""
        Write-Host "  [DIFF] $($file.Relative)" -ForegroundColor Yellow

        $srcDateStr = $srcDate.ToString('yyyy-MM-dd HH:mm:ss')
        $tgtDateStr = $tgtDate.ToString('yyyy-MM-dd HH:mm:ss')

        if ($srcDate -gt $tgtDate) {
            Write-Host "    Source (this repo) : $srcDateStr  ** NEWER **" -ForegroundColor Green
            Write-Host "    Target (remote)    : $tgtDateStr" -ForegroundColor Gray
        }
        elseif ($tgtDate -gt $srcDate) {
            Write-Host "    Source (this repo) : $srcDateStr" -ForegroundColor Gray
            Write-Host "    Target (remote)    : $tgtDateStr  ** NEWER **" -ForegroundColor Red
        }
        else {
            Write-Host "    Source (this repo) : $srcDateStr" -ForegroundColor Gray
            Write-Host "    Target (remote)    : $tgtDateStr  (same date)" -ForegroundColor Gray
        }

        # Show diff
        Write-Host ""
        Write-Host "  --- Diff (source vs target) ---" -ForegroundColor DarkCyan

        $srcLines = $srcContent -split "`n"
        $tgtLines = $tgtContent -split "`n"

        $maxLines = [Math]::Max($srcLines.Count, $tgtLines.Count)
        $diffShown = 0
        $maxDiffLines = 30

        for ($i = 0; $i -lt $maxLines; $i++) {
            if ($diffShown -ge $maxDiffLines) {
                $remaining = $maxLines - $i
                Write-Host ('    ... ' + $remaining + ' more lines differ') -ForegroundColor DarkGray
                break
            }
            $sl = if ($i -lt $srcLines.Count) { $srcLines[$i] } else { "" }
            $tl = if ($i -lt $tgtLines.Count) { $tgtLines[$i] } else { "" }

            if ($sl -ne $tl) {
                $lineNum = $i + 1
                Write-Host "    L${lineNum}:" -ForegroundColor DarkGray -NoNewline
                Write-Host " - $($tl.TrimEnd())" -ForegroundColor Red
                Write-Host "         + $($sl.TrimEnd())" -ForegroundColor Green
                $diffShown++
            }
        }
        Write-Host "  --------------------------------" -ForegroundColor DarkCyan
    }

    # Check for files that exist in target but not in source
    $targetFiles = Get-ChildItem -Path $targetSkillPath -Recurse -File -ErrorAction SilentlyContinue
    foreach ($tf in $targetFiles) {
        $relPath = $tf.FullName.Substring($targetSkillPath.Length + 1)
        $matchingSource = $sourceFiles | Where-Object { $_.Relative -eq $relPath }
        if (-not $matchingSource) {
            Write-Host ""
            Write-Host "  [EXTRA] $relPath -- exists in target but not in source" -ForegroundColor Magenta
            $hasDifferences = $true
        }
    }

    if (-not $hasDifferences) {
        Write-Host "  [OK] Identical -- no changes needed." -ForegroundColor Green
        $identicalCount++
        return
    }

    # Ask user
    Write-Host ""
    $answer = Read-Host "  Update '$SkillName' in $repoName? (y/N)"

    if ($answer -eq 'y' -or $answer -eq 'Y') {
        Remove-Item -Path $targetSkillPath -Recurse -Force
        Copy-Item -Path $skillSourcePath -Destination $targetSkillPath -Recurse -Force
        Write-Host "  [UPDATED] Skill copied successfully." -ForegroundColor Green
        $updatedCount++
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
Write-Host "  Repos with skill : $scannedCount"
Write-Host "  Identical        : $identicalCount"            -ForegroundColor Green
Write-Host "  Updated          : $updatedCount"              -ForegroundColor Green
Write-Host "  Skipped          : $skippedCount"              -ForegroundColor DarkYellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
