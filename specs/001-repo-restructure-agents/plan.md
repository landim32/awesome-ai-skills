# Implementation Plan: Repository Restructure and Role-Based Agent Creation

**Branch**: `001-repo-restructure-agents` | **Date**: 2026-04-17 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/001-repo-restructure-agents/spec.md`

## Summary

Bring the repository layout into compliance with constitution v2.0.1 (8
canonical top-level folders, English-only policy, kebab-case) and deliver
five role-based agents under `agents/` following the Claude Code native
convention. Each agent is a single `<agent-name>.md` file with mandatory
YAML frontmatter (`name`, `description`, `tools`) whose body composes
existing skills from `skills/` by reference without duplicating their
content. No application code is written; the deliverables are Markdown
artifacts, relocations, and placeholder `README.md` files.

## Technical Context

**Language/Version**: Markdown (CommonMark) + YAML frontmatter; existing PowerShell 7+ utility scripts (unchanged logic, only relocated).
**Primary Dependencies**: Claude Code (agent runtime/consumer), Spec Kit (authoring tooling, already in `.specify/`).
**Storage**: Filesystem. No database. Files are the artifact.
**Testing**: Manual review against the contracts in `specs/001-repo-restructure-agents/contracts/`. Automated validators for the constitution are an open TODO (`VALIDATION_SCRIPTS` in constitution v2.0.1); not in scope for this feature.
**Target Platform**: Claude Code (CLI, desktop, IDE extensions, web); GitHub Actions consumes reusable pipelines under `workflows/` via `workflow_call`.
**Project Type**: AI artifact repository — no `src/`, no build output. Deliverables are five agent Markdown files, five folder `README.md` stubs, and four script relocations.
**Performance Goals**: N/A (no runtime performance surface).
**Constraints**:
- Principle III — EN only in `rules/`, `skills/`, `agents/`, `commands/`, `scripts/`, `workflows/`.
- Principle V §Agents — flat `agents/<agent-name>.md`; `name`+`description`+`tools` mandatory frontmatter.
- Clarification Q3 — every agent body MUST implement "name-and-stop" deferral.
- Clarification Q4 — Analyst defaults to PT-BR output; EN only on explicit request.
- FR-003 — `workflows/` content MUST NOT be relocated.
- FR-005 — no content loss under `skills/`, `prompts/`, `workflows/`.
**Scale/Scope**:
- 5 agents created.
- 5 placeholder folders created (`rules/`, `agents/`, `commands/`, `docs/`, `scripts/`) with `README.md` stubs.
- 4 `.ps1` utilities relocated to `scripts/`.
- Documentation references in `README.md` and `CLAUDE.md` updated to new paths.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitution version: **v2.0.1**.

| Principle | Requirement | Plan compliance |
|-----------|-------------|-----------------|
| I. Single Source of Truth | New AI artifacts (agents) live in the canonical repository | ✅ Agents under `agents/` |
| II. Canonical Folder Structure | Only 8 top-level content folders; no unauthorized additions | ✅ Creates missing canonical folders; relocates loose `.ps1` to `scripts/`; `workflows/` stays |
| III. Language Policy | EN-only in `agents/`, `scripts/`, `rules/`, `commands/`, `workflows/` | ✅ Agent files, stubs, and scripts produced in EN. Analyst's **output** to `docs/` (PT-BR default per Q4) does not violate this — `docs/` is bilingual by Principle III |
| IV. Canonical Technology Stack | Agents align with .NET/C# backend, React/TS frontend, PostgreSQL/RabbitMQ/Redis/Elasticsearch | ✅ Each developer agent targets a slice of the canonical stack; MAUI in-scope via Mobile agent per spec Assumption |
| V. Authoring Standards & Metadata Discipline | Agents as `agents/<agent-name>.md`; `name`+`description`+`tools` mandatory frontmatter; body states role, skills, boundaries | ✅ Contracts in Phase 1 make this explicit; all 5 agents conform |

**Gate result**: PASS. No violations to justify.

## Project Structure

### Documentation (this feature)

```text
specs/001-repo-restructure-agents/
├── spec.md                     # Feature specification
├── plan.md                     # This file
├── research.md                 # Phase 0 output
├── data-model.md               # Phase 1 output — agent definition schema
├── quickstart.md               # Phase 1 output — how to invoke and validate agents
├── contracts/                  # Phase 1 output
│   ├── agent-schema.md         # Shared frontmatter schema + body contract
│   ├── dotnet-senior-developer.md
│   ├── dotnet-mobile-developer.md
│   ├── frontend-react-developer.md
│   ├── qa-developer.md
│   └── analyst.md
├── checklists/
│   └── requirements.md         # From /speckit.specify + /speckit.clarify
└── tasks.md                    # Phase 2 output (/speckit.tasks — NOT created here)
```

### Repository Layout After Implementation

```text
awesome-ai-skills/
├── agents/                       # NEW — canonical folder per constitution II
│   ├── README.md                 # NEW — purpose stub
│   ├── analyst.md                # NEW — PT-BR default docs author
│   ├── dotnet-mobile-developer.md# NEW — MAUI-focused
│   ├── dotnet-senior-developer.md# NEW — backend/web
│   ├── frontend-react-developer.md # NEW — React/TS
│   └── qa-developer.md           # NEW — xUnit tests
├── commands/                     # NEW — canonical folder (empty + README.md)
│   └── README.md
├── docs/                         # NEW — canonical folder (empty + README.md)
│   └── README.md
├── prompts/                      # unchanged
│   ├── BACKEND_CONSTITUTION.md
│   ├── DEFAULT_CONSTITUTION.md
│   ├── FRONTEND_CONSTITUTION.md
│   └── MAUI_CONSTITUTION.md
├── rules/                        # NEW — canonical folder (empty + README.md)
│   └── README.md
├── scripts/                      # NEW — canonical folder
│   ├── README.md                 # NEW — stub
│   ├── collect-skills.ps1        # MOVED from root
│   ├── copy-dependency.ps1       # MOVED from root
│   ├── push-skill.ps1            # MOVED from root
│   └── replace-skill.ps1         # MOVED from root
├── skills/                       # unchanged (22 skill folders preserved)
├── workflows/                    # unchanged (canonical per constitution v2.0.0)
│   ├── build-apk.yml
│   ├── create-release.yml
│   ├── deploy-prod.yml
│   ├── npm-publish.yml
│   └── version-tag.yml
├── .claude/                      # tooling — exempt
├── .github/                      # tooling — exempt (callers for workflows/)
├── .specify/                     # Spec Kit tooling — exempt
├── specs/                        # Spec Kit working folder — exempt
├── CLAUDE.md                     # UPDATED — script paths refreshed
├── GitVersion.yml                # unchanged
├── LICENSE                       # unchanged
└── README.md                     # UPDATED — script paths refreshed
```

**Structure Decision**: This is an AI-artifact repository, not an application.
The canonical structure is dictated by constitution v2.0.1 Principle II.
Implementation is mechanical: create missing folders with stub `README.md`
files, move four PowerShell utilities to `scripts/`, author five agent
Markdown files under `agents/`, and refresh documentation references to the
relocated scripts. The existing `skills/`, `prompts/`, and `workflows/`
trees are not touched.

## Complexity Tracking

> No Constitution Check violations. Table intentionally omitted.
