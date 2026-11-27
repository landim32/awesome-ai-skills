## Estrutura do Repositório

<!-- Use UM dos blocos abaixo e apague os demais. -->

<!-- Bloco "raiz": projeto com um único componente (só frontend, só backend). -->

O projeto tem um único componente (**<backend | frontend>**), que fica na **raiz** do repositório.
**NÃO** criar pastas `backend/`, `frontend/` ou `mobile/` sem emendar esta constitution.

```text
/
├── <estrutura do componente — ver seção do componente>
├── docs/                 # documentação (analyst)
├── deploy/k8s/           # manifestos Kubernetes (devops-engineer), se houver deploy no cluster
└── .github/workflows/    # pipelines (devops-engineer)
```

<!-- Bloco "multi": dois ou mais componentes. Mantenha só as pastas presentes. -->

O projeto é dividido em componentes, **cada um na sua pasta**. Nenhum código de um componente pode
ficar fora da sua pasta, e a raiz contém só arquivos de repositório, documentação e infraestrutura.

```text
/
├── backend/              # API .NET (dotnet-senior-developer)
├── frontend/             # aplicação web React (frontend-react-developer)
├── mobile/               # app .NET MAUI (dotnet-mobile-developer)
├── docs/                 # documentação (analyst)
├── deploy/k8s/           # manifestos Kubernetes (devops-engineer)
└── .github/workflows/    # pipelines (devops-engineer)
```

- Os contratos entre componentes (DTOs ↔ types TypeScript / DTOs ↔ Models) DEVEM usar os mesmos
  nomes de propriedades em camelCase no JSON.
- Cada componente tem build, testes e Dockerfile próprios dentro da sua pasta.
