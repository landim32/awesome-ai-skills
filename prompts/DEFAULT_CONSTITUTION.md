# Princípios Inegociáveis

> Padrões obrigatórios de stack tecnológica, convenções de código, arquitetura e acessibilidade que devem ser seguidos por todos os contribuidores em todos os projetos.

**Created:** 2026-04-02
**Last Updated:** 2026-04-02

---

## Skills Obrigatórias

Para implementação de novas entidades e funcionalidades, as seguintes skills **DEVEM** ser utilizadas:

| Skill | Quando usar | Invocação |
|---|---|---|
| **dotnet-architecture** | Criar/modificar entidades, services, repositories, DTOs, migrations, DI no backend | `/dotnet-architecture` |
| **react-architecture** | Criar Types, Service, Context, Hook e registrar Provider no frontend | `/react-architecture` |

Estas skills cobrem em detalhe:
- Estrutura de projetos e fluxo de dependência (Clean Architecture backend)
- Regras de repositórios genéricos, mapeamento manual, DI centralizado
- Configuração de DbContext, Fluent API e migrações via `dotnet ef`
- Padrões de arquivos frontend (Types, Services, Contexts, Hooks)
- Provider chain e registro de novos providers
- Padrões de tratamento de erros no frontend (handleError, clearError, loading state)
- Convenções de nomeação de DTOs (`Info`, `InsertInfo`, `Result`) e chaves portuguesas (`sucesso`, `mensagem`, `erros`)

**NÃO** reimplemente esses padrões manualmente — siga as skills.

---

## 1. Stack Tecnológica

### Backend

| Tecnologia | Versão | Finalidade |
|---|---|---|
| .NET | 8.0 | Runtime e framework principal |
| Entity Framework Core | 9.x | ORM e migrações |
| PostgreSQL | Latest | Banco de dados relacional |
| NAuth | Latest | Autenticação (Basic token) |
| zTools | Latest | Upload S3, e-mail (MailerSend), slugs |
| Swashbuckle | 8.x | Swagger / OpenAPI |

### Frontend

| Tecnologia | Versão | Finalidade |
|---|---|---|
| React | 18.x | Framework UI |
| TypeScript | 5.x | Tipagem estática |
| React Router | 6.x | Roteamento SPA |
| Vite | 6.x | Build toolchain |
| Bootstrap | 5.x | Sistema de grid e componentes base |
| i18next | 25.x | Internacionalização |
| Axios | 1.x | HTTP client (legado) |
| Fetch API | Nativo | HTTP client (novos serviços) |

### Regras de Stack

- **Vite é o bundler obrigatório** — NÃO usar CRA, Webpack manual, ou outros bundlers.
- **NÃO** introduzir ORMs alternativos (Dapper, etc.) — EF Core é o único ORM permitido.
- **NÃO** adicionar bibliotecas de state management (Redux, Zustand, MobX) — Context API é o padrão.
- **NÃO** executar comandos `docker` ou `docker compose` no ambiente local — Docker não está acessível.
- Variáveis de ambiente frontend usam prefixo `VITE_` (padrão Vite). **NÃO** usar `REACT_APP_`.

---

## 2. Case Sensitivity de Diretórios (Inviolável)

| Diretório | Casing | Motivo |
|---|---|---|
| `Contexts/` | Uppercase C | Compatibilidade Docker/Linux |
| `Services/` | Uppercase S | Compatibilidade Docker/Linux |
| `hooks/` | Lowercase h | Convenção React |
| `types/` | Lowercase t | Convenção TypeScript |

**Todos os imports DEVEM corresponder exatamente ao casing no disco.**

---

## 3. Convenções de Código

### Backend (.NET)

| Elemento | Convenção | Exemplo |
|---|---|---|
| Namespaces | PascalCase | `{Nome do Projeto}.Domain.Services` |
| Classes / Interfaces | PascalCase | `CampaignService`, `ICampaignRepository` |
| Métodos | PascalCase | `GetById()`, `MapToDto()` |
| Propriedades | PascalCase | `CampaignId`, `CreatedAt` |
| Campos privados | _camelCase | `_repository`, `_context` |
| Constantes | UPPER_CASE | `BUCKET_NAME` |
| Namespaces | File-scoped | `namespace {Nome do Projeto}.API;` |

### Frontend (TypeScript/React)

| Elemento | Convenção | Exemplo |
|---|---|---|
| Componentes | PascalCase | `LoginPage`, `CampaignCard` |
| Interfaces | PascalCase | `CampaignContextType` |
| Variáveis / Funções | camelCase | `getHeaders`, `loadCampaigns` |
| Constantes | UPPER_CASE | `AUTH_STORAGE_KEY` |
| Tipos | `interface` (não `type`) | `interface CampaignInfo {}` |
| Funções | Arrow functions | `const fn = () => {}` |
| Variáveis | `const` por padrão | `const campaigns = []` |

### JSON Property Names

- Backend: `[JsonPropertyName("camelCase")]` em todas as propriedades de DTOs.
- Frontend: Acesso direto via camelCase nos tipos TypeScript.

---

## 4. Convenções de Banco de Dados (PostgreSQL)

| Elemento | Convenção | Exemplo |
|---|---|---|
| Tabelas | snake_case plural | `campaigns`, `campaign_entries` |
| Colunas | snake_case | `campaign_id`, `created_at` |
| Primary Keys | `{entidade}_id`, bigint identity | `campaign_id bigint PK` |
| Constraint PK | `{tabela}_pkey` | `campaigns_pkey` |
| Foreign Keys | `fk_{pai}_{filho}` | `fk_campaign_entry` |
| Delete behavior | `ClientSetNull` | Nunca Cascade |
| Timestamps | `timestamp without time zone` | Sem timezone |
| Strings | `varchar` com MaxLength | `varchar(260)` |
| Booleans | `boolean` com default | `DEFAULT true` |
| Status/Enums | `integer` | `DEFAULT 1` |

> **Nota:** Configuração de DbContext, Fluent API e comandos de migração são detalhados na skill `dotnet-architecture`.

---

## 5. Autenticação e Segurança

| Aspecto | Padrão |
|---|---|
| Esquema | Basic Authentication via NAuth |
| Header | `Authorization: Basic {token}` |
| Storage (frontend) | localStorage key `"login-with-metamask:auth"` |
| Handler | `NAuthHandler` registrado no DI |
| Proteção de rotas | Atributo `[Authorize]` nos controllers |

### Regras de Segurança

- **NUNCA** armazenar tokens em cookies — usar localStorage.
- **NUNCA** expor connection strings ou secrets no frontend.
- Controllers com dados sensíveis DEVEM ter `[Authorize]`.
- CORS configurado como `AllowAnyOrigin` apenas em Development.

---

## 6. Variáveis de Ambiente

### Backend

| Variável | Obrigatória | Descrição |
|---|---|---|
| `ConnectionStrings__{Nome do Projeto}Context` | Sim | Connection string PostgreSQL |
| `ASPNETCORE_ENVIRONMENT` | Sim | Development, Docker, Production |

### Frontend

| Variável | Obrigatória | Descrição |
|---|---|---|
| `VITE_API_URL` | Sim | URL base da API backend |
| `VITE_SITE_BASENAME` | Não | Base path do React Router |

**Prefixo obrigatório `VITE_`** — padrão Vite. Acessar via `import.meta.env.VITE_*`.

---

## 7. Padrões de Tratamento de Erros — Backend

```csharp
try { /* lógica */ }
catch (Exception ex) { return StatusCode(500, ex.Message); }
```

> **Nota:** Padrões de tratamento de erros no frontend (handleError, clearError, loading state) são cobertos pela skill `react-architecture`.

---

## 8. Checklist para Novos Contribuidores

Antes de submeter qualquer código, verifique:

- [ ] Utilizou a skill `dotnet-architecture` para novas entidades backend
- [ ] Utilizou a skill `react-architecture` para novas entidades frontend
- [ ] Tabelas e colunas seguem snake_case no PostgreSQL
- [ ] Imports respeitam o casing exato dos diretórios
- [ ] Variáveis de ambiente frontend usam prefixo `VITE_`
- [ ] Controllers com dados sensíveis possuem `[Authorize]`
