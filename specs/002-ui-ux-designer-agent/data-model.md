# Phase 1 — Data Model: `ui-ux-pro-max-designer`

**Feature**: 002-ui-ux-designer-agent
**Date**: 2026-04-18

## Nature of this model

O feature não lida com dados relacionais em banco. As "entidades" são **artefatos de filesystem** e **slots estruturais de markdown** — a disciplina aqui é tratá-los com rigor de schema porque Claude Code e validadores de CI consomem esses arquivos como dados.

---

## Entity 1 — `AgentFile`

Arquivo único sob `agents/<kebab-case-name>.md`.

### Attributes

| Field | Type | Rules |
|---|---|---|
| `path` | string | `agents/<name>.md` onde `<name>` é kebab-case. Este feature: `agents/ui-ux-pro-max-designer.md`. |
| `frontmatter.name` | string | Obrigatório. Kebab-case. DEVE bater com o filename sem extensão. Valor: `ui-ux-pro-max-designer`. |
| `frontmatter.description` | string | Obrigatório. Uma frase. Descreve o que o agente faz e para que NÃO é invocado. EN only. |
| `frontmatter.tools` | list<string> | Obrigatório. Allowlist explícita. Valor fixado: `Read, Grep, Glob, Bash, Write, Edit, Task, Skill, WebFetch`. |
| `frontmatter.model` | string? | Opcional. **Omitido** neste agente (alinhado com os irmãos). |
| `attribution_line` | string | Obrigatório. Blockquote imediatamente após o frontmatter. URL canônica obrigatória. |
| `body.h1` | string | `# UI/UX Pro Max Designer`. |
| `body.sections` | ordered list | Ordem fixa: Role & Scope → Composed Skills → Default Behavior → Boundaries / Out of Scope → Output Language. |
| `body.line_count` | integer | ≤ 100 linhas no total do arquivo (SC-006). |

### Validation rules

- Frontmatter passes JSON Schema em `contracts/agent-frontmatter.schema.json`.
- `tools` exatamente igual ao conjunto definido, sem duplicatas, ordem livre.
- `attribution_line` bate exatamente o snippet em `contracts/attribution.snippet.md`.
- Seção `## Output Language` bate exatamente o snippet em `contracts/output-language.snippet.md`.
- Seção `## Boundaries / Out of Scope` cita pelo `name` frontmatter os 5 agentes irmãos: `frontend-react-developer`, `dotnet-senior-developer`, `dotnet-mobile-developer`, `qa-developer`, `analyst`.
- Seção `## Composed Skills` lista exatamente as 7 skills: `banner-design`, `brand`, `design`, `design-system`, `slides`, `ui-styling`, `ui-ux-pro-max`. Cada uma com 1 frase "when to invoke".
- Zero blocos de código `.tsx`/`.jsx`/`.ts` no corpo (SC-009 preventivo).

### State transitions

N/A — arquivo é versionado por git. Não tem estado interno.

---

## Entity 2 — `ComposedSkillReference`

Referência declarativa a uma skill em `skills/<skill-name>/`.

### Attributes

| Field | Type | Rules |
|---|---|---|
| `skill_folder` | string | Nome da pasta em `skills/` (kebab-case). DEVE existir no momento do merge. |
| `invocation_trigger` | string | Uma frase descrevendo *quando* o agente invoca a skill. |
| `delegation_ordering` | enum | `brand-phase` \| `design-system-phase` \| `delivery-phase`. Captura a ordem canônica brand → tokens → delivery (FR-007). |

### Validation rules

- Cada referência no corpo do agente bate um diretório real sob `skills/`.
- Zero duplicação do conteúdo do `SKILL.md` no corpo do agente (FR-003, SC-004).

### Instances (fixadas por este feature)

| Skill | Delegation phase | Invocation trigger (síntese) |
|---|---|---|
| `ui-ux-pro-max` | delivery-phase | Qualquer trabalho de UI/UX — base de inteligência de design. |
| `ui-styling` | delivery-phase | Recomendar família de componentes shadcn/Tailwind para a stack React + Vite + Tailwind. |
| `design-system` | design-system-phase | Criar/consumir tokens primitive→semantic→component e tema Tailwind. |
| `brand` | brand-phase | Identidade, voz, paletas, sync com `docs/brand-guidelines.md`. |
| `banner-design` | delivery-phase | Banners de social media, ads, hero, print. |
| `slides` | delivery-phase | HTML presentations, pitch decks, Chart.js. |
| `design` | delivery-phase | Roteador de logo/CIP/ícones/social photos (sub-skills). |

---

## Entity 3 — `SiblingAgentReference`

Referência usada pela regra name-and-stop (FR-005, FR-006, FR-018).

### Attributes

| Field | Type | Rules |
|---|---|---|
| `agent_name` | string | Valor do campo `name` do frontmatter do irmão. |
| `defer_scope` | string | Uma frase descrevendo o que defere. |

### Instances (fixadas)

| Sibling | Defer scope |
|---|---|
| `frontend-react-developer` | Código `.tsx` React, arquitetura de feature module (Types → Service → Context → Hook → Provider), i18n, modais, alerts. |
| `dotnet-senior-developer` | Backend .NET/C# e Web. |
| `dotnet-mobile-developer` | .NET MAUI e mobile nativo. |
| `qa-developer` | Trabalho apenas de testes (unit tests, xUnit). |
| `analyst` | Documentação em `docs/` (autoria de prosa). |

---

## Entity 4 — `OutputLanguageRule` (shared across all agents)

Regra canônica aplicada uniformemente aos 6 agentes (1 novo + 5 existentes).

### Attributes

| Field | Type | Rules |
|---|---|---|
| `section_header` | literal | `## Output Language` |
| `canonical_text` | literal | Conteúdo fixado em `contracts/output-language.snippet.md`. |

### Invariant

Grep `rg "^## Output Language" -A 3 agents/` DEVE retornar o mesmo bloco em todos os agentes de `agents/`, sem exceção, após a entrega (SC-010).

---

## Entity 5 — `DesignDeliveryIndex` (runtime, não criado nesta PR)

Gerado pelo agente quando completa uma feature de design para uma aplicação.

### Attributes

| Field | Type | Rules |
|---|---|---|
| `path` | string | `docs/design/<feature-slug>/README.md` |
| `slug` | string | Kebab-case. |
| `artifacts` | list | Cada item: `{ path, purpose, skill_of_origin }`. |

### Lifecycle

1. `draft` — agente começou a produzir, README ainda incompleto.
2. `complete` — todos os artefatos listados com paths relativos válidos.
3. `consumed` — `frontend-react-developer` leu o README e usou-o como spec para o `.tsx`.

Neste feature **não** criamos nenhuma instância; apenas declaramos o schema que o agente seguirá em runtime.

---

## Relationships

```text
AgentFile (1) ── composes ──> (7) ComposedSkillReference
AgentFile (1) ── defers to ──> (5) SiblingAgentReference
AgentFile (6) ── declares ──> (1) OutputLanguageRule (shared invariant)
AgentFile (1) ── produces at runtime ──> (n) DesignDeliveryIndex
```

Os 5 agentes irmãos *também* declaram `OutputLanguageRule` (mesma instância lógica), por isso o total de consumidores é 6.
