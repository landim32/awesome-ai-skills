# Implementation Plan: Skill `dotnet-test-api`

**Branch**: `003-dotnet-test-api` | **Date**: 2026-04-18 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-dotnet-test-api/spec.md`

## Summary

Criar uma skill reutilizável em `skills/dotnet-test-api/SKILL.md` que descreve, como template consumível por Claude Code, **como gerar um projeto `<Solution>.ApiTests`** em uma solução .NET 8 — seguindo o padrão observado em `MonexUp.ApiTests` (xUnit + Flurl.Http + FluentAssertions + `IAsyncLifetime` fixture com token compartilhado via `[CollectionDefinition]`). A skill emite:

1. csproj com dependências canônicas e referência auto-detectada a um projeto de DTOs.
2. `appsettings.Test.json` com **placeholders `REPLACE_VIA_ENV_*`** para credenciais (nunca valores reais).
3. `Fixtures/ApiTestFixture.cs` com auth Generic JWT Bearer default + fast-fail quando placeholders remanescem.
4. `Fixtures/ApiTestCollection.cs` com `[CollectionDefinition("ApiTests")]`.
5. `Controllers/<Name>ControllerTests.cs` por controller, com cenários autenticado/anônimo e FluentAssertions.
6. `Helpers/TestDataHelper.cs` crescendo **on-demand per controller** (sem factories órfãs).
7. Presets documentados (NAuth, OAuth2 client credentials, API key) como diffs do default.

Escopo cross-artefato: atualizar `agents/qa-developer.md` para compor `dotnet-test-api` ao lado de `dotnet-test`, com desambiguação unit vs API quando o pedido for genérico.

Abordagem: autoria de artefato AI + templates de código. Zero runtime executando em produção — o código gerado pela skill é que roda `dotnet test` contra uma API externa.

## Technical Context

**Language/Version**:
- Skill artefato: Markdown (CommonMark) + YAML 1.2 frontmatter.
- Código gerado pela skill: C# / .NET 8.0.

**Primary Dependencies**:
- Skill: nenhuma em runtime. Referência lógica à `dotnet-test` (skill irmã, não composição técnica).
- Código gerado (declarado no csproj template): `xunit` ≥ 2.5, `xunit.runner.visualstudio`, `Microsoft.NET.Test.Sdk` 17.8+, `FluentAssertions` ≥ 7.0, `Flurl.Http` ≥ 4.0, `Microsoft.Extensions.Configuration` + `.Json` + `.EnvironmentVariables` ≥ 9.0, `coverlet.collector` ≥ 6.0.

**Storage**: Filesystem apenas — `skills/dotnet-test-api/` (skill) e o projeto `.ApiTests/` (gerado na solução alvo). Sem DB.

**Testing**:
- Skill: validação estrutural (frontmatter schema + grep), manual review.
- Código gerado: `dotnet build` + `dotnet test` na solução alvo (SC-003, SC-004).

**Target Platform**:
- Skill: Claude Code runtime (CLI + IDE extensions).
- Código gerado: .NET 8 SDK (cross-platform — Windows/Linux/macOS).

**Project Type**: AI artifact authoring + code-generation templates. Categoria "single project" do template, adaptada.

**Performance Goals**:
- SC-004: suite gerada executa ≤ 60 s por controller com API externa respondendo ≤ 2 s/request e até 10 endpoints por controller.
- SKILL.md ≤ 400 linhas (SC-010).

**Constraints**:
- Constitution §II: só toca pastas canônicas (`skills/` e `agents/`).
- Constitution §III: ambos EN-only — SKILL.md e agent update em inglês.
- Constitution §IV: .NET 8 é stack canônico backend; alinhado. Flurl.Http/FluentAssertions/xUnit são libs-de-teste internas a esse stack — não introduzem novo stack.
- Constitution §V: frontmatter `name`, `description`, `allowed-tools`, `user-invocable: true` (paridade com `dotnet-test`).
- Spec §Clarifications: default auth é Generic JWT Bearer, secrets via env vars, detect-and-prompt de projeto DTO, on-demand `TestDataHelper`.

**Scale/Scope**:
- 1 arquivo novo: `skills/dotnet-test-api/SKILL.md` (≤ 400 linhas).
- 1 arquivo modificado: `agents/qa-developer.md` (adicionar skill na lista de Composed Skills + ajustar description, Role & Scope, Default Behavior).
- 5 templates de código embutidos no SKILL.md: csproj, appsettings.Test.json, ApiTestFixture.cs (default JWT), ApiTestCollection.cs, ControllerTests.cs + TestDataHelper.cs.
- 3 presets adicionais documentados no SKILL.md: NAuth, OAuth2 client credentials, API key.
- Zero código runtime no próprio repositório (awesome-ai-skills) — o código .NET só existe como string dentro da skill.

## Constitution Check

Avaliação contra `.specify/memory/constitution.md` v2.0.1.

| Principle | Status | Evidência |
|---|---|---|
| **I. Repository as SSoT** | ✅ PASS | Nova skill autorada em `skills/`; agente consumidor atualizado em `agents/`. Referência ao MonexUp é inspiração conceitual, não dependência técnica. |
| **II. Canonical Folder Structure (NON-NEGOTIABLE)** | ✅ PASS | Só toca `skills/dotnet-test-api/` (novo) e `agents/qa-developer.md` (modificação) — ambas top-level canônicas. Nenhum novo folder top-level. |
| **III. Language Policy (EN-only)** | ✅ PASS | SKILL.md 100% em inglês; agent update em inglês; código C# template naturalmente em inglês. Placeholders e mensagens de erro (fast-fail da fixture) em inglês. |
| **IV. Canonical Technology Stack** | ✅ PASS | .NET 8 + C# é backend canônico (Principle IV). xUnit é stack-interno de teste — sem novo stack introduzido. Flurl.Http / FluentAssertions são libs cliente HTTP e assertion dentro de .NET, não novo stack. |
| **V. Authoring Standards & Metadata Discipline** | ✅ PASS | Nome `dotnet-test-api` kebab-case; `skills/<name>/SKILL.md` convenção respeitada; frontmatter com `name`, `description`, `allowed-tools`, `user-invocable: true`; conteúdo declarativo. Agent update preserva todos campos obrigatórios (§V Agents sub-bullet). |

**Gate result**: PASS sem violações. Sem itens para *Complexity Tracking*.

**Notas adicionais**:

- A skill é primariamente **template provider**: emite código C# como strings. Não executa código .NET no próprio repositório awesome-ai-skills. A compilação/execução acontece na solução alvo do usuário.
- Placeholder `REPLACE_VIA_ENV_*` é convenção local da skill, documentada no SKILL.md. Fast-fail da fixture é um padrão defensivo introduzido (FR-016).
- Atualização do `qa-developer.md` preserva intactos: `tools`, `## Output Language` (canônico bilíngue da feature 002), `## Boundaries / Out of Scope`. Só amplia `description`, `## Role & Scope`, `## Composed Skills`, `## Default Behavior`.

## Project Structure

### Documentation (this feature)

```text
specs/003-dotnet-test-api/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── skill-frontmatter.schema.json    # JSON Schema for skills/ frontmatter
│   ├── appsettings-test.schema.json     # JSON Schema for the generated appsettings.Test.json
│   ├── api-test-fixture.template.cs     # Canonical ApiTestFixture.cs (Generic JWT default)
│   ├── api-test-collection.template.cs  # Canonical ApiTestCollection.cs
│   ├── controller-tests.template.cs     # Canonical <Name>ControllerTests.cs skeleton
│   └── test-data-helper.template.cs     # Canonical empty TestDataHelper.cs shell
├── checklists/
│   └── requirements.md  # (já existente)
├── spec.md              # Feature specification (já existente)
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

Este feature **não** cria código-fonte executável no repositório awesome-ai-skills. Toca somente:

```text
skills/
└── dotnet-test-api/
    └── SKILL.md                          # NEW — skill (≤ 400 linhas)

agents/
└── qa-developer.md                       # MODIFY — add dotnet-test-api as Composed Skill + expand Role & Scope + ambiguity rule
```

Estrutura **gerada pela skill na solução alvo** (não criada por este PR):

```text
<Solution>/
├── <Solution>.sln                        # modificada via `dotnet sln add`
├── <Solution>.DTO/                       # referenciado (auto-detect via sufixos conhecidos)
└── <Solution>.ApiTests/                  # NEW (gerado pela skill)
    ├── <Solution>.ApiTests.csproj
    ├── appsettings.Test.json             # com placeholders REPLACE_VIA_ENV_*
    ├── Fixtures/
    │   ├── ApiTestFixture.cs             # Generic JWT default (presets docs no SKILL.md)
    │   └── ApiTestCollection.cs
    ├── Controllers/
    │   └── <Name>ControllerTests.cs      # um por controller, via invocações sucessivas
    └── Helpers/
        └── TestDataHelper.cs             # factories on-demand per controller
```

**Structure Decision**: Single-project, documentation + code-generation. O "source code" deste feature é **declarativo** (SKILL.md como template provider). Segue exatamente o layout canônico do repositório (Constitution §II): `skills/<kebab-case>/SKILL.md`.

## Complexity Tracking

Sem violações a justificar. Não preenchido.
