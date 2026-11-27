---
name: dotnet-auth
description: "Padrão de autenticação de usuários em APIs .NET 8 com JWT Bearer (HS256): JwtSettings via IOptions (expiração padrão de 90 dias, configurável), emissão do token, AddJwtBearer, hash de senha PBKDF2, cadastro/login/me, leitura do usuário logado pelas claims e Swagger. Use para adicionar ou revisar autenticação JWT num projeto .NET seguindo Clean Architecture."
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Task
user-invocable: true
---

# dotnet-auth — autenticação JWT em .NET

Padrão consolidado dos projetos .NET da emagine (finami, Roll6, ambrosio). Encaixa nas camadas
da skill `dotnet-architecture` (DTO → Infra.Interfaces → Domain → Infra → Application → API).

## Entrada

Contexto opcional em `$ARGUMENTS` (ex.: "só login por email", "com roles", "SignalR"). Sem argumentos,
aplique o padrão completo: cadastro, login, `me`, roles opcionais.

## 0. Antes de começar

1. Leia a solução: nomes dos projetos (`{Project}.DTO`, `.Domain`, `.Infra.Interfaces`, `.Infra`,
   `.Application`, `.API`), o `Startup.cs` da Application, a entidade de usuário (se existir) e a
   forma como os controllers tratam erros. **Siga o que já existe**; este padrão preenche o que falta.
2. A autenticação é **sempre própria do projeto**, com este padrão. **Não** usar NAuth (sistema
   legado): nada de pacote `NAuth`, `NAuthHandler`, `IUserClient` ou chamadas à API do NAuth em
   código novo. Multi-tenant com secret por tenant: combine com `dotnet-multi-tenant`.
3. Pacotes:

   | Projeto | Pacote |
   |---|---|
   | `{Project}.Infra` | `System.IdentityModel.Tokens.Jwt` 8.x, `Microsoft.Extensions.Identity.Core` 8.x |
   | `{Project}.Application` (ou API, onde estiver o DI) | `Microsoft.AspNetCore.Authentication.JwtBearer` 8.x |

## 1. Decisões do padrão

| Item | Padrão |
|---|---|
| Esquema | `Authorization: Bearer {token}` — `JwtBearerDefaults.AuthenticationScheme` |
| Algoritmo | HS256 (`SecurityAlgorithms.HmacSha256`), chave `Encoding.UTF8` do `Jwt:Secret` |
| Tamanho mínimo do secret | **32 bytes** — a API **não sobe** com secret menor (fail-fast) |
| Expiração | **90 dias** (`Jwt:ExpirationDays = 90`), configurável por ambiente (`Jwt__ExpirationDays`) |
| Validação | issuer, audience, lifetime e assinatura; `ClockSkew = 1 min` |
| Claims | `sub` (userId), `email`, `name`, `jti`; `role` (uma por papel) quando houver roles |
| Mapeamento de claims | `MapInboundClaims = false` (claims chegam com o nome curto: `sub`, `email`, `role`) |
| Senha | `PasswordHasher<T>` do ASP.NET Core Identity (PBKDF2-HMAC-SHA256 com salt), com rehash |
| Resposta do login | `{ token, expiresAt, user }` — `expiresAt` em UTC, igual ao `exp` do token |
| Usuário logado | `User.GetUserId()` (claim `sub`) — **nunca** aceitar userId do body/query para "quem sou eu" |
| Refresh token | não há: ao expirar, o cliente faz login de novo |

## 2. DTO — `{Project}.DTO`

### `Settings/JwtSettings.cs`

```csharp
namespace {Project}.DTO.Settings;

public class JwtSettings
{
    public const int DEFAULT_EXPIRATION_DAYS = 90;
    public const int MIN_SECRET_BYTES = 32;

    public string Secret { get; set; } = string.Empty;
    public string Issuer { get; set; } = "{project}";
    public string Audience { get; set; } = "{project}";
    public int ExpirationDays { get; set; } = DEFAULT_EXPIRATION_DAYS;
}
```

### `Auth/AuthDtos.cs`

```csharp
using System.Text.Json.Serialization;
using {Project}.DTO.Users;

namespace {Project}.DTO.Auth;

public class RegisterInfo
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("email")]
    public string Email { get; set; } = string.Empty;

    [JsonPropertyName("password")]
    public string Password { get; set; } = string.Empty;
}

public class LoginInfo
{
    [JsonPropertyName("email")]
    public string Email { get; set; } = string.Empty;

    [JsonPropertyName("password")]
    public string Password { get; set; } = string.Empty;
}

public class AuthResult
{
    [JsonPropertyName("token")]
    public string Token { get; set; } = string.Empty;

    [JsonPropertyName("expiresAt")]
    public DateTime ExpiresAt { get; set; }

    [JsonPropertyName("user")]
    public UserInfo User { get; set; } = new();
}
```

`UserInfo` (em `Users/`) **nunca** expõe `PasswordHash`.

## 3. Infra.Interfaces — contratos (`{Project}.Infra.Interfaces/AppServices`)

Infra.Interfaces não depende do Domain: os contratos usam tipos primitivos.

```csharp
namespace {Project}.Infra.Interfaces.AppServices;

public interface IJwtTokenAppService
{
    (string Token, DateTime ExpiresAt) Generate(long userId, string email, string name, IEnumerable<string>? roles = null);
}

public interface IPasswordHashAppService
{
    string Hash(string password);
    /// <summary>Retorna (válida, precisa de rehash).</summary>
    (bool Valid, bool NeedsRehash) Verify(string passwordHash, string password);
}
```

## 4. Infra — implementações (`{Project}.Infra/AppServices`)

### `JwtTokenAppService.cs`

```csharp
using System.Globalization;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using {Project}.DTO.Settings;
using {Project}.Infra.Interfaces.AppServices;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace {Project}.Infra.AppServices;

public class JwtTokenAppService : IJwtTokenAppService
{
    private readonly JwtSettings _settings;

    public JwtTokenAppService(IOptions<JwtSettings> settings)
    {
        _settings = settings.Value;
    }

    public (string Token, DateTime ExpiresAt) Generate(long userId, string email, string name, IEnumerable<string>? roles = null)
    {
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, userId.ToString(CultureInfo.InvariantCulture)),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString("N")),
            new(JwtRegisteredClaimNames.Email, email),
            new(JwtRegisteredClaimNames.Name, name)
        };
        if (roles != null)
            claims.AddRange(roles.Select(role => new Claim("role", role)));

        var now = DateTime.UtcNow;
        // `exp` tem granularidade de segundos: truncar garante expiresAt == exp do token.
        var expiresAt = TruncateToSeconds(now.AddDays(_settings.ExpirationDays));

        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.Secret)),
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _settings.Issuer,
            audience: _settings.Audience,
            claims: claims,
            notBefore: now,
            expires: expiresAt,
            signingCredentials: credentials);

        return (new JwtSecurityTokenHandler().WriteToken(token), expiresAt);
    }

    private static DateTime TruncateToSeconds(DateTime value) =>
        new(value.Ticks - (value.Ticks % TimeSpan.TicksPerSecond), value.Kind);
}
```

### `PasswordHashAppService.cs`

```csharp
using {Project}.Infra.Interfaces.AppServices;
using Microsoft.AspNetCore.Identity;

namespace {Project}.Infra.AppServices;

/// <summary>PBKDF2-HMAC-SHA256 com salt (formato v3 do ASP.NET Core Identity).</summary>
public class PasswordHashAppService : IPasswordHashAppService
{
    private static readonly object HASH_OWNER = new();
    private readonly PasswordHasher<object> _hasher = new();

    public string Hash(string password) => _hasher.HashPassword(HASH_OWNER, password);

    public (bool Valid, bool NeedsRehash) Verify(string passwordHash, string password)
    {
        var result = _hasher.VerifyHashedPassword(HASH_OWNER, passwordHash, password);
        return (result != PasswordVerificationResult.Failed,
                result == PasswordVerificationResult.SuccessRehashNeeded);
    }
}
```

Coluna no banco: `password_hash varchar(260)` **nullable** (usuário de login social não tem senha).
Projeto que já tem hashes em outro formato (ex.: BCrypt) mantém a verificação deles — não migre
hashes existentes sem pedido.

## 5. Domain — `IAuthService` / `AuthService`

```csharp
namespace {Project}.Domain.Services;

public class AuthService : IAuthService
{
    public const string INVALID_CREDENTIALS = "Email ou senha inválidos.";

    private readonly IUserRepository<User> _userRepository;
    private readonly IPasswordHashAppService _passwordHash;
    private readonly IJwtTokenAppService _jwtToken;

    public AuthService(IUserRepository<User> userRepository, IPasswordHashAppService passwordHash, IJwtTokenAppService jwtToken)
    {
        _userRepository = userRepository;
        _passwordHash = passwordHash;
        _jwtToken = jwtToken;
    }

    public async Task<AuthResult> RegisterAsync(RegisterInfo info)
    {
        // validação (FluentValidation, skill dotnet-fluent-validation): email válido, senha >= 8
        var email = info.Email.Trim().ToLowerInvariant();
        if (await _userRepository.ExistsEmailAsync(email))
            throw new ConflictException("Este email já está em uso.");

        var user = new User { Name = info.Name.Trim(), Email = email, PasswordHash = _passwordHash.Hash(info.Password) };
        await _userRepository.InsertAsync(user);
        return BuildResult(user);
    }

    public async Task<AuthResult> LoginAsync(LoginInfo info)
    {
        var user = await _userRepository.GetByEmailAsync(info.Email.Trim().ToLowerInvariant());
        // Mensagem sempre genérica: não revelar se o email existe.
        if (user == null || !user.IsActive || string.IsNullOrEmpty(user.PasswordHash))
            throw new UnauthorizedException(INVALID_CREDENTIALS);

        var (valid, needsRehash) = _passwordHash.Verify(user.PasswordHash, info.Password);
        if (!valid)
            throw new UnauthorizedException(INVALID_CREDENTIALS);
        if (needsRehash)
        {
            user.PasswordHash = _passwordHash.Hash(info.Password);
            await _userRepository.UpdateAsync(user);
        }
        return BuildResult(user);
    }

    public async Task<UserInfo> GetMeAsync(long userId)
    {
        var user = await _userRepository.GetByIdAsync(userId) ?? throw new UnauthorizedException();
        return user.ToInfo();
    }

    private AuthResult BuildResult(User user)
    {
        var (token, expiresAt) = _jwtToken.Generate(user.UserId, user.Email, user.Name, user.Roles);
        return new AuthResult { Token = token, ExpiresAt = expiresAt, User = user.ToInfo() };
    }
}
```

Regras: email normalizado (trim + minúsculas) no cadastro e no login; usuário inativo/bloqueado não
loga; troca de senha exige a senha atual e usa o mesmo `IPasswordHashAppService`.

## 6. Application — DI e validação na subida (`Startup.cs`)

```csharp
public static void AddAuthentication{Project}(this IServiceCollection services, IConfiguration configuration)
{
    services.Configure<JwtSettings>(configuration.GetSection("Jwt"));
    var jwt = configuration.GetSection("Jwt").Get<JwtSettings>() ?? new JwtSettings();

    if (Encoding.UTF8.GetByteCount(jwt.Secret) < JwtSettings.MIN_SECRET_BYTES)
        throw new InvalidOperationException(
            $"Jwt:Secret deve ter pelo menos {JwtSettings.MIN_SECRET_BYTES} bytes. Defina a variável Jwt__Secret.");
    if (jwt.ExpirationDays <= 0)
        throw new InvalidOperationException("Jwt:ExpirationDays deve ser maior que zero.");

    services.AddScoped<IJwtTokenAppService, JwtTokenAppService>();
    services.AddScoped<IPasswordHashAppService, PasswordHashAppService>();
    services.AddScoped<IAuthService, AuthService>();

    services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            options.MapInboundClaims = false;
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = jwt.Issuer,
                ValidateAudience = true,
                ValidAudience = jwt.Audience,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.Secret)),
                ValidAlgorithms = new[] { SecurityAlgorithms.HmacSha256 },
                ClockSkew = TimeSpan.FromMinutes(1),
                NameClaimType = "name",
                RoleClaimType = "role"
            };
        });
    services.AddAuthorization();
}
```

No `Program.cs`: `app.UseAuthentication();` **antes** de `app.UseAuthorization();`.

**SignalR** (opcional): navegadores não mandam header no WebSocket — aceite `access_token` da query
**só** nos caminhos `/hubs`:

```csharp
options.Events = new JwtBearerEvents
{
    OnMessageReceived = context =>
    {
        var token = context.Request.Query["access_token"];
        if (!string.IsNullOrEmpty(token) && context.HttpContext.Request.Path.StartsWithSegments("/hubs"))
            context.Token = token;
        return Task.CompletedTask;
    }
};
```

## 7. Configuração (`appsettings*.json` / variáveis de ambiente)

```json
"Jwt": {
  "Secret": "",
  "Issuer": "{project}",
  "Audience": "{project}",
  "ExpirationDays": 90
}
```

| Variável | Obrigatória | Descrição |
|---|---|---|
| `Jwt__Secret` | Sim | ≥ 32 bytes, aleatório (`openssl rand -base64 48`). Só em secrets/env, nunca commitado |
| `Jwt__Issuer` / `Jwt__Audience` | Não | Padrão: nome do projeto em minúsculas |
| `Jwt__ExpirationDays` | Não | Padrão **90**. Ex.: `1` em homologação, `30` para apps sensíveis |

`appsettings.Development.json` pode ter um secret de desenvolvimento (≥ 32 bytes); `appsettings.json`
e `appsettings.Production.json` ficam com `"Secret": ""`. Organização por ambiente: skill `dotnet-env`.
No cluster (`k8s-deploy`) o secret vem do GitHub (`<APP>_JWT_SECRET` → `Jwt__Secret`).

## 8. API — usuário logado e controller

### `Extensions/ClaimsPrincipalExtensions.cs`

```csharp
using System.Security.Claims;

namespace {Project}.API.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static long GetUserId(this ClaimsPrincipal principal)
    {
        var value = principal.FindFirstValue("sub") ?? principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(value) || !long.TryParse(value, out var userId))
            throw new UnauthorizedException();
        return userId;
    }

    public static string? GetEmail(this ClaimsPrincipal principal) => principal.FindFirstValue("email");
}
```

Na base dos controllers: `protected long CurrentUserId => User.GetUserId();`.

### `Controllers/AuthController.cs`

```csharp
[ApiController]
[Route("api/auth")]
[Authorize]
public class AuthController : {Project}ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService) => _authService = authService;

    [HttpPost("register")]
    [AllowAnonymous]
    public Task<IActionResult> Register([FromBody] RegisterInfo info) =>
        Execute(async () => StatusCode(StatusCodes.Status201Created, await _authService.RegisterAsync(info)));

    [HttpPost("login")]
    [AllowAnonymous]
    public Task<IActionResult> Login([FromBody] LoginInfo info) =>
        Execute(async () => Ok(await _authService.LoginAsync(info)));

    [HttpGet("me")]
    public Task<IActionResult> Me() =>
        Execute(async () => Ok(await _authService.GetMeAsync(CurrentUserId)));
}
```

- `[Authorize]` na classe e `[AllowAnonymous]` só nos endpoints públicos (falha segura).
- `UnauthorizedException` → **401**, sem dados extras; erro de validação → 400; email repetido → 409.
- Roles: `[Authorize(Roles = "admin")]` (funciona porque `RoleClaimType = "role"`).

### Swagger

```csharp
services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http, Scheme = "bearer", BearerFormat = "JWT",
        In = ParameterLocation.Header, Description = "Informe apenas o token JWT."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        { new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } }, Array.Empty<string>() }
    });
});
```

## 9. Frontend / mobile (consumidores)

- Header `Authorization: Bearer {token}` em toda chamada autenticada.
- Web: token em `localStorage` (constitution do frontend); mobile: `SecureStorage`.
- Guardar `expiresAt`; ao receber **401**, limpar a sessão e mandar para o login.

## 10. Proibido (anti-padrões encontrados)

- Logar senha, hash ou token — nem em `LogTrace`.
- Usar o NAuth (pacote, handler ou API) — é legado; a autenticação é própria do projeto.
- Expiração fixa no código (`AddMonths(2)`): sempre `JwtSettings.ExpirationDays`.
- `Encoding.ASCII` na chave, secret curto ou secret commitado.
- Desligar validação de issuer/audience/lifetime ou aceitar outro algoritmo além de HS256.
- Mensagens diferentes para "email não existe" e "senha errada".
- Guardar senha com hash rápido (MD5/SHA puro) ou sem salt.
- Ler o userId do body/query em vez da claim `sub`.
- Colocar dados sensíveis nas claims (o payload do JWT é só Base64, não é criptografado).

## 11. Testes (via `qa-developer` / skills `dotnet-test` e `dotnet-test-api`)

- `JwtTokenAppService`: claims `sub`/`email`/`name`, `exp` = `expiresAt`, expiração padrão = 90 dias
  e respeita `ExpirationDays` configurado.
- `PasswordHashAppService`: hash ≠ senha, verifica certa/errada, dois hashes da mesma senha diferem.
- `AuthService`: login inválido gera a mesma mensagem nos dois casos; email duplicado → conflito.
- Startup: secret < 32 bytes e `ExpirationDays <= 0` impedem a subida.
- API: endpoint protegido sem token → 401; token expirado/assinado com outro secret → 401.

## Checklist

- [ ] `JwtSettings` com `ExpirationDays = 90` e seção `Jwt` em todos os `appsettings*.json`
- [ ] Validação de secret (≥ 32 bytes) e expiração na subida
- [ ] `MapInboundClaims = false`, `NameClaimType = "name"`, `RoleClaimType = "role"`
- [ ] `UseAuthentication()` antes de `UseAuthorization()`
- [ ] Senhas com `PasswordHashAppService`; `UserInfo` sem hash
- [ ] Controllers com `[Authorize]` na classe e `[AllowAnonymous]` explícito
- [ ] Swagger com esquema Bearer
- [ ] Nenhum log de senha/token; `Jwt__Secret` só em secrets
