---
name: homelab-new-app
description: Use when adding a new application to the Federico Serini homelab Kubernetes cluster — covers tunnel creation, manifest scaffolding, SOPS-encrypted secrets, and Flux GitOps wiring for apps/{base,staging} layout on Talos/FluxCD.
---

# Homelab: New App Onboarding

## Overview

Full workflow to bring a new app live on the homelab cluster. Covers all required artifacts — missing any one will leave Flux in a broken state.

## Prerequisites / Gather First

Before touching files, collect:

| Item | Where |
|---|---|
| `<name>` | app slug (e.g. `linkding`) |
| `<image>` | full image ref + tag |
| `<port>` | container port |
| `<hostname>` | `<name>.federicoserini.com` |
| DB type | none / CNPG / MariaDB / SQLite+PVC |
| Private registry? | needs `ghcr-login-secret` |
| Env vars / secrets | keys + values (NEVER commit plaintext) |

---

## Step 1 — Cloudflare Tunnel

```bash
cloudflared tunnel create <name>
cloudflared tunnel route dns <name> <hostname>
# credentials land at ~/.cloudflared/<tunnel-id>.json
```

Note the `<tunnel-id>` UUID — needed in Step 4.

---

## Step 2 — App Manifests

### `apps/base/<name>/`

**namespace.yaml**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <name>
```

**deployment.yaml** — key fields:
- `image: <image>`
- `containerPort: <port>`
- `envFrom` for secret (if needed)
- `volumeMounts` + PVC if SQLite/data persistence
- Private image → add `imagePullSecrets: [{name: ghcr-login-secret}]`

**service.yaml** — ClusterIP on `<port>`

**pvc.yaml** (if needed) — `storageClassName: synology-iscsi-storage`, `accessModes: [ReadWriteOnce]`

**kustomization.yaml** — lists all resources in this folder

### `apps/staging/<name>/`

**kustomization.yaml**:
```yaml
namespace: <name>
resources:
  - ../../base/<name>
  - cloudflare.yaml
  - secret.yaml          # SOPS-encrypted
  - tunnel-credentials.yaml  # SOPS-encrypted
```

**cloudflare.yaml** — Deployment running `cloudflared` with config pointing to `http://<name>:<port>`

---

## Step 3 — SOPS App Secret (if env vars needed)

```bash
# Run from repo root
kubectl create secret generic <name>-secret \
  --from-literal=KEY1=VAL1 \
  --from-literal=KEY2=VAL2 \
  --dry-run=client -o yaml > secret.yaml

sops --age=$AGE_PUBLIC --encrypt \
  --encrypted-regex '^(data|stringData)$' \
  --config clusters/staging/.sops.yaml \
  --in-place secret.yaml

mv secret.yaml apps/staging/<name>/secret.yaml
```

---

## Step 4 — SOPS Tunnel-Credentials Secret

```bash
kubectl create secret generic tunnel-credentials \
  --from-file=credentials.json=~/.cloudflared/<tunnel-id>.json \
  --dry-run=client -o yaml > secret.yaml

sops --age=$AGE_PUBLIC --encrypt \
  --encrypted-regex '^(data|stringData)$' \
  --config clusters/staging/.sops.yaml \
  --in-place secret.yaml

mv secret.yaml apps/staging/<name>/tunnel-credentials.yaml
```

---

## Step 5 — Database (if needed)

### CNPG PostgreSQL

Create `databases/data/<name>/cluster.yaml` — CNPG `Cluster` CRD, `storageClass: synology-iscsi-storage`, 1 instance, `pg-<name>` name.
Add kustomization entry to `databases/data/kustomization.yaml`.

### MariaDB

Use mariadb-operator CRD. Add to `databases/data/<name>/`.

### SQLite + PVC

No database folder needed — PVC handles it (done in Step 2).

---

## Step 6 — Wire into Flux

Verify `clusters/staging/apps.yaml` (or equivalent Flux entrypoint) already points to `apps/staging` — it does for existing apps. Only touch if adding a new top-level path.

Update **INFRA.md** `APPS:` section with:
```
<name>  ns:<name>  img:<image>  port:<port>  db:<db-type>  host:<hostname>
```

---

## Step 7 — Commit & Verify

```bash
git add apps/ databases/   # be explicit, never git add -A
git commit
git push origin main        # Flux tracks main only
```

Watch reconciliation:
```bash
flux get kustomizations --watch
kubectl -n <name> get pods --watch
```

---

## Known Traps

| Trap | Fix |
|---|---|
| SOPS encrypt without `--config` | always pass `--config clusters/staging/.sops.yaml` |
| `AGE_PUBLIC` unset | export from your key file before running sops |
| Bitnami images | avoid — Docker Hub auth-gated since Nov 2023 |
| `kubectl patch` hotfix | safe, but remember Flux will overwrite on next reconcile |
| Flux stalled HelmRelease | annotate `reconcile.fluxcd.io/requestedAt`; `flux reconcile` alone insufficient |
| StatefulSet stuck on CrashLoop | delete pod manually to force new revision |
| ConfigMap hash rename | patch existing CM + delete pod; StatefulSet won't self-update |

## Quick Checklist

- [ ] Tunnel created + DNS routed
- [ ] `apps/base/<name>/` — namespace, deployment, service, PVC (if needed), kustomization
- [ ] `apps/staging/<name>/` — kustomization, cloudflare.yaml
- [ ] App secret SOPS-encrypted → `apps/staging/<name>/secret.yaml`
- [ ] Tunnel-credentials SOPS-encrypted → `apps/staging/<name>/tunnel-credentials.yaml`
- [ ] Database manifests (if needed) + wired into databases kustomization
- [ ] INFRA.md APPS section updated
- [ ] Pushed to `main`
- [ ] Flux reconciled + pod Running
