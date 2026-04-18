# Phase 0 — Research: Skill `dotnet-test-api`

**Feature**: 003-dotnet-test-api
**Date**: 2026-04-18

## Scope

A spec não contém `[NEEDS CLARIFICATION]` após `/speckit.clarify`. Esta fase consolida as decisões de autoria (convenções do repositório + constituição + padrões MonexUp) antes de gerar o SKILL.md e os contracts.

---

## Decision 1 — Frontmatter schema da skill

**Decision**: YAML frontmatter com 4 campos, nesta ordem: `name`, `description`, `allowed-tools`, `user-invocable: true`. Sem `metadata`, sem `version`, sem `argument-hint` (campos usados por skills `ckm:*` externas, não pelas internas como `dotnet-test`).

**Rationale**:
- Paridade com `skills/dotnet-test/SKILL.md` (skill irmã) e `skills/dotnet-architecture/SKILL.md`.
- Constitution §V declara `name` + `description` como mandatório; `allowed-tools` e `user-invocable` são convenção do repositório (visível nas skills `dotnet-*`).
- Q4 fixou `user-invocable: true`.

**Alternatives considered**:
- Adicionar `version`, `author`, `license` (como em `skills/design/SKILL.md`). Rejeitado: skills internas não usam; versionamento fica por git/GitVersion.
- Omitir `user-invocable`. Rejeitado: sem ele, o campo fica implícito e quebra paridade com `dotnet-test`.

---

## Decision 2 — Tools allowlist da skill

**Decision**: `allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task`.

**Rationale**:
- `Read`/`Grep`/`Glob`: inspecionar `.sln`, `.csproj` e controllers na solução alvo.
- `Bash`: rodar `dotnet new xunit`, `dotnet sln add`, `dotnet add package`, `dotnet build`, `dotnet test`.
- `Write`/`Edit`: gerar os arquivos do projeto `.ApiTests/`.
- `Task`: delegar a sub-tarefas longas (ex.: scanning de todos os controllers quando a skill for escalada).
- Sem `AskUserQuestion` aqui: o **Claude Code injeta tools de runtime conforme a skill precisa**; a prática em `dotnet-test` confirma este conjunto mínimo.

**Alternatives considered**:
- Incluir `WebFetch`. Rejeitado: a skill não faz requisições HTTP fora da fixture gerada (que roda no runtime do usuário, não da skill).
- Incluir `AskUserQuestion` explicitamente. Rejeitado: skills irmãs não listam — o runtime expõe.

---

## Decision 3 — Estrutura de seções do SKILL.md

**Decision**: Ordem fixa das seções no corpo do SKILL.md:

1. `# .NET API Test Project Manager (xUnit + Flurl + FluentAssertions)` (H1)
2. `## Input` — descreve o contrato `$ARGUMENTS` (o que o usuário pode pedir: "create api tests", "add tests for X controller", etc.).
3. `## Pre-conditions` — o que a skill lê antes de gerar: `.sln`, projetos candidatos a DTO, controllers existentes.
4. `## Project Layout Convention` — single `<Solution>.ApiTests/` folder, subpastas `Fixtures/`, `Controllers/`, `Helpers/`, `appsettings.Test.json`.
5. `## Dependencies` — tabela de pacotes + versões canônicas.
6. `## Secrets Policy` — placeholder `REPLACE_VIA_ENV_*` + fast-fail + env var convention (double-underscore).
7. `## DTO Project Detection` — regra detect-and-prompt (sufixos `.DTO`, `.Dto`, `.Dtos`, `.Contracts`, `.Models`, `.Shared`).
8. `## Default Auth Scheme — Generic JWT Bearer` — template default com snippets.
9. `## Auth Presets` — NAuth, OAuth2 client credentials, API key; cada um com diff de `appsettings.Test.json` + diff de `ApiTestFixture.cs`.
10. `## Creating the Project` — passos `dotnet new xunit` → add packages → add to sln → generate files.
11. `## Adding Tests for a Controller` — como crescer `Controllers/<Name>ControllerTests.cs` + `TestDataHelper.cs` on-demand.
12. `## Naming Conventions` — `<Method>_<Condition>_ShouldReturn<Expected>`.
13. `## Running the Tests` — `dotnet test`, env vars, CI.
14. `## Boundaries` — não modifica produção; defere para `dotnet-senior-developer`; defere para `dotnet-test` para unit tests.

**Rationale**:
- Espelha o fluxo do `dotnet-test/SKILL.md` (Input → Convention → Creating → Adding → Running) para reduzir a curva de aprendizado do usuário que já conhece a skill irmã.
- Secrets Policy e DTO Project Detection têm seções próprias porque são as decisões mais impactantes (Q2 e Q3 da clarificação).
- Auth Presets vem logo após Default para o leitor encontrar rápido a variante que precisa.

**Alternatives considered**:
- Colocar Auth Presets no final (apêndice). Rejeitado: é decisão de topo; quem não usa o default precisa achar rápido.
- Fundir Pre-conditions dentro de Creating the Project. Rejeitado: pré-condições são ortogonais a "criar vs adicionar".

---

## Decision 4 — Snippet canônico do `ApiTestFixture.cs` default (Generic JWT Bearer)

**Decision**: Fixture default expõe `BaseUrl`, `AuthToken`, `CreateAuthenticatedRequest(path)`, `CreateAnonymousRequest(path)`. Faz POST `{BaseUrl}{LoginEndpoint}` com JSON `{ email, password }` e espera resposta `{ token, success }`. Fast-fail se qualquer chave de `Auth:*` tiver valor `REPLACE_VIA_ENV_*`.

**Rationale**:
- Q1: default Generic JWT Bearer, zero headers proprietários.
- Q3: placeholders `REPLACE_VIA_ENV_*` + fast-fail (FR-016).
- Padrão próximo ao `MonexUp.ApiTests/Fixtures/ApiTestFixture.cs`, mas removendo `Tenant`, `DeviceFingerprint`, `UserAgent`.

**Alternatives considered**:
- Usar `HttpClient` puro em vez de Flurl. Rejeitado: spec fixa Flurl (consistente com MonexUp e com SC-004).
- Fixture faz login lazily no primeiro request. Rejeitado: `IAsyncLifetime.InitializeAsync` é idiomático xUnit; falha cedo é desejável.

---

## Decision 5 — Diffs dos presets de auth

**Decision**: Cada preset listado abaixo é documentado como um bloco ≤ 30 linhas no SKILL.md, mostrando somente o que muda em `appsettings.Test.json` e em `ApiTestFixture.cs`:

- **NAuth** (MonexUp legacy): adiciona `Auth.Tenant`, `Auth.UserAgent`, `Auth.DeviceFingerprint`; no `InitializeAsync` injeta `X-Tenant-Id`, `User-Agent`, `X-Device-Fingerprint` no login E nos helpers; `CreateAuthenticatedRequest`/`CreateAnonymousRequest` passam os headers.
- **OAuth2 client credentials**: substitui `Email`/`Password` por `ClientId`/`ClientSecret`; body do login vira `grant_type=client_credentials&client_id=...&client_secret=...` (form-urlencoded, não JSON).
- **API key por header**: elimina `InitializeAsync` (não há login); `Auth` só tem `ApiKey`; `CreateAuthenticatedRequest` adiciona `X-Api-Key: {ApiKey}` em vez de bearer.

**Rationale**:
- FR-014 exige ≥ 2 presets além do default; 3 cobre o espaço prático (legacy tenant-based, OAuth2 moderno, key estática).
- Diffs ≤ 30 linhas cada mantém SKILL.md ≤ 400 linhas (SC-010).

**Alternatives considered**:
- Basic Auth. Rejeitado: raro em APIs modernas e fácil de improvisar a partir do API key preset.
- mTLS. Rejeitado: requer infra não-trivial; fora do escopo.

---

## Decision 6 — Critério de desambiguação unit vs API no `qa-developer`

**Decision**: Atualização do `qa-developer.md` adiciona ao `## Default Behavior` a regra:

> When the request says "tests" without qualifying, ask the user (via `AskUserQuestion`) whether they want **unit tests** (invokes `dotnet-test`) or **external API tests** (invokes `dotnet-test-api`) before proceeding. When the request explicitly says "unit tests" / "xUnit service tests" / "domain tests" → invoke `dotnet-test`. When it says "API tests" / "HTTP tests" / "integration tests via HTTP" / "external tests" → invoke `dotnet-test-api`.

**Rationale**:
- FR-010, FR-011, FR-012.
- Evita regressão em SC-002 (pedidos claros de unit continuam indo para `dotnet-test`).
- Evita escolha silenciosa em pedido ambíguo (US4 acceptance #3).

**Alternatives considered**:
- Default para `dotnet-test` sem perguntar. Rejeitado: viola US4 acceptance #3 e SC-001 (pode roteirizar mal um pedido de API).
- Regex/keyword matching automático sem fallback de pergunta. Rejeitado: frágil em pedidos em português ou híbridos.

---

## Decision 7 — Alvo do auto-detect do projeto DTO

**Decision**: A skill escaneia `.sln` (`dotnet sln list` ou leitura direta) em busca de sub-projetos cujo nome termina em um dos sufixos canônicos: `.DTO`, `.Dto`, `.Dtos`, `.Contracts`, `.Models`, `.Shared`. Case-insensitive. Resultado:

- 0 candidatos → `AskUserQuestion` oferece opção "usar payloads inline" + opção "informar caminho manualmente".
- 1 candidato → referencia automaticamente; informa ao usuário a escolha.
- 2+ candidatos → `AskUserQuestion` com a lista + opção "nenhum — usar payloads inline".

**Rationale**:
- Q2 fixou detect-and-prompt.
- Sufixos cobrem convenções observadas em `dotnet-architecture` (`.DTO`), APIs com `.Contracts`, projetos simples com `.Models`, e compartilhados com `.Shared`.
- Case-insensitive reduz falhas por variação de case.

**Alternatives considered**:
- Escanear classes dentro de projetos por herança de marker interface (ex.: `IDto`). Rejeitado: heurística frágil; nem todo projeto usa marker.
- Perguntar sempre, mesmo com 1 candidato. Rejeitado: fricção desnecessária quando a resposta é óbvia.

---

## Decision 8 — Empacotamento da skill (estrutura de arquivos internos)

**Decision**: Skill composta por **um único arquivo** `skills/dotnet-test-api/SKILL.md`. Sem subpastas `references/`, `scripts/`, `assets/` neste primeiro release. Os templates de código (csproj, appsettings, fixture, etc.) vão como code fences dentro do SKILL.md.

**Rationale**:
- SC-010 limita a 400 linhas; templates cabem.
- Skills irmãs `dotnet-*` também são single-file.
- Simplifica descoberta e revisão.

**Alternatives considered**:
- Quebrar cada preset em `references/preset-nauth.md` etc. Rejeitado: viola o pattern do repo para skills `dotnet-*` e adiciona overhead sem ganho tangível.
- Colocar templates em `contracts/` do spec e referenciar. Rejeitado: `contracts/` é artefato de spec-kit (Phase 1), não da skill publicada.

---

## Open Questions

Nenhuma. Todas as decisões resolvidas pela combinação spec + clarifications + Constitution + convenções das skills irmãs + código real do MonexUp.
