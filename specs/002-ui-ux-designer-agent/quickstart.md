# Quickstart — Verifying the `ui-ux-pro-max-designer` Agent

**Feature**: 002-ui-ux-designer-agent
**Prereq**: PR merged or branch checked out locally at `002-ui-ux-designer-agent`.

## 1. Structural Verification (≤ 2 minutes)

Run these from repo root; each command MUST pass.

### 1.1 New agent file exists

```bash
test -f agents/ui-ux-pro-max-designer.md && echo OK
```

### 1.2 Frontmatter has all 3 required fields

```bash
rg -U "^---\nname: ui-ux-pro-max-designer\ndescription: .+\ntools: .+\n---" agents/ui-ux-pro-max-designer.md
```

### 1.3 Tools allowlist matches the contract

```bash
rg "^tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill, WebFetch$" agents/ui-ux-pro-max-designer.md
```

(Order of tool names is irrelevant — equivalent sets OK. If you prefer strict set-equality, run the validator in `scripts/` once implemented.)

### 1.4 Upstream attribution present (SC-013)

```bash
# Must return exactly 1
rg -c "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill" agents/ui-ux-pro-max-designer.md
```

### 1.5 Output Language canonical block present in ALL 6 agents (SC-010)

```bash
for f in agents/ui-ux-pro-max-designer.md agents/frontend-react-developer.md agents/dotnet-senior-developer.md agents/dotnet-mobile-developer.md agents/qa-developer.md agents/analyst.md; do
  rg -q "Respond in the language of the request" "$f" || echo "MISSING: $f"
done
```

No `MISSING:` lines means all 6 carry the canonical block.

### 1.6 Agent file stays ≤ 100 lines (SC-006)

```bash
wc -l agents/ui-ux-pro-max-designer.md
```

### 1.7 Zero `.tsx` / `.jsx` / `.ts` fenced blocks in the agent body (SC-009 preventive)

```bash
# Must return 0
rg -c "^```(tsx|jsx|ts)" agents/ui-ux-pro-max-designer.md || echo 0
```

## 2. Behavioral Smoke Tests (≤ 10 minutes, manual)

Invoke the agent via Claude Code in a scratch directory and verify.

### 2.1 US1 — Design de tela (P1)

**Prompt**: `"Desenhe uma tela de login para app SaaS B2B estilo minimalista para React + Vite + Tailwind."`

**Expect**:
- Resposta em português (espelha idioma do pedido, FR-011).
- Declaração de direção visual nomeada (FR-010).
- Invocação das skills `ui-ux-pro-max`, `design-system`, `ui-styling` (FR-002, FR-007).
- Entrega: mockup HTML/CSS + spec de componentes + tokens (CSS vars + `tailwind.config` extend). **Zero `.tsx`**.
- Ao final, oferece deferir implementação `.tsx` a `frontend-react-developer` (FR-018).

### 2.2 US2 — Identidade de marca (P1)

**Prompt**: `"Define brand identity and design tokens for a fintech startup."`

**Expect**:
- Response in English.
- Skills: `brand` + `design-system` (in that order).
- Outputs: `docs/brand-guidelines.md` draft + tokens in `assets/design-tokens.{json,css}`.

### 2.3 Out-of-scope — name-and-stop (FR-006, SC-002)

**Prompt**: `"Create a C# controller for user registration."`

**Expect**:
- Response names `dotnet-senior-developer` by its frontmatter `name` field.
- ≤ 3 sentences.
- No code produced.

### 2.4 Out-of-scope — `.tsx` (FR-018, SC-009)

**Prompt**: `"Write the full React component for the login screen in .tsx."`

**Expect**:
- Agent declares it owns design, not code, and defers `.tsx` to `frontend-react-developer`.
- No `.tsx` written by this agent.

### 2.5 Script failure handling (FR-020, SC-012)

Setup: temporarily remove `docs/brand-guidelines.md` or break a script under a skill's `scripts/`.

**Prompt**: `"Sync brand to tokens."`

**Expect**:
- Agent runs the script, catches failure, reports stderr + exit code.
- Proposes 2–3 paths (retry, fix config, fallback).
- Waits for user choice before continuing.

### 2.6 Build-tool detection (FR-015)

Setup: scratch dir with `next.config.js` (Next.js, not Vite).

**Prompt**: `"Give me tokens for this project."`

**Expect**:
- Agent detects non-Vite build tool, declares the discrepancy, asks whether to adapt.

## 3. Constitution Alignment

- `agents/` content remains 100% English (§III). Check: no non-ASCII letters outside code fences in the agent file.
- Frontmatter conforms to `contracts/agent-frontmatter.schema.json`.

## 4. Ready to ship signals

- All grep checks in §1 pass.
- All behavioral tests in §2 match expected outcomes.
- Sibling agents (5 files) still pass their own existing behavioral tests unchanged — the only mutation was the `## Output Language` section (and for `analyst.md`, one sentence removed from description).
