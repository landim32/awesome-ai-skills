---

description: "Task list for feature 001-repo-restructure-agents"
---

# Tasks: Repository Restructure and Role-Based Agent Creation

**Input**: Design documents from `specs/001-repo-restructure-agents/`
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md` (all present)

**Tests**: The spec does NOT request automated tests. Verification is manual against `contracts/agent-schema.md`, each per-agent contract, and `quickstart.md`. No test tasks are generated.

**Organization**: Tasks are grouped by user story to enable independent implementation and validation of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1 through US6)
- Exact file paths are included in every task description

## Path Conventions

- Repository root: `C:\repos\awesome-ai-skills` (Windows bash / PowerShell)
- Agents live at `agents/<agent-name>.md` (Claude Code flat-file convention per constitution v2.0.1)
- Scripts live at `scripts/<name>.ps1`
- Spec artifacts live at `specs/001-repo-restructure-agents/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm branch state before touching the tree.

- [x] T001 Confirm current branch is `001-repo-restructure-agents` and working tree has no unrelated uncommitted changes. Run `git status` and visually scan; if unrelated changes exist, stash or commit them separately before proceeding.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the canonical folders and per-folder `README.md` stubs required by constitution v2.0.1 Principle II. Every user story after this point depends on these folders existing.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T002 [P] Create folder `rules/` and author stub `rules/README.md` — H1 "Rules", one-sentence purpose quoted from constitution Principle II, "Language: EN only", "Authoring: kebab-case, one-concern-per-file, declarative, testable", link to `.specify/memory/constitution.md`.
- [x] T003 [P] Create folder `agents/` and author stub `agents/README.md` — H1 "Agents", one-sentence purpose, "Language: EN only", "Authoring: Claude Code flat-file convention `<agent-name>.md`, mandatory frontmatter `name`+`description`+`tools`", link to the constitution and to `specs/001-repo-restructure-agents/contracts/agent-schema.md`.
- [x] T004 [P] Create folder `commands/` and author stub `commands/README.md` — H1 "Commands", one-sentence purpose, "Language: EN only", "Authoring: self-contained, explicit I/O and side effects", link to constitution.
- [x] T005 [P] Create folder `docs/` and author stub `docs/README.md` (in English) — H1 "Docs", one-sentence purpose, "Language: EN or PT-BR (bilingual folder); PT-BR files use `.pt-BR.md` suffix", "Authoring: UPPER_SNAKE_CASE filenames per `doc-manager` skill", link to constitution.
- [x] T006 [P] Create folder `scripts/` and author stub `scripts/README.md` — H1 "Scripts", one-sentence purpose, "Language: EN only", "Authoring: kebab-case filenames, appropriate extensions (`.ps1`, `.sh`)", link to constitution. Do NOT move the loose `*.ps1` files yet — that is US1 work.
- [x] T007 Inventory existing caller references to the four root PowerShell utilities. Grep `README.md`, `CLAUDE.md`, `.github/workflows/**/*.yml`, and every `skills/**/SKILL.md` for the exact strings `collect-skills.ps1`, `copy-dependency.ps1`, `push-skill.ps1`, `replace-skill.ps1`. Record the hit list (file + line) in a scratch note for use by T012. Do not edit anything in this task.

**Checkpoint**: Foundation ready — user story work can now begin in parallel after US1.

---

## Phase 3: User Story 1 — Repository complies with the constitution (Priority: P1) 🎯 MVP

**Goal**: The repo layout matches constitution v2.0.1. Loose `*.ps1` utilities live under `scripts/` with history preserved; every caller reference is updated; the canonical eight-folder top-level structure is concretely present.

**Independent Test**: Follow `specs/001-repo-restructure-agents/quickstart.md` §1, §4, and §5. Expected: eight canonical folders visible; no loose `*.ps1` at root; `git log --follow scripts/collect-skills.ps1` shows pre-move history; grep for the four script filenames returns only `scripts/`-prefixed hits.

### Implementation for User Story 1

- [x] T008 [US1] Relocate `collect-skills.ps1` to `scripts/collect-skills.ps1` via `git mv collect-skills.ps1 scripts/collect-skills.ps1` to preserve history.
- [x] T009 [US1] Relocate `copy-dependency.ps1` to `scripts/copy-dependency.ps1` via `git mv copy-dependency.ps1 scripts/copy-dependency.ps1`.
- [x] T010 [US1] Relocate `push-skill.ps1` to `scripts/push-skill.ps1` via `git mv push-skill.ps1 scripts/push-skill.ps1`.
- [x] T011 [US1] Relocate `replace-skill.ps1` to `scripts/replace-skill.ps1` via `git mv replace-skill.ps1 scripts/replace-skill.ps1`.
- [x] T012 [US1] Update every caller reference discovered in T007. For each hit, rewrite the path to its `scripts/`-prefixed form. Touch files: `README.md`, `CLAUDE.md`, any hit under `.github/workflows/**/*.yml`, any hit under `skills/**/SKILL.md`. Do NOT edit files inside `specs/` (they are historical).
- [x] T013 [US1] Verify history preservation — run `git log --follow --oneline scripts/collect-skills.ps1 | head -5` and confirm at least one commit pre-dates the move. Repeat for the other three relocated scripts.
- [x] T014 [US1] Re-run the grep from T007 against the four filenames. Every hit MUST now be prefixed by `scripts/`. If any bare (root-level) reference remains, fix it and re-run until the grep is clean.
- [x] T015 [US1] Run the language-policy spot-check from `quickstart.md` §5 — `grep -Eri "não|função|está|já" agents/ rules/ commands/ scripts/ workflows/`. Expected: empty output. If non-empty, fix the PT-BR content or file a follow-up ticket (cleanup of legacy PT-BR is out of scope per spec Assumptions, but *new* content introduced by this feature MUST be EN).

**Checkpoint**: User Story 1 is fully functional and independently verifiable. This is the MVP cut.

---

## Phase 4: User Story 2 — .NET Senior Developer agent available (Priority: P2)

**Goal**: Authoring `agents/dotnet-senior-developer.md` so backend/web work has a dedicated agent composing the seven `dotnet-*` skills.

**Independent Test**: Follow `quickstart.md` §3a. Expected: the agent invokes `dotnet-architecture` for a "Customer entity" request, defers with "use `dotnet-mobile-developer`" on a MAUI prompt, and defers to `qa-developer` on a tests-only prompt.

### Implementation for User Story 2

- [x] T016 [P] [US2] Author `agents/dotnet-senior-developer.md` exactly per `specs/001-repo-restructure-agents/contracts/dotnet-senior-developer.md` — frontmatter (`name: dotnet-senior-developer`, `description` ≤ 200 chars, `tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill`), body sections H1 / Role & Scope / Composed Skills (7 bullets listing the `dotnet-*` skill folders) / Default Behavior / Boundaries (defer to `dotnet-mobile-developer`, `frontend-react-developer`, `qa-developer`, `analyst`) / Output Language (`English`).
- [x] T017 [US2] Manually verify the file against `contracts/agent-schema.md` §"Acceptance test" (filename regex, frontmatter parse, `name` == stem, `tools` non-empty, six body sections in order) and against `contracts/dotnet-senior-developer.md` §"Acceptance tests specific to this agent" (positive and negative prompts).

**Checkpoint**: User Story 2 is independently functional.

---

## Phase 5: User Story 3 — Frontend React Developer agent available (Priority: P2)

**Goal**: Authoring `agents/frontend-react-developer.md` so React/TypeScript work has a dedicated agent composing the React skills plus `frontend-design`.

**Independent Test**: Follow `quickstart.md` §3c. Expected: scaffolding follows the `react-architecture` order; modal/alert requests delegate to `react-modal`/`react-alert`; design requests invoke `frontend-design` with a bold aesthetic direction.

### Implementation for User Story 3

- [x] T018 [P] [US3] Author `agents/frontend-react-developer.md` exactly per `specs/001-repo-restructure-agents/contracts/frontend-react-developer.md` — frontmatter (`name: frontend-react-developer`, `description` ≤ 200 chars, `tools: Read, Grep, Glob, Write, Edit, Task, Skill`), body H1 / Role & Scope / Composed Skills (6 bullets: `react-architecture`, `react-arch`, `react-alert`, `react-modal`, `add-react-i18n`, `frontend-design`) / Default Behavior / Boundaries (defer to `dotnet-senior-developer`, `dotnet-mobile-developer`, `qa-developer`, `analyst`) / Output Language (`English`).
- [x] T019 [US3] Manually verify against `contracts/agent-schema.md` and `contracts/frontend-react-developer.md` acceptance tests.

**Checkpoint**: User Story 3 is independently functional.

---

## Phase 6: User Story 4 — QA Developer agent available (Priority: P2)

**Goal**: Authoring `agents/qa-developer.md` so unit-test work has a dedicated agent composing `dotnet-test` with forward compatibility for future test skills.

**Independent Test**: Follow `quickstart.md` §3d. Expected: test files land under `<Solution>.Tests` mirroring source layers; refactor prompts defer to the correct developer agent; React test requests declare the current skill gap.

### Implementation for User Story 4

- [x] T020 [P] [US4] Author `agents/qa-developer.md` exactly per `specs/001-repo-restructure-agents/contracts/qa-developer.md` — frontmatter (`name: qa-developer`, `description` ≤ 200 chars, `tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill`), body H1 / Role & Scope / Composed Skills (`dotnet-test` + forward-compatibility note) / Default Behavior / Boundaries (defer to all three developer agents and to `analyst`) / Output Language (`English`).
- [x] T021 [US4] Manually verify against `contracts/agent-schema.md` and `contracts/qa-developer.md` acceptance tests.

**Checkpoint**: User Story 4 is independently functional.

---

## Phase 7: User Story 5 — Analyst agent authors project documentation (Priority: P2)

**Goal**: Authoring `agents/analyst.md` as the sole owner of `docs/` with PT-BR default output language per Clarification Q4.

**Independent Test**: Follow `quickstart.md` §3e. Expected: PT-BR request → `docs/GUIA_DE_DEPLOY.pt-BR.md`; EN request → `docs/DEPLOYMENT_GUIDE.md`; diagram request → Mermaid block; non-doc request defers to the owning developer agent.

### Implementation for User Story 5

- [x] T022 [P] [US5] Author `agents/analyst.md` exactly per `specs/001-repo-restructure-agents/contracts/analyst.md` — frontmatter (`name: analyst`, `description` ≤ 200 chars declaring PT-BR default, `tools: Read, Write, Edit, Glob, Grep, Task, Skill` — NO `Bash`), body H1 / Role & Scope / Composed Skills (`doc-manager`, `readme-generator`, `mermaid-chart`) / Default Behavior (explicit PT-BR default rule; UPPER_SNAKE_CASE filenames; `.pt-BR.md` suffix for PT-BR) / Boundaries (defer to all four developer/QA agents) / Output Language (`PT-BR by default; EN only when the user writes in EN or asks explicitly for EN`).
- [x] T023 [US5] Manually verify against `contracts/agent-schema.md` and `contracts/analyst.md` acceptance tests. In particular confirm `Bash` is absent from `tools` (least-privilege per research.md R3).

**Checkpoint**: User Story 5 is independently functional.

---

## Phase 8: User Story 6 — .NET Mobile Developer agent available (Priority: P2)

**Goal**: Authoring `agents/dotnet-mobile-developer.md` so MAUI mobile work has a dedicated agent composing `maui-architecture` plus shared backend skills.

**Independent Test**: Follow `quickstart.md` §3b. Expected: end-to-end mobile entity request scaffolds backend layers via `dotnet-architecture` first, then MAUI layers via `maui-architecture`; pure-backend prompt defers to `dotnet-senior-developer`; APK build prompt cites `workflows/build-apk.yml`.

### Implementation for User Story 6

- [x] T024 [P] [US6] Author `agents/dotnet-mobile-developer.md` exactly per `specs/001-repo-restructure-agents/contracts/dotnet-mobile-developer.md` — frontmatter (`name: dotnet-mobile-developer`, `description` ≤ 200 chars, `tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill`), body H1 / Role & Scope / Composed Skills (`maui-architecture` primary, plus `dotnet-architecture`, `dotnet-fluent-validation`, `dotnet-env`, `dotnet-test`) / Default Behavior (including explicit reference to `workflows/build-apk.yml` for APK CI per FR-018) / Boundaries (defer to `dotnet-senior-developer`, `frontend-react-developer`, `qa-developer`, `analyst`) / Output Language (`English`).
- [x] T025 [US6] Manually verify against `contracts/agent-schema.md` and `contracts/dotnet-mobile-developer.md` acceptance tests. Specifically confirm the acceptance test "request 'how do we build the APK?' → cites `workflows/build-apk.yml`" passes.

**Checkpoint**: User Story 6 is independently functional. All five agents now exist.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency pass across README, CLAUDE.md, and end-to-end validation.

- [x] T026 Update repo-root `README.md` so any section that lists contents, folders, or scripts reflects the post-reorg state (scripts under `scripts/`, agents under `agents/`, canonical eight-folder layout).
- [x] T027 Update repo-root `CLAUDE.md` so the "Collecting Skills from Other Projects" snippet points at `scripts/collect-skills.ps1` (not the root path) and so the project-structure narrative references the eight canonical folders and the five agents. Preserve any Spec Kit context markers previously inserted by `update-agent-context.ps1`.
- [x] T028 [P] Run the end-to-end manual validation path in `specs/001-repo-restructure-agents/quickstart.md` §1 through §6 and record any deviations. Fix any that stem from this feature's work; file follow-ups for anything legacy.
- [x] T029 [P] Re-run the final Constitution Check from `plan.md` against the deployed state of the repo. All five principles MUST be green. If any principle fails, return to the responsible phase and fix before closing the PR.
- [ ] T030 Commit in logical chunks per phase (setup, foundational folders, US1 relocations, each agent file, polish) with conventional commit messages (`feat:`, `fix:`, `docs:`) so GitVersion computes the correct bump. Do NOT amend or force-push.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: no dependencies; can start immediately.
- **Phase 2 (Foundational)**: depends on Phase 1 completion. Blocks Phase 3+.
- **Phase 3 (US1)**: depends on Phase 2 (needs `scripts/` folder to exist before moving `.ps1` files into it).
- **Phases 4–8 (US2–US6)**: each depends on Phase 2 (needs `agents/` to exist) and is independent of every other US phase. They can run fully in parallel after Phase 2.
- **Phase 9 (Polish)**: depends on Phases 3–8 (final passes need all agents and relocated scripts in place).

### Within Each User Story Phase

- Authoring the agent file must precede its manual verification task.
- Within a single phase there are no further sub-dependencies.

### Parallel Opportunities

- **Phase 2**: T002–T006 are all `[P]` — five folder stubs, five distinct files, zero dependencies between them. Run in parallel.
- **Phase 3 (US1)**: T008–T011 are serial with each other only in the sense of minimizing git-move noise; they target distinct paths and COULD run as a single batched set, but are listed sequentially for clarity. T012/T013/T014/T015 are gates that must each complete before the next.
- **Phases 4–8**: T016, T018, T020, T022, T024 are all `[P]` — each targets a distinct agent file under `agents/`. These five can be authored truly in parallel by different developers or in a single batched AI run.
- **Phase 9**: T028 and T029 are `[P]` — they read-only-scan the repo and can run concurrently.

---

## Parallel Example: All five agents (after Phase 2 completes)

```bash
# Five agent files — zero shared state, all parallelizable:
Task: "Author agents/dotnet-senior-developer.md per contract"     # T016
Task: "Author agents/frontend-react-developer.md per contract"    # T018
Task: "Author agents/qa-developer.md per contract"                # T020
Task: "Author agents/analyst.md per contract"                     # T022
Task: "Author agents/dotnet-mobile-developer.md per contract"     # T024
```

After all five files land, the five verification tasks (T017, T019, T021, T023, T025) can also run in parallel against their respective files.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (T001).
2. Complete Phase 2 (T002–T007) — canonical folders + caller inventory.
3. Complete Phase 3 (T008–T015) — script relocations + caller updates + verification.
4. **STOP and VALIDATE**: Run `quickstart.md` §1, §4, §5. Repo is constitution-compliant.
5. This is a legitimate MVP — it can be merged and released as a standalone structural PR, with the five agents delivered in a follow-up PR.

### Incremental Delivery

After the MVP, author one agent at a time and validate each independently:

1. T016–T017 — `.NET Senior Developer`
2. T018–T019 — `Frontend React Developer`
3. T020–T021 — `QA Developer`
4. T022–T023 — `Analyst`
5. T024–T025 — `.NET Mobile Developer`

Each agent file is standalone; merging them one-by-one is safe.

### Parallel Team Strategy

With multiple developers (or a batched AI run):

1. One developer completes Phases 1–3 (MVP).
2. Five developers (or five parallel agent invocations) take the five US2–US6 tasks concurrently.
3. One developer runs Phase 9 polish after all agents land.

---

## Notes

- `[P]` tasks target distinct files with no dependencies on incomplete tasks.
- `[Story]` labels map tasks to user stories US1–US6 for traceability.
- Every task includes the exact file path or git command needed to execute it.
- No automated test tasks are included — the spec did not request them and the plan keeps validators deferred per `TODO(VALIDATION_SCRIPTS)` in constitution v2.0.1.
- Verify manually against `contracts/agent-schema.md` and per-agent contracts for every US2–US6 task.
- Commit per phase with conventional-commit prefixes (`feat:`, `fix:`, `docs:`) so GitVersion computes the right release bump.
- Do not skip hooks (`--no-verify`) or force-push; diagnose root cause if a hook fails.
