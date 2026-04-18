# Implementation Plan: Agente `ui-ux-pro-max-designer`

**Branch**: `002-ui-ux-designer-agent` | **Date**: 2026-04-18 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-ui-ux-designer-agent/spec.md`

## Summary

Criar um novo agente de Claude Code em `agents/ui-ux-pro-max-designer.md` que compõe sete skills de design (`banner-design`, `brand`, `design`, `design-system`, `slides`, `ui-styling`, `ui-ux-pro-max`) para entregar direção visual, tokens, mockups, specs de componente, banners, slides, logo, CIP e ícones — **sem escrever `.tsx`** (código React fica com `frontend-react-developer`). O agente segue a convenção flat-file dos agentes irmãos, declara `tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill, WebFetch`, usa a regra "respond in the language of the request" e cita o repositório upstream `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill` como origem conceitual.

Escopo expandido: normalizar a seção `## Output Language` dos 5 agentes existentes (`frontend-react-developer`, `dotnet-senior-developer`, `dotnet-mobile-developer`, `qa-developer`, `analyst`) para a mesma regra bilíngue.

Abordagem técnica: trata-se de autoria de artefato AI (Markdown + YAML frontmatter), sem runtime, sem dependências de terceiros, sem storage. Os "contratos" do sistema são a schema de frontmatter (Constitution §V) e os snippets de texto canônicos (atribuição, Output Language, Boundaries name-and-stop).

## Technical Context

**Language/Version**: Markdown (CommonMark) + YAML 1.2 frontmatter
**Primary Dependencies**: Nenhuma em runtime. Referências lógicas aos skills em `skills/` (composição por nome de pasta, sem import técnico). Ferramenta orquestradora: Claude Code nativo.
**Storage**: Filesystem apenas (`agents/`, `docs/design/<feature-slug>/`). Sem DB.
**Testing**: Validação estrutural via os validadores de `scripts/` mandatados pela Constitution (language-policy, structure, metadata) + grep-based assertions derivadas dos Success Criteria (URL canônica, Output Language, tools allowlist, zero `.tsx` escrito). Revisão humana em PR.
**Target Platform**: Claude Code runtime (CLI + IDE extensions). Multi-plataforma (qualquer OS onde o Claude Code rode).
**Project Type**: AI artifact authoring (documentation-only). Categoria "single project" do template, adaptada à natureza declarativa do repositório.
**Performance Goals**: N/A — agente é arquivo declarativo. Proxy de qualidade: arquivo ≤ 100 linhas (SC-006) para velocidade de contexto.
**Constraints**:
- Constitution §II: apenas pastas canônicas (`agents/` e `docs/`).
- Constitution §III: `agents/` é EN-only para conteúdo de arquivo. A regra "respond in the language of the request" vale para o *output* do agente em runtime, não para o texto do arquivo.
- Constitution §V: frontmatter obrigatório (`name`, `description`, `tools`); `model` opcional; body com Role & Scope + Composed Skills + Boundaries.
- Atribuição upstream (FR-022): URL exata `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill`.
**Scale/Scope**: 1 arquivo novo + 5 arquivos modificados (seção `## Output Language`). Zero código runtime. Zero test suites novas. Índice de design criado sob demanda por feature consumida (`docs/design/<feature-slug>/README.md`), fora do scope de implementação inicial.

## Constitution Check

Avaliação contra `.specify/memory/constitution.md` v2.0.1.

| Principle | Status | Evidência |
|---|---|---|
| **I. Repository as SSoT** | ✅ PASS | Novo agente autorado aqui; compõe skills locais; atribuição upstream é crédito, não dependência (Assumptions). |
| **II. Canonical Folder Structure (NON-NEGOTIABLE)** | ✅ PASS | Só toca `agents/` (top-level canônico) e `docs/design/<feature-slug>/` (subpath de `docs/`, permitido; nenhum novo folder top-level). |
| **III. Language Policy (EN-only for `agents/`)** | ✅ PASS | O arquivo `agents/ui-ux-pro-max-designer.md` é 100% em inglês (frontmatter + body + atribuição). A regra "respond in the language of the request" é *comportamento de runtime* do agente, escrita em inglês no arquivo — não introduz PT no arquivo. Idem para os 5 agentes atualizados (só troca texto EN por texto EN). |
| **IV. Canonical Technology Stack** | ✅ PASS | Agente declara foco em **React + Vite + Tailwind** (FR-013), que é uma especialização dentro do eixo frontend canônico (React + TypeScript em §IV). Vite e Tailwind são stack-internos dentro do ecossistema React, não representam um desvio fora do React. |
| **V. Authoring Standards & Metadata Discipline** | ✅ PASS | Nome kebab-case `ui-ux-pro-max-designer.md`; arquivo único em `agents/` (flat-file); frontmatter com `name` + `description` + `tools` (allowlist explícita); body com Role & Scope, Composed Skills (por referência), Boundaries (deferral name-and-stop). |

**Gate result**: PASS sem violações. Sem itens para *Complexity Tracking*.

**Notas adicionais**:

- Tarefa de normalização dos 5 agentes existentes (FR-019) é **alteração de uma única seção**, não toca frontmatter nem principles; consistente com §V (metadata discipline) reforçando uniformidade.
- `analyst.md` tem, na *description* do frontmatter, a frase `Default output is PT-BR; EN only when explicitly requested` — após a normalização, essa frase fica inconsistente com o novo `## Output Language`. O plano inclui atualizar ambos (description + `## Output Language`) para manter metadata coerente com Principle V.

## Project Structure

### Documentation (this feature)

```text
specs/002-ui-ux-designer-agent/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── agent-frontmatter.schema.json   # YAML/JSON Schema for agent frontmatter
│   ├── output-language.snippet.md      # Canonical bilingual rule text
│   └── attribution.snippet.md          # Canonical upstream attribution line
├── checklists/
│   └── requirements.md  # Spec quality checklist (já existente)
├── spec.md              # Feature specification (já existente)
└── tasks.md             # Phase 2 output (/speckit.tasks - NOT created here)
```

### Source Code (repository root)

Este feature **não** cria código-fonte executável. Toca apenas artefatos AI declarativos:

```text
agents/
├── ui-ux-pro-max-designer.md    # NEW — arquivo do agente (≤ 100 linhas)
├── frontend-react-developer.md   # MODIFY — seção `## Output Language`
├── dotnet-senior-developer.md    # MODIFY — seção `## Output Language`
├── dotnet-mobile-developer.md    # MODIFY — seção `## Output Language`
├── qa-developer.md               # MODIFY — seção `## Output Language`
└── analyst.md                    # MODIFY — `## Output Language` + ajuste de frontmatter.description
```

Diretório consumido pelo agente em tempo de execução (criado *por feature* de design, não na implementação inicial):

```text
docs/
└── design/
    └── <feature-slug>/
        └── README.md            # Índice de entrega, gerado dinamicamente pelo agente em runtime (SC-011, FR-021)
```

**Structure Decision**: Single-project, documentation-only. Nenhum dos três options do template (library, web app, mobile+API) se aplica literalmente — usamos layout de *AI artifact repository* já canonizado pela Constitution (§II). Trabalho concentrado em `agents/`; artefatos consumidos por `frontend-react-developer` via `docs/design/<feature-slug>/README.md` (criados em runtime, não nesta PR).

## Complexity Tracking

Sem violações a justificar. Não preenchido.
