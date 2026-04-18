# Princípios Inegociáveis — .NET MAUI

> Padrões obrigatórios de stack tecnológica, convenções de código, arquitetura e acessibilidade que devem ser seguidos por todos os contribuidores em todos os projetos .NET MAUI.

**Created:** 2026-04-02
**Last Updated:** 2026-04-02

---

## Skills Obrigatórias

Para implementação de novas entidades e funcionalidades, as seguintes skills **DEVEM** ser utilizadas:

| Skill | Quando usar | Invocação |
|---|---|---|
| **maui-architecture** | Criar/modificar Models SQLite, AutoMapper profiles, ViewModels, Pages XAML, Shell navigation e DI no MauiProgram.cs | `/maui-architecture` |

Esta skill cobre em detalhe:
- Estrutura de projetos e fluxo de dependência
- Models SQLite com atributos (`[Table]`, `[PrimaryKey]`, `[AutoIncrement]`, `[MaxLength]`)
- AutoMapper profiles (DTO ↔ Model)
- AppDatabase e registro no DI
- ViewModels com CommunityToolkit.Mvvm (ObservableProperty, RelayCommand)
- Pages XAML e Shell routing
- Registro de serviços e páginas no `MauiProgram.cs`

**NÃO** reimplemente esses padrões manualmente — siga as skills.

---

## 1. Stack Tecnológica

### MAUI App

| Tecnologia | Versão | Finalidade |
|---|---|---|
| .NET MAUI | 8.0 | Framework multiplataforma (Android, iOS, Windows, macOS) |
| CommunityToolkit.Mvvm | Latest | MVVM source generators (ObservableProperty, RelayCommand) |
| SQLite-net | Latest | Banco de dados local no dispositivo |
| AutoMapper | Latest | Mapeamento DTO ↔ Model SQLite |
| Shell | Nativo MAUI | Navegação e roteamento |

### Regras de Stack

- **NÃO** introduzir ORMs alternativos (Dapper, EF Core, etc.) — SQLite-net é o único ORM permitido.
- **NÃO** executar comandos `docker` ou `docker compose` no ambiente local — Docker não está acessível.
- **NÃO** usar frameworks MVVM alternativos (Prism, MVVMLight) — CommunityToolkit.Mvvm é o padrão.
- **NÃO** usar Xamarin.Forms — apenas .NET MAUI.

---

## 2. Convenções de Código

### MAUI App (.NET)

| Elemento | Convenção | Exemplo |
|---|---|---|
| ViewModels | PascalCase + sufixo `ViewModel` | `CampaignListViewModel`, `CampaignDetailViewModel` |
| Pages | PascalCase + sufixo `Page` | `CampaignListPage`, `CampaignDetailPage` |
| Models SQLite | PascalCase | `CampaignModel` |
| ObservableProperties | camelCase (campo) → PascalCase (gerado) | `[ObservableProperty] string name;` → `Name` |
| Commands | PascalCase + sufixo `Command` (gerado) | `[RelayCommand] async Task LoadData()` → `LoadDataCommand` |
| Shell Routes | kebab-case | `campaign-detail`, `campaign-list` |

---

## 3. Convenções de Banco de Dados (SQLite)

| Elemento | Convenção | Exemplo |
|---|---|---|
| Tabelas | PascalCase plural (atributo `[Table]`) | `[Table("Campaigns")]` |
| Primary Keys | `Id` ou `{Entidade}Id`, autoincrement | `[PrimaryKey, AutoIncrement] public int Id` |
| Colunas | PascalCase (propriedades C#) | `CampaignId`, `CreatedAt` |
| Strings | `[MaxLength]` quando aplicável | `[MaxLength(260)]` |
| Booleans | `bool` com valor default no construtor | `IsActive = true` |
| Status/Enums | `int` | `Status = 1` |

> **Nota:** Registro do `AppDatabase` e padrões de acesso são detalhados na skill `maui-architecture`.

---

## 4. Autenticação e Segurança

| Aspecto | Padrão |
|---|---|
| Storage | SecureStorage para tokens e dados sensíveis |
| Preferences | Apenas para configurações não-sensíveis |

### Regras de Segurança

- **NUNCA** armazenar tokens em texto plano — usar SecureStorage.
- **NUNCA** expor secrets ou API keys hardcoded no app.

---

## 5. Padrões de Tratamento de Erros

Padrões de tratamento de erros no MAUI (try/catch em Commands, exibição de alertas) são cobertos pela skill `maui-architecture`.

---

## 7. Checklist para Novos Contribuidores

Antes de submeter qualquer código, verifique:

- [ ] Utilizou a skill `maui-architecture` para novas entidades (Model, ViewModel, Page, Shell route)
- [ ] Models SQLite possuem atributos corretos (`[Table]`, `[PrimaryKey]`, `[AutoIncrement]`)
- [ ] ViewModels usam CommunityToolkit.Mvvm (ObservableProperty, RelayCommand)
- [ ] Pages estão registradas no Shell e no DI (`MauiProgram.cs`)
- [ ] Tokens armazenados via SecureStorage
