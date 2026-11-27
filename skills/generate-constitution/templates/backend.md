## Backend (`__BACKEND_DIR__/`)

Responsável: `dotnet-developer` (testes: `qa-developer`).

### Stack Tecnológica

| Tecnologia | Versão | Finalidade |
|---|---|---|
| .NET | 8.0 | Runtime e framework principal |
| Entity Framework Core | 9.x | ORM e migrações |
| PostgreSQL | Latest | Banco de dados relacional |
| Swashbuckle | 8.x | Swagger / OpenAPI |

- **NÃO** introduzir ORMs alternativos (Dapper, etc.) — EF Core é o único ORM permitido.
- Skills de apoio: `dotnet-env` (ambientes Development/Docker/Production — arquivos de ambiente
  pelo `devops-engineer`, classes `IOptions` pelo `dotnet-developer`),
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

<!-- Padrão: JWT Bearer da skill dotnet-auth. Se o projeto não tiver login de usuários, troque esta
     seção por "API sem autenticação de usuários" e remova as linhas Jwt__* das variáveis.
     NAuth é legado: não usar. -->

Autenticação de usuários **sempre** pela skill `dotnet-auth` — **NÃO** criar esquemas próprios e
**NÃO** usar NAuth (legado).

| Aspecto | Padrão |
|---|---|
| Esquema | JWT Bearer (`JwtBearerDefaults.AuthenticationScheme`), HS256 |
| Header | `Authorization: Bearer {token}` |
| Expiração | **90 dias** por padrão (`Jwt:ExpirationDays`), configurável por ambiente |
| Secret | `Jwt:Secret` com ≥ 32 bytes; a API não sobe sem ele |
| Claims | `sub` (userId), `email`, `name`, `jti`, `role` |
| Senha | `PasswordHasher` do ASP.NET Core Identity (PBKDF2 com salt) |
| Endpoints | `POST api/auth/register`, `POST api/auth/login`, `GET api/auth/me` |
| Usuário logado | `User.GetUserId()` (claim `sub`) — nunca do body/query |
| Proteção de rotas | `[Authorize]` na classe do controller, `[AllowAnonymous]` explícito nos públicos |

- **NUNCA** logar senha, hash ou token, nem expor connection strings ou secrets em respostas da API.
- Login inválido devolve sempre a mesma mensagem genérica (não revelar se o email existe).
- Controllers com dados sensíveis DEVEM ter `[Authorize]`.
- CORS `AllowAnyOrigin` apenas em Development.
- A API confia em forwarded headers (`X-Forwarded-For`/`X-Forwarded-Proto`) e expõe `/health`.

### Variáveis de Ambiente

| Variável | Obrigatória | Descrição |
|---|---|---|
| `ConnectionStrings__Default` | Sim | Connection string PostgreSQL do `__PROJECT__` |
| `ASPNETCORE_ENVIRONMENT` | Sim | Development, Docker, Production |
| `Jwt__Secret` | Sim | Secret de assinatura do JWT (≥ 32 bytes; só em secrets, nunca no Git) |
| `Jwt__Issuer` / `Jwt__Audience` | Não | Padrão: `__PROJECT_SLUG__` |
| `Jwt__ExpirationDays` | Não | Expiração do token em dias (padrão `90`) |

### Tratamento de Erros

```csharp
try { /* lógica */ }
catch (Exception ex) { return StatusCode(500, ex.Message); }
```

### Checklist do Backend

- [ ] Utilizou a skill `dotnet-architecture` para novas entidades
- [ ] Tabelas e colunas seguem snake_case no PostgreSQL
- [ ] Autenticação feita com a skill `dotnet-auth` (sem NAuth)
- [ ] Controllers com dados sensíveis possuem `[Authorize]`
- [ ] Testes criados/atualizados pelo `qa-developer`
