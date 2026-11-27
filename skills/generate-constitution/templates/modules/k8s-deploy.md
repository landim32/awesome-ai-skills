## Infraestrutura e Deploy

Responsável: `devops-engineer` (skill `k8s-deploy`).

- Produção roda no cluster Kubernetes compartilhado da emagine (`do-nyc2-emagine-k8s`), atrás do
  Cloudflare Tunnel `emagine-k8s` e do `ingress-nginx`. Namespace do projeto: `__PROJECT_SLUG__`.
- Manifestos em `deploy/k8s/` (Kustomize), gerados a partir dos templates da skill `k8s-deploy`;
  pipeline em `.github/workflows/deploy-prod.yml` (imagens no GHCR + `kubectl apply -k`).
- Imagens: `__PROJECT_SLUG__-api` (backend) e `__PROJECT_SLUG__-web` (frontend), conforme os
  componentes do projeto.
- Secrets exclusivos do projeto no GitHub com prefixo `__PROJECT_SLUG__` em MAIÚSCULAS
  (ex.: `MEUAPP_CONNECTION_STRING` → `ConnectionStrings__Default`, `MEUAPP_JWT_SECRET` → `Jwt__Secret`,
  obrigatório quando houver autenticação); a pipeline usa só o kubeconfig da ServiceAccount do projeto,
  **nunca** o kubeconfig de admin.
- Sem TLS no Ingress (HTTPS termina na Cloudflare); a aplicação confia em forwarded headers.
- Toda alteração no cluster ou nos secrets exige confirmação explícita do usuário.
