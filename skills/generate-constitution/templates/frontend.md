## Frontend (`__FRONTEND_DIR__/`)

Responsável: `frontend-react-developer` (design: `ux-designer`).

### Stack Tecnológica

| Tecnologia | Versão | Finalidade |
|---|---|---|
| React | 18.x | Framework UI |
| TypeScript | 5.x | Tipagem estática |
| React Router | 6.x | Roteamento SPA |
| Vite | 6.x | Build toolchain |
| Tailwind CSS | 4.x | Estilização utility-first (layout, grid e componentes) |
| i18next | 25.x | Internacionalização |
| Fetch API | Nativo | HTTP client (novos serviços; Axios 1.x só em código legado) |

- **Vite é o bundler obrigatório** — NÃO usar CRA, Webpack manual ou outros bundlers.
- **Tailwind CSS é obrigatório** — NÃO usar Bootstrap, React-Bootstrap, Material UI ou outros
  frameworks CSS de componentes.
- **NÃO** adicionar state management (Redux, Zustand, MobX) — Context API é o padrão.
- Skills de apoio: `add-react-i18n` (i18n), `react-modal`, `react-alert`, `frontend-design`.

### Case Sensitivity de Diretórios (Inviolável)

| Diretório | Casing | Motivo |
|---|---|---|
| `Contexts/` | Uppercase C | Compatibilidade Docker/Linux |
| `Services/` | Uppercase S | Compatibilidade Docker/Linux |
| `hooks/` | Lowercase h | Convenção React |
| `types/` | Lowercase t | Convenção TypeScript |

**Todos os imports DEVEM corresponder exatamente ao casing no disco.**

### Convenções de Código (TypeScript/React)

| Elemento | Convenção | Exemplo |
|---|---|---|
| Componentes | PascalCase | `LoginPage`, `CampaignCard` |
| Interfaces | PascalCase | `CampaignContextType` |
| Variáveis / Funções | camelCase | `getHeaders`, `loadCampaigns` |
| Constantes | UPPER_CASE | `AUTH_STORAGE_KEY` |
| Tipos | `interface` (não `type`) | `interface CampaignInfo {}` |
| Funções | Arrow functions | `const fn = () => {}` |
| Variáveis | `const` por padrão | `const campaigns = []` |

### Autenticação e Segurança

- Header `Authorization: Bearer {token}` em toda chamada autenticada (JWT do backend, skill `dotnet-auth`).
- Guardar o `expiresAt` do login; ao receber **401**, limpar a sessão e redirecionar para o login.
- **NUNCA** armazenar tokens em cookies — usar localStorage.
- **NUNCA** expor connection strings ou secrets no frontend.

### Variáveis de Ambiente

| Variável | Obrigatória | Descrição |
|---|---|---|
| `VITE_API_URL` | Sim, se houver API | URL base da API (vazio = mesma origem, atrás do mesmo Ingress) |
| `VITE_SITE_BASENAME` | Não | Base path do React Router |

**Prefixo obrigatório `VITE_`** — acessar via `import.meta.env.VITE_*`. **NÃO** usar `REACT_APP_`.

### Checklist do Frontend

- [ ] Utilizou a skill `react-architecture` para novas entidades
- [ ] Imports respeitam o casing exato dos diretórios
- [ ] Variáveis de ambiente usam prefixo `VITE_`
- [ ] Telas novas seguem a especificação do `ux-designer`
