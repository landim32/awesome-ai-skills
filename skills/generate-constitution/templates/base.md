# Princípios Inegociáveis — __PROJECT__

> Padrões obrigatórios de stack tecnológica, convenções de código, arquitetura, estrutura de pastas e
> responsabilidades dos agentes que devem ser seguidos por todos os contribuidores (pessoas e agentes).

**Created:** __TODAY__
**Last Updated:** __TODAY__

---

## Skills Obrigatórias

Para implementação de novas entidades e funcionalidades, as seguintes skills **DEVEM** ser utilizadas:

<!-- Mantenha só as linhas dos componentes presentes no projeto. -->

| Skill | Quando usar | Invocação |
|---|---|---|
| **dotnet-architecture** | Criar/modificar entidades, services, repositories, DTOs, migrations, DI no backend | `/dotnet-architecture` |
| **dotnet-auth** | Criar/alterar autenticação de usuários (JWT Bearer, cadastro, login, `me`, hash de senha, roles) no backend | `/dotnet-auth` |
| **react-architecture** | Criar Types, Service, Context, Hook e registrar Provider no frontend | `/react-architecture` |
| **maui-architecture** | Criar/modificar Models SQLite, AutoMapper profiles, ViewModels, Pages XAML, Shell e DI no `MauiProgram.cs` | `/maui-architecture` |
| **k8s-deploy** | Configurar e operar o deploy no cluster Kubernetes (se o deploy for no cluster) | `/k8s-deploy` |
| **deploy-prod** | Gerar a pipeline de deploy em produção via SSH + docker compose (se o deploy for num servidor) | `/deploy-prod` |

**NÃO** reimplemente esses padrões manualmente — siga as skills.

---

## Regras Gerais

- **Docker** roda apenas dentro do WSL2 (skill `wsl-docker`) — **NÃO** existe `docker` no Windows;
  não tente executá-lo diretamente no PowerShell/Git Bash.
- **Secrets** (connection strings, tokens, chaves) **NUNCA** entram no Git, em logs ou no código
  cliente (frontend/mobile).
- **Versionamento** com GitVersion (`GitVersion.yml` + workflows `version-tag.yml` e
  `create-release.yml`, gerados pela skill `gitversion`).
- **Commits** usam o prefixo **`fix:`** (patch) por padrão. Outro prefixo — `feat:` (minor),
  `major:`/`breaking:`/`!` (major) — **somente** quando o usuário pedir explicitamente. Escopo
  opcional: `fix(api): ...`. Só commitar/push quando solicitado.
- **Documentação** em `docs/` (pt-BR por padrão, sufixo `.pt-BR.md`), mantida pelo agente `analyst`.
- Cada agente só altera as pastas sob sua responsabilidade (seção **Responsabilidades dos Agentes**).

---

## Governança

- Esta constitution prevalece sobre qualquer outra prática ou preferência individual.
- Emendas só via `/speckit.constitution` (ou `/generate-constitution`), com incremento de versão
  semântico: MAJOR (remoção/redefinição de princípio), MINOR (princípio ou seção nova), PATCH
  (clarificação/redação).
- Todo plano (`/speckit.plan`) e toda revisão de código DEVEM verificar conformidade com estes
  princípios; desvios precisam de justificativa explícita no plano.
