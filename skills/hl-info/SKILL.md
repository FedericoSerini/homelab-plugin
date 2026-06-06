---
name: hl-info
description: Show static config and live status for a specific app. Reads INFRA.md (loaded at session start) and runs live kubectl queries.
---

Show info for a specific app. Argument: app name (e.g. mealie, keycloak, linkding).

1. Parse INFRA.md APPS section for the app line. Extract:
   - `ns:` → namespace
   - `img:` → image (if present)
   - `chart:` → chart ref (if present — means HelmRelease)
   - `port:` → port
   - `db:` → database type and resource name
   - `host:` → hostname
   - `secret:` → secret names (if present)

2. Detect app type:
   - Line contains `chart:` → HelmRelease
   - Line contains `img:` → Deployment

3. Run live kubectl:

   **Deployment apps:**
   ```bash
   kubectl get pods -n <ns> --no-headers
   kubectl get deployment <name> -n <ns> -o jsonpath='{.spec.template.spec.containers[0].image}'
   ```

   **HelmRelease apps (keycloak):**
   ```bash
   kubectl get pods -n <ns> --no-headers
   kubectl get helmrelease <name> -n <ns> -o jsonpath='{.status.conditions[0].message}'
   ```

4. Compare live image vs INFRA.md image:
   - Match → `✅ match`
   - Mismatch → `⚠️ live=<actual-image>`
   - HelmRelease → skip image comparison, show HR status instead

Output format:
```
<app>
  ns:      <namespace>
  image:   <infra-image>  (live: ✅ match | ⚠️ live=<actual>)
  port:    <port>
  db:      <db-type> → <db-resource> (ns:<db-ns>)
  host:    <hostname>
  secrets: <names | none>
  pods:    <pod-name>  <status>  <ready>
```

If app not found in INFRA.md:
```
<app> not in INFRA.md — check spelling or run /hl-init
```
