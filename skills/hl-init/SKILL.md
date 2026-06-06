---
name: hl-init
description: Scaffold a .claude/INFRA.md template in the current project. Run when no INFRA.md exists or user wants to reset it.
---

Initialize INFRA.md for this homelab project.

1. Check if `.claude/INFRA.md` already exists:
   ```bash
   ls .claude/INFRA.md 2>/dev/null && echo "EXISTS" || echo "NOT_FOUND"
   ```
   If EXISTS: warn the user and ask for explicit confirmation before overwriting.

2. Create `.claude/` directory if needed, then write this template to `.claude/INFRA.md`:

```
# HOMELAB — <your-name>
CLUSTER: Talos v<version> / k8s v<version> / containerd <version>
  <node-name>: control-plane, Ready

GITOPS: FluxCD / branch=main ONLY / SOPS+Age (secret:sops-age)
  kustomizations: apps(15m) databases(15m) infr-controllers(1h) monitoring(1h)
  TRAP: Flux tracks main only → kubectl patch is fast path for hotfixes

STORAGE: <storage-class> / NAS:<ip> / iSCSI/ext4/Retain

APPS:
  <name>  ns:<name>  img:<image>:<tag>  port:<port>  db:<none|CNPG|MariaDB|SQLite>  host:<name>.example.com

INFRA CONTROLLERS (HelmReleases in ns matching name):
  ✅ cloudnative-pg-operator@<version>

DATABASES (all in same ns as app):
  CNPG PostgreSQL <version> (1 instance, <storage-class>):
    pg-<app> (ns:<app>-pg)

INGRESS: Cloudflare Tunnels / one cloudflared Deployment per namespace
  secret:tunnel-credentials / creds:/etc/cloudflared/creds/credentials.json
  service pattern: http://<app-svc>:<port>

SECRETS: all SOPS+Age encrypted / NEVER decode in terminal

REPO LAYOUT:
  apps/{base,staging}/<app>/          ← Deployments, Services, Cloudflare, Secrets
  databases/data/<app>/               ← CNPG Cluster / MariaDB CRDs
  infrastructure/controllers/{base,staging}/<ctrl>/ ← HelmReleases
  clusters/staging/                   ← Flux entrypoints

WORKFLOWS:
  New Cloudflare tunnel:
    cloudflared tunnel create <name>
    cloudflared tunnel route dns <name> <hostname>
    credentials → ~/.cloudflared/<tunnel-id>.json

  New SOPS secret:
    kubectl create secret generic <name> --from-literal=KEY=VAL ... --dry-run=client -o yaml > secret.yaml
    sops --age=$AGE_PUBLIC --encrypt --encrypted-regex '^(data|stringData)$' \
      --config clusters/staging/.sops.yaml --in-place secret.yaml
    mv secret.yaml apps/staging/<app>/secret.yaml

KNOWN TRAPS:
  ConfigMap patch → pod won't restart → must delete pod manually
  HelmRelease stalled → annotate reconcile.fluxcd.io/requestedAt
  Bitnami images: Docker Hub auth-gated since Nov 2023 — avoid
```

3. Print: `INFRA.md created at .claude/INFRA.md — fill in your cluster details`
