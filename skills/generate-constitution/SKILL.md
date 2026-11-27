---
name: generate-constitution
description: "Gera a constitution do projeto (.specify/memory/constitution.md) via /speckit.constitution a partir de uma descrição do projeto: site (só frontend), webapp (backend + frontend), app mobile (backend + app) ou só API. Monta stack, convenções, estrutura de pastas (backend/, frontend/, mobile/ ou raiz) e responsabilidades dos agentes, pergunta o que ficar em aberto e referencia a constitution no CLAUDE.md."
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Skill, AskUserQuestion
user-invocable: true
---

# generate-constitution — constitution do projeto a partir de uma descrição

Monta um **rascunho de princípios** a partir dos fragmentos em `templates/` (ao lado deste arquivo),
entrega esse rascunho ao `/speckit.constitution` (que preenche `.specify/memory/constitution.md` e
sincroniza os templates do Spec Kit) e, por fim, referencia a constitution no `CLAUDE.md`.

## Entrada

Descrição do projeto em `$ARGUMENTS`. Se vier vazia, **pergunte** antes de qualquer coisa:
"Descreva o projeto: o que ele é, quem usa e o que vai ter (site, webapp, app mobile, API...)."

## Templates

```text
templates/
├── base.md                  # sempre: cabeçalho, regras gerais, governança
├── structure.md             # sempre: estrutura de pastas (raiz ou backend/ frontend/ mobile/)
├── agents.md                # sempre: responsabilidades dos agentes (só as linhas aplicáveis)
├── backend.md               # se tiver backend (.NET 8 + EF Core + PostgreSQL)
├── frontend.md              # se tiver frontend (React + Vite + Tailwind)
├── mobile.md                # se tiver app mobile (.NET MAUI)
└── modules/
    ├── k8s-deploy.md        # deploy no cluster Kubernetes (devops-engineer)
    ├── deploy-ssh.md        # deploy num servidor via SSH + docker compose (devops-engineer)
    ├── multi-tenant.md      # API multi-tenant
    └── external-bazzuca.md  # integração com redes sociais via BazzucaMedia
```

| Placeholder | Significado | Exemplo |
|---|---|---|
| `__PROJECT__` | nome do projeto em PascalCase (namespaces .NET, connection string) | `MeuApp` |
| `__PROJECT_SLUG__` | nome em minúsculas/kebab-case (pacote npm, namespace k8s) | `meuapp` |
| `__BACKEND_DIR__` | pasta do backend (`backend` ou `.` se for o único componente) | `backend` |
| `__FRONTEND_DIR__` | pasta do frontend (`frontend` ou `.`) | `frontend` |
| `__MOBILE_DIR__` | pasta do app mobile (`mobile` ou `.`) | `mobile` |
| `__TODAY__` | data de hoje (ISO) | `2026-11-27` |

## Fluxo

### 1. Pré-requisitos

1. Confirme que o Spec Kit está inicializado: `.specify/` e `.specify/memory/constitution.md` (ou
   `.specify/templates/constitution-template.md`) existem. Se não, pare e peça ao usuário para rodar
   `specify init --here --ai claude` (ou equivalente) antes.
2. Se `.specify/memory/constitution.md` já estiver preenchida (sem tokens `[ALL_CAPS]`), avise que
   ela será **emendada** (o speckit incrementa a versão) e pergunte se deve continuar.
3. Leia o projeto existente (se houver código): `*.sln`/`*.csproj`, `package.json`, pastas
   `backend/`, `frontend/`, `mobile/`, `deploy/k8s/`, `CLAUDE.md`, `README.md`. O que já existe no
   disco tem prioridade sobre a dedução da descrição — e divergências viram pergunta.

### 2. Classificar o projeto

| Descrição | Componentes | Layout |
|---|---|---|
| Site / landing page / site institucional / SPA sem API própria | frontend | raiz (`.`) |
| Webapp / sistema web / painel / SaaS | backend + frontend | `backend/` + `frontend/` |
| App mobile / aplicativo Android/iOS | backend + mobile | `backend/` + `mobile/` |
| App mobile **e** versão web | backend + frontend + mobile | `backend/` + `frontend/` + `mobile/` |
| API / serviço / microsserviço / worker | backend | raiz (`.`) |

Regra de layout: **um componente só → raiz**; **dois ou mais → uma pasta por componente**
(`backend/`, `frontend/`, `mobile/`), cada um com sua seção na constitution.

### 3. Perguntar o que ficou em aberto

Não invente. Use `AskUserQuestion` (até 4 perguntas por rodada, só o que **não** dá para deduzir da
descrição ou do código; a opção recomendada primeiro). Pontos típicos:

| Ponto | Quando perguntar | Padrão sugerido |
|---|---|---|
| Classificação | a descrição não deixa claro se há backend (ex.: "site com área do cliente", "app offline") | conforme tabela da etapa 2 |
| Nome do projeto | não há nome na descrição nem no repositório | — |
| Autenticação | há backend | Basic Authentication (padrão dos templates); alternativa: JWT Bearer próprio (skill `dotnet-auth`). **Não** oferecer NAuth (legado) |
| Multi-tenant | há backend e a descrição fala em clientes/empresas/tenants isolados | não |
| Deploy | sempre | cluster Kubernetes da emagine (`modules/k8s-deploy.md`); alternativas: servidor via SSH + docker compose (`modules/deploy-ssh.md`, skill `deploy-prod`) ou sem deploy definido ainda |
| Redes sociais | a descrição fala em postar/integrar redes sociais | BazzucaMedia (`modules/external-bazzuca.md`) |
| Idiomas da UI | há frontend ou mobile | pt-BR (com i18next no frontend) |

Repita até não restar ambiguidade. Se o usuário não souber, registre como `TODO(<ponto>)` na
constitution em vez de chutar.

### 4. Montar o rascunho

1. Leia os fragmentos aplicáveis e concatene nesta ordem: `base.md` → `structure.md` →
   `agents.md` → `backend.md` → `frontend.md` → `mobile.md` → módulos escolhidos (no máximo um
   módulo de deploy: `k8s-deploy.md` **ou** `deploy-ssh.md`).
2. Substitua os placeholders. Com um componente só, o diretório dele é `.` e os caminhos ficam na
   raiz (ex.: `./src`), e a seção de estrutura usa o bloco "raiz".
3. Em `structure.md` e `agents.md`, **mantenha só os blocos/linhas aplicáveis** (cada um diz quando
   entra) e remova os comentários `<!-- ... -->` de instrução.
4. Na tabela **Skills Obrigatórias** de `base.md`, deixe só as linhas dos componentes presentes.
5. Ajuste o que as respostas da etapa 3 mudaram (ex.: autenticação JWT em vez de Basic, idiomas).
6. Salve o rascunho **fora do repositório** (diretório temporário da sessão / scratchpad), ex.:
   `$SCRATCH/constitution-draft.md`.

### 5. Gerar com o Spec Kit

Invoque a skill `speckit.constitution` (ferramenta `Skill`) com `args` neste formato:

```text
Use o arquivo <caminho absoluto do rascunho> como fonte AUTORITATIVA dos princípios do projeto
__PROJECT__. Preserve todas as seções, tabelas, regras e a seção "Responsabilidades dos Agentes"
do rascunho (pode reorganizar no formato do template, mas não remover nem resumir regras).
PROJECT_NAME=__PROJECT__; RATIFICATION_DATE=__TODAY__ (se for a primeira versão);
LAST_AMENDED_DATE=__TODAY__. Idioma: português (pt-BR), identificadores técnicos em inglês.
```

Depois que ela terminar:

- Confira `.specify/memory/constitution.md`: nenhum token `[ALL_CAPS]` restante
  (`grep -nE '\[[A-Z_]{3,}\]' .specify/memory/constitution.md`), seção de agentes presente e uma
  seção por componente (com os caminhos `backend/`, `frontend/`, `mobile/` quando houver mais de um).
- Apague o rascunho temporário.

### 6. Referenciar no `CLAUDE.md`

Crie o `CLAUDE.md` na raiz se não existir (com um título `# CLAUDE.md` e uma linha de visão geral do
projeto). Adicione — ou substitua, se já existir — a seção abaixo, logo após a visão geral:

```markdown
## Constitution

A constitution do projeto está em [`.specify/memory/constitution.md`](.specify/memory/constitution.md)
e é **inegociável**: leia-a antes de planejar ou implementar qualquer mudança e siga suas regras de
stack, convenções, estrutura de pastas e responsabilidades dos agentes.

- Componentes: <ex.: backend (`backend/`) + frontend (`frontend/`)>
- Agentes: <ex.: `dotnet-senior-developer` → `backend/`; `frontend-react-developer` → `frontend/`; ...>
- Alterações na constitution só via `/speckit.constitution` (ou `/generate-constitution`).
```

Não duplique o conteúdo da constitution no `CLAUDE.md` — só a referência e o resumo acima.

### 7. Agentes no projeto

Verifique se os agentes citados existem em `.claude/agents/<nome>.md`. Os que faltarem: liste-os e
sugira instalá-los com a skill `install` (a partir do repositório `awesome-ai-skills`). Não instale
sem o usuário pedir.

### 8. Resumo final

Informe: classificação e layout escolhidos, respostas usadas, versão da constitution, arquivos
alterados (constitution, templates do Spec Kit, `CLAUDE.md`), TODOs pendentes e agentes faltando.
Não faça commit nem push sem pedido.

## Regras

- A constitution sai em **pt-BR**; identificadores, comandos e caminhos ficam em inglês.
- Não copie seções de componentes ausentes (ex.: site só frontend não tem seção de banco de dados).
- Não altere o código do projeto — esta skill só escreve a constitution, os templates do Spec Kit
  (via `speckit.constitution`) e o `CLAUDE.md`.
