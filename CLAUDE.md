# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A curated collection of Claude AI skills — reusable instructional guides and templates for AI-assisted development across React/TypeScript and .NET/C# stacks. Each skill lives in `skills/<skill-name>/SKILL.md` and provides implementation patterns, code templates, and best practices.

## Repository Structure

- **skills/** — Main skills collection. Each subdirectory contains a `SKILL.md` with metadata (name, description, allowed-tools) and detailed implementation guides.
- **workflows/** — Reusable GitHub Actions workflow templates (version-tag, create-release, npm-publish).
- **prompts/** — Prompt templates for specific use cases.
- **.github/workflows/** — CI/CD pipelines that consume the workflow templates.
- **scripts/** — Repository utility scripts. `scripts/collect-skills.ps1` scans `C:\repos` for `.claude/skills/` directories in other projects and copies new skills into this repo's `skills/` folder. Also `scripts/copy-dependency.ps1`, `scripts/push-skill.ps1`, `scripts/replace-skill.ps1`.
- **agents/** — Role-based agent definitions (Claude Code flat-file convention, `agents/<agent-name>.md`).
- **rules/** — Machine-readable rules and constraints.
- **commands/** — Named invokable commands.
- **docs/** — Human-facing documentation (bilingual: EN or PT-BR with `.pt-BR.md` suffix).

## Versioning and Releases

Uses **GitVersion** (ContinuousDelivery mode) configured in `GitVersion.yml`. Version bumps are driven by commit message prefixes:

| Prefix | Bump |
|---|---|
| `major:` or `breaking:` | Major |
| `feat:` or `feature:` or `minor:` | Minor |
| `fix:` or `patch:` | Patch |

Tag prefix accepts both `v` and `V` (e.g., `v1.2.3`). The CI pipeline auto-tags on push to main and creates GitHub Releases for major/minor changes only.

## Collecting Skills from Other Projects

```powershell
powershell -File scripts/collect-skills.ps1
```

This scans all repos under `C:\repos` for `.claude/skills/` directories and copies any skill not already present into `skills/`.

## Adding a New Skill

Create a directory under `skills/` with a `SKILL.md` file. The file must include frontmatter-style metadata at the top:

```
---
name: skill-name
description: Brief description
allowed-tools: Tool1, Tool2
user-invocable: true|false
---
```

Follow existing skills as examples for structure and depth of documentation.
