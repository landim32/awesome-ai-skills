# Feature Specification: Repository Restructure and Role-Based Agent Creation

**Feature Branch**: `001-repo-restructure-agents`
**Created**: 2026-04-17
**Last Updated**: 2026-04-17 (amended to add .NET Mobile Developer agent)
**Status**: Draft
**Input**: User description:
- Reorganize repository files to comply with the constitution.
- Create agents based on existing skills:
  - **.NET Senior Developer** — behavior grounded in the `dotnet-*` skills
    (backend/web scope).
  - **.NET Mobile Developer** — behavior grounded in the `maui-architecture`
    skill plus the shared backend `dotnet-*` skills, covering mobile apps
    (MAUI).
  - **Frontend React Developer** — behavior grounded in the `react-*` and
    `frontend-design` skills.
  - **QA Developer** — behavior grounded in the testing skills.
  - **Analyst** — the agent responsible for authoring all project
    documentation.

## Clarifications

### Session 2026-04-17

- Q: What is the canonical filename and layout for agent definitions inside
  `agents/`? → A: Use the Claude Code convention. Agents are **flat
  single-file Markdown definitions** directly under `agents/` — one
  `<agent-name>.md` file per agent, no per-agent subfolder. YAML frontmatter
  follows Claude Code's agent schema (`name`, `description`, optional
  `tools`, optional `model`). This supersedes the folder-per-agent layout
  described in constitution v2.0.0 Principle V §Agents; Principle V MUST be
  amended (PATCH-level) before this feature merges.
- Q: Which YAML frontmatter fields are mandatory in every agent definition?
  → A: `name`, `description`, and `tools` are MANDATORY. `model` is
  OPTIONAL (agents inherit the orchestrator's model unless they specify
  otherwise). The `tools` field MUST be an explicit comma-separated list
  (or equivalent YAML list) — no agent may implicitly inherit all tools.
- Q: What deferral behavior must every agent express when it receives a
  request outside its scope (including cross-stack requests)? → A: **Name
  the correct sibling agent and stop.** The agent MUST declare the request
  out of scope, name the specific sibling agent that owns the scope (e.g.,
  "this is a backend/web task — use `dotnet-senior-developer`"), and
  return without executing the work. No active handoff via the Task tool
  is required, and no split-and-execute behavior is allowed. For
  multi-stack requests, the agent names every sibling that owns a slice.
- Q: What is the Analyst agent's default output language? → A: **PT-BR by
  default**, aligned with the repo's `CLAUDE.md` directive. The Analyst
  emits EN only when the user explicitly asks for it (or writes the
  request in EN). Default filenames therefore use the `.pt-BR.md` suffix
  per the constitution's bilingual convention; the unsuffixed `.md` form
  is reserved for EN output. The Analyst MUST NOT produce bilingual pairs
  unless the user explicitly requests both.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Repository complies with the constitution (Priority: P1)

As a maintainer of this AI-artifacts repository, I want the top-level layout to
match the canonical structure declared in the constitution so that automated
validators pass, contributors can locate any artifact deterministically, and
new agents have a well-defined home to live in.

**Why this priority**: The constitution (Principle II) forbids unauthorized
top-level folders and Principle V requires kebab-case and metadata discipline.
Nothing else in this feature — including agent creation — can be validated
cleanly until the repository layout is compliant. This is the MVP foundation.

**Independent Test**: Running a structure scan against the repo root returns
only the eight canonical folders (`rules/`, `skills/`, `agents/`,
`commands/`, `docs/`, `prompts/`, `scripts/`, `workflows/`) plus tooling
dotfolders and permitted root files. All previous non-compliant content has
a documented new home.

**Acceptance Scenarios**:

1. **Given** the repo currently has loose `*.ps1` files at the root, **When**
   the reorganization is complete, **Then** those files live under
   `scripts/` with every caller reference updated.
2. **Given** the constitution (v2.0.0) declares eight canonical folders,
   **When** a structure validator runs, **Then** every content folder at
   the repo root is one of those eight, ignoring tooling dotfolders
   (`.github`, `.claude`, `.specify`, `.git`) and Spec Kit's `specs/`
   working directory.
3. **Given** no `rules/`, `agents/`, `commands/`, `docs/`, or `scripts/`
   folders exist yet, **When** the reorganization is complete, **Then** each
   of those folders exists with at least a placeholder `README.md` so the
   canonical structure is concretely present.
4. **Given** `skills/`, `prompts/`, and `workflows/` already contain
   content, **When** the reorganization is complete, **Then** no content
   is lost or relocated out of those folders and every existing
   subfolder/file remains intact.

---

### User Story 2 - .NET Senior Developer agent available (Priority: P2)

As a developer working on **backend/web** tickets, I want to invoke a
`dotnet-senior-developer` agent that already understands the project's Clean
Architecture conventions, EF Core usage, validation, multi-tenant patterns,
and environment configuration so that I get expert-level backend output
without having to cherry-pick individual skills. Mobile/MAUI concerns are
explicitly out of this agent's scope and belong to the
`dotnet-mobile-developer` agent (User Story 6).

**Why this priority**: The .NET/C# stack is the canonical backend stack
(Principle IV). This agent collapses multiple existing skills into a single
coherent role and delivers the highest immediate value to backend work.

**Independent Test**: Opening `agents/dotnet-senior-developer.md` shows a
compliant definition file whose description declares its role, scope, and
boundaries, and whose behavior explicitly delegates to (or composes) the
`dotnet-architecture`, `dotnet-doc-controller`, `dotnet-env`,
`dotnet-fluent-validation`, `dotnet-graphql`, `dotnet-multi-tenant`, and
`dotnet-test` skills. Invoking the agent for a sample backend task
(e.g., "add a new entity with repository and service") produces output
aligned with those skills.

**Acceptance Scenarios**:

1. **Given** the `agents/` folder exists, **When** the agent definition is
   created, **Then** it lives at `agents/dotnet-senior-developer.md` with a
   definition file containing required frontmatter (`name`, `description`,
   role, tools, boundaries).
2. **Given** the `dotnet-*` skills already exist under `skills/`, **When** the
   agent is invoked, **Then** the agent references those skills by name and
   does not duplicate their content.
3. **Given** the agent receives a non-.NET request, **When** it responds,
   **Then** it clearly declares the request is out of scope and defers to
   another agent or to the human.
4. **Given** the canonical stack is PostgreSQL/RabbitMQ/Redis/Elasticsearch,
   **When** the agent is asked to pick defaults, **Then** those technologies
   are preferred over alternatives.

---

### User Story 3 - Frontend React Developer agent available (Priority: P2)

As a developer working on frontend tickets, I want to invoke a
`frontend-react-developer` agent that understands the project's React +
TypeScript architecture conventions and the team's design aesthetic so that
I get frontend output that matches both structural and visual standards.

**Why this priority**: React + TypeScript is the canonical frontend stack
(Principle IV). A unified frontend agent shortens the path from ticket to
aligned implementation.

**Independent Test**: Opening `agents/frontend-react-developer.md` shows a
compliant definition file whose behavior composes the `react-architecture`,
`react-arch`, `react-alert`, `react-modal`, `add-react-i18n`, and
`frontend-design` skills. A sample request (e.g., "scaffold a new entity
module") produces output that follows the types/service/context/hook pattern
declared in `react-architecture`.

**Acceptance Scenarios**:

1. **Given** the `agents/` folder exists, **When** the agent definition is
   created, **Then** it lives at `agents/frontend-react-developer.md` with
   compliant frontmatter.
2. **Given** a scaffolding request, **When** the agent responds, **Then** it
   follows the creation order and rules defined in `react-architecture`
   (types → service → context → hook → provider registration) and cites the
   composed skills.
3. **Given** a visual design request, **When** the agent responds, **Then**
   the aesthetic guidance comes from the `frontend-design` skill and avoids
   generic AI-slop defaults.
4. **Given** an i18n or modal/alert request, **When** the agent responds,
   **Then** it delegates to the matching specialized skill rather than
   reinventing its patterns.

---

### User Story 4 - QA Developer agent available (Priority: P2)

As a developer who needs test coverage, I want to invoke a `qa-developer`
agent that generates and maintains unit tests following the project's xUnit
conventions so that tests match the rest of the codebase in structure and
quality.

**Why this priority**: Testing is explicitly scoped to a dedicated skill
(`dotnet-test`). Turning that skill into an agent role lets testing be
parallelized alongside backend and frontend work without requiring each
developer to load test conventions manually.

**Independent Test**: Opening `agents/qa-developer.md` shows a compliant
definition file whose behavior is grounded in `dotnet-test` (and any future
test skills). A request for unit-test generation on a sample class produces
tests that follow the xUnit project-and-folder conventions declared in the
skill.

**Acceptance Scenarios**:

1. **Given** the `agents/` folder exists, **When** the agent definition is
   created, **Then** it lives at `agents/qa-developer.md` with compliant
   frontmatter.
2. **Given** a class under any layer (Domain, Application, Infra, API),
   **When** the agent generates tests, **Then** the output lives under the
   `.Tests` project and mirrors the source folder structure.
3. **Given** the agent is asked to write non-test code, **When** it responds,
   **Then** it declares the request out of scope and defers.
4. **Given** future test skills are added to `skills/`, **When** the agent
   is re-read, **Then** it can incorporate them by skill name without
   structural changes to the agent definition.

---

### User Story 5 - Analyst agent authors project documentation (Priority: P2)

As a maintainer who needs docs, READMEs, and diagrams produced consistently,
I want to invoke an `analyst` agent that owns documentation authorship so
that all human-facing documentation in this repository follows a single,
coherent standard.

**Why this priority**: Documentation is the one deliverable that cuts across
every other agent's work. Making it a dedicated role prevents docs from
being an afterthought attached to each developer agent.

**Independent Test**: Opening `agents/analyst.md` shows a compliant definition
file whose behavior composes `doc-manager`, `readme-generator`, and
`mermaid-chart`. A request like "write a deployment guide" produces a
document saved in `docs/` using the file-naming conventions declared by
`doc-manager`, with diagrams generated via `mermaid-chart` when helpful.

**Acceptance Scenarios**:

1. **Given** the `agents/` folder exists, **When** the agent definition is
   created, **Then** it lives at `agents/analyst.md` with compliant
   frontmatter.
2. **Given** a request to create a new document, **When** the agent
   responds, **Then** the document is placed in `docs/` using the naming
   convention of `doc-manager`.
3. **Given** a request to generate a README, **When** the agent responds,
   **Then** it follows the template enforced by `readme-generator`.
4. **Given** a document benefits from a diagram, **When** the agent responds,
   **Then** it emits a mermaid diagram per the `mermaid-chart` skill rather
   than embedding an image or ASCII art.
5. **Given** `docs/` is a bilingual folder per Principle III and the
   Analyst's default language is PT-BR, **When** the agent is invoked
   without an explicit language request, **Then** the document is written
   in PT-BR and the filename uses the `.pt-BR.md` suffix, while code
   identifiers and technical keywords remain in English.
6. **Given** the user explicitly asks for English output (or writes the
   request in English), **When** the agent authors the document, **Then**
   the document is written in EN and the filename uses the unsuffixed
   `.md` form; no PT-BR counterpart is produced unless explicitly
   requested.

---

### User Story 6 - .NET Mobile Developer agent available (Priority: P2)

As a developer working on **mobile** tickets, I want to invoke a
`dotnet-mobile-developer` agent that understands the project's MAUI
presentation-layer conventions (SQLite model attributes, AutoMapper
profiles, ViewModels using CommunityToolkit.Mvvm, XAML Pages, Shell
navigation, MauiProgram DI, APK build pipeline) plus the shared backend
Clean Architecture layers so that mobile work stays consistent with the
rest of the stack without overloading the web/backend agent.

**Why this priority**: Mobile apps reuse the backend layers defined by
`dotnet-architecture` but add a distinct presentation layer covered
exclusively by `maui-architecture`. A dedicated agent prevents .NET Senior
Developer from conflating web and mobile concerns and keeps MAUI-specific
output (XAML, ViewModels, Shell) coherent.

**Independent Test**: Opening `agents/dotnet-mobile-developer.md` shows a
compliant definition file whose behavior composes `maui-architecture` as
the primary skill and references the shared backend skills
(`dotnet-architecture`, `dotnet-fluent-validation`, `dotnet-env`,
`dotnet-test`) for cross-cutting backend layers. Invoking the agent for a
sample mobile task (e.g., "add an entity end-to-end to the mobile app")
produces output that follows the MAUI presentation layer conventions
declared in `maui-architecture`.

**Acceptance Scenarios**:

1. **Given** the `agents/` folder exists, **When** the agent definition is
   created, **Then** it lives at `agents/dotnet-mobile-developer.md` with
   compliant frontmatter that declares mobile/MAUI as its role.
2. **Given** a mobile entity scaffolding request, **When** the agent
   responds, **Then** it follows the MAUI layer coverage declared by
   `maui-architecture` (SQLite model → Mapper/AutoMapper profile →
   AppDatabase registration → ViewModel → XAML Page → Shell route →
   MauiProgram DI).
3. **Given** the backend layers (DTO, Domain, Infra.Interfaces, Infra,
   Application) are not yet in place for the entity, **When** the agent
   responds, **Then** it first invokes (or cites) `dotnet-architecture` for
   those layers before producing MAUI-specific artifacts.
4. **Given** a pure backend/web request (e.g., "create a GraphQL endpoint"),
   **When** the agent responds, **Then** it declares the request out of
   scope and defers to `dotnet-senior-developer`.
5. **Given** a mobile CI/build request, **When** the agent responds, **Then**
   it references the reusable APK build pipeline under `workflows/`
   (e.g., `build-apk.yml`) rather than inventing a new pipeline.
6. **Given** a request for MAUI unit tests, **When** the agent responds,
   **Then** it delegates to `dotnet-test` for project structure and naming
   conventions and does not duplicate test-skill content.

---

### Edge Cases

- **`workflows/` was promoted to a canonical folder in constitution v2.0.0.**
  It stays at the repo root and is no longer relocated. Any callers under
  `.github/workflows/` continue to resolve unchanged. New pipeline
  templates added here MUST satisfy Principle V (reusable via
  `workflow_call`, explicit inputs/outputs/secrets, English-only).
- **Loose `*.ps1` files at the repo root** (`collect-skills.ps1`,
  `copy-dependency.ps1`, `push-skill.ps1`, `replace-skill.ps1`) — every
  caller, documentation reference, and `CLAUDE.md` example path must be
  updated when these files move to `scripts/`.
- **Skills with PT-BR content** — `skills/` is an English-only folder per
  Principle III. If any existing skill carries PT-BR content, it is flagged
  but left in place for this feature; cleanup is out of scope for this spec.
- **Shared skill ownership** — if a skill is relevant to more than one agent
  (e.g., `dotnet-test` used by both QA and .NET Senior Developer), each
  agent may reference it without duplication.
- **Missing skill coverage** — if an agent's declared role implies a
  behavior that no existing skill covers, the agent definition MUST
  explicitly call out the gap rather than inventing behavior.
- **Spec Kit's `specs/` folder and `.specify/` metadata** — these are tool
  scaffolding from Spec Kit and are treated as out-of-scope for constitution
  structural validation.

## Requirements *(mandatory)*

### Functional Requirements

#### Repository reorganization

- **FR-001**: The repository root MUST contain only the eight canonical
  content folders declared by the constitution (v2.0.0): `rules/`,
  `skills/`, `agents/`, `commands/`, `docs/`, `prompts/`, `scripts/`,
  `workflows/`. Tooling dotfolders (`.github/`, `.claude/`, `.specify/`,
  `.git/`) and the Spec Kit working folder (`specs/`) are explicitly
  exempt from this check.
- **FR-002**: All loose PowerShell utility scripts currently at the repo
  root (`collect-skills.ps1`, `copy-dependency.ps1`, `push-skill.ps1`,
  `replace-skill.ps1`) MUST be relocated under `scripts/`, and every
  documentation or automation reference to them MUST be updated.
- **FR-003**: The existing top-level `workflows/` folder MUST remain at
  the repo root (it is now canonical per constitution v2.0.0). No content
  MUST be moved out of it by this feature, and any existing caller under
  `.github/workflows/` MUST continue to resolve.
- **FR-004**: Each newly created canonical folder (`rules/`, `agents/`,
  `commands/`, `docs/`, `scripts/`) MUST contain at minimum a `README.md`
  describing its purpose, so the folder structure is concretely present.
  `workflows/` already exists with content and is exempt from this rule.
- **FR-005**: No existing content under `skills/`, `prompts/`, or
  `workflows/` MUST be lost or moved as part of this reorganization.
- **FR-006**: All filenames and folder names introduced by this feature MUST
  use `kebab-case` (Principle V).
- **FR-007**: All content introduced by this feature inside `rules/`,
  `skills/`, `agents/`, `commands/`, and `scripts/` MUST be in English only
  (Principle III).

#### Agents

- **FR-008**: Each of the five agents MUST live as a single Markdown file
  directly under `agents/`, named `<agent-name>.md` (kebab-case), following
  the Claude Code native agent convention. No per-agent subfolder is used.
  Agent files MUST be:
  `agents/dotnet-senior-developer.md`, `agents/dotnet-mobile-developer.md`,
  `agents/frontend-react-developer.md`, `agents/qa-developer.md`,
  `agents/analyst.md`.
- **FR-009**: Each agent definition file MUST carry YAML frontmatter with
  these MANDATORY fields: `name` (kebab-case, matching filename), a
  `description` that clearly states trigger conditions, and `tools` as an
  explicit comma-separated (or YAML list) allowlist — no agent may
  implicitly inherit all tools. `model` is OPTIONAL. Role/scope MUST be
  stated in the body of the definition.
- **FR-010**: Each agent description MUST state the conditions under which
  it is invoked clearly enough to support automated routing.
- **FR-011**: Each agent MUST enumerate the existing skills it composes,
  referencing them by skill folder name, and MUST NOT duplicate the
  content of those skills.
- **FR-012**: The **.NET Senior Developer** agent MUST compose these
  existing skills: `dotnet-architecture`, `dotnet-doc-controller`,
  `dotnet-env`, `dotnet-fluent-validation`, `dotnet-graphql`,
  `dotnet-multi-tenant`, and `dotnet-test`. Its scope is backend/web; MAUI
  and mobile-specific concerns are out of scope and belong to the
  `dotnet-mobile-developer` agent (FR-012b).
- **FR-012b**: The **.NET Mobile Developer** agent MUST compose
  `maui-architecture` as its primary skill and MUST reference these shared
  backend skills for cross-cutting layers: `dotnet-architecture`,
  `dotnet-fluent-validation`, `dotnet-env`, and `dotnet-test`. Backend/web
  concerns that do not touch the mobile presentation layer are out of
  scope and belong to the `dotnet-senior-developer` agent.
- **FR-013**: The **Frontend React Developer** agent MUST compose these
  existing skills: `react-architecture`, `react-arch`, `react-alert`,
  `react-modal`, `add-react-i18n`, and `frontend-design`.
- **FR-014**: The **QA Developer** agent MUST compose the `dotnet-test`
  skill and MUST be designed to absorb additional test skills as they are
  added to `skills/` without structural changes to its definition.
- **FR-015**: The **Analyst** agent MUST compose these existing skills:
  `doc-manager`, `readme-generator`, and `mermaid-chart`. It is the only
  agent authorized to author files in `docs/`. Its default output
  language is **PT-BR** (aligned with the repo's `CLAUDE.md`); EN output
  is produced only when the user explicitly requests it or writes the
  request in EN. Default filenames therefore use the `.pt-BR.md` suffix
  per Principle III; the unsuffixed `.md` form is reserved for EN
  output. The Analyst MUST NOT produce bilingual pairs unless the user
  explicitly requests both.
- **FR-016**: Each agent definition MUST declare explicit out-of-scope
  behavior as "name-and-stop": when asked for work outside its role, the
  agent MUST (a) state that the request is out of scope, (b) name the
  specific sibling agent (by its `name` field) that owns the scope, and
  (c) return without executing the work. For multi-stack requests, the
  agent MUST name every sibling that owns a slice of the request. No
  active handoff via the Task tool and no split-and-execute behavior is
  allowed.
- **FR-017**: When the canonical technology stack (Principle IV) offers a
  default, agents MUST prefer it over alternatives unless the user
  explicitly requests otherwise.
- **FR-018**: The **.NET Mobile Developer** agent MUST reference the
  reusable mobile build pipeline under `workflows/` (currently
  `build-apk.yml`) when asked about mobile CI and MUST NOT inline or
  reinvent the pipeline.

### Key Entities

- **Agent Definition** — A single self-contained Markdown file at
  `agents/<agent-name>.md` (Claude Code convention) carrying YAML
  frontmatter. Frontmatter attributes: `name` (kebab-case), `description`
  (trigger conditions), optional `tools` (comma-separated), optional
  `model`. Body describes role, composed-skills (by reference), and
  boundaries (out-of-scope statement).
- **Skill Reference** — A pointer from an agent to an existing skill by
  folder name under `skills/`. Agents compose skills by reference; they
  never inline skill content.
- **Canonical Folder Layout** — The eight top-level content folders
  declared by Principle II of the constitution (v2.0.0): `rules/`,
  `skills/`, `agents/`, `commands/`, `docs/`, `prompts/`, `scripts/`,
  `workflows/`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A structure validator run against the repo root reports zero
  unauthorized top-level content folders (exempting the tooling dotfolders
  and Spec Kit's `specs/`).
- **SC-002**: 100% of the files previously at the repo root that were
  non-compliant (the loose `*.ps1` utilities) are reachable at their new
  canonical location under `scripts/`, with no broken references in
  `README.md`, `CLAUDE.md`, or `.github/workflows/`. `workflows/` itself
  is unchanged.
- **SC-003**: All five required agents exist at exactly these paths:
  `agents/dotnet-senior-developer.md`, `agents/dotnet-mobile-developer.md`,
  `agents/frontend-react-developer.md`, `agents/qa-developer.md`,
  `agents/analyst.md`.
- **SC-004**: Each agent definition's mandatory frontmatter fields
  (`name`, `description`, `tools`) are present and well-formed per the
  Claude Code schema, and the role/scope is stated in the body. A
  metadata validator (future work) will enforce this mechanically; for
  this feature a manual review against the schema suffices.
- **SC-005**: Each agent definition references at least the minimum skill
  set declared in FR-012, FR-012b, and FR-013 through FR-015, by folder
  name, with zero duplicated skill content.
- **SC-008**: The `.NET Senior Developer` and `.NET Mobile Developer`
  agents produce no overlapping outputs on identical mobile or backend
  requests: given a mobile request, only the Mobile agent responds
  substantively; given a pure backend/web request, only the Senior agent
  does. Verified by a reviewer on at least two representative prompts per
  agent.
- **SC-006**: A sample invocation of each agent on a representative task
  produces output that a human reviewer confirms as "consistent with the
  composed skills" in under 5 minutes of review per agent.
- **SC-007**: The language-policy validator reports zero non-English tokens
  in any file under `rules/`, `agents/`, `commands/`, and `scripts/`
  introduced by this feature.

## Assumptions

- **Tooling dotfolders are exempt.** `.github/`, `.claude/`, `.specify/`,
  and `.git/` are tool metadata folders and are not subject to the
  constitution's structural validation. Spec Kit's `specs/` working folder
  is also exempt for the same reason.
- **Legitimate root files remain at the root.** `README.md`, `LICENSE`,
  `CLAUDE.md`, and `GitVersion.yml` are standard project metadata and
  remain at the repository root.
- **`workflows/` is a canonical top-level folder** (constitution v2.0.0).
  It hosts reusable CI/CD pipeline templates and is distinct from
  `scripts/` (which is for local/repo utilities only). No relocation is
  performed.
- **MAUI belongs to a dedicated mobile agent.** The .NET Senior Developer
  agent covers backend/web only; MAUI and mobile concerns are owned by the
  `dotnet-mobile-developer` agent introduced in this feature (User Story
  6). The two agents share the backend skills (`dotnet-architecture`,
  `dotnet-fluent-validation`, `dotnet-env`, `dotnet-test`) by reference.
- **MAUI is treated as part of the .NET stack for this repository.**
  Although the constitution's canonical stack (Principle IV) names .NET/C#
  primarily for server-side work, .NET MAUI is accepted as the team's
  mobile presentation layer and is in scope via the Mobile agent without
  a constitutional amendment. If the team later wants MAUI listed
  explicitly in Principle IV, that is a separate PATCH-level amendment.
- **Cross-agent skill sharing is allowed.** A skill may be referenced by
  more than one agent (e.g., `dotnet-test` by both QA and .NET Senior
  Developer). There is no exclusivity constraint.
- **Existing PT-BR content in English-only folders is out of scope.** If
  legacy skills contain PT-BR content, they are flagged but not cleaned up
  here; that is a separate compliance task.
- **Agent definition file format.** Each agent uses a single Markdown
  definition file with YAML-style frontmatter, matching the convention
  already used by skills' `SKILL.md`.
- **No tests or CI changes are in scope.** Constitution validators
  themselves are an explicit follow-up (`TODO(VALIDATION_SCRIPTS)` in the
  constitution) and are not delivered by this feature.
