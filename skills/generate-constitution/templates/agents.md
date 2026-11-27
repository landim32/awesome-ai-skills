## Responsabilidades dos Agentes

Toda tarefa DEVE ser executada pelo agente responsável. Um agente que receber uma tarefa fora do seu
escopo DEVE declarar que ela está fora do escopo, indicar o agente responsável e parar.

<!-- Mantenha só as linhas aplicáveis (coluna "Entra quando") e depois apague essa coluna. -->

| Agente | Responsabilidade | Pastas | Entra quando |
|---|---|---|---|
| `analyst` | Documentação, README, diagramas Mermaid; especificações e análise de requisitos | `docs/`, `README.md` | sempre |
| `ux-designer` | Direção visual, design tokens, mockups HTML/CSS, specs de componentes, ícones/banners — **nunca** código `.tsx`/XAML | `docs/design/` (ou pasta de design definida) | houver frontend ou mobile |
| `dotnet-developer` | API .NET: Clean Architecture, EF Core, migrations, validação, autenticação JWT (`dotnet-auth`), configuração | `__BACKEND_DIR__/` | houver backend |
| `frontend-react-developer` | Frontend React + TypeScript: types, services, contexts, hooks, páginas, i18n, implementação dos designs do `ux-designer` | `__FRONTEND_DIR__/` | houver frontend |
| `dotnet-mobile-developer` | App .NET MAUI: Models SQLite, ViewModels, Pages XAML, Shell, DI, build do APK | `__MOBILE_DIR__/` | houver mobile |
| `qa-developer` | Testes unitários (`<Solution>.Tests`) e testes de API (`<Solution>.ApiTests`) — só testes | projetos de teste em `__BACKEND_DIR__/` | houver backend |
| `devops-engineer` | Infraestrutura: Dockerfiles, ambientes .NET (`dotnet-env`: `appsettings.{Ambiente}.json`, `docker-compose`, `.env`), deploy em produção — cluster Kubernetes (`k8s-deploy`) ou servidor via SSH + docker compose (`deploy-prod`), operação do cluster, DNS/Cloudflare | `deploy/`, `.github/workflows/`, `Dockerfile`s, `docker-compose*.yml`, `appsettings.*.json`, `.env.example`, `.env.prod.example` | sempre |

### Regras de colaboração

- **Fluxo de uma funcionalidade**: `analyst` (especificação) → `ux-designer` (design, se houver UI)
  → desenvolvedor(es) do componente → `qa-developer` (testes) → `devops-engineer` (deploy).
- Mudança que atravessa componentes (ex.: novo endpoint + tela) é dividida por agente; nenhum agente
  implementa a parte do outro.
- Ajustes de aplicação exigidos pelo deploy (endpoint `/health`, forwarded headers, variáveis de
  ambiente) são feitos pelo desenvolvedor do componente, a pedido do `devops-engineer`.
- O `ux-designer` entrega especificações; quem converte em código é o `frontend-react-developer`
  (web) ou o `dotnet-mobile-developer` (mobile).
