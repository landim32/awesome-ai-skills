## Mobile (`__MOBILE_DIR__/`)

Responsável: `dotnet-mobile-developer` (design: `ux-designer`). O app consome a API do backend.

### Stack Tecnológica

| Tecnologia | Versão | Finalidade |
|---|---|---|
| .NET MAUI | 8.0 | Framework multiplataforma (Android, iOS, Windows, macOS) |
| CommunityToolkit.Mvvm | Latest | MVVM source generators (ObservableProperty, RelayCommand) |
| SQLite-net | Latest | Banco de dados local no dispositivo |
| AutoMapper | Latest | Mapeamento DTO ↔ Model SQLite |
| Shell | Nativo MAUI | Navegação e roteamento |

- **NÃO** usar outros ORMs no app (Dapper, EF Core) — SQLite-net é o único permitido.
- **NÃO** usar frameworks MVVM alternativos (Prism, MVVMLight) — CommunityToolkit.Mvvm é o padrão.
- **NÃO** usar Xamarin.Forms — apenas .NET MAUI.
- Build do APK pelo workflow reutilizável `build-apk.yml`.

### Convenções de Código (MAUI)

| Elemento | Convenção | Exemplo |
|---|---|---|
| ViewModels | PascalCase + sufixo `ViewModel` | `CampaignListViewModel` |
| Pages | PascalCase + sufixo `Page` | `CampaignListPage` |
| Models SQLite | PascalCase | `CampaignModel` |
| ObservableProperties | camelCase (campo) → PascalCase (gerado) | `[ObservableProperty] string name;` → `Name` |
| Commands | PascalCase + sufixo `Command` (gerado) | `[RelayCommand] async Task LoadData()` → `LoadDataCommand` |
| Shell Routes | kebab-case | `campaign-detail` |

### Banco Local (SQLite)

| Elemento | Convenção | Exemplo |
|---|---|---|
| Tabelas | PascalCase plural (`[Table]`) | `[Table("Campaigns")]` |
| Primary Keys | `Id` ou `{Entidade}Id`, autoincrement | `[PrimaryKey, AutoIncrement] public int Id` |
| Colunas | PascalCase | `CampaignId`, `CreatedAt` |
| Strings | `[MaxLength]` quando aplicável | `[MaxLength(260)]` |
| Booleans | `bool` com default no construtor | `IsActive = true` |
| Status/Enums | `int` | `Status = 1` |

### Autenticação e Segurança

- Header `Authorization: Bearer {token}` nas chamadas à API (JWT do backend, skill `dotnet-auth`);
  ao receber **401**, limpar a sessão e voltar para o login.
- Tokens e dados sensíveis **só** em `SecureStorage`; `Preferences` apenas para configurações
  não sensíveis.
- **NUNCA** secrets ou API keys hardcoded no app.

### Tratamento de Erros

Try/catch nos Commands e exibição de alertas conforme a skill `maui-architecture`.

### Checklist do Mobile

- [ ] Utilizou a skill `maui-architecture` (Model, ViewModel, Page, Shell route)
- [ ] Models SQLite com `[Table]`, `[PrimaryKey]`, `[AutoIncrement]`
- [ ] ViewModels com CommunityToolkit.Mvvm
- [ ] Pages registradas no Shell e no DI (`MauiProgram.cs`)
- [ ] Tokens armazenados via SecureStorage
