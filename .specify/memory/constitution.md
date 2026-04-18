<!--
SYNC IMPACT REPORT
==================
Version change: 2.0.0 → 2.0.1
Bump rationale: PATCH — refines the sub-structure rule for `agents/` inside
Principle V §Agents to match the Claude Code native agent convention (flat
single-file layout under `agents/`). Top-level canonical structure
(Principle II) is unchanged, so the change does not trigger the MAJOR rule
for "altering folder structure". Wording-level clarification; no principle
redefinition.

Modified principles:
  - V. Authoring Standards & Metadata Discipline — §Agents sub-bullet
    rewritten: flat `agents/<agent-name>.md` (Claude Code convention)
    replaces the prior folder-per-agent layout. Mandatory frontmatter set
    made explicit: `name`, `description`, `tools`. `model` optional.

Added sections: none.
Removed sections: none.

Templates requiring review:
  ✅ .specify/memory/constitution.md           — this file, updated.
  ✅ specs/001-repo-restructure-agents/spec.md — already aligned with the
     new §Agents rule via the 2026-04-17 /speckit.clarify session.
  ⚠  .specify/templates/plan-template.md       — Constitution Check must
     still account for eight canonical folders (from v2.0.0) and the new
     §Agents layout rule.
  ⚠  .specify/templates/tasks-template.md      — language-policy validation
     step must still include `workflows/` among EN-only folders (v2.0.0
     pending).
  ✅ .specify/templates/commands/               — folder not present; no action.

Follow-up TODOs (unchanged from prior versions):
  - TODO(VALIDATION_SCRIPTS): open since v1.0.0 — validators in `scripts/`.
  - TODO(CI_INTEGRATION): open since v1.0.0 — wire validators into CI.
-->

# Awesome AI Skills Constitution

## Core Principles

### I. Repository as Single Source of Truth for AI Artifacts

This repository is the canonical home for reusable AI artifacts — **skills**,
**agents**, **commands**, **rules**, **prompts**, and **reusable CI/CD
workflow templates** — consumed by Claude Code, related AI tooling, and the
team's build systems. Artifacts MUST be authored here, versioned here, and
referenced from downstream environments rather than duplicated. Any expertise,
workflow, or automation encoded for AI or CI consumption MUST live in one of
the approved top-level folders defined by Principle II.

**Rationale**: Centralizing AI- and CI-consumable assets prevents drift,
makes review and audit tractable, and enables consistent distribution across
environments.

### II. Canonical Folder Structure (NON-NEGOTIABLE)

The repository MUST follow exactly this top-level structure. No additional
top-level folders MAY be introduced without a constitutional amendment
(Section: Governance).

```
.
├── rules/        # Coding standards, architectural rules, constraints (EN only)
├── skills/       # Reusable Claude skills — domain expertise packages (EN only)
├── agents/       # Specialized agent definitions and configurations (EN only)
├── commands/     # Slash commands and executable command definitions (EN only)
├── docs/         # Human-facing documentation (EN or PT-BR)
├── prompts/      # Prompt templates and libraries (EN or PT-BR)
├── scripts/      # Build, validation, and utility scripts (EN only)
└── workflows/    # Reusable CI/CD pipeline templates (EN only)
```

Folder responsibilities:

| Folder       | Purpose                                                                                    | Primary Consumer  |
| ------------ | ------------------------------------------------------------------------------------------ | ----------------- |
| `rules/`     | Machine-readable rules that constrain AI behavior and enforce standards                    | AI agents         |
| `skills/`    | Packaged expertise (SKILL.md + assets) loaded on-demand by Claude                          | Claude Code       |
| `agents/`    | Autonomous agent definitions with scoped responsibilities                                  | Orchestrators     |
| `commands/`  | Named, invokable commands (e.g., slash commands) with defined I/O                          | End users / CLI   |
| `docs/`      | Onboarding, architecture notes, decision records, how-to guides                            | Humans            |
| `prompts/`   | Raw prompt templates, variations, and reference prompts                                    | Humans + AI       |
| `scripts/`   | Local automation for linting, validation, packaging, and repo utilities (non-pipeline)     | Build system      |
| `workflows/` | Reusable CI/CD pipeline templates (e.g., version-tag, create-release, publish, deploy)     | CI systems        |

The `workflows/` folder SHOULD host the pipeline templates most commonly
reused across the team's projects — at a minimum: version tagging, release
creation, package publishing (e.g., npm), production deployment, and mobile
build (e.g., APK) pipelines. `workflows/` contains **reusable** pipeline
definitions intended to be consumed from repository-specific CI (typically
via `.github/workflows/*.yml` callers); repository-specific CI glue itself
is not part of `workflows/` and remains under tooling dotfolders such as
`.github/`.

**Rationale**: A fixed, shallow top-level layout makes discovery deterministic
for both humans and AI tooling, permits automated structural validation, and
keeps reusable pipelines first-class citizens alongside AI artifacts.

### III. Language Policy — English-Only for AI- and CI-Consumed Artifacts

This is a strict, machine-enforceable rule.

The following folders MUST contain content exclusively in **English** — file
contents, filenames, identifiers, comments, and metadata:

- `rules/`
- `skills/`
- `agents/`
- `commands/`
- `scripts/`
- `workflows/`

The following folders MAY contain content in either **English** or
**Portuguese (PT-BR)**:

- `docs/`
- `prompts/`

Bilingual guidelines:

- When a document exists in both languages, use the suffix convention:
  `filename.md` (English) and `filename.pt-BR.md` (Portuguese).
- Code snippets, identifiers, and technical keywords inside Portuguese
  documents MUST remain in English.
- Prompts written in Portuguese MUST declare their target language in
  frontmatter or a header.

**Rationale**: Artifacts consumed directly by AI models, CI systems, and
third-party tooling require consistent, portable, English-language inputs.
Human-facing documentation and prompt libraries benefit from native-language
expression and are therefore bilingual by design.

### IV. Canonical Technology Stack

All skills, agents, commands, and rules produced in this repository target
the following canonical stack by default. Artifacts that apply to other
stacks MUST declare their scope explicitly in their frontmatter or
description.

**Backend:**

- **.NET / C#** — primary backend language and runtime
  - Clean Architecture conventions
  - Entity Framework Core for data access
- **PostgreSQL** — primary relational database
- **RabbitMQ** — asynchronous messaging, event-driven workflows, retry/DLQ
  patterns
- **Redis** — caching, distributed locks, ephemeral state
- **Elasticsearch** — full-text search, log aggregation, analytics

**Frontend:**

- **React** — primary UI framework
  - **TypeScript** is the expected language
  - Component-driven architecture

New technologies MAY be added to this list only via a constitutional
amendment (Section: Governance).

**Rationale**: A named default stack keeps skills and agents aligned with
the team's real-world projects, reducing the chance of AI output that is
plausible but off-target.

### V. Authoring Standards & Metadata Discipline

Every artifact in `skills/`, `agents/`, `commands/`, and `rules/` MUST
carry a frontmatter or header block that states its purpose and the
conditions under which it should be used.

General requirements:

- File and folder names MUST use `kebab-case`.
- Markdown files MUST use `.md`. Executable or structured configs MUST use
  the appropriate extension (`.json`, `.yaml`, `.ps1`, `.sh`).
- Pipeline templates in `workflows/` MUST use `.yml` (or `.yaml`) and SHOULD
  include a top-level comment header stating the pipeline's name, purpose,
  required inputs, and intended callers.

Artifact-specific requirements:

- **Skills** — Each skill lives under `skills/<skill-name>/` with a
  `SKILL.md` at its root. `SKILL.md` MUST include a `name` and a
  `description` that clearly state triggering conditions.
- **Agents** — Each agent is a single Markdown file at
  `agents/<agent-name>.md` (kebab-case), following the Claude Code native
  agent convention — no per-agent subfolder. YAML frontmatter MUST include
  `name`, `description`, and `tools` (explicit allowlist; implicit
  inheritance of all tools is forbidden). `model` is optional. The body
  MUST state the agent's role, the skills it composes (by reference), and
  its boundaries (out-of-scope deferral behavior).
- **Commands** — Each command is self-contained with explicit inputs,
  outputs, and side effects documented.
- **Rules** — Rules are declarative, atomic, and testable. Each rule file
  covers exactly one coherent concern.
- **Workflows** — Each pipeline template is a single self-contained YAML
  file under `workflows/`, reusable via `workflow_call` (or the equivalent
  in the CI system). Inputs, outputs, and secrets MUST be declared
  explicitly; no hard-coded, repository-specific values.

**Rationale**: Discoverability, automated triggering, and safe use by AI
orchestrators and CI systems all depend on uniformly structured,
well-described artifacts.

## Validation & Tooling

Scripts under `scripts/` are responsible for enforcing this constitution.
At minimum, the repository MUST provide:

- A **language-policy validator** that flags non-English content in
  English-only folders (Principle III), including `workflows/`.
- A **structure validator** that ensures no unauthorized top-level folders
  exist (Principle II). The canonical set is now eight folders.
- A **metadata validator** that ensures skills, agents, commands, rules,
  and workflow templates carry the required frontmatter/header fields
  (Principle V).

Validation MUST run in CI and MUST pass before any merge to the `main`
branch. A validator failure is a hard gate, not an advisory signal.

## Governance

### Amendments

This constitution is a living document. To amend it:

1. Open a pull request modifying `.specify/memory/constitution.md`.
2. Clearly describe the change and its rationale in the PR description.
3. Bump the version at the bottom of the document per semantic versioning:
   - **MAJOR** — backward-incompatible governance changes or principle
     removals/redefinitions (e.g., altering folder structure, relaxing the
     language policy, changing precedence rules).
   - **MINOR** — new principle or new materially expanded section.
   - **PATCH** — clarifications, wording, or typo fixes with no semantic
     change.
4. Update the `Last Amended` date to today (ISO `YYYY-MM-DD`).
5. Require review and approval before merge.

### Precedence

When conflicts arise between this constitution, individual artifact
instructions, or ad-hoc requests, the following order applies:

1. **This constitution** takes precedence over all other repository-level
   guidance.
2. **Rules in `rules/`** take precedence over individual skill, agent, or
   command defaults.
3. **Artifact-specific frontmatter** takes precedence over general
   conventions, but only within the scope of that artifact.

Safety, security, and correctness concerns always supersede stylistic or
structural rules.

### Compliance Review

Reviewers MUST verify that every PR:

- Places new artifacts in the correct top-level folder (Principle II).
- Respects the language policy for that folder (Principle III).
- Declares stack scope when diverging from the canonical stack
  (Principle IV).
- Includes the required frontmatter/metadata (Principle V).
- Passes all validators under `scripts/` (Section: Validation & Tooling).

**Version**: 2.0.1 | **Ratified**: 2026-04-17 | **Last Amended**: 2026-04-17
