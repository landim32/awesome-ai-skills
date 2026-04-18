# Contract — Agent Definition Schema

**Applies to**: every file under `agents/` introduced by this feature.

This contract is the single source of truth for what "a compliant agent
definition file" means. Individual per-agent contracts in this folder
reference this document for the shared rules and only specify
agent-specific values.

---

## File location

```
agents/<agent-name>.md
```

`<agent-name>` MUST match the regex `^[a-z][a-z0-9-]*$` and MUST equal the
`name` field in frontmatter.

## Frontmatter (YAML, required)

```yaml
---
name: <agent-name>              # REQUIRED — kebab-case; == filename stem
description: <single sentence>  # REQUIRED — trigger conditions, ≤ 200 chars
tools: <tool-list>              # REQUIRED — explicit allowlist, comma-separated
model: <opus|sonnet|haiku>      # OPTIONAL — omit to inherit orchestrator's model
---
```

### Allowlist rules

- `tools` MUST list every tool by exact name (e.g., `Read`, `Write`, `Edit`, `Bash`, `Task`, `Skill`, `Glob`, `Grep`).
- The token `*` and an absent `tools` field are both forbidden.
- The list MUST be the minimum needed for the agent's composed skills plus agent-level orchestration.

## Body sections (required, in this order)

### 1. H1 — human-readable role

```markdown
# <Agent Display Name>
```

### 2. Role & Scope

One paragraph stating what the agent does and who it serves. MUST make the
in-scope stack/platform explicit (e.g., ".NET backend/web", "React +
TypeScript frontend", "MAUI mobile apps").

### 3. Composed Skills

A bulleted list. Each bullet MUST name an existing folder under `skills/`
and describe WHEN that skill is invoked.

```markdown
## Composed Skills

- `<skill-folder>` — invoke when <condition>.
```

### 4. Default Behavior

A numbered list of rules the agent follows on every invocation (e.g.,
"read the solution structure before generating code", "prefer the
canonical stack defaults from constitution Principle IV").

### 5. Boundaries / Out of Scope

A bulleted list. Each bullet MUST (a) state a disallowed scope and
(b) name the sibling agent that owns that scope. Implements Clarification
Q3 "name-and-stop".

```markdown
## Boundaries / Out of Scope

- <disallowed scope> — defer to `<sibling-agent-name>`.
```

For multi-scope requests the agent MUST list every sibling that owns a
slice and MUST NOT attempt partial execution.

### 6. Output Language

One line stating the default output language.

- Developer/QA agents: `English`.
- Analyst: `PT-BR by default; EN only when the user writes in EN or asks
  explicitly for EN` (per Clarification Q4).

---

## Acceptance test for a compliant file

A reviewer (or future validator) checks:

1. Filename matches `^[a-z][a-z0-9-]*\.md$`.
2. YAML frontmatter parses; `name`, `description`, `tools` present;
   `description` ≤ 200 chars.
3. `name` == filename stem.
4. `tools` is a non-empty list without `*` or absent.
5. Body contains H1, Role & Scope, Composed Skills, Default Behavior,
   Boundaries / Out of Scope, Output Language — in order.
6. Every bullet in Composed Skills references an existing folder under
   `skills/`.
7. Every bullet in Boundaries / Out of Scope names an agent that exists
   under `agents/`.
8. The whole file is English (Principle III), except for PT-BR *examples*
   inside the Analyst agent's body where necessary.

A file failing any of the above is non-compliant and blocks merge.
