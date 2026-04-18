# Feature Specification: Skill `dotnet-test-api` — Testes de API externa em .NET

**Feature Branch**: `003-dotnet-test-api`
**Created**: 2026-04-18
**Status**: Draft
**Input**: User description: "Crie uma skill teste de API chamada 'dotnet-test-api': se baseie no projeto MonexUp (`C:\repos\MonexUp`), leia a spec `C:\repos\MonexUp\specs\003-unit-api-tests` para entender como foi criado, inclua ela para uso do agente 'qa-developer'."

## Clarifications

### Session 2026-04-18

- Q: Qual é o template de autenticação default emitido pela skill? → A: Generic JWT Bearer — skeleton mínimo (email + password + endpoint configurável), zero headers proprietários (`X-Tenant-Id`, `X-Device-Fingerprint`, etc.). Adaptação para NAuth e outros schemes é documentada como preset/seção na SKILL.md, não como default.
- Q: Como a skill escolhe qual projeto referenciar para tipagem de payloads? → A: Detect-and-prompt — escaneia o `.sln` por projetos com sufixos conhecidos (`.DTO`, `.Dto`, `.Dtos`, `.Contracts`, `.Models`, `.Shared`). Se encontra um único candidato, referencia automaticamente; se encontra múltiplos ou nenhum, pergunta ao usuário via `AskUserQuestion` com a lista (opção "nenhum — usar payloads inline" incluída).
- Q: Qual política de secrets em `appsettings.Test.json` a skill impõe? → A: Template + env overrides **obrigatórios**. O arquivo gerado contém placeholders não-funcionais (ex.: `"Email": "REPLACE_VIA_ENV_Auth__Email"`) e o SKILL.md documenta a convenção double-underscore para fornecer valores reais via variáveis de ambiente (local dev + CI/CD secrets). Credenciais reais nunca vão para o arquivo commitado.
- Q: A skill `dotnet-test-api` é `user-invocable` ou apenas chamada pelo `qa-developer`? → A: `user-invocable: true` — paridade com `dotnet-test`. O `qa-developer` permanece o caminho canônico (com desambiguação unit vs API), mas o power-user pode invocar a skill diretamente quando quer feedback imediato.
- Q: Qual escopo de factory methods a skill gera em `TestDataHelper.cs`? → A: On-demand per controller — factories são adicionadas apenas quando o controller correspondente recebe testes (criação ou adição). `TestDataHelper.cs` começa vazio no boot do projeto e cresce incrementalmente. Sem factories órfãs para DTOs de controllers ainda não testados.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Criar projeto `.ApiTests` em solução .NET sem testes de API (Priority: P1)

Um engenheiro QA pede ao agente `qa-developer`: "crie os testes de API para o projeto X". O agente invoca a skill `dotnet-test-api` e gera um novo projeto `<Solution>.ApiTests` paralelo ao `<Solution>.Tests` (unit), com csproj configurado (xUnit + Flurl.Http + FluentAssertions + Configuration), `appsettings.Test.json` base, fixture compartilhada de autenticação (`ApiTestFixture` + `ApiTestCollection`), pasta `Controllers/` para os arquivos de teste por endpoint, e pasta `Helpers/` com `TestDataHelper`. O projeto é adicionado à solution via `dotnet sln add`.

**Why this priority**: É o caso de uso central da skill — criar a infraestrutura de testes de API externa do zero. Sem esse fluxo, a skill não tem valor.

**Independent Test**: Em uma solução .NET 8 sem testes de API, pedir "crie testes de API para os controllers X e Y". Ao final, rodar `dotnet test <Solution>.ApiTests/` e ver a suite executando (mesmo que falhando por ambiente) — significa que projeto, dependências, fixture e auth foram produzidos corretamente.

**Acceptance Scenarios**:

1. **Given** solução .NET sem projeto de testes de API, **When** a skill é invocada para "criar testes de API", **Then** cria `<Solution>.ApiTests.csproj` referenciando apenas o projeto de DTOs, com pacotes xUnit + Flurl.Http + FluentAssertions + Microsoft.Extensions.Configuration + coverlet.collector nas versões alinhadas ao MonexUp, e registra o projeto no `.sln`.
2. **Given** projeto recém-criado, **When** a skill gera o `appsettings.Test.json`, **Then** o arquivo contém `ApiBaseUrl`, bloco `Auth` (BaseUrl, Tenant, JwtSecret, UserAgent, DeviceFingerprint, Email, Password, LoginEndpoint) e `Timeout`, e é marcado como `CopyToOutputDirectory: PreserveNewest` no csproj.
3. **Given** projeto recém-criado, **When** a skill gera a fixture, **Then** `Fixtures/ApiTestFixture.cs` implementa `IAsyncLifetime`, faz login em `Auth:BaseUrl + Auth:LoginEndpoint` durante `InitializeAsync`, captura o token JWT, e expõe `CreateAuthenticatedRequest(path)` e `CreateAnonymousRequest(path)` como helpers Flurl com headers padrão (`X-Tenant-Id`, `User-Agent`, `X-Device-Fingerprint`). `Fixtures/ApiTestCollection.cs` registra `[CollectionDefinition("ApiTests")]`.

---

### User Story 2 - Adicionar arquivo de testes de um novo controller (Priority: P1)

A solução já tem `<Solution>.ApiTests` configurado. O engenheiro pede: "adicione testes para o `OrderController`". A skill gera `Controllers/OrderControllerTests.cs` com o padrão MonexUp: classe anotada `[Collection("ApiTests")]`, construtor recebendo a fixture, métodos `[Fact]` cobrindo cada endpoint (GET + POST/PUT conforme existir), asserts de status HTTP com FluentAssertions e cenários negativos de autenticação (401) onde aplicável. Dados de request vêm de `Helpers/TestDataHelper.cs`.

**Why this priority**: É o segundo caso de uso mais frequente — adicionar testes controller-a-controller. Mesma prioridade da US1 porque o fluxo "crie testes de API" quase sempre envolve N controllers.

**Independent Test**: Em uma solução já com `<Solution>.ApiTests` configurado, pedir "adicione testes para Controller X". Verificar que `Controllers/XControllerTests.cs` existe com `[Collection("ApiTests")]`, usa `_fixture.CreateAuthenticatedRequest` ou `CreateAnonymousRequest`, e os asserts usam FluentAssertions.

**Acceptance Scenarios**:

1. **Given** fixture e collection já presentes, **When** pedido adicionar testes para um controller com endpoints `[Authorize]` e `[AllowAnonymous]`, **Then** gera `[Fact]` distintos para cenário autenticado (não deve ser 401) e anônimo (deve ser 401 em endpoints protegidos), conforme padrão `OrderControllerTests.cs` do MonexUp.
2. **Given** um endpoint POST com payload complexo, **When** o teste é gerado, **Then** o payload é criado via método `TestDataHelper.Create<DTO>()` — nunca inline no teste.
3. **Given** endpoints com parâmetros de query/route, **When** os testes são gerados, **Then** usam `Flurl.Url.AppendPathSegment` ou `SetQueryParam` em vez de interpolação de string.

---

### User Story 3 - Rodar testes contra ambiente externo configurável (Priority: P2)

Um desenvolvedor quer rodar a suite contra staging em vez de local. A skill documenta como sobrescrever `appsettings.Test.json` via variáveis de ambiente (`ApiBaseUrl`, `Auth__*`) — o `ConfigurationBuilder` da fixture já carrega `AddEnvironmentVariables()`. O SKILL.md explica a convenção de double-underscore para seções aninhadas.

**Why this priority**: Configurabilidade de ambiente é importante para CI/CD mas não bloqueia a criação inicial do projeto.

**Independent Test**: Em uma solução com `.ApiTests` pronto, exportar `ApiBaseUrl=https://staging.example.com/api` e rodar `dotnet test`. A fixture pega a URL da env var em vez do arquivo.

**Acceptance Scenarios**:

1. **Given** `appsettings.Test.json` apontando para localhost e variável de ambiente `ApiBaseUrl` definida, **When** a fixture inicializa, **Then** usa o valor da variável de ambiente (padrão `AddEnvironmentVariables()` sobrescreve JSON).
2. **Given** credenciais de auth em variáveis `Auth__Email` e `Auth__Password`, **When** a fixture autentica, **Then** usa os valores das variáveis (convenção double-underscore para aninhamento).

---

### User Story 4 - Integração com o agente `qa-developer` (Priority: P1)

O agente `qa-developer` atualmente só compõe `dotnet-test` (unit). Esta feature atualiza o agente para também compor `dotnet-test-api` — quando o pedido mencionar "testes de API", "testes externos", "testes HTTP" ou "testes end-to-end da API", o agente invoca a nova skill em vez de (ou além de) `dotnet-test`. A seção `## Role & Scope` do agente é expandida para cobrir unit tests **e** external API tests.

**Why this priority**: Sem essa integração, a skill existe mas ninguém a invoca pelo caminho idiomático. É parte crítica do entregável.

**Independent Test**: Pedir ao `qa-developer` "crie testes de API para o projeto". O agente deve citar `dotnet-test-api` (não `dotnet-test`), gerar projeto `.ApiTests` (não adicionar ao `.Tests`). Pedir "crie testes unitários" deve continuar invocando `dotnet-test`.

**Acceptance Scenarios**:

1. **Given** pedido "testes de API" ou "testes HTTP externos" ao `qa-developer`, **When** o agente decide qual skill invocar, **Then** invoca `dotnet-test-api`, não `dotnet-test`.
2. **Given** pedido "testes unitários" ao `qa-developer`, **When** o agente decide, **Then** continua invocando `dotnet-test` — sem regressão.
3. **Given** pedido ambíguo ("crie testes"), **When** o agente responde, **Then** pergunta ao usuário qual tipo (unit ou API) em vez de escolher silenciosamente.

---

### Edge Cases

- O que acontece quando a solução **já tem** um `<Solution>.ApiTests`? A skill detecta, nunca sobrescreve o csproj/fixture existente, e só adiciona o novo arquivo de controller solicitado.
- O que acontece quando não existe submódulo `NAuth` ou equivalente de auth? A skill emite uma fixture genérica baseada em endpoint `POST /auth/login` customizável via `appsettings.Test.json`, e documenta no SKILL.md como adaptar para outros esquemas (Bearer manual, OAuth2, API key por header).
- O que acontece quando o controller testado é `[AllowAnonymous]` em todos os endpoints? A skill omite cenários de 401 e usa apenas `CreateAnonymousRequest`.
- O que acontece quando a API externa está offline durante o teste? O teste falha com exceção clara do Flurl; o SKILL.md documenta como rodar a suite em ambiente local (docker-compose) antes do push.
- O que acontece quando um endpoint retorna multipart (upload de imagem)? A skill referencia o padrão do `ImageControllerTests.cs` do MonexUp como exemplo — `.PostMultipartAsync` do Flurl.
- O que acontece quando o projeto alvo não é .NET 8? A skill detecta `<TargetFramework>` do `.sln`/csproj, e se for .NET 6/7/9 ajusta versões de pacotes para versões suportadas daquele framework; se for .NET Framework legado, declara out-of-scope.
- O que acontece quando `appsettings.Test.json` contém credenciais reais? O SKILL.md exige adicionar `appsettings.Test.json` ao `.gitignore` local se contiver secrets, e oferece modo "template + env overrides" como alternativa.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O repositório MUST conter uma nova skill em `skills/dotnet-test-api/SKILL.md` seguindo a convenção de frontmatter do Claude Code (`name`, `description`, `allowed-tools`, `user-invocable: true`) — paridade com `dotnet-test`. A skill é invocável diretamente pelo usuário via `/dotnet-test-api` **e** composta pelo agente `qa-developer`.
- **FR-002**: O SKILL.md MUST declarar seu propósito: criar projeto `<Solution>.ApiTests` separado do `<Solution>.Tests`, voltado a testes de integração HTTP contra uma API externa em URL configurável.
- **FR-003**: A skill MUST gerar csproj com as dependências canônicas: `xunit` (≥ 2.5), `xunit.runner.visualstudio`, `Microsoft.NET.Test.Sdk`, `FluentAssertions` (≥ 7.0), `Flurl.Http` (≥ 4.0), `Microsoft.Extensions.Configuration` + `.Json` + `.EnvironmentVariables` (≥ 9.0 quando alvo é .NET 8), `coverlet.collector` (≥ 6.0). A referência de projeto segue a regra **detect-and-prompt**: escaneia o `.sln` por projetos com sufixos `.DTO`, `.Dto`, `.Dtos`, `.Contracts`, `.Models`, `.Shared`; se exatamente 1 candidato, referencia automaticamente; se múltiplos ou zero candidatos, pergunta ao usuário via `AskUserQuestion` (a lista inclui a opção "nenhum — usar payloads inline"). Em nenhum caso referencia Domain, Application, Infra ou API.
- **FR-004**: A skill MUST gerar `appsettings.Test.json` com schema **genérico** (default): chaves `ApiBaseUrl`, bloco `Auth` com (`BaseUrl`, `Email`, `Password`, `LoginEndpoint`) e `Timeout`. **Todos os valores de credencial (`Email`, `Password`) e segredos são placeholders não-funcionais** no formato `"REPLACE_VIA_ENV_<ChaveCompleta>"` (ex.: `"REPLACE_VIA_ENV_Auth__Email"`). Valores não-sensíveis (ex.: `ApiBaseUrl` de localhost, `LoginEndpoint`, `Timeout`) podem ter defaults reais. O csproj MUST marcar `CopyToOutputDirectory: PreserveNewest` para o arquivo. Campos específicos de NAuth (`Tenant`, `JwtSecret`, `UserAgent`, `DeviceFingerprint`) vêm apenas no **preset NAuth** documentado na SKILL.md — não no default.
- **FR-005**: A skill MUST gerar `Fixtures/ApiTestFixture.cs` implementando `IAsyncLifetime`: em `InitializeAsync` faz POST de login (email + password) no endpoint configurado (`Auth:BaseUrl + Auth:LoginEndpoint`), captura o token JWT no campo `AuthToken`, e expõe os helpers `CreateAuthenticatedRequest(path)` (com `WithOAuthBearerToken(AuthToken)`) e `CreateAnonymousRequest(path)`. O default NÃO envia headers proprietários; presets (NAuth, OAuth2, API key) adicionam headers via seção separada no SKILL.md. Em caso de falha de auth, lança exceção com mensagem clara apontando a URL.
- **FR-006**: A skill MUST gerar `Fixtures/ApiTestCollection.cs` com `[CollectionDefinition("ApiTests")]` e `ICollectionFixture<ApiTestFixture>` para compartilhar a fixture entre todas as classes de teste.
- **FR-007**: A skill MUST gerar arquivos em `Controllers/<Name>ControllerTests.cs` seguindo o padrão: classe com `[Collection("ApiTests")]`, construtor com DI da fixture, métodos `[Fact]` com nomes no padrão `<Method>_<Condition>_ShouldReturn<Expected>`, asserts via FluentAssertions (`Should().Be(...)`), cenários de 401 para endpoints `[Authorize]` quando invocados anônimos.
- **FR-008**: A skill MUST gerar `Helpers/TestDataHelper.cs` como classe estática e crescê-la **on-demand por controller**: no boot (User Story 1) o arquivo é criado com a shell da classe (vazia ou com 1 exemplo mínimo). Cada invocação subsequente que adiciona testes para um controller MUST adicionar factories `Create<DTO>()` apenas para os DTOs usados pelos endpoints desse controller. Nunca gera factories para DTOs de controllers ainda não testados; nunca inclui payloads inline em arquivos de teste.
- **FR-009**: A skill MUST suportar sobrescrita de configuração via variáveis de ambiente (convenção double-underscore: `Auth__Email`, `ApiBaseUrl`, etc.), pois `AddEnvironmentVariables()` já é adicionado ao `ConfigurationBuilder`.
- **FR-010**: O repositório MUST atualizar `agents/qa-developer.md` para adicionar `dotnet-test-api` como Composed Skill ao lado de `dotnet-test`, com instrução de "quando invocar" distinguindo os dois (unit → `dotnet-test`; API externa / HTTP end-to-end → `dotnet-test-api`).
- **FR-011**: O `agents/qa-developer.md` MUST atualizar sua frontmatter `description` para refletir que o agente agora cobre **unit tests e external API tests** (não apenas unit).
- **FR-012**: O `agents/qa-developer.md` MUST atualizar o `## Role & Scope` para explicar a dupla responsabilidade e adicionar regra de desambiguação para pedidos genéricos de "testes" (perguntar qual tipo em vez de escolher).
- **FR-013**: A skill `dotnet-test-api` MUST nunca modificar código de produção — seu escopo é exclusivamente a pasta do novo projeto `<Solution>.ApiTests`. Deferência para `dotnet-senior-developer` se o controller precisar mudar para ser testável.
- **FR-014**: O SKILL.md MUST conter uma seção `## Auth Presets` com pelo menos 3 presets além do default: (a) **NAuth** (Tenant + DeviceFingerprint + UserAgent headers, `/user/loginWithEmail` — espelhando o MonexUp), (b) **OAuth2 client credentials** (grant_type=client_credentials, token endpoint), (c) **API key via header** (X-Api-Key estático, sem login). Cada preset mostra o diff de `appsettings.Test.json` e de `ApiTestFixture.cs` em relação ao default.
- **FR-015**: A skill MUST emitir, ao final da geração do projeto, um bloco de instruções "How to provide secrets" listando as variáveis de ambiente esperadas (uma por placeholder `REPLACE_VIA_ENV_*`), com exemplos para (a) shell local (`export Auth__Email=...` / `$env:Auth__Email = "..."`), (b) arquivo `.env` opcional, (c) secrets em CI/CD (ex.: GitHub Actions `secrets.*`). A skill MUST NÃO gerar credenciais reais no arquivo; qualquer credencial real detectada em input do usuário deve ser redirecionada para env var equivalente.
- **FR-016**: A skill MUST incluir, na fixture gerada (`Fixtures/ApiTestFixture.cs`), uma verificação em `InitializeAsync` que falha rápido com mensagem clara caso qualquer placeholder `REPLACE_VIA_ENV_*` permaneça no valor efetivo de config (significa que a env var não foi exportada). A mensagem MUST nomear a variável de ambiente faltante.

### Key Entities *(include if feature involves data)*

- **Skill `dotnet-test-api`**: arquivo `skills/dotnet-test-api/SKILL.md` com frontmatter Claude Code (`name`, `description`, `allowed-tools`, `user-invocable`) + corpo com convenções, estrutura de pastas, snippets de código canônicos, adaptações por esquema de auth.
- **Projeto `<Solution>.ApiTests`**: artefato .NET gerado pela skill — csproj + appsettings.Test.json + Fixtures/ + Controllers/ + Helpers/, integrado ao `.sln` via `dotnet sln add`.
- **Fixture de autenticação (`ApiTestFixture`)**: classe `IAsyncLifetime` que executa login uma vez por sessão de testes e compartilha o token via collection fixture.
- **Agente `qa-developer` (modificado)**: arquivo `agents/qa-developer.md` atualizado para compor `dotnet-test-api` ao lado de `dotnet-test`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% das invocações do `qa-developer` com pedidos do tipo "testes de API", "testes externos", "HTTP end-to-end" invocam `dotnet-test-api` — não `dotnet-test`. Verificável por revisão de transcript.
- **SC-002**: 100% das invocações do `qa-developer` com pedidos do tipo "testes unitários", "unit tests" continuam invocando `dotnet-test` (zero regressão). Verificável por revisão.
- **SC-003**: Um projeto gerado pela skill em solução .NET 8 limpa compila com `dotnet build` sem erros na primeira tentativa. Verificável em ambiente de teste.
- **SC-004**: A suite gerada executa com `dotnet test` em ≤ 60 segundos por controller quando a API externa responde em ≤ 2 s/request e tem até 10 endpoints por controller. Verificável por medição.
- **SC-005**: 100% dos arquivos de teste gerados usam FluentAssertions (`Should()`) para asserts — zero uso de `Assert.Equal` / `Assert.True` nativos do xUnit. Verificável por grep.
- **SC-006**: 100% dos payloads complexos (record/class DTO) nos testes são criados via `TestDataHelper.Create<T>()` — zero payloads inline com 2+ campos. Verificável por inspeção estática. Adicionalmente, 0 factories órfãs em `TestDataHelper.cs` — toda factory presente corresponde a pelo menos um uso em `Controllers/*Tests.cs`. Verificável por grep cruzado.
- **SC-007**: 100% dos endpoints anotados `[Authorize]` no controller testado recebem pelo menos 1 teste de 401 via `CreateAnonymousRequest`. Verificável por diff controller → testes.
- **SC-008**: O SKILL.md `dotnet-test-api` documenta ≥ 2 esquemas de auth alternativos ao NAuth/JWT (ex.: OAuth2 client credentials, API key por header). Verificável por inspeção do arquivo.
- **SC-009**: O arquivo `agents/qa-developer.md` lista `dotnet-test-api` em `## Composed Skills` com instrução clara de "quando invocar" que distingue do `dotnet-test`. Verificável por grep.
- **SC-010**: Arquivo `skills/dotnet-test-api/SKILL.md` permanece ≤ 400 linhas — é template/guia, não duplicação exaustiva de código. Verificável por `wc -l`.
- **SC-011**: 0 credenciais reais no `appsettings.Test.json` gerado. Todo campo de segredo é placeholder `REPLACE_VIA_ENV_*`. Verificável por grep de `REPLACE_VIA_ENV_` no arquivo produzido e grep negativo de `@` (email signature) e strings longas.
- **SC-012**: A fixture gerada falha com mensagem explícita (nomeando a env var) quando qualquer placeholder `REPLACE_VIA_ENV_*` permanece sem override. Verificável por teste da fixture sem env vars definidas.

## Assumptions

- O stack canônico do teste é **.NET 8** com **xUnit + Flurl.Http + FluentAssertions + Moq opcional** (Moq apenas se testes de API precisarem mockar algum serviço externo, o que é raro). Essa escolha segue integralmente o `MonexUp.ApiTests` (spec `003-unit-api-tests` do MonexUp).
- A skill foca em APIs REST com autenticação JWT via header Bearer. OAuth2 / API key / Basic são documentadas como variações, não como default.
- O projeto alvo pode, mas não precisa, seguir a convenção de solution com sub-projetos separados por camada (Domain, Application, Infra, DTO, API). Quando existir projeto de tipos compartilhados (sufixo `.DTO`/`.Dto`/`.Dtos`/`.Contracts`/`.Models`/`.Shared`), o `.ApiTests` referencia-o automaticamente; caso contrário, pergunta ou usa payloads inline.
- A skill NÃO é responsável por iniciar a API sendo testada — assume que ela está rodando na URL configurada (localmente via `docker-compose` ou em staging/preview).
- O nome da skill (`dotnet-test-api`) segue a convenção kebab-case do repositório (Constitution §V) e é disjunto de `dotnet-test` — são skills irmãs, não aninhadas.
- As credenciais NUNCA vão para `appsettings.Test.json`; o arquivo contém apenas placeholders `REPLACE_VIA_ENV_*` e a skill instrui o usuário a prover valores via variáveis de ambiente (local dev + CI/CD secrets). A fixture falha rápido se algum placeholder permanecer no runtime.
- A atualização do `qa-developer` preserva toda a regra name-and-stop existente (backend → `dotnet-senior-developer`, MAUI → `dotnet-mobile-developer`, etc.) — apenas amplia o que o agente *aceita*, não o que ele defere.
- O arquivo do agente permanece em inglês (Constitution §III: `agents/` EN-only) e segue a regra bilíngue de `## Output Language` estabelecida na feature 002.
