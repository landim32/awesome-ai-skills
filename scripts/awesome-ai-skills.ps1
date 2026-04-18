#Requires -Version 5.0
<#
.SYNOPSIS
    Install awesome-ai-skills artifacts into the current project's .claude/ directory.

.DESCRIPTION
    Clones https://github.com/landim32/awesome-ai-skills and copies the canonical
    artifact folders (skills, agents, rules, commands) into .claude/ of the target
    project. Files with the same name in the destination are overwritten; files
    that exist only in the destination (e.g., your custom skills) are preserved.

.PARAMETER Target
    Project root where .claude/ will be created or updated.
    Default: current working directory.

.PARAMETER Branch
    Source branch of the awesome-ai-skills repository.
    Default: main.

.EXAMPLE
    pwsh scripts/awesome-ai-skills.ps1
    # Installs into .\.claude\ using the main branch.

.EXAMPLE
    pwsh scripts/awesome-ai-skills.ps1 -Target C:\my\project -Branch develop

.NOTES
    Requires: git available in PATH (shallow clone is used).
    Language policy: file is English-only per constitution Principle III.
#>

[CmdletBinding()]
param(
    [string]$Target = (Get-Location).Path,
    [string]$Branch = 'main'
)

$ErrorActionPreference = 'Stop'

$RepoUrl   = 'https://github.com/landim32/awesome-ai-skills.git'
$Folders   = @('skills', 'agents', 'rules', 'commands')
$TempDir   = Join-Path ([IO.Path]::GetTempPath()) ("awesome-ai-skills-" + [guid]::NewGuid().ToString("N"))
$ClaudeDir = Join-Path $Target '.claude'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required but was not found in PATH."
}

try {
    Write-Host "Cloning $RepoUrl ($Branch)..." -ForegroundColor Cyan
    git clone --depth 1 --branch $Branch --quiet $RepoUrl $TempDir
    if ($LASTEXITCODE -ne 0) {
        throw "git clone failed (exit code $LASTEXITCODE)."
    }

    if (-not (Test-Path $ClaudeDir)) {
        Write-Host "Creating $ClaudeDir" -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
    }

    foreach ($folder in $Folders) {
        $src = Join-Path $TempDir $folder
        $dst = Join-Path $ClaudeDir $folder

        if (-not (Test-Path $src)) {
            Write-Warning "Source folder '$folder' missing in repo; skipped."
            continue
        }

        if (-not (Test-Path $dst)) {
            New-Item -ItemType Directory -Path $dst | Out-Null
        }

        Write-Host "Copying $folder -> $dst" -ForegroundColor Green
        Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force
    }

    Write-Host "Done. Artifacts installed into $ClaudeDir" -ForegroundColor Green
}
finally {
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
