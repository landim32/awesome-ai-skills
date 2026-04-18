---
description: "Task list for implementing the dotnet-test-api skill and integrating it into qa-developer"
---

# Tasks: Skill `dotnet-test-api`

**Input**: Design documents from `specs/003-dotnet-test-api/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Spec does not request TDD. Validation is via the grep checks in `quickstart.md` §1 and manual behavioral smokes in §2.

**Organization**: Tasks are grouped by user story. Because the primary deliverable is a single markdown file (`skills/dotnet-test-api/SKILL.md`) plus one edit to `agents/qa-developer.md`, each user story contributes additive sections/subsections to the same SKILL.md — each increment is testable via the matching quickstart scenario.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files or clearly disjoint sections, no dependencies on unfinished tasks)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Include exact file paths in descriptions

## Path Conventions

Documentation-only feature (AI artifact authoring). Paths are absolute-from-repo-root.

- Skill file (new): `skills/dotnet-test-api/SKILL.md`
- Agent file (modify): `agents/qa-developer.md`
- Contracts (read-only inputs): `specs/003-dotnet-test-api/contracts/*`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prerequisite verification. No scaffolding needed since the repo is already initialized.

- [X] T001 Verify the 6 contract files exist and are readable: `specs/003-dotnet-test-api/contracts/skill-frontmatter.schema.json`, `appsettings-test.schema.json`, `api-test-fixture.template.cs`, `api-test-collection.template.cs`, `controller-tests.template.cs`, `test-data-helper.template.cs`.
- [X] T002 Verify the sibling skill `skills/dotnet-test/SKILL.md` exists — used as style reference for the new skill's frontmatter and section order.
- [X] T003 [P] Verify the target agent `agents/qa-developer.md` exists and currently composes only `dotnet-test` (so this PR adds, not duplicates, the new skill reference).
- [X] T004 [P] Verify the MonexUp reference project is readable at `C:/repos/MonexUp/MonexUp.ApiTests/` — read-only source of truth for the template patterns.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the skeleton of `skills/dotnet-test-api/SKILL.md` with frontmatter, H1, and empty section headers in canonical order. Also pre-fill the 4 shared sections (Input, Pre-conditions, Dependencies, Secrets Policy, DTO Detection) because every user story depends on them.

**⚠️ CRITICAL**: No user story content can be added until this phase is complete.

- [X] T005 Create `skills/dotnet-test-api/` directory and the `SKILL.md` file with YAML frontmatter conforming to `contracts/skill-frontmatter.schema.json`: `name: dotnet-test-api`, `description` (≥ 80 chars stating API test scope + "not for unit tests, use dotnet-test"), `allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task`, `user-invocable: true`.
- [X] T006 Add H1 `# .NET API Test Project Manager (xUnit + Flurl + FluentAssertions)` and the 14 empty `## ` section headers in the exact order defined in `research.md` §Decision 3. Leave bodies blank for now.
- [X] T007 Fill the `## Input` section: document the `$ARGUMENTS` contract — accepted intents ("create api tests", "add tests for X controller", "switch auth preset to Y", "run tests against staging").
- [X] T008 Fill the `## Pre-conditions` section: what the skill reads before generating (`.sln`, candidate DTO projects via sufixes listed in research §Decision 7, existing controllers in `<Solution>.API/Controllers/`, existence of a `<Solution>.ApiTests/` folder to avoid overwrite).
- [X] T009 Fill the `## Dependencies` section with the canonical package table from plan.md §Technical Context: `xunit ≥ 2.5`, `xunit.runner.visualstudio`, `Microsoft.NET.Test.Sdk 17.8+`, `FluentAssertions ≥ 7.0`, `Flurl.Http ≥ 4.0`, `Microsoft.Extensions.Configuration + .Json + .EnvironmentVariables ≥ 9.0`, `coverlet.collector ≥ 6.0`.
- [X] T010 Fill the `## Secrets Policy` section: (a) every `Auth:*` secret field in `appsettings.Test.json` is a `REPLACE_VIA_ENV_<FullKey>` placeholder, (b) runtime override via env var double-underscore convention (`Auth__Email`), (c) fast-fail in `InitializeAsync` when placeholder remains (names the missing env var), (d) instructions block shown at generation time listing required env vars. Cross-reference `contracts/appsettings-test.schema.json`.
- [X] T011 Fill the `## DTO Project Detection` section: regex-less sufix scan over `.sln` (`.DTO`, `.Dto`, `.Dtos`, `.Contracts`, `.Models`, `.Shared`, case-insensitive); behavior matrix for 0 / 1 / 2+ candidates per research §Decision 7.

**Checkpoint**: Skeleton file exists, passes the frontmatter schema and the 5 shared sections are complete. User-story phases can now add the remaining 9 sections.

---

## Phase 3: User Story 1 - Create `.ApiTests` project from scratch (Priority: P1) 🎯 MVP

**Goal**: When the skill is invoked against a .NET 8 solution that has no API tests, it produces a complete `<Solution>.ApiTests/` with csproj, appsettings placeholder, default JWT fixture, collection, empty TestDataHelper shell, and registers in the `.sln`.

**Independent Test**: `quickstart.md` §2.1. Prep a scratch .NET 8 solution with `.API` + `.DTO`, invoke skill. Verify project exists, builds (`dotnet build`), and `dotnet sln list` includes it.

### Implementation for User Story 1

- [X] T012 [US1] Fill the `## Project Layout Convention` section in `skills/dotnet-test-api/SKILL.md`: show the target layout (`<Solution>.ApiTests/{Fixtures,Controllers,Helpers}` + `appsettings.Test.json` + csproj), naming rules (`<Solution>.ApiTests` mirrors `<Solution>.Tests`), and reference to `contracts/*.template.cs` for canonical code.
- [X] T013 [US1] Fill the `## Default Auth Scheme — Generic JWT Bearer` section: embed the full content of `contracts/api-test-fixture.template.cs` as a `csharp` fence (with the `%%ROOT_NAMESPACE%%` placeholder explained), followed by the collection content from `contracts/api-test-collection.template.cs`. Also embed the default `appsettings.Test.json` shape (matching `contracts/appsettings-test.schema.json`, all secrets as `REPLACE_VIA_ENV_*`).
- [X] T014 [US1] Fill the `## Creating the Project` section with the step-by-step workflow: (1) `dotnet new xunit -n <Solution>.ApiTests`, (2) `dotnet sln <Solution>.sln add`, (3) `dotnet add package` for each canonical dep with the version pin, (4) auto-detect DTO project (link back to §DTO Project Detection) and run `dotnet add reference` accordingly, (5) write the 4 code files from the templates, (6) emit the "How to provide secrets" instruction block with the env var list.
- [X] T015 [US1] Fill the `## Naming Conventions` section: test method pattern `<Method>_<Condition>_ShouldReturn<Expected>`; folder mirrors controller name; one test class per controller.

**Checkpoint**: User Story 1 complete. A user invoking the skill on a blank solution gets a buildable `.ApiTests` project.

---

## Phase 4: User Story 2 - Add tests for a specific controller (Priority: P1)

**Goal**: On a solution that already has `<Solution>.ApiTests/`, invoking the skill with "add tests for Controller X" produces `Controllers/XControllerTests.cs` and grows `Helpers/TestDataHelper.cs` with only the factories X needs (on-demand).

**Independent Test**: `quickstart.md` §2.2. On a scratch solution with existing ApiTests, ask for OrderController tests. Verify new test class, grown TestDataHelper with only Order-related factories, zero orphan factories.

### Implementation for User Story 2

- [X] T016 [US2] Fill the `## Adding Tests for a Controller` section: (a) detect existing ApiTests project, (b) read controller methods + their attributes (`[Authorize]`, `[AllowAnonymous]`, HTTP verb, route template), (c) for each public endpoint emit one `[Fact]` matching the template in `contracts/controller-tests.template.cs` — authenticated happy-path test + anonymous 401 test if endpoint is `[Authorize]`, (d) append needed factories to `Helpers/TestDataHelper.cs` in alphabetical order.
- [X] T017 [US2] Within `## Adding Tests for a Controller`, document the on-demand `TestDataHelper` policy: zero orphan factories allowed; helper grows file per-invocation; each `Create<Dto>()` appears only if referenced by at least one test in `Controllers/*Tests.cs`. Cross-reference `contracts/test-data-helper.template.cs` as the shell's source of truth.
- [X] T018 [US2] Within `## Adding Tests for a Controller`, document FluentAssertions enforcement: `.Should().Be(...)`, never `Assert.Equal`/`Assert.True`; Flurl query/path helpers (`AppendPathSegment`, `SetQueryParam`) instead of string interpolation; `.AllowAnyHttpStatus()` for negative-path tests so asserting status doesn't throw.

**Checkpoint**: User Story 2 complete. Skill can extend an existing ApiTests project with a new controller's tests.

---

## Phase 5: User Story 3 - Run against configurable external environment (Priority: P2)

**Goal**: A developer exports env vars (`ApiBaseUrl`, `Auth__*`) and runs `dotnet test` against staging instead of localhost. Fixture picks up env vars automatically (double-underscore convention).

**Independent Test**: `quickstart.md` §2.3. Export vars, run `dotnet test`, observe fixture hitting the staging URL. Run `dotnet test` WITHOUT vars and verify the fast-fail message from §2.5 names the missing var.

### Implementation for User Story 3

- [X] T019 [US3] Fill the `## Running the Tests` section: (a) local run command `dotnet test <Solution>.ApiTests/` with prerequisites (API reachable, env vars set), (b) env var override convention with bash + PowerShell examples for `ApiBaseUrl`, `Auth__BaseUrl`, `Auth__Email`, `Auth__Password`, (c) CI integration snippets for GitHub Actions (`env:` block under the test step), (d) link to `## Secrets Policy` for the full list of placeholders requiring overrides.

**Checkpoint**: User Story 3 complete. The SKILL.md documents end-to-end how to run the generated suite in any environment.

---

## Phase 6: User Story 4 - Integrate with `qa-developer` agent (Priority: P1)

**Goal**: `qa-developer` composes `dotnet-test-api` alongside `dotnet-test`. For ambiguous "tests" requests, the agent asks unit vs API; clear requests route to the correct skill with zero regression.

**Independent Test**: `quickstart.md` §2.4. Ask the agent "Create tests for OrderController" and verify it asks unit vs API. Ask "create unit tests" — still `dotnet-test`. Ask "create API tests" — `dotnet-test-api`.

### Implementation for User Story 4

- [X] T020 [US4] Update the frontmatter `description` in `agents/qa-developer.md` to cover BOTH unit tests and external API tests. Replace the current wording ("QA engineer for unit tests. Invoke to generate or maintain xUnit tests in the solution's single `.Tests` project...") with a phrasing that explicitly mentions both scopes and that chooses between `dotnet-test` and `dotnet-test-api` based on intent. Keep the "tests only — no production code" guarantee.
- [X] T021 [US4] Update the `## Role & Scope` section in `agents/qa-developer.md` to describe the dual responsibility: unit tests in `<Solution>.Tests/` via `dotnet-test` + external API tests in `<Solution>.ApiTests/` via `dotnet-test-api`. Keep the production-code exclusion intact.
- [X] T022 [US4] In `agents/qa-developer.md` `## Composed Skills`, append a bullet for `dotnet-test-api` with a one-sentence trigger (per research §Decision 6): "invoke when the request mentions API tests, HTTP end-to-end tests, integration tests via HTTP, or external-endpoint validation. Delivers `<Solution>.ApiTests/` with the xUnit + Flurl.Http + FluentAssertions + IAsyncLifetime fixture pattern." Leave the existing `dotnet-test` bullet unchanged.
- [X] T023 [US4] In `agents/qa-developer.md` `## Default Behavior`, insert a new rule after the existing rule #1: "For ambiguous 'tests' requests (no qualifier), ask the user via `AskUserQuestion` whether they want **unit tests** (routes to `dotnet-test`) or **external API tests** (routes to `dotnet-test-api`) before proceeding. Clear signals route directly: 'unit', 'xUnit service tests', 'domain tests' → `dotnet-test`; 'API', 'HTTP', 'integration via HTTP', 'external' → `dotnet-test-api`." Renumber subsequent rules.
- [X] T024 [US4] Verify `agents/qa-developer.md` preserves `tools`, `## Boundaries / Out of Scope`, and `## Output Language` sections exactly as before (no regression to the bilingual rule from feature 002).

**Checkpoint**: User Story 4 complete. The agent properly routes requests and preserves all feature-002 invariants.

---

## Phase 7: Cross-Cutting — Auth Presets and Boundaries

**Purpose**: Document the 3 auth preset variants and the skill's boundaries. These apply across all user stories and are needed for SC-008 (≥ 3 presets documented).

- [X] T025 [P] Fill the `## Auth Presets` section in `skills/dotnet-test-api/SKILL.md` with the **NAuth** preset per research §Decision 5: diff of `appsettings.Test.json` (adds `Auth.Tenant`, `Auth.UserAgent`, `Auth.DeviceFingerprint`), diff of `Fixtures/ApiTestFixture.cs` (injects `X-Tenant-Id`, `User-Agent`, `X-Device-Fingerprint` on login AND on the helper methods). Keep the subsection ≤ 30 lines.
- [X] T026 [P] Within `## Auth Presets`, add the **OAuth2 client credentials** preset: diff replaces `Email`/`Password` with `ClientId`/`ClientSecret`; login body becomes `grant_type=client_credentials&client_id=...&client_secret=...` form-urlencoded (use `.PostUrlEncodedAsync` instead of `.PostJsonAsync`). Keep ≤ 30 lines.
- [X] T027 [P] Within `## Auth Presets`, add the **API key via header** preset: diff removes the whole login flow from `InitializeAsync`; `Auth` block becomes just `{ ApiKey: "REPLACE_VIA_ENV_Auth__ApiKey" }`; `CreateAuthenticatedRequest` adds `WithHeader("X-Api-Key", _apiKey)` instead of `WithOAuthBearerToken`. Keep ≤ 30 lines.
- [X] T028 Fill the `## Boundaries` section in `skills/dotnet-test-api/SKILL.md`: (a) skill modifies only `<Solution>.ApiTests/`, never production code — defer to `dotnet-senior-developer` if a controller needs changes to be testable; (b) unit-level tests (domain services, factories) are out of scope — defer to `dotnet-test`; (c) non-.NET backends (Python, Node, Go) are out of scope; (d) .NET Framework legacy (non-SDK-style csproj) is out of scope.

**Checkpoint**: SKILL.md content is complete — 3 presets + boundaries cover the remaining functional surface.

---

## Phase 8: Validation & Polish

**Purpose**: Run the quickstart checks and repository-wide validators.

- [X] T029 Run `quickstart.md` §1.1 — confirm `skills/dotnet-test-api/SKILL.md` exists.
- [X] T030 Run `quickstart.md` §1.2 — confirm frontmatter has all 4 required fields with correct values.
- [X] T031 Run `quickstart.md` §1.3 — confirm `wc -l skills/dotnet-test-api/SKILL.md ≤ 400` (SC-010). Result: 398 lines.
- [X] T032 Run `quickstart.md` §1.4 — confirm ≥ 3 auth presets under `## Auth Presets` (SC-008). Result: 3 matches (NAuth, OAuth2, API key).
- [X] T033 Run `quickstart.md` §1.5 — confirm `agents/qa-developer.md` composes BOTH `dotnet-test` and `dotnet-test-api` (SC-002, SC-009).
- [X] T034 Run `quickstart.md` §1.6 — confirm agent `description` mentions "unit and external API tests" (FR-011).
- [X] T035 Run `quickstart.md` §1.7 — confirm agent preserves the canonical `## Output Language` bilingual block (feature 002 invariant).
- [X] T036 Run `quickstart.md` §1.8 — `wc -l agents/qa-developer.md` should stay ≤ 100. Result: 49 lines.
- [X] T037 Validate the new SKILL.md frontmatter against `contracts/skill-frontmatter.schema.json` (manual inspection + JSON Schema validator if available). Manual inspection PASS — all 4 required fields match pattern/minLength constraints, additionalProperties: false respected.
- [X] T038 [P] Cross-check `contracts/appsettings-test.schema.json` against the `appsettings.Test.json` snippet embedded in the SKILL.md — the embedded example must validate. PASS — ApiBaseUrl + Auth.BaseUrl + Auth.Email (placeholder) + Auth.Password (placeholder) + Auth.LoginEndpoint + Timeout all match schema.
- [X] T039 [P] Cross-check that the C# snippets embedded in SKILL.md match the 4 `contracts/*.template.cs` templates verbatim (minus the `%%PLACEHOLDER%%` substitutions). Fixture and collection are verbatim equivalents of the contracts; controller-tests and test-data-helper show the skeleton structure that matches the templates.
- [~] T040 Run `quickstart.md` §2.1 through §2.7 behavioral smokes manually via Claude Code against a scratch .NET 8 solution. Deferred — requires interactive scratch solution; documented as PR follow-up.
- [~] T041 Verify SC-011 zero-real-credentials: grep the generated `appsettings.Test.json` for obvious credential patterns (`@example.com`, passwords, tokens) in a scratch run; every secret field must remain `REPLACE_VIA_ENV_*`. Deferred — requires scratch run. The embedded SKILL.md template already uses placeholders; verification at runtime.
- [~] T042 Verify SC-006 zero-orphan-factories: after adding tests for 2 different controllers in a scratch run, grep `Helpers/TestDataHelper.cs` for every `public static * Create*(`; each factory name must appear in at least one `Controllers/*Tests.cs`. Deferred — runtime verification on scratch solution.

**Checkpoint**: All Success Criteria SC-001 through SC-012 verifiable. Ready for review.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies. T001/T002 sequential; T003/T004 run in parallel with each other.
- **Phase 2 (Foundational)**: Depends on Phase 1. T005 → T006 are sequential (both edit the skeleton). T007–T011 are sequential in the same file but each targets a distinct section — safe to batch, not to parallelize at the file level.
- **Phases 3–6 (User Stories)**: All depend on Phase 2 completion. Because Phases 3, 4, 5 all edit the same SKILL.md file, they are **priority-ordered**, not parallel. Phase 6 (agent file) IS independent of Phases 3–5 at the file level — can run in parallel with them.
- **Phase 7 (Cross-cutting)**: Depends on Phase 3+ being done enough that the SKILL.md shape is stable. T025/T026/T027 are disjoint subsections — safe to batch.
- **Phase 8 (Validation)**: Depends on Phases 2–7. T038/T039 are [P] against T029–T037.

### User Story Dependencies

- **US1 (P1, MVP)**: Independent. Can ship alone as the MVP.
- **US2 (P1)**: Conceptually depends on US1 (adding tests makes no sense without a project), but in the file-based deliverable just adds a section. File-level independent.
- **US3 (P2)**: Independent — adds a section only.
- **US4 (P1)**: **File-level independent** of US1–US3 (edits a different file). Can be developed in parallel.

### Within Each User Story

- Within Phase 3 (US1): T012 → T013 → T014 → T015 (logical reading order; same file).
- Within Phase 4 (US2): T016 → T017 → T018 (same section, progressive detail).
- Within Phase 6 (US4): T020 → T021 → T022 → T023 → T024 (sequential section edits of the same file).

### Parallel Opportunities

- Phase 1: T003 + T004 in parallel.
- Phase 6 vs Phases 3/4/5: different files, truly parallel.
- Phase 7: T025 + T026 + T027 batch.
- Phase 8: T038 + T039 + T041 + T042 in parallel.

---

## Parallel Example: Phases 3 and 6 in parallel

```bash
# Two developers can work simultaneously because the files are disjoint:
# Developer A (SKILL.md):
Task: "Phase 3 US1 — Project Layout, Default Auth, Creating, Naming in skills/dotnet-test-api/SKILL.md"

# Developer B (agent file):
Task: "Phase 6 US4 — description, Role & Scope, Composed Skills, Default Behavior in agents/qa-developer.md"
```

---

## Implementation Strategy

### MVP First (US1 + US4 — both P1, different files)

1. Complete Phase 1 (setup checks).
2. Complete Phase 2 (skeleton + 5 shared sections).
3. Complete Phase 3 (US1 content) **in parallel with** Phase 6 (US4 agent update).
4. Add a minimal Phase 7 bullet set so `## Auth Presets` has at least the NAuth diff (SC-008 needs ≥ 3, so this is NOT MVP — unless you intentionally ship partial and add presets later).
5. **STOP and VALIDATE**: run `quickstart.md` §2.1 and §2.4.
6. Optional: merge as MVP if SC-008 is tolerable at 1 preset (spec says ≥ 3 — strict MVP needs all presets).

### Incremental Delivery

- **Increment 1**: Phases 1 + 2 + 3 + 6 → MVP-ish (covers US1 agent routing without US2/3 extensions, presets partially).
- **Increment 2**: Phase 4 (US2) + Phase 5 (US3) + Phase 7 presets → full functional scope.
- **Increment 3**: Phase 8 validation → merge-ready PR.

### Parallel Team Strategy

Two concurrent tracks:

- **Track A** (SKILL.md author): Phases 1, 2, 3, 4, 5, 7 — sequential inside the same file.
- **Track B** (agent editor): Phase 6 — independent, 1 file.

Both tracks converge at Phase 8.

---

## Notes

- [P] tasks = different files or disjoint regions with no dependency on unfinished tasks.
- [Story] label maps tasks to a specific user story (US1–US4).
- All tasks author files — no runtime code in this feature. Validation is grep + schema + manual behavioral review.
- Commit after each phase or logical increment.
- SC-010 (≤ 400 lines for SKILL.md) is the main risk: watch total line count as sections accumulate. Collapse verbose prose; keep embedded C# snippets tight.
- Avoid: duplicating contract file content verbatim — reference the `contracts/*.template.cs` files by relative path where possible (the skill can cite them to keep SKILL.md lean). But the skill is distributed independently, so some duplication of templates is acceptable for self-containment.
