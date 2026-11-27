## Backend (`__BACKEND_DIR__/`)

Responsável: `dotnet-senior-developer` (testes: `qa-developer`).

### Stack Tecnológica

| Tecnologia | Versão | Finalidade |
|---|---|---|
| .NET | 8.0 | Runtime e framework principal |
| Entity Framework Core | 9.x | ORM e migrações |
| PostgreSQL | Latest | Banco de dados relacional |
| Swashbuckle | 8.x | Swagger / OpenAPI |

- **NÃO** introduzir ORMs alternativos (Dapper, etc.) — EF Core é o único ORM permitido.
- Skills de apoio: `dotnet-env` (ambientes Development/Docker/Production — arquivos de ambiente
  pelo `devops-engineer`, classes `IOptions` pelo `dotnet-senior-developer`),
  `dotnet-fluent-validation` (validação),
  `dotnet-test` / `dotnet-test-api` (testes, via `qa-developer`).

### Convenções de Código (.NET)

| Elemento | Convenção | Exemplo |
|---|---|---|
| Namespaces | PascalCase, file-scoped | `namespace __PROJECT__.Domain.Services;` |
| Classes / Interfaces | PascalCase | `CampaignService`, `ICampaignRepository` |
| Métodos | PascalCase | `GetById()`, `MapToDto()` |
| Propriedades | PascalCase | `CampaignId`, `CreatedAt` |
| Campos privados | _camelCase | `_repository`, `_context` |
| Constantes | UPPER_CASE | `BUCKET_NAME` |

- `[JsonPropertyName("camelCase")]` em todas as propriedades de DTOs.
- DTOs seguem `Info`, `InsertInfo`, `Result` e as chaves `sucesso`, `mensagem`, `erros`
  (detalhes na skill `dotnet-architecture`).

### Banco de Dados (PostgreSQL)

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

> DbContext, Fluent API e migrações (`dotnet ef`) são detalhados na skill `dotnet-architecture`.

### Autenticação e Segurança

<!-- Padrão: Basic Authentication. Troque a tabela se o usuário escolheu JWT Bearer
     (skill dotnet-auth: `Authorization: Bearer {token}`, `AddJwtBearer`, expiração `Jwt:ExpirationDays` = 90,
     configurável). NAuth é legado: não usar. -->

| Aspecto | Padrão |
|---|---|
| Esquema | Basic Authentication |
| Header | `Authorization: Basic {token}` |
| Handler | `AuthenticationHandler` customizado registrado no DI |
| Proteção de rotas | Atributo `[Authorize]` nos controllers |

- **NUNCA** expor connection strings ou secrets em respostas da API.
- Controllers com dados sensíveis DEVEM ter `[Authorize]`.
- CORS `AllowAnyOrigin` apenas em Development.
- A API confia em forwarded headers (`X-Forwarded-For`/`X-Forwarded-Proto`) e expõe `/health`.

### Variáveis de Ambiente

| Variável | Obrigatória | Descrição |
|---|---|---|
| `ConnectionStrings__Default` | Sim | Connection string PostgreSQL do `__PROJECT__` |
| `ASPNETCORE_ENVIRONMENT` | Sim | Development, Docker, Production |

### Tratamento de Erros

```csharp
try { /* lógica */ }
catch (Exception ex) { return StatusCode(500, ex.Message); }
```

### Checklist do Backend

- [ ] Utilizou a skill `dotnet-architecture` para novas entidades
- [ ] Tabelas e colunas seguem snake_case no PostgreSQL
- [ ] Controllers com dados sensíveis possuem `[Authorize]`
- [ ] Testes criados/atualizados pelo `qa-developer`
