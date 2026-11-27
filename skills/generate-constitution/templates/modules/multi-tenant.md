## Multi-Tenant (backend)

Responsável: `dotnet-developer` (skill `dotnet-multi-tenant`).

- Isolamento por **banco de dados separado por tenant** (ConnectionString dinâmica) e `JwtSecret`
  próprio por tenant, configurados em `Tenants:<TenantId>` no `appsettings.json`.
- Resolução do `TenantId`: endpoints não autenticados → header `X-Tenant-Id`; endpoints
  autenticados → claim `tenant_id` do JWT. Camada ACL lê `Tenant:DefaultTenantId` e injeta
  `X-Tenant-Id` via `DelegatingHandler` (nunca como parâmetro de método).
- **NÃO** alterar Models, DTOs ou a estrutura do DbContext para suportar multi-tenant.
- `X-Tenant-Id` ausente onde é obrigatório → `400 Bad Request`; configuração de tenant ausente
  (ConnectionString/JwtSecret) → exceção descritiva.
