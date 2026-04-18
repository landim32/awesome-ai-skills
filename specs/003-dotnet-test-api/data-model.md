# Phase 1 — Data Model: Skill `dotnet-test-api`

**Feature**: 003-dotnet-test-api
**Date**: 2026-04-18

## Nature of this model

Este feature não lida com dados relacionais. Suas "entidades" são artefatos de filesystem e slots estruturais de C#/JSON/Markdown. A disciplina é schema porque Claude Code e validadores de CI consomem estes artefatos como dados.

---

## Entity 1 — `SkillFile`

Arquivo único em `skills/dotnet-test-api/SKILL.md`.

### Attributes

| Field | Type | Rules |
|---|---|---|
| `path` | string | `skills/dotnet-test-api/SKILL.md` |
| `frontmatter.name` | literal | `dotnet-test-api` (kebab-case, matches folder name) |
| `frontmatter.description` | string | One paragraph stating trigger conditions and scope; ≥ 80 chars |
| `frontmatter.allowed-tools` | csv | `Read, Grep, Glob, Bash, Write, Edit, Task` |
| `frontmatter.user-invocable` | bool | `true` |
| `body.sections` | ordered list | 14 sections per `research.md` §Decision 3 |
| `body.line_count` | integer | ≤ 400 lines total (SC-010) |

### Validation rules

- Frontmatter validates against `contracts/skill-frontmatter.schema.json`.
- Section order EXACT per research §Decision 3.
- Zero non-English prose (Constitution §III).
- Presets documented: `NAuth`, `OAuth2 client credentials`, `API key` (minimum 3 beyond default — SC-008).

---

## Entity 2 — `AgentFileUpdate`

Existing agent file `agents/qa-developer.md` modified in-place.

### Changes

| Section | Change | Rationale |
|---|---|---|
| `frontmatter.description` | Replace "QA engineer for unit tests" scope with "QA engineer for unit and external API tests" phrasing; preserve kebab ID and tools | FR-011 |
| `## Role & Scope` | Expand to cover BOTH unit and API tests; explain the two compositions | FR-012 |
| `## Composed Skills` | Add bullet for `dotnet-test-api` with trigger sentence; keep `dotnet-test` bullet intact | FR-010 |
| `## Default Behavior` | Add rule: on ambiguous "tests" request, `AskUserQuestion` to choose unit vs API | research §Decision 6 |
| `## Boundaries / Out of Scope` | UNCHANGED | preserves sibling routing |
| `## Output Language` | UNCHANGED (canonical bilingual block from feature 002) | preserves SC-010 of feature 002 |
| `tools` | UNCHANGED (`Read, Grep, Glob, Bash, Write, Edit, Task, Skill`) | no new tool needed |

### Invariants after update

- Kept bullet for `dotnet-test` (zero regression, SC-002).
- New bullet for `dotnet-test-api` with trigger sentence (SC-009).
- Frontmatter schema from feature 002 still validates.
- File remains ≤ 100 lines (stretch goal consistent with `ui-ux-pro-max-designer.md` line budget).

---

## Entity 3 — `GeneratedTestProject` (runtime artifact, not in this PR)

Produced by the skill when invoked. Lives under the **target solution**, not under `awesome-ai-skills`.

### Root

| Field | Type | Rules |
|---|---|---|
| `project.name` | string | `<Solution>.ApiTests` (mirrors `<Solution>.Tests` naming of `dotnet-test`) |
| `project.root_path` | string | `<repo>/<Solution>.ApiTests/` |
| `project.target_framework` | string | `net8.0` (default); derived from `.sln` / other projects when different |
| `project.sln_entry` | bool | `true` — `dotnet sln add` executed |

### Required files

| File | Purpose | Validation |
|---|---|---|
| `<Solution>.ApiTests.csproj` | SDK project with test packages | Matches canonical package list (FR-003); references detected DTO project (if any) |
| `appsettings.Test.json` | Config template | Validates against `contracts/appsettings-test.schema.json`; all secret fields are `REPLACE_VIA_ENV_*` placeholders (SC-011) |
| `Fixtures/ApiTestFixture.cs` | Auth + request helpers | Matches `contracts/api-test-fixture.template.cs`; fast-fail on placeholder (SC-012) |
| `Fixtures/ApiTestCollection.cs` | Collection binding | Matches `contracts/api-test-collection.template.cs` |
| `Helpers/TestDataHelper.cs` | Factories (empty/minimal at boot) | Matches `contracts/test-data-helper.template.cs` shell |
| `Controllers/<Name>ControllerTests.cs` | Per-controller test class | Created on-demand; matches `contracts/controller-tests.template.cs` skeleton |

### Lifecycle

1. **Boot** (US1): skill creates csproj + appsettings + Fixtures + empty Helper + solution entry. Zero Controllers files.
2. **Grow** (US2): each invocation adding a controller appends `Controllers/<Name>ControllerTests.cs` AND adds only the needed factories to `Helpers/TestDataHelper.cs` (on-demand, Q5).
3. **Run** (US3): env vars override placeholders; `dotnet test` executes against configured `ApiBaseUrl`.

---

## Entity 4 — `AuthPreset` (documentation-only)

Documented variant of the default fixture in the SKILL.md `## Auth Presets` section.

### Attributes

| Field | Type | Rules |
|---|---|---|
| `name` | enum | `NAuth` \| `OAuth2ClientCredentials` \| `ApiKey` |
| `appsettings_diff` | snippet | Shows added/removed keys under `Auth` |
| `fixture_diff` | snippet | Shows added/modified code in `ApiTestFixture.cs` |

### Invariant

Each preset snippet ≤ 30 lines (research §Decision 5).

---

## Entity 5 — `DtoProjectCandidate` (runtime detection)

Structure returned by the skill's pre-flight DTO detection.

### Attributes

| Field | Type | Rules |
|---|---|---|
| `project_name` | string | e.g., `<Solution>.DTO`, `<Solution>.Contracts` |
| `csproj_path` | string | Absolute path read from `.sln` |
| `matched_suffix` | enum | `.DTO` \| `.Dto` \| `.Dtos` \| `.Contracts` \| `.Models` \| `.Shared` |

### Invariant

Case-insensitive match. Skill behavior by candidate count:
- 0 → prompt for inline payloads / manual path.
- 1 → auto-reference, inform user.
- 2+ → prompt with full list + "none / inline" option.

---

## Relationships

```text
SkillFile (1) ── produces at runtime ──> (n) GeneratedTestProject
SkillFile (1) ── documents ──> (3+) AuthPreset
AgentFileUpdate (1) ── composes ──> (1) SkillFile
GeneratedTestProject (1) ── references (optional) ──> (0..1) DtoProjectCandidate
```
