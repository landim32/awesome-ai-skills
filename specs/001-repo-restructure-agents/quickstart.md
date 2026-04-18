# Quickstart — Using the new agents and the reorganized repo

**Feature**: Repository Restructure and Role-Based Agent Creation
**Date**: 2026-04-17

This quickstart shows how a contributor exercises the deliverables of this
feature once merged. It is also the manual-verification path for the
acceptance tests declared in `spec.md` and `contracts/`.

---

## 1. Verify the repository structure

From the repo root, list the top level. You should see exactly eight
canonical content folders plus tooling dotfolders and permitted root
files:

```bash
ls -la
```

Expected (ignoring `.github`, `.claude`, `.specify`, `.git`, `specs/`):

```
agents/      commands/   docs/       prompts/
rules/       scripts/    skills/     workflows/
CLAUDE.md    GitVersion.yml   LICENSE   README.md
```

No loose `*.ps1` files at the root. Every new canonical folder has a
`README.md` stub.

## 2. Verify the agents

```bash
ls agents/
```

Expected:

```
README.md
analyst.md
dotnet-mobile-developer.md
dotnet-senior-developer.md
frontend-react-developer.md
qa-developer.md
```

Open one agent file and confirm the frontmatter matches its contract in
`specs/001-repo-restructure-agents/contracts/<agent-name>.md`.

## 3. Invoke each agent

In Claude Code, use the Task tool (or the agent picker) and address the
agent by its `name`.

### 3a. `dotnet-senior-developer`

Prompt: *"Add a new entity `Customer` end-to-end in the .NET solution."*

Expected: the agent invokes `dotnet-architecture`, produces DTO / Domain
(Model + Service + Interface) / Infra / Application scaffolding consistent
with that skill, cites the skill by name, does NOT duplicate skill
content, and does NOT touch MAUI or React.

Negative prompt: *"Now add a MAUI page for `Customer`."*
Expected: `"Out of scope. Defer to dotnet-mobile-developer."`

### 3b. `dotnet-mobile-developer`

Prompt: *"Add `Customer` to the mobile app end-to-end."*

Expected: the agent first confirms or scaffolds backend layers via
`dotnet-architecture`, then produces the MAUI presentation layer (SQLite
model → Mapper → AppDatabase → ViewModel → XAML Page → Shell → MauiProgram
DI) via `maui-architecture`.

Negative prompt: *"Create a GraphQL endpoint for `Customer`."*
Expected: `"Out of scope. Defer to dotnet-senior-developer."`

CI prompt: *"How do we build the APK?"*
Expected: cites `workflows/build-apk.yml` without rewriting the pipeline.

### 3c. `frontend-react-developer`

Prompt: *"Scaffold a new `Achievement` entity in the frontend."*

Expected: types → service → context → hook → provider registration per
`react-architecture`, with `toast` (not `alert()`), `useCallback` in
context methods, and class-based service with `handleResponse`.

Negative prompt: *"Add a .NET controller for `Achievement`."*
Expected: `"Out of scope. Defer to dotnet-senior-developer."`

### 3d. `qa-developer`

Prompt: *"Write unit tests for the existing `CustomerService`."*

Expected: tests under the single `<Solution>.Tests` project, mirroring the
source folder path, using xUnit conventions from `dotnet-test`.

Negative prompt: *"Now refactor `CustomerService` to use a repository."*
Expected: `"Out of scope. Defer to dotnet-senior-developer."`

### 3e. `analyst`

PT-BR default prompt: *"Escreva um guia de deploy."*
Expected: document created at `docs/GUIA_DE_DEPLOY.pt-BR.md`, UPPER_SNAKE_CASE,
PT-BR content, technical keywords in English.

EN prompt: *"Write a deployment guide."*
Expected: document created at `docs/DEPLOYMENT_GUIDE.md`, EN content.

Diagram prompt: *"Adicione um diagrama de arquitetura ao guia de deploy."*
Expected: a Mermaid block appended to `docs/GUIA_DE_DEPLOY.pt-BR.md`.

Negative prompt: *"Implement the payment controller."*
Expected: `"Fora de escopo. Defer to dotnet-senior-developer."`

## 4. Verify relocated scripts

```bash
ls scripts/
```

Expected (EN-only folder, `.ps1` files preserved with history):

```
README.md
collect-skills.ps1
copy-dependency.ps1
push-skill.ps1
replace-skill.ps1
```

Confirm history is preserved:

```bash
git log --follow scripts/collect-skills.ps1 | head -20
```

Should show commits dating back to before the move.

Confirm no stale references:

```bash
grep -r "collect-skills.ps1\|copy-dependency.ps1\|push-skill.ps1\|replace-skill.ps1" --include="*.md" --include="*.yml" --exclude-dir=specs --exclude-dir=scripts .
```

Every hit MUST be prefixed by `scripts/` — no bare `./collect-skills.ps1`
or root-level reference.

## 5. Spot-check the language policy

```bash
# Fail-fast grep for common PT-BR tokens in EN-only folders.
grep -Eri "não|função|está|já" agents/ rules/ commands/ scripts/ workflows/ 2>/dev/null
```

Expected output: empty.

(A real validator is deferred per `TODO(VALIDATION_SCRIPTS)` in the
constitution; manual grep is the interim check.)

## 6. Confirm the constitution is honored

- `agents/*.md` uses Claude Code flat-file convention (Principle V §Agents, v2.0.1).
- Eight canonical folders at root (Principle II, v2.0.0+).
- English-only content in `agents/`, `rules/`, `commands/`, `scripts/`, `workflows/` (Principle III).
- Each developer agent aligns with a slice of the canonical stack (Principle IV).
- Every agent declares `name`, `description`, `tools` in frontmatter (Principle V).

If all six sections above pass, the feature is ready for review.
