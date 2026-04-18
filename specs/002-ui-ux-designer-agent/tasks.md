---
description: "Task list for implementing ui-ux-pro-max-designer agent"
---

# Tasks: Agente `ui-ux-pro-max-designer`

**Input**: Design documents from `specs/002-ui-ux-designer-agent/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Spec does not request TDD. Validation is performed via the grep-based structural checks in `quickstart.md` §1 and the behavioral smoke tests in §2 (manual).

**Organization**: Tasks are grouped by user story. Because the deliverable is a single markdown file (`agents/ui-ux-pro-max-designer.md`) plus edits to 5 sibling agents, each user story contributes additive sections/bullets to the same agent file — each increment is testable via the corresponding quickstart scenario.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files or clearly disjoint sections, no unfinished dependencies)
- **[Story]**: Which user story this task belongs to (US1–US5)
- Include exact file paths in descriptions

## Path Conventions

This feature is documentation-only (AI artifact authoring). All paths are absolute-from-repo-root Windows-style as used in the repo, but forward slashes are accepted.

- Agent file (new): `agents/ui-ux-pro-max-designer.md`
- Sibling agents (modify only `## Output Language`): `agents/frontend-react-developer.md`, `agents/dotnet-senior-developer.md`, `agents/dotnet-mobile-developer.md`, `agents/qa-developer.md`, `agents/analyst.md`
- Contracts (read-only inputs): `specs/002-ui-ux-designer-agent/contracts/agent-frontmatter.schema.json`, `.../output-language.snippet.md`, `.../attribution.snippet.md`
- Runtime deliveries (NOT created in this PR; agent creates per-feature in runtime): `docs/design/<feature-slug>/README.md`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prerequisite verification — no scaffolding needed since the repo is an established Claude Code artifact repository.

- [X] T001 Verify the 7 composed skills exist (directories `skills/banner-design/`, `skills/brand/`, `skills/design/`, `skills/design-system/`, `skills/slides/`, `skills/ui-styling/`, `skills/ui-ux-pro-max/`), each containing a `SKILL.md`. If any is missing, halt and escalate — the agent cannot compose a skill that doesn't exist.
- [X] T002 Verify the 5 sibling agents exist: `agents/frontend-react-developer.md`, `agents/dotnet-senior-developer.md`, `agents/dotnet-mobile-developer.md`, `agents/qa-developer.md`, `agents/analyst.md`. Confirm each has a `## Output Language` section currently.
- [X] T003 [P] Verify the 3 contracts exist and are readable: `specs/002-ui-ux-designer-agent/contracts/agent-frontmatter.schema.json`, `specs/002-ui-ux-designer-agent/contracts/output-language.snippet.md`, `specs/002-ui-ux-designer-agent/contracts/attribution.snippet.md`. These drive every subsequent task.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the skeleton of `agents/ui-ux-pro-max-designer.md` with frontmatter, upstream attribution, H1, and the canonical section order — empty section bodies to be filled by US phases. No user story can be implemented until the skeleton exists.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 Create `agents/ui-ux-pro-max-designer.md` with YAML frontmatter conforming to `contracts/agent-frontmatter.schema.json`: `name: ui-ux-pro-max-designer`, `description` (one line stating the agent scope and the "no .tsx" rule), `tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill, WebFetch`. No `model` field.
- [X] T005 Insert the canonical upstream attribution line immediately after the frontmatter `---` and before the H1 in `agents/ui-ux-pro-max-designer.md`, copied verbatim from `contracts/attribution.snippet.md`.
- [X] T006 Add H1 `# UI/UX Pro Max Designer` and the 5 empty section headers in the exact order defined in `research.md` §Decision 7: `## Role & Scope`, `## Composed Skills`, `## Default Behavior`, `## Boundaries / Out of Scope`, `## Output Language`. Leave bodies blank for now (except `## Output Language`).
- [X] T007 Fill `## Output Language` in `agents/ui-ux-pro-max-designer.md` with the exact canonical block from `contracts/output-language.snippet.md`.
- [X] T008 Fill `## Role & Scope` in `agents/ui-ux-pro-max-designer.md` stating: (a) senior UI/UX designer role; (b) target stack React + Vite + Tailwind with shadcn/ui (FR-013); (c) agent NEVER writes `.tsx` — code is deferred to `frontend-react-developer` (FR-018); (d) out-of-scope areas enumerated at a high level (defer to boundaries section).
- [X] T009 Fill `## Boundaries / Out of Scope` in `agents/ui-ux-pro-max-designer.md` with the name-and-stop rule and explicit deferrals: `.tsx` code → `frontend-react-developer`; backend .NET → `dotnet-senior-developer`; MAUI/mobile → `dotnet-mobile-developer`; tests-only → `qa-developer`; `docs/` authoring → `analyst`; non-React-ecosystem UI (Vue, Svelte, SwiftUI, Flutter, RN) → out-of-scope without sibling (FR-005, FR-006, FR-016).

**Checkpoint**: Skeleton file exists, passes frontmatter schema, carries attribution and Output Language — user story phases can now add content to `## Composed Skills` and `## Default Behavior`.

---

## Phase 3: User Story 1 - Desenho de interfaces (Priority: P1) 🎯 MVP

**Goal**: Agent can take requests like "desenhe uma tela de login React + Vite + Tailwind estilo minimalista" and deliver a named visual direction + HTML/CSS mockup + component spec + tokens (CSS vars + `tailwind.config` extend) — without writing `.tsx`.

**Independent Test**: Run `quickstart.md` §2.1. Agent must (a) respond in the language of the prompt, (b) declare a named visual direction, (c) invoke `ui-ux-pro-max` + `design-system` + `ui-styling`, (d) output mockup + spec + tokens, (e) defer `.tsx` to `frontend-react-developer`.

### Implementation for User Story 1

- [X] T010 [US1] Add bullet for `ui-ux-pro-max` under `## Composed Skills` in `agents/ui-ux-pro-max-designer.md`: one-sentence invocation trigger ("primary design-intelligence skill — invoke for any UI/UX task to choose style, palette, typography, layout rules from the 50+ styles / 161 palettes / 99 UX guidelines database").
- [X] T011 [US1] Add bullet for `ui-styling` under `## Composed Skills`: "invoke to recommend the shadcn/ui + Tailwind + Radix component family that materializes the chosen direction on the React + Vite + Tailwind stack — without producing `.tsx`".
- [X] T012 [US1] Add bullet for `design-system` under `## Composed Skills`: "invoke to produce primitive → semantic → component tokens as CSS variables plus a `tailwind.config` `theme.extend` block".
- [X] T013 [US1] Add Default Behavior rule to `## Default Behavior` in `agents/ui-ux-pro-max-designer.md`: "Before sketching, declare a named visual direction (minimalism, brutalism, bento grid, claymorphism, glassmorphism, neumorphism, skeuomorphism, flat, editorial, retro-futurism, etc.). Never fall back to generic defaults (Inter + purple gradient, system fonts, cookie-cutter layouts)." (FR-010, SC-005)
- [X] T014 [US1] Add Default Behavior rule to `## Default Behavior`: "For UI tasks, apply the `ui-ux-pro-max` priority ladder — Accessibility → Touch → Performance → Style → Layout → Typography/Color → Animation → Forms → Navigation → Charts. Non-negotiable minimums: contrast ≥ 4.5:1, touch target ≥ 44×44px, visible focus rings, `prefers-reduced-motion` respected, never convey information by color alone." (FR-004, FR-009, SC-003)
- [X] T015 [US1] Add Default Behavior rule to `## Default Behavior`: "Deliverables for a design-of-screen/component request: (1) named visual direction, (2) HTML/CSS mockup, (3) component spec (props, states, variants, which shadcn components to compose), (4) tokens — a CSS-variables file fragment plus a `tailwind.config` `theme.extend` block. Never write `.tsx`. If the user explicitly requests React code, defer to `frontend-react-developer` via name-and-stop and pass the spec + tokens along." (FR-013, FR-014, FR-018, SC-007, SC-009)

**Checkpoint**: User Story 1 fully functional. Agent produces design-only deliverables on React + Vite + Tailwind requests and defers code to the sibling.

---

## Phase 4: User Story 2 - Identidade de marca e tokens (Priority: P1)

**Goal**: Agent can take requests like "defina identidade de marca e tokens para uma fintech" and produce brand guidelines + three-layer tokens, syncing `docs/brand-guidelines.md` to `assets/design-tokens.{json,css}`.

**Independent Test**: Run `quickstart.md` §2.2. Agent invokes `brand` then `design-system` in that order, writes/updates `docs/brand-guidelines.md`, regenerates tokens via `brand/scripts/sync-brand-to-tokens.cjs`.

### Implementation for User Story 2

- [X] T016 [US2] Add bullet for `brand` under `## Composed Skills` in `agents/ui-ux-pro-max-designer.md`: "invoke to define or update brand voice, visual identity, palettes, typography; `docs/brand-guidelines.md` is the source of truth synced to `assets/design-tokens.{json,css}` via the skill's scripts".
- [X] T017 [US2] Extend the existing `design-system` bullet (from T012) to mention three-layer-token discipline (primitive → semantic → component) so a brand change cascades through all layers predictably. Do not add a second `design-system` bullet.
- [X] T018 [US2] Add Default Behavior rule to `## Default Behavior`: "For any design task, compose skills in the canonical order `brand` → `design-system` → delivery skill (`ui-styling` / `banner-design` / `slides` / `design`). If `docs/brand-guidelines.md` does not exist, offer to create it first or proceed with a documented neutral direction — never assume silently." (FR-007, FR-008, edge case #3)

**Checkpoint**: User Story 2 fully functional. Brand + tokens flow works end-to-end.

---

## Phase 5: User Story 3 - Banners, covers, social photos (Priority: P2)

**Goal**: Agent produces N options of a banner (social cover, ad, hero, print) respecting platform dimensions, safe zone, and injected brand context.

**Independent Test**: Run quickstart-equivalent: "3 opções de banner hero para um site de café artesanal". Agent invokes `banner-design`, collects requirements via `AskUserQuestion` (provided by the skill), respects safe zone 70–80%, injects brand context when `docs/brand-guidelines.md` exists.

### Implementation for User Story 3

- [X] T019 [US3] Add bullet for `banner-design` under `## Composed Skills` in `agents/ui-ux-pro-max-designer.md`: "invoke for banners (social media covers/posts, ads, website hero, print). The skill owns platform dimensions, safe-zone rules (70–80% central), the 22 style catalog, and Gemini image-generation invocation. Agent never re-implements content already in the skill's references (FR-003)".
- [X] T020 [US3] Add Default Behavior rule to `## Default Behavior`: "For banner requests, collect requirements via the skill's `AskUserQuestion` workflow, run Pinterest reference research (via WebFetch) only when art direction is not predetermined, and produce the number of options the skill recommends (default 3). Brand context injection via `brand/scripts/inject-brand-context.cjs` is mandatory when a brand exists." (US3 acceptance scenarios)

**Checkpoint**: User Story 3 fully functional. Banner-producing requests route through `banner-design` with brand alignment.

---

## Phase 6: User Story 4 - Apresentações e pitch decks (Priority: P2)

**Goal**: Agent produces strategic HTML presentations (marketing, pitch decks, data-driven with Chart.js), using `slides` layout patterns and copywriting formulas, tokens from `design-system`, and brand alignment from `brand`.

**Independent Test**: "deck de 10 slides para apresentação de produto SaaS". Agent invokes `slides` + `design-system` + `brand`, delivers responsive HTML, includes Chart.js only when metrics are present.

### Implementation for User Story 4

- [X] T021 [US4] Add bullet for `slides` under `## Composed Skills` in `agents/ui-ux-pro-max-designer.md`: "invoke for HTML pitch decks and strategic presentations. Skill owns layout patterns, copywriting formulas, slide strategies, Chart.js recipes. Respect `charts-and-data` rules from `ui-ux-pro-max` (legends, tooltips, accessible colors) whenever charts are used".
- [X] T022 [US4] Add Default Behavior rule to `## Default Behavior`: "For presentation requests, apply `slides` layout + copywriting patterns. Include Chart.js only when the pitch actually contains metrics — do not force charts. Reuse `design-system` tokens in the HTML so decks stay brand-consistent." (US4 acceptance scenarios)

**Checkpoint**: User Story 4 fully functional. Presentation requests route through `slides`.

---

## Phase 7: User Story 5 - Logo, CIP, ícones (Priority: P3)

**Goal**: Agent produces logo, Corporate Identity Program (CIP) deliverables, or icon sets via `design` skill's sub-routing, aligning with `brand`, optionally offering HTML preview via `ui-ux-pro-max` gallery.

**Independent Test**: "logo minimalista para startup de tecnologia". Agent invokes `design` with logo sub-skill, respects the white-background rule, offers HTML preview after confirmation.

### Implementation for User Story 5

- [X] T023 [US5] Add bullet for `design` under `## Composed Skills` in `agents/ui-ux-pro-max-designer.md`: "invoke as the unified entry point for logo generation (55 styles), CIP deliverables (50+ mockups), icon sets (15 styles, SVG), and multi-platform social photos. `design/SKILL.md` owns sub-routing — never reimplement its decision matrix". (FR-003)
- [X] T024 [US5] Add Default Behavior rule to `## Default Behavior`: "For logo generation, enforce the white-background rule documented in `design/SKILL.md` and — after generation — offer an HTML preview gallery via `ui-ux-pro-max` when the user confirms via `AskUserQuestion`. For CIP requests, route to the 50+ deliverables catalog without duplicating it in the response." (US5 acceptance scenarios)

**Checkpoint**: All five user stories fully implemented in `agents/ui-ux-pro-max-designer.md`.

---

## Phase 8: Cross-Cutting Behavioral Rules

**Purpose**: Add Default Behavior rules that apply across stories (script failure, build-tool detection, delivery index).

- [X] T025 [P] Add Default Behavior rule to `## Default Behavior` covering script failure handling: "When any script invoked by a composed skill fails, (a) report the exact error (message, exit code, file/step), (b) list 2–3 concrete paths — retry, adjust config/credential/input, or a skill-free fallback — and (c) wait for explicit user choice. Never silence failures, never proceed with partial output silently, never fabricate artifacts." (FR-020, SC-012, edge case #7)
- [X] T026 [P] Add Default Behavior rule to `## Default Behavior` covering build-tool detection: "Before generating tokens or mockups intended for a concrete project, detect the real build tool (Vite / Next.js / Remix / CRA / other). If it is not Vite, declare the discrepancy, ask whether to adapt or proceed with Vite conventions, and record the decision before producing artifacts." (FR-015, edge case #6)
- [X] T027 [P] Add Default Behavior rule to `## Default Behavior` covering the design delivery index: "For each completed design feature, create (or update) `docs/design/<feature-slug>/README.md` listing every artifact produced — relative path, purpose, skill of origin — as a single consumption point for `frontend-react-developer` when implementing `.tsx`." (FR-021, SC-011)

**Checkpoint**: Cross-cutting rules added. Agent file content is complete — ready for validation.

---

## Phase 9: Sibling Agent Normalization (FR-019)

**Purpose**: Apply the canonical `## Output Language` block to the 5 existing agents to enforce the bilingual rule across the repository (SC-010).

- [X] T028 [P] Replace the `## Output Language` section in `agents/frontend-react-developer.md` with the exact canonical block from `specs/002-ui-ux-designer-agent/contracts/output-language.snippet.md`. Leave all other sections, frontmatter, and content untouched.
- [X] T029 [P] Replace the `## Output Language` section in `agents/dotnet-senior-developer.md` with the exact canonical block from the same snippet. Leave all other sections untouched.
- [X] T030 [P] Replace the `## Output Language` section in `agents/dotnet-mobile-developer.md` with the exact canonical block. Leave all other sections untouched.
- [X] T031 [P] Replace the `## Output Language` section in `agents/qa-developer.md` with the exact canonical block. Leave all other sections untouched.
- [X] T032 Replace the `## Output Language` section in `agents/analyst.md` with the exact canonical block AND remove the phrase `Default output is PT-BR; EN only when explicitly requested.` from the frontmatter `description` (keep the rest of the description intact). Rationale in `research.md` §Decision 5. This task is not [P] because it touches both frontmatter and body of the same file.

**Checkpoint**: All 6 agents (the new one + 5 existing) carry identical `## Output Language`. Grep over `agents/` returns the canonical block in every file.

---

## Phase 10: Validation & Polish

**Purpose**: Run the quickstart checks and any repository-wide validators to close the loop.

- [X] T033 Run `quickstart.md` §1.1 — confirm `agents/ui-ux-pro-max-designer.md` exists.
- [X] T034 Run `quickstart.md` §1.2 — confirm frontmatter fields.
- [X] T035 Run `quickstart.md` §1.3 — confirm `tools` allowlist.
- [X] T036 Run `quickstart.md` §1.4 — confirm upstream attribution URL appears exactly once (SC-013).
- [X] T037 Run `quickstart.md` §1.5 — confirm the canonical `## Output Language` block exists in all 6 agent files (SC-010).
- [X] T038 Run `quickstart.md` §1.6 — confirm `agents/ui-ux-pro-max-designer.md` ≤ 100 lines (SC-006). If over, condense verbose bullets — never drop required sections. Result: 55 lines.
- [X] T039 Run `quickstart.md` §1.7 — confirm zero `.tsx`/`.jsx`/`.ts` fenced code blocks in the agent body (SC-009 preventive).
- [X] T040 Validate the new agent frontmatter against `contracts/agent-frontmatter.schema.json` with a JSON Schema validator (Constitution §V). Manual validation — matches all pattern/required/additionalProperties constraints.
- [~] T041 [P] Run the repository-level structure and language validators from `scripts/` if they exist (Constitution Validation & Tooling section). Skipped — validators still TODO per Constitution v2.0.1 (`TODO(VALIDATION_SCRIPTS)` still open).
- [~] T042 Execute the behavioral smoke tests `quickstart.md` §2.1 through §2.6 manually through the Claude Code runtime. Deferred — requires interactive Claude Code invocation by user; documented as PR follow-up.
- [X] T043 Verify `SC-004` zero-duplication: for each of the 7 composed skills, diff the agent's invocation bullet against `skills/<skill>/SKILL.md` — bullet must be a one-sentence trigger, not a paraphrase of skill content. All 7 bullets are trigger summaries, not content reproductions.

**Checkpoint**: All 13 Success Criteria (SC-001 to SC-013) verifiable. Ready for review.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies. Starts immediately. T001/T002 are sequential; T003 is [P].
- **Phase 2 (Foundational)**: Depends on Phase 1. T004 → T005 → T006 → T007 are sequential (same file, same region). T008 and T009 can follow T006 but both touch the same file, so run sequentially.
- **Phases 3–7 (User Stories)**: All depend on Phase 2 completion. Because they all edit `agents/ui-ux-pro-max-designer.md`, the stories are **not truly parallel at the file level** — treat them as a priority-ordered sequence. Within a story, the two `## Composed Skills` and `## Default Behavior` bullet additions target different regions and can be batched, but don't run them against a partially-written file.
- **Phase 8 (Cross-cutting)**: Depends on Phases 3–7 being done with content. T025/T026/T027 touch different bullets — safe to batch.
- **Phase 9 (Sibling normalization)**: Independent of Phases 2–8 *for the file targets* (different files), so T028–T031 are genuinely [P]. T032 touches both frontmatter and body of `analyst.md` — sequential within its own file.
- **Phase 10 (Validation)**: Depends on Phases 2–9. T041 is [P] against T033–T040 because it runs external scripts.

### User Story Dependencies

- **US1 (P1)**: MVP. No dependency on any other story.
- **US2 (P1)**: Same priority as US1. Independent conceptually, but in this file-based deliverable it reads bullets US1 has already added (only for ordering). Running US2 immediately after US1 avoids merge churn.
- **US3 (P2)**: Depends only on Phase 2. Can start after US1/US2 without intermediate integration.
- **US4 (P2)**: Same as US3.
- **US5 (P3)**: Depends only on Phase 2. Can ship after the P1/P2 stories without breaking them.

### Within Each User Story

- Add `## Composed Skills` bullet(s) for the story's skills before `## Default Behavior` rules that reference them.
- Keep each bullet ≤ 2 lines to respect SC-006 (≤ 100 lines total).

### Parallel Opportunities

- Phase 1: T003 runs in parallel with T001/T002.
- Phase 9: T028–T031 run in parallel (4 different files).
- Phase 10: T041 runs in parallel with T033–T040.
- Within Phase 8: T025/T026/T027 are disjoint bullets — batch acceptable.

---

## Parallel Example: Phase 9 (Sibling Agent Normalization)

```bash
# Launch 4 disjoint file edits in parallel — each replaces one section block:
Task: "Replace ## Output Language in agents/frontend-react-developer.md"
Task: "Replace ## Output Language in agents/dotnet-senior-developer.md"
Task: "Replace ## Output Language in agents/dotnet-mobile-developer.md"
Task: "Replace ## Output Language in agents/qa-developer.md"

# Then sequentially (frontmatter + body in the same file):
Task: "Replace ## Output Language + remove PT-BR sentence from description in agents/analyst.md"
```

---

## Implementation Strategy

### MVP First (US1 + US2 — both P1)

1. Complete Phase 1 (Setup checks).
2. Complete Phase 2 (skeleton + role + boundaries + output language).
3. Complete Phase 3 (US1 — design of interfaces).
4. Complete Phase 4 (US2 — brand and tokens).
5. **STOP and VALIDATE**: Run `quickstart.md` §2.1 and §2.2. If both pass, the agent is functional for the two highest-priority flows.
6. Consider shipping MVP as a partial PR (agent file + Phase 9 sibling updates) before adding the P2/P3 stories.

### Incremental Delivery

- **Increment 1**: Phases 1–4 → MVP agent handling P1 flows.
- **Increment 2**: Phases 5–7 → full scope across banners, slides, logo/CIP.
- **Increment 3**: Phase 8 cross-cutting rules + Phase 9 sibling normalization + Phase 10 validation → merge-ready PR.

### Parallel Team Strategy

Limited parallel opportunity because most tasks write to the same agent file. Two sensible splits:

- **Developer A** (content): Phases 2 through 8 (agent file authoring).
- **Developer B** (sibling normalization): Phase 9 (5 files, truly parallel edits).

Both converge at Phase 10 validation.

---

## Notes

- [P] tasks = different files or clearly disjoint regions with no dependency on unfinished tasks.
- [Story] label maps task to a specific user story (US1–US5).
- All tasks are file-authoring — there is no runtime code in this feature. Validation is grep + schema + manual behavioral review.
- Commit after each phase or logical increment. Small, reviewable commits help the PR reviewer spot constitution drift early.
- SC-006 (≤ 100 lines) is the main risk: watch total line count as bullets accumulate. Condense by collapsing rules into one-sentence directives rather than multi-paragraph prose.
- Avoid: duplicating skill content in the agent body (violates FR-003, SC-004); writing `.tsx` examples in the agent (violates FR-018, SC-009).
