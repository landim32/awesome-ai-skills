## Infraestrutura e Deploy

Responsável: `devops-engineer` (skills `deploy-prod` e `dotnet-env`).

- Produção roda num **servidor acessado via SSH**, com os serviços em `docker compose`, no
  diretório `/opt/__PROJECT_SLUG__`.
- Arquivos de produção na raiz do repositório: `docker-compose-prod.yml` (serviços, porta exposta,
  rede externa) e `.env.prod.example` (só os **nomes** das variáveis; valores nunca no Git).
- Pipeline em `.github/workflows/deploy-prod.yml`, gerada pela skill `deploy-prod`: jobs
  estritamente sequenciais `checkout → inject-secrets → network-setup → stop-services →
  build-deploy → health-check → summary`, cada script SSH começando com `set -e`.
- Secrets no GitHub: conexão `PROD_SSH_HOST`, `PROD_SSH_USER`, `PROD_SSH_PASSWORD`, `PROD_SSH_PORT`
  e uma secret por variável do `.env.prod.example` (incluindo `Jwt__Secret` quando houver autenticação).
- Toda variável nova de produção DEVE entrar no `.env.prod.example` e na pipeline (via
  `deploy-prod`) no mesmo PR.
