# Princípios Inegociáveis — Frontend

> Padrões obrigatórios de stack tecnológica, convenções de código e arquitetura que devem ser seguidos por todos os contribuidores em projetos frontend.

**Created:** 2026-04-02
**Last Updated:** 2026-04-06

---

## Skills Obrigatórias

Para implementação de novas funcionalidades frontend, a seguinte skill **DEVE** ser utilizada:

| Skill | Quando usar | Invocação |
|---|---|---|
| **react-architecture** | Criar Types, Service, Context, Hook e registrar Provider no frontend | `/react-architecture` |

Esta skill cobre em detalhe:
- Padrões de arquivos frontend (Types, Services, Contexts, Hooks)
- Provider chain e registro de novos providers
- Padrões de tratamento de erros no frontend (handleError, clearError, loading state)

**NÃO** reimplemente esses padrões manualmente — siga a skill.

---

## 1. Stack Tecnológica

| Tecnologia | Versão | Finalidade |
|---|---|---|
| React | 18.x | Framework UI |
| TypeScript | 5.x | Tipagem estática |
| React Router | 6.x | Roteamento SPA |
| Vite | 6.x | Build toolchain |
| Bootstrap | 5.x | Sistema de grid e componentes base |
| i18next | 25.x | Internacionalização |
| Axios | 1.x | HTTP client (legado) |
| Fetch API | Nativo | HTTP client (novos serviços) |

### Regras de Stack

- **Vite é o bundler obrigatório** — NÃO usar CRA, Webpack manual, ou outros bundlers.
- **NÃO** adicionar bibliotecas de state management (Redux, Zustand, MobX) — Context API é o padrão.
- **NÃO** executar comandos `docker` ou `docker compose` no ambiente local — Docker não está acessível.
- Variáveis de ambiente frontend usam prefixo `VITE_` (padrão Vite). **NÃO** usar `REACT_APP_`.

---

## 2. Case Sensitivity de Diretórios (Inviolável)

| Diretório | Casing | Motivo |
|---|---|---|
| `Contexts/` | Uppercase C | Compatibilidade Docker/Linux |
| `Services/` | Uppercase S | Compatibilidade Docker/Linux |
| `hooks/` | Lowercase h | Convenção React |
| `types/` | Lowercase t | Convenção TypeScript |

**Todos os imports DEVEM corresponder exatamente ao casing no disco.**

---

## 3. Convenções de Código (TypeScript/React)

| Elemento | Convenção | Exemplo |
|---|---|---|
| Componentes | PascalCase | `LoginPage`, `CampaignCard` |
| Interfaces | PascalCase | `CampaignContextType` |
| Variáveis / Funções | camelCase | `getHeaders`, `loadCampaigns` |
| Constantes | UPPER_CASE | `AUTH_STORAGE_KEY` |
| Tipos | `interface` (não `type`) | `interface CampaignInfo {}` |
| Funções | Arrow functions | `const fn = () => {}` |
| Variáveis | `const` por padrão | `const campaigns = []` |

---

## 4. Autenticação e Segurança

| Aspecto | Padrão |
|---|---|
| Header | `Authorization: Basic {token}` |
| Storage | localStorage key `"login-with-metamask:auth"` |

### Regras de Segurança

- **NUNCA** armazenar tokens em cookies — usar localStorage.
- **NUNCA** expor connection strings ou secrets no frontend.

---

## 5. Variáveis de Ambiente

| Variável | Obrigatória | Descrição |
|---|---|---|
| `VITE_API_URL` | Sim | URL base da API backend |
| `VITE_SITE_BASENAME` | Não | Base path do React Router |

**Prefixo obrigatório `VITE_`** — padrão Vite. Acessar via `import.meta.env.VITE_*`.

---

## 6. Checklist para Novos Contribuidores

Antes de submeter qualquer código, verifique:

- [ ] Utilizou a skill `react-architecture` para novas entidades frontend
- [ ] Imports respeitam o casing exato dos diretórios
- [ ] Variáveis de ambiente frontend usam prefixo `VITE_`
