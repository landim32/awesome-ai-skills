# Princípios Inegociáveis

> Padrões obrigatórios de stack tecnológica, convenções de código e arquitetura backend que devem ser seguidos por todos os contribuidores em todos os projetos.

**Created:** 2026-04-02
**Last Updated:** 2026-04-02

---

## Skills Obrigatórias

Para implementação de novas entidades e funcionalidades, as seguintes skills **DEVEM** ser utilizadas:

| Skill | Quando usar | Invocação |
|---|---|---|
| **dotnet-architecture** | Criar/modificar entidades, services, repositories, DTOs, migrations, DI no backend | `/dotnet-architecture` |

Estas skills cobrem em detalhe:
- Estrutura de projetos e fluxo de dependência (Clean Architecture backend)
- Regras de repositórios genéricos, mapeamento manual, DI centralizado
- Configuração de DbContext, Fluent API e migrações via `dotnet ef`
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

### Regras de Stack

- **NÃO** introduzir ORMs alternativos (Dapper, etc.) — EF Core é o único ORM permitido.
- **NÃO** executar comandos `docker` ou `docker compose` no ambiente local — Docker não está acessível.

---

## 2. Convenções de Código

### .NET

| Elemento | Convenção | Exemplo |
|---|---|---|
| Namespaces | PascalCase | `<nome-do-projeto>.Domain.Services` |
| Classes / Interfaces | PascalCase | `CampaignService`, `ICampaignRepository` |
| Métodos | PascalCase | `GetById()`, `MapToDto()` |
| Propriedades | PascalCase | `CampaignId`, `CreatedAt` |
| Campos privados | _camelCase | `_repository`, `_context` |
| Constantes | UPPER_CASE | `BUCKET_NAME` |
| Namespaces | File-scoped | `namespace <nome-do-projeto>.API;` |

### JSON Property Names

- `[JsonPropertyName("camelCase")]` em todas as propriedades de DTOs.

---

## 3. Convenções de Banco de Dados (PostgreSQL)

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

## 4. Autenticação e Segurança

| Aspecto | Padrão |
|---|---|
| Esquema | Basic Authentication via NAuth |
| Header | `Authorization: Basic {token}` |
| Handler | `NAuthHandler` registrado no DI |
| Proteção de rotas | Atributo `[Authorize]` nos controllers |

### Regras de Segurança

- **NUNCA** expor connection strings ou secrets em respostas da API.
- Controllers com dados sensíveis DEVEM ter `[Authorize]`.
- CORS configurado como `AllowAnyOrigin` apenas em Development.

---

## 5. Variáveis de Ambiente

| Variável | Obrigatória | Descrição |
|---|---|---|
| `ConnectionStrings__<nome-do-projeto>Context` | Sim | Connection string PostgreSQL |
| `ASPNETCORE_ENVIRONMENT` | Sim | Development, Docker, Production |

---

## 6. Padrões de Tratamento de Erros

```csharp
try { /* lógica */ }
catch (Exception ex) { return StatusCode(500, ex.Message); }
```

---

## 7. Checklist para Novos Contribuidores

Antes de submeter qualquer código, verifique:

- [ ] Utilizou a skill `dotnet-architecture` para novas entidades backend
- [ ] Tabelas e colunas seguem snake_case no PostgreSQL
- [ ] Controllers com dados sensíveis possuem `[Authorize]`
