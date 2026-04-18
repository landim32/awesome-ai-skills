# Feature Specification: Agente `ui-ux-pro-max-designer`

**Feature Branch**: `002-ui-ux-designer-agent`
**Created**: 2026-04-18
**Status**: Draft
**Input**: User description: "Crie um agente chamado 'ui-ux-pro-max-designer'. Esse agente é um designer UI UX, ele deve usar as skills: banner-design, brand, design, design-system, slides, ui-styling, ui-ux-pro-max. Leia e entenda as skills e se baseie nelas para criar o agente."

**Refinement (2026-04-18)**: "Inclua na spec as tecnologias que esse agente deve trabalhar: React + Vite + Tailwind." — stack alvo para User Story 1 e para entregas de componentes/telas definida como **React + Vite + Tailwind** (com shadcn/ui via `ui-styling`). As demais entregas (banners, slides, logo, CIP) não dependem dessa stack e seguem o que cada skill entrega (HTML/CSS estáticos, assets gerados por IA, etc.).

**Refinement (2026-04-18, attribution)**: "Inclua uma menção que esse agente foi criado baseado no repositório https://github.com/nextlevelbuilder/ui-ux-pro-max-skill." — o agente deve trazer, no cabeçalho do arquivo em `agents/`, uma linha de atribuição explícita a esse repositório upstream, identificado como a origem conceitual do skill `ui-ux-pro-max` (coração da composição). A atribuição é de crédito/proveniência, não de dependência técnica.

## Clarifications

### Session 2026-04-18

- Q: Qual o conjunto de tools no frontmatter do agente? → A: `Read, Grep, Glob, Bash, Write, Edit, Task, Skill, WebFetch` (superset com Bash para executar scripts dos skills + WebFetch para pesquisa visual/Pinterest refs).
- Q: Critério de roteamento entre `ui-ux-pro-max-designer` e `frontend-react-developer`? → A: Por tipo de output — código `.tsx` de componente/tela React é entregue por `frontend-react-developer`; design sem código React (mockups HTML/CSS, wireframes, tokens, direção visual, specs de componente) é entregue por `ui-ux-pro-max-designer`.
- Q: Em que idioma o agente responde? → A: No idioma em que for consultado (PT → PT, EN → EN). **Mudança de escopo**: esta regra aplica-se a TODOS os agentes do repositório — os agentes existentes (`frontend-react-developer`, `dotnet-senior-developer`, `dotnet-mobile-developer`, `qa-developer`, `analyst`) devem ser atualizados para seguir a mesma convenção bilíngue, substituindo a seção `## Output Language` atual ("English") por "Respond in the language of the request".
- Q: Como o agente reage quando um script invocado por um skill falha? → A: Report + propose — reportar o erro exato, propor 2-3 caminhos (retry, corrigir config, fallback sem script) e esperar a escolha do usuário antes de prosseguir. Nunca silenciar a falha nem inventar saída.
- Q: Onde os artefatos do agente são salvos? → A: Cada skill usa seus defaults documentados (ex.: `assets/banners/`, `docs/brand-guidelines.md`), e o agente MUST também produzir um índice em `docs/design/<feature>/README.md` apontando para todos os artefatos daquela entrega — ponto único de consumo por `frontend-react-developer` ao implementar o `.tsx`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Desenho de interfaces web/mobile com direção visual deliberada (Priority: P1)

Um desenvolvedor ou designer pede ao agente para **desenhar** (não codar em React) uma página (landing page, dashboard, painel admin, SaaS, e-commerce, portfolio, app mobile-web) ou um componente (botão, modal, navbar, sidebar, card, tabela, form, chart) para uma aplicação **React + Vite + Tailwind**. O agente compõe `ui-ux-pro-max` (inteligência de design — 50+ estilos, 161 paletas, 57 pares de fontes, 99 guidelines de UX, 161 tipos de produto), `ui-styling` (shadcn/ui + Tailwind + Radix como referência de padrões para a stack) e `design-system` (tokens primitive → semantic → component expostos como CSS variables e tema Tailwind) para entregar **direção visual + mockup HTML/CSS + spec de componente + tokens** prontos para serem implementados em `.tsx` por `frontend-react-developer`.

**Why this priority**: É o caso de uso central do agente. Desenho de interface é a tarefa mais frequente de um UI/UX e concentra o maior valor percebido pelo usuário (qualidade visual, acessibilidade, coerência de sistema).

**Independent Test**: Pedir ao agente uma tela de dashboard para SaaS B2B. O agente deve declarar uma direção visual nomeada (ex.: minimalismo, brutalismo, bento grid, claymorphism), invocar `ui-ux-pro-max` para escolhas de paleta/tipografia/estilo, invocar `design-system` para tokens e invocar `ui-styling` para recomendar a família de componentes shadcn/Tailwind a usar. Entrega: mockup HTML/CSS + tokens + spec de componentes — sem escrever `.tsx`. Testável de forma isolada.

**Acceptance Scenarios**:

1. **Given** pedido "desenhe uma tela de login para um app SaaS", **When** o agente recebe a tarefa, **Then** declara direção visual, invoca `ui-ux-pro-max` + `design-system` + `ui-styling` e entrega **mockup HTML/CSS + spec de componentes shadcn a usar + trecho de `tailwind.config` / CSS variables com tokens**, com contraste ≥ 4.5:1, toque mínimo 44×44px, foco visível e tokens nomeados. **Não entrega `.tsx`** — esse código é deferido a `frontend-react-developer`.
2. **Given** pedido de revisão de UI existente, **When** o agente analisa, **Then** aplica a tabela de prioridades do `ui-ux-pro-max` (Acessibilidade → Touch → Performance → Estilo → Layout → Tipografia/Cor → Animação → Forms → Nav → Charts) e reporta achados por categoria.

---

### User Story 2 - Identidade de marca e tokens de design (Priority: P1)

Alguém pede ao agente para criar ou atualizar guidelines de marca, tokens de cor/tipografia, variáveis CSS, spec de componentes ou temas Tailwind. O agente compõe `brand` (voz, identidade visual, paletas, tipografia, asset management) com `design-system` (arquitetura de tokens em três camadas, specs de componentes, estados e variantes) para manter `docs/brand-guidelines.md` como fonte da verdade sincronizado com `assets/design-tokens.json` / `assets/design-tokens.css`.

**Why this priority**: Identidade e tokens são o fundamento de qualquer sistema de design — sem isso, todas as outras entregas ficam inconsistentes. Mesma prioridade da US1 porque antecede desenhos de tela quando a marca ainda não existe.

**Independent Test**: Pedir "defina identidade de marca e tokens para uma startup fintech". O agente deve invocar `brand` para voz/paleta/tipografia, invocar `design-system` para estruturar tokens em primitive/semantic/component e produzir guidelines + tokens prontos para sincronização.

**Acceptance Scenarios**:

1. **Given** ausência de `docs/brand-guidelines.md`, **When** o agente é acionado para criar identidade, **Then** invoca `brand` para gerar o guia e `design-system` para gerar os tokens em três camadas.
2. **Given** alteração de paleta em `docs/brand-guidelines.md`, **When** o agente é acionado para sincronizar, **Then** dispara o fluxo `brand → sync-brand-to-tokens → validate-asset` sem duplicar conteúdo dos skills.

---

### User Story 3 - Banners, covers e social photos (Priority: P2)

Pedido para produzir banners (Facebook cover, Twitter/X header, LinkedIn banner, YouTube thumbnail, Instagram post/story, Google Display, hero de site, banner impresso) ou social photos multi-plataforma. O agente compõe `banner-design` (22 estilos, dimensões por plataforma, regras de safe zone) com `brand` (para contexto de marca) e `design` (como roteador de sub-skill e ponto de entrada unificado para logo/CIP/ícones/social photos).

**Why this priority**: Alto valor para marketing e conteúdo, mas é uma entrega pontual — menos frequente do que desenho de telas e identidade. Pode ser quebrado em MVP sem bloquear US1/US2.

**Independent Test**: Pedir "3 opções de banner hero para um site de café artesanal". O agente deve coletar requisitos via `AskUserQuestion`, invocar `banner-design` para estilos e dimensões, injetar contexto de marca via `brand` e entregar 3 variações com safe zone e contraste aprovados.

**Acceptance Scenarios**:

1. **Given** pedido de banner para plataforma específica, **When** o agente inicia, **Then** usa `banner-design` para selecionar dimensões exatas, estilos compatíveis e regras de safe zone (70-80% central), e nunca reimplementa conteúdo que já esteja nas references do skill.
2. **Given** marca já definida em `docs/brand-guidelines.md`, **When** o agente cria o banner, **Then** injeta contexto de marca sem contradizer a paleta/tipografia oficial.

---

### User Story 4 - Apresentações e pitch decks estratégicos (Priority: P2)

Pedido para criar apresentação HTML (marketing, pitch deck, data-driven com Chart.js). O agente compõe `slides` (padrões de layout, fórmulas de copywriting, estratégias de slide) com `design-system` (tokens reutilizáveis no HTML) e `brand` (voz e visual).

**Why this priority**: Entrega importante e recorrente para decks comerciais, mas posterior à capacidade de desenhar interfaces e manter identidade. Isolável em MVP.

**Independent Test**: Pedir "deck de 10 slides para apresentação de produto SaaS". O agente invoca `slides` para estrutura estratégica e copywriting, `design-system` para tokens e `brand` para alinhamento visual, entregando HTML responsivo com Chart.js quando dados exigirem.

**Acceptance Scenarios**:

1. **Given** pedido de apresentação sem dados quantitativos, **When** o agente monta, **Then** aplica layout patterns e fórmulas de copywriting do `slides` sem forçar gráficos.
2. **Given** pedido com métricas, **When** o agente monta, **Then** inclui slides com Chart.js respeitando `charts-and-data` do `ui-ux-pro-max` (legendas, tooltips, cores acessíveis).

---

### User Story 5 - Logo, Corporate Identity Program (CIP) e ícones (Priority: P3)

Pedido para gerar logo, programa de identidade corporativa (mockups, deliverables) ou sets de ícones. O agente compõe `design` (entrada unificada com sub-routing para logo, CIP, ícones, social photos) com `brand` (para alinhamento de voz/visual) e, opcionalmente, `ui-ux-pro-max` para preview HTML em galeria.

**Why this priority**: Entregas especializadas e menos frequentes. Dependem de `brand` já existir ou ser criada em paralelo (US2), por isso ficam com prioridade mais baixa.

**Independent Test**: Pedir "logo minimalista para startup de tecnologia". O agente invoca `design` com sub-skill de logo, busca estilo/cor/indústria, gera com IA (fundo branco obrigatório) e oferece preview HTML quando relevante.

**Acceptance Scenarios**:

1. **Given** pedido de logo, **When** o agente invoca `design`, **Then** respeita a regra de fundo branco para o logo gerado e oferece preview HTML via `ui-ux-pro-max` após confirmação do usuário.
2. **Given** pedido de CIP completo, **When** o agente invoca `design`, **Then** direciona para os 50+ deliverables documentados sem duplicar conteúdo.

---

### Edge Cases

- O que acontece quando o pedido mistura escopos (ex.: "crie a identidade e o banner hero já aplicando")? O agente deve compor os skills na ordem `brand` → `design-system` → skill de entrega final (`banner-design` / `slides` / `ui-styling`), sem achatar o trabalho em uma única chamada.
- O que acontece quando o pedido é de backend, testes, mobile nativo MAUI ou arquitetura React (não-UI)? O agente deve declarar out-of-scope, nomear o agente irmão correto (`dotnet-senior-developer`, `qa-developer`, `dotnet-mobile-developer`, `frontend-react-developer`, `analyst`) e parar — sem executar.
- O que acontece quando `docs/brand-guidelines.md` não existe e o usuário pede um banner? O agente deve oferecer criar a marca primeiro (US2) ou prosseguir com uma direção neutra documentada, nunca assumir silenciosamente.
- O que acontece quando dois skills têm conteúdo sobreposto (ex.: `design` × `banner-design` para banners, `design` × `slides` para apresentações)? O agente deve seguir a matriz de roteamento declarada em `design/SKILL.md` e invocar o skill mais específico; nunca duplicar o conteúdo do skill na resposta.
- O que acontece quando a acessibilidade entra em conflito com uma escolha estética? Acessibilidade vence (Priority 1 do `ui-ux-pro-max`): contraste ≥ 4.5:1, toque ≥ 44×44px, foco visível, reduced-motion respeitado.
- O que acontece quando o usuário pede entregas em outra stack web (Next.js, Vue, Svelte, Remix, Astro) ou mobile nativo (SwiftUI, Flutter, React Native)? O agente deve declarar que a stack padrão é **React + Vite + Tailwind**; se a stack alternativa for compatível com `ui-styling` (ex.: Next.js com Tailwind), o agente pode prosseguir apenas com confirmação explícita do usuário e documentar a escolha. Caso contrário (Vue/Svelte/SwiftUI/Flutter/RN), fica out-of-scope e o agente aponta o ponto-de-partida correto sem executar.
- O que acontece em um repositório sem Vite (ex.: Create React App, Next.js App Router, Remix)? O agente deve detectar o build tool antes de gerar código, e se não for Vite, declarar a discrepância ao usuário para confirmar se deve usar as convenções Vite mesmo assim ou adaptar ao build real.
- O que acontece quando um script invocado por um skill falha (ex.: `sync-brand-to-tokens.cjs` erra; Gemini API indisponível; `logo/generate.py` retorna erro)? O agente **não silencia** a falha: reporta o erro exato (stderr, exit code, arquivo), propõe 2-3 caminhos ao usuário (retry; ajustar config/credencial/input; fallback sem o script — ex.: gerar mockup HTML em vez de imagem IA) e espera a escolha antes de prosseguir. Nunca inventa saída nem finge sucesso.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O repositório MUST conter um arquivo `agents/ui-ux-pro-max-designer.md` seguindo a convenção flat-file dos agentes existentes (frontmatter com `name`, `description`, `tools`, seções de Role & Scope, Composed Skills, Default Behavior, Boundaries / Out of Scope, Output Language). O campo `tools` MUST ser exatamente `Read, Grep, Glob, Bash, Write, Edit, Task, Skill, WebFetch` — Bash é obrigatório para executar scripts dos skills (ex.: `sync-brand-to-tokens.cjs`, `gemini_batch_process.py`, `logo/generate.py`); WebFetch é obrigatório para pesquisa visual (ex.: Pinterest references citadas em `banner-design/SKILL.md`).
- **FR-002**: O agente MUST declarar como `Composed Skills` exatamente os sete skills solicitados: `banner-design`, `brand`, `design`, `design-system`, `slides`, `ui-styling`, `ui-ux-pro-max`, cada um com uma instrução clara de "quando invocar".
- **FR-003**: O agente MUST nunca duplicar o conteúdo de um skill na sua própria resposta — deve invocar ou citar o skill pelo nome da pasta e deixar o template vir do skill.
- **FR-004**: O agente MUST aplicar a tabela de prioridades do `ui-ux-pro-max` quando avaliar ou revisar UI (Acessibilidade → Touch → Performance → Estilo → Layout → Tipografia/Cor → Animação → Forms → Navegação → Charts).
- **FR-005**: O agente MUST declarar Boundaries / Out of Scope cobrindo: backend .NET/C# (defer para `dotnet-senior-developer`), .NET MAUI/mobile nativo (defer para `dotnet-mobile-developer`), **código React `.tsx`, arquitetura, i18n, modais e alerts** (defer para `frontend-react-developer`), trabalho apenas de testes (defer para `qa-developer`), documentação em `docs/` (defer para `analyst`).
- **FR-006**: O agente MUST seguir a regra name-and-stop dos agentes irmãos: se o pedido cai fora do escopo, nomear o agente irmão pelo campo `name` e parar, sem executar o trabalho e sem split-and-execute.
- **FR-007**: O agente MUST compor skills na ordem correta para pedidos multi-skill: identidade (`brand`) → tokens (`design-system`) → entrega (`ui-styling` / `banner-design` / `slides` / `design`).
- **FR-008**: O agente MUST preferir editar `docs/brand-guidelines.md` como fonte da verdade de marca e sincronizar tokens via `brand/scripts/sync-brand-to-tokens.cjs` quando a marca mudar.
- **FR-009**: O agente MUST aplicar as restrições não-negociáveis de acessibilidade do `ui-ux-pro-max`: contraste ≥ 4.5:1 para texto normal, alvos de toque ≥ 44×44px, focus rings visíveis, suporte a `prefers-reduced-motion`, não conveyar informação apenas por cor.
- **FR-010**: O agente MUST comprometer-se com uma direção visual nomeada e deliberada (ex.: minimalismo, brutalismo, bento grid, glassmorphism, claymorphism, neumorphism, skeuomorphism, flat, editorial, retro-futurista) em vez de cair em defaults genéricos (Inter + gradiente roxo, fontes de sistema, layouts cookie-cutter).
- **FR-011**: O agente MUST declarar explicitamente na seção `## Output Language` a regra "Respond in the language of the request" — inglês para pedidos em inglês, português para pedidos em português, etc. Esta regra se aplica igualmente aos demais agentes do repositório (ver FR-019).
- **FR-019**: O escopo desta feature inclui **atualizar a seção `## Output Language` de todos os agentes existentes** em `agents/` (`frontend-react-developer.md`, `dotnet-senior-developer.md`, `dotnet-mobile-developer.md`, `qa-developer.md`, `analyst.md`) para a mesma regra bilíngue "Respond in the language of the request", substituindo o atual "English". O conteúdo técnico, Composed Skills e Boundaries desses agentes permanecem intactos.
- **FR-020**: Quando qualquer script invocado por um skill composto falhar, o agente MUST (a) reportar ao usuário o erro exato (mensagem, exit code, arquivo ou etapa), (b) listar 2 a 3 caminhos concretos (retry, ajuste de config/credencial/input, fallback sem o script) e (c) aguardar a escolha explícita do usuário antes de prosseguir. É **proibido** silenciar a falha, continuar com saída parcial sem avisar, ou fabricar artefato que não foi produzido pelo script.
- **FR-021**: O agente MUST preservar os diretórios de saída default de cada skill composto (ex.: `assets/banners/` do `banner-design`, `docs/brand-guidelines.md` do `brand`, `assets/design-tokens.{json,css}` do `design-system`) — não centraliza nem sobrescreve. Para cada feature de design solicitada, o agente MUST adicionalmente criar `docs/design/<feature-slug>/README.md` listando todos os artefatos produzidos (paths relativos, propósito, skill de origem) como ponto único de consumo por outros agentes — especialmente por `frontend-react-developer` ao implementar o `.tsx`.
- **FR-022**: O arquivo `agents/ui-ux-pro-max-designer.md` MUST incluir, logo após o frontmatter e antes da seção `# UI/UX Pro Max Designer`, uma linha de atribuição no formato: `> Based on [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) by @nextlevelbuilder — origin of the `ui-ux-pro-max` skill this agent composes.` A URL MUST ser exatamente `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill` (sem encurtadores, sem tracking params). Essa atribuição é obrigatória independente do idioma de saída do agente (permanece em inglês por ser metadata de proveniência).
- **FR-012**: O arquivo do agente MUST se manter curto e focado em composição de skills — o detalhe operacional fica nos skills invocados, não duplicado no agente.
- **FR-013**: O agente MUST declarar **React + Vite + Tailwind** (com shadcn/ui via `ui-styling`) como a stack alvo para a qual os artefatos de design são destinados. O agente NÃO escreve `.tsx`; escreve **mockups HTML/CSS**, **specs de componente** (props, estados, variantes, com quais componentes shadcn compor) e **tokens** (CSS variables + bloco `tailwind.config` `theme.extend`) — o código React é responsabilidade de `frontend-react-developer`.
- **FR-014**: O agente MUST entregar tokens do `design-system` em dois artefatos consumíveis pela stack: (a) arquivo de CSS variables pronto para ser importado pelo entry do Vite e (b) trecho do `tailwind.config.{js,ts}` (tema `extend`) referenciando essas variáveis — nunca hex crus em mockup.
- **FR-015**: O agente MUST detectar o build tool real do projeto antes de gerar tokens/mockups. Se for Vite, prossegue; se for Next.js/Remix/CRA/outro, declara a discrepância, pergunta ao usuário se deve adaptar e registra a decisão antes de entregar os artefatos.
- **FR-016**: O agente MUST considerar out-of-scope (name-and-stop) pedidos de UI em stacks fora de `ui-styling` + React: Vue, Svelte, SwiftUI, Flutter, React Native nativo. Pode aceitar Next.js/Remix/Astro com Tailwind **apenas mediante confirmação explícita**, documentando o desvio em relação ao default.
- **FR-017**: As entregas que **não** são direcionadas a aplicação React (banners estáticos em HTML/CSS, slides HTML, logos em PNG/SVG gerados por IA, CIP mockups, ícones SVG) NÃO precisam respeitar a stack React + Vite + Tailwind — seguem o que cada skill (`banner-design`, `slides`, `design`) entrega nativamente.
- **FR-018**: O agente MUST deferir a **implementação em `.tsx`** a `frontend-react-developer` via regra name-and-stop. Se o usuário explicitamente pedir código React, o agente declara que o design/mockup/spec/tokens são dele, mas o código é do irmão — e passa a tarefa adiante sem codar.

### Key Entities *(include if feature involves data)*

- **Agente (`agents/ui-ux-pro-max-designer.md`)**: arquivo markdown flat-file; frontmatter (`name`, `description`, `tools`) + seções (`Role & Scope`, `Composed Skills`, `Default Behavior`, `Boundaries / Out of Scope`, `Output Language`).
- **Skill composto**: referência nominal a uma pasta dentro de `skills/`; o agente declara **quando invocar** sem duplicar o conteúdo do skill.
- **Irmão (sibling agent)**: outro arquivo em `agents/`; o agente lista esses irmãos pelo campo `name` para aplicar a regra name-and-stop em out-of-scope.
- **Fonte da verdade de marca**: `docs/brand-guidelines.md` alimenta `assets/design-tokens.json` e `assets/design-tokens.css` via scripts do skill `brand`.
- **Índice de entrega de design (`docs/design/<feature-slug>/README.md`)**: ponto único de consumo de uma feature de design; lista todos os artefatos produzidos pelo agente com path relativo, propósito e skill de origem. Consumido por `frontend-react-developer` ao implementar `.tsx`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% dos pedidos de UI/UX no escopo (desenho de telas, identidade, banners, slides, logo/CIP) são atendidos exclusivamente pelo novo agente, sem handoff para outros agentes do repositório.
- **SC-002**: 100% dos pedidos fora do escopo (backend .NET, MAUI, testes, React architecture, documentação) recebem resposta name-and-stop em ≤ 3 frases, nomeando o agente irmão correto.
- **SC-003**: 100% das entregas visuais cumprem os mínimos de acessibilidade do `ui-ux-pro-max` (contraste ≥ 4.5:1, toque ≥ 44×44px, foco visível, reduced-motion respeitado) verificáveis por inspeção estática.
- **SC-004**: 0 ocorrências de duplicação do conteúdo dos skills no corpo do arquivo do agente (verificável por diff textual contra cada `SKILL.md` referenciado).
- **SC-005**: Em ≥ 90% das respostas do agente a um pedido de "desenhe X", o agente declara uma direção visual nomeada (não default genérico) antes de produzir código ou mockup.
- **SC-006**: Arquivo do agente permanece ≤ 100 linhas, mantendo-se como índice composicional e não como documentação duplicada dos skills.
- **SC-007**: 100% das entregas de tokens referenciadas a projeto **React + Vite + Tailwind** vêm em dois artefatos: arquivo CSS com variables + trecho `tailwind.config` `theme.extend` — sem hex crus em mockup. Verificável por inspeção estática.
- **SC-008**: 100% dos pedidos de UI em stacks fora de `ui-styling` (Vue, Svelte, SwiftUI, Flutter, React Native) recebem resposta name-and-stop sem geração de artefato.
- **SC-009**: 0 arquivos `.tsx` escritos pelo agente. Pedidos de código React são deferidos a `frontend-react-developer` em ≤ 3 frases. Verificável por diff de arquivos tocados na PR.
- **SC-010**: 100% dos agentes em `agents/` têm a seção `## Output Language` com a regra "Respond in the language of the request" — nenhum agente mantém o texto antigo "English" isolado. Verificável por grep de `^## Output Language` seguido de match da frase canônica.
- **SC-011**: 100% das entregas de design têm um `docs/design/<feature-slug>/README.md` listando todos os artefatos com paths relativos e skill de origem. Verificável por inspeção estática pós-entrega.
- **SC-012**: 100% das falhas de script reportam erro exato + ≥ 2 caminhos propostos antes de o agente continuar. Verificável por revisão de transcript.
- **SC-013**: Arquivo `agents/ui-ux-pro-max-designer.md` contém exatamente uma linha de atribuição citando a URL canônica `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill`. Verificável por grep da URL no arquivo — deve retornar 1 match.

## Assumptions

- O repositório usa a convenção flat-file do Claude Code para agentes (`agents/<nome>.md` com frontmatter), como evidenciam `frontend-react-developer.md` e `dotnet-senior-developer.md`.
- Os sete skills listados já existem em `skills/` (verificado) e suas `SKILL.md` são a fonte da verdade operacional — o agente referencia, não duplica.
- O idioma de saída do agente segue o idioma do pedido (bilíngue PT/EN). Esta decisão foi aplicada retroativamente a todos os agentes existentes do repositório para manter consistência (FR-019).
- O agente assume que `docs/brand-guidelines.md` é a fonte da verdade de marca quando existir; se não existir, o agente propõe criar antes de gerar entregas dependentes de marca.
- Os comandos e scripts (Pinterest research, Gemini AI generation, sync-brand-to-tokens, etc.) vivem dentro de cada skill e são invocados **pelo skill**, não replicados no agente.
- A regra name-and-stop para out-of-scope (usada por `frontend-react-developer.md` e `dotnet-senior-developer.md`) é a convenção do projeto para agentes irmãos e se aplica aqui.
- A composição de skills segue a ordem marca → tokens → entrega, refletindo a cadeia de dependências declarada em `design/SKILL.md` (sub-skill routing).
- A stack alvo para User Story 1 é **React + Vite + Tailwind** com shadcn/ui. Essa escolha está alinhada com a primeira oção documentada em `ui-styling/SKILL.md` ("React-based frameworks (Next.js, Vite, Remix, Astro)") e com a regra de primeiro cidadão do `ui-ux-pro-max` (10 stacks suportadas, React/Tailwind/shadcn como prioridade para web).
- TypeScript (`.tsx`) é assumido como padrão do ecossistema React + Vite + shadcn/ui — o agente não gera JavaScript puro salvo pedido explícito.
- Os skills `banner-design`, `slides`, `design` (logo/CIP/ícones/social photos) e `brand` permanecem stack-agnósticos; a obrigatoriedade de React + Vite + Tailwind aplica-se apenas às entregas de componentes/telas de aplicação.
- O repositório upstream `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill` é creditado como origem conceitual do skill `ui-ux-pro-max` que o agente compõe. A atribuição é metadata de proveniência — não implica dependência de submódulo, instalação remota ou sincronização automática com aquele repositório.
