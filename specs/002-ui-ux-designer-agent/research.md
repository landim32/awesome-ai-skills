# Phase 0 — Research: `ui-ux-pro-max-designer`

**Feature**: 002-ui-ux-designer-agent
**Date**: 2026-04-18

## Scope

A spec não possui nenhum marcador `[NEEDS CLARIFICATION]` remanescente após a sessão `/speckit.clarify`. Logo, a fase de pesquisa foca em decisões de autoria (padrões do repositório + constituição) que o plano precisa fixar antes de gerar o arquivo do agente.

---

## Decision 1 — Convenção de frontmatter

**Decision**: YAML frontmatter com exatamente os campos `name`, `description`, `tools`. Nenhum outro campo (ex.: `model`, `version`) é incluído.

**Rationale**:
- Constitution §V (Authoring Standards): `name`, `description`, `tools` são obrigatórios; `model` é opcional.
- Agentes irmãos (`frontend-react-developer.md`, `dotnet-senior-developer.md`, `dotnet-mobile-developer.md`, `qa-developer.md`, `analyst.md`) todos usam exatamente esses três campos.
- `model` opcional foi deliberadamente omitido em todos os agentes existentes — manter a ausência preserva consistência e deixa a escolha ao orquestrador.

**Alternatives considered**:
- Adicionar `model: claude-opus-4-7`. Rejeitado: amarra o agente a uma versão de modelo sem necessidade; nenhum agente irmão fez essa escolha.
- Adicionar `version: 1.0.0`. Rejeitado: versionamento já é responsabilidade do git + GitVersion (documentado em CLAUDE.md).

---

## Decision 2 — Tools allowlist

**Decision**: `tools: Read, Grep, Glob, Bash, Write, Edit, Task, Skill, WebFetch`.

**Rationale**:
- Clarificação Q1 da spec: essa lista foi a opção escolhida pelo usuário.
- `Bash` é necessário para executar scripts dos skills (`sync-brand-to-tokens.cjs`, `gemini_batch_process.py`, `logo/generate.py`, `inject-brand-context.cjs`, `validate-asset.cjs`).
- `WebFetch` é necessário para referências visuais (`banner-design/SKILL.md` documenta pesquisa em Pinterest via browser).
- `Task` permite delegar ao `frontend-react-developer` quando o usuário insistir em `.tsx` (FR-018).
- `Skill` é obrigatório para invocar as 7 skills compostas sem duplicar conteúdo (FR-003).

**Alternatives considered**:
- Incluir `AskUserQuestion`. Rejeitado: a spec não exige — `banner-design/SKILL.md` chama esse tool, mas a responsabilidade de ter o tool está no skill, não no agente; o Claude Code injeta tools de skills quando invocadas.
- Omitir `WebFetch`. Rejeitado: quebraria o workflow de referências do `banner-design`.
- Adicionar `NotebookEdit` ou ferramentas MCP. Rejeitado: fora do escopo.

---

## Decision 3 — Posição e formato da atribuição upstream

**Decision**: Linha em blockquote, logo após o frontmatter e antes do H1, no formato:

```markdown
> Based on [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) by @nextlevelbuilder — origin of the `ui-ux-pro-max` skill this agent composes.
```

**Rationale**:
- FR-022 define o formato canônico e SC-013 exige exatamente 1 match da URL no arquivo.
- Blockquote (`>`) destaca visualmente que é metadata de proveniência, não conteúdo funcional.
- Posicionamento antes do H1 é convenção comum em OSS (README upstream pattern) e permanece fora de qualquer seção navegável (não é "Role & Scope" nem "Composed Skills").
- Texto em inglês respeita Constitution §III (`agents/` EN-only).

**Alternatives considered**:
- Atribuição em frontmatter como campo `based-on: https://...`. Rejeitado: adiciona campo fora do schema constitucional (§V); SC-013 exige *exatamente* 1 match da URL, e um campo extra aumenta o risco de divergência.
- Atribuição no final do arquivo. Rejeitado: menos visível; convenção OSS coloca crédito no topo.
- Duas URLs (curta + canônica). Rejeitado: SC-013 demanda 1 match exato.

---

## Decision 4 — Texto canônico do `## Output Language`

**Decision**: Substituir todas as ocorrências atuais da seção `## Output Language` por exatamente:

```markdown
## Output Language

Respond in the language of the request. Match the user's language (e.g., Portuguese → Portuguese, English → English). Keep all code identifiers, file paths, and technical keywords in English regardless of the response language.
```

**Rationale**:
- Clarificação Q3 fixou a regra bilíngue.
- FR-011 e FR-019 exigem a mesma frase canônica em todos os agentes — texto único simplifica validação via grep (SC-010).
- A segunda frase previne um risco óbvio: tradução espúria de identificadores de código ou paths quando o agente responde em português (consistente com a CLAUDE.md top-level que já declara essa regra para o usuário).

**Alternatives considered**:
- "Match the language of the user prompt" (forma curta). Rejeitado: ambíguo — um prompt pode misturar línguas.
- Adicionar exemplos de todos os idiomas possíveis. Rejeitado: ruído; PT/EN são os únicos praticados no repositório.

---

## Decision 5 — Tratamento específico de `analyst.md`

**Decision**: Atualizar **duas partes** do `analyst.md`:
1. Seção `## Output Language` → texto canônico (como os outros 4 agentes).
2. Campo `description` do frontmatter: remover `Default output is PT-BR; EN only when explicitly requested.` (ou substituir por neutro se necessário — o resto da description permanece intacto).

**Rationale**:
- A description atual entra em conflito direto com a nova regra bilíngue — deixar ambas gera instrução ambígua para o agente.
- Constitution §V: metadata discipline exige coerência entre frontmatter e body.

**Alternatives considered**:
- Deixar a description como está. Rejeitado: instrução contraditória é pior que inconsistência estilística.
- Reescrever toda a description do analyst. Rejeitado: mudança de escopo; remoção cirúrgica da frase é suficiente.

---

## Decision 6 — Local de saída do índice de entrega

**Decision**: `docs/design/<feature-slug>/README.md` (conforme FR-021 e Q5 da clarificação). Criado pelo agente *em runtime por feature*, não nesta PR.

**Rationale**:
- `docs/` é folder canônico (§II) e admite EN ou PT-BR (§III), compatível com agentes bilíngues.
- Sub-pasta `design/` isola entregas do agente de outras documentações.
- `<feature-slug>` kebab-case: compatível com §V.
- README.md é o ponto de entrada esperado por humanos e pelo `frontend-react-developer` ao implementar `.tsx`.

**Alternatives considered**:
- Diretório raiz `design/`. Rejeitado: criaria novo top-level fora dos 8 canônicos (§II, NON-NEGOTIABLE).
- `docs/features/<feature-slug>/design/`. Rejeitado: profundidade extra sem ganho.

---

## Decision 7 — Ordem das seções no corpo do agente

**Decision**: Ordem obrigatória abaixo, espelhando os dois agentes-modelo (`frontend-react-developer`, `dotnet-senior-developer`):

1. `# UI/UX Pro Max Designer` (H1)
2. `## Role & Scope`
3. `## Composed Skills`
4. `## Default Behavior`
5. `## Boundaries / Out of Scope`
6. `## Output Language`

**Rationale**:
- Consistência visual com os agentes irmãos facilita navegação e revisão.
- Constitution §V exige Role + Composed Skills + Boundaries; os demais são convenção do repositório.

**Alternatives considered**:
- Inserir seção `## Stack` separada. Rejeitado: conteúdo de stack cabe dentro de Role & Scope (como o `dotnet-senior-developer` faz para .NET/C#).
- Seção "Examples". Rejeitado: exemplos vivem nos skills; duplicação é proibida por FR-003.

---

## Open Questions

Nenhuma. Todas as decisões de pesquisa foram resolvidas pela combinação spec + clarificações + Constitution + convenções observadas nos agentes irmãos.
