# Phase 0 — Research

**Feature**: Repository Restructure and Role-Based Agent Creation
**Branch**: `001-repo-restructure-agents`
**Date**: 2026-04-17

## Scope

No `NEEDS CLARIFICATION` markers survive in spec.md (resolved via
`/speckit.clarify` session 2026-04-17). This research log captures the
load-bearing decisions behind the plan so that Phase 1 contracts and the
eventual `/speckit.tasks` output can be derived without re-deriving them.

---

## R1. Agent file layout and frontmatter schema

**Decision**: Follow the Claude Code native agent convention exactly — flat
single-file Markdown definitions at `agents/<agent-name>.md` (kebab-case),
YAML frontmatter with `name`, `description`, `tools` (mandatory) and
optional `model`, body as the system prompt.

**Rationale**:
- Claude Code's orchestrator discovers agents via `name` and routes based on
  `description`. Matching the native schema removes friction and makes the
  Task tool find the agents automatically when invoked by a superagent.
- A single file per agent avoids the overhead of a folder-per-agent layout
  and aligns with `/speckit.clarify` Q1 (user decision).
- Mandatory explicit `tools` allowlist (Q2) implements least-privilege: an
  agent writing docs does not need `Bash`, a QA agent does not need `Write`
  into non-test paths, etc.

**Alternatives considered**:
- Folder-per-agent (`agents/<name>/AGENT.md`) — rejected in Q1 as
  inconsistent with Claude Code's native discovery.
- Structured `composed-skills` frontmatter field (Q2 Option D) — rejected
  because Claude Code does not understand that field; keeping skill
  composition in the body preserves native semantics and lets prose
  context explain *how* each skill is used, not just *which*.

---

## R2. Out-of-scope deferral pattern

**Decision**: Every agent body includes a **"Boundaries / Out of Scope"**
section that implements the **name-and-stop** deferral rule (Q3). The
section enumerates what the agent does NOT do and names the specific
sibling agent that owns each excluded scope.

**Rationale**:
- Claude Code does not provide automatic cross-agent handoff on every
  surface (CLI vs web vs IDE), so a prose rule that the agent emits in its
  response is the only reliable implementation.
- Naming the sibling by its `name` field (kebab-case) lets a human
  orchestrator invoke the correct agent with a single copy-paste.
- "Stop" behavior is safer than split-execute: it prevents the agent from
  attempting partial work that later conflicts with the correct agent's
  output.

**Alternatives considered**:
- Active handoff via the Task tool (Q3 Option C) — rejected because the
  Task tool is not universally available and when it IS, the orchestrator
  rather than the deferring agent should decide the handoff.
- Silent defer to human (Q3 Option A) — rejected because naming the sibling
  adds zero cost and removes a routing step for the user.
- Split-and-execute (Q3 Option D) — rejected because it couples agents,
  making cross-agent outputs hard to review and trace.

---

## R3. Per-agent `tools` allowlist

**Decision**: Derive each agent's `tools` field from the `allowed-tools`
declared by the skills it composes, plus the minimum needed for the
agent's own orchestration (reading the repo, writing to its target
location). Agents get `Skill` so they can invoke composed skills.

Mapping (per agent):

| Agent | Composed skills' allowed-tools union | Agent `tools` |
|-------|---------------------------------------|---------------|
| `dotnet-senior-developer` | Read, Grep, Glob, Bash, Write, Edit, Task (from `dotnet-architecture`, `dotnet-test`) | `Read, Grep, Glob, Bash, Write, Edit, Task, Skill` |
| `dotnet-mobile-developer` | Same as backend skills + MAUI (Read, Grep, Glob, Bash, Write, Edit, Task) | `Read, Grep, Glob, Bash, Write, Edit, Task, Skill` |
| `frontend-react-developer` | Read, Grep, Glob, Write, Edit, Task (React skills) | `Read, Grep, Glob, Write, Edit, Task, Skill` |
| `qa-developer` | Read, Grep, Glob, Bash, Write, Edit, Task (from `dotnet-test`) | `Read, Grep, Glob, Bash, Write, Edit, Task, Skill` |
| `analyst` | Read, Write, Edit, Glob, Grep, Bash, Task (from `doc-manager`, `readme-generator`, `mermaid-chart`) | `Read, Write, Edit, Glob, Grep, Task, Skill` (no `Bash` — doc authoring does not need shell) |

**Rationale**: Least-privilege with enough surface for each agent to read
the project, compose its skills, and write its canonical outputs. `Bash`
is removed from `analyst` because document authoring never needs shell
execution and every `Bash` call on a doc agent is a red flag.

**Alternatives considered**:
- Grant all agents every tool — rejected (Q2 constraint: explicit
  allowlist forbidden from being implicit-all).
- Restrict developer agents to read-only — rejected because their skills
  (`dotnet-architecture`, `react-architecture`, etc.) explicitly need
  `Write`/`Edit` to scaffold entity files.

---

## R4. Analyst default language (PT-BR)

**Decision**: `analyst.md` body states PT-BR as default output language and
`foo.pt-BR.md` as default filename suffix; EN (`foo.md`) only when the
user writes the request in English or asks explicitly for English output
(Q4).

**Rationale**:
- Matches the repo's `CLAUDE.md` policy ("Always respond in Portuguese").
- Preserves the bilingual convention from constitution Principle III:
  `.md` for EN, `.pt-BR.md` for PT-BR.
- Avoids doubling maintenance cost of bilingual pairs by default; users
  opt in to both versions explicitly when needed.

**Alternatives considered**:
- EN default (Q4 Option A) — rejected by user.
- Always bilingual (Q4 Option C) — rejected; doubles cost.
- Language auto-detection (Q4 Option D) — rejected; Option B subsumes it
  because explicit EN request already opts into EN.

---

## R5. Relocation safety for loose PowerShell utilities

**Decision**: Move the four utilities (`collect-skills.ps1`,
`copy-dependency.ps1`, `push-skill.ps1`, `replace-skill.ps1`) to
`scripts/` with `git mv` to preserve history. Update every caller
reference in:
- `README.md`
- `CLAUDE.md`
- `.github/workflows/*.yml` (searched; no current callers found)
- Skill SKILL.md files (searched; no hard-coded root paths to `.ps1`)

**Rationale**: `git mv` keeps blame/history intact. A grep-based sweep
before and after the move catches every caller. Absence of CI references
(verified in `.github/workflows/create-release.yml` and `version-tag.yml`)
reduces risk to zero.

**Alternatives considered**:
- Copy + delete — rejected; breaks history.
- Leave scripts at root, amend constitution to allow them — rejected; the
  constitution is the source of truth and has higher gravity than saving
  a few reference updates.

---

## R6. Placeholder `README.md` content per new folder

**Decision**: Each newly created canonical folder (`rules/`, `agents/`,
`commands/`, `docs/`, `scripts/`) gets a terse `README.md` stating:
1. The folder's purpose (quoted from constitution Principle II table).
2. The language policy that applies (EN-only or bilingual).
3. The authoring standards that apply (kebab-case, frontmatter requirements
   where relevant).
4. A pointer to the constitution.

**Rationale**: FR-004 requires at least a `README.md` in each new folder
so the canonical structure is concretely present. Terse stubs are enough
— the constitution is authoritative and linked from each stub.

**Alternatives considered**:
- Empty folders with `.gitkeep` — rejected; fails FR-004.
- Full documentation per folder — rejected; premature, duplicates the
  constitution, decays independently.

---

## R7. Constitution validators (deferred)

**Decision**: Constitution validators (language-policy, structure,
metadata) remain **out of scope** for this feature per spec Assumptions
and the open `TODO(VALIDATION_SCRIPTS)` in constitution v2.0.1. SC-001,
SC-004, and SC-007 are verified by **manual review** for this feature.

**Rationale**: Scope control. Validator design is a feature of its own
and mixing it with the reorganization delays the foundational MVP (US1).

**Alternatives considered**:
- Ship minimal validators alongside — rejected; doubles feature scope,
  introduces test/CI changes explicitly excluded in spec Assumptions.

---

## Open items (none blocking)

- **Constitution Principle V amendment** to flat-file agent layout: **DONE**
  in v2.0.1 (2026-04-17). Cleared.
- **Tools allowlist refinement**: the union-based derivation in R3 is
  conservative; a future PATCH to individual agents MAY narrow the list
  after observing actual invocations. Not blocking.
