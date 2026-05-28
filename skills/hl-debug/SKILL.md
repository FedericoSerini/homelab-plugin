---
name: hl-debug
description: Diagnose app or infra component failures. Maps app name to namespace, runs pod+HR+log diagnostics, reasons against known traps.
---

Debug an app or infrastructure component. Argument: app name (keycloak, bookstack, linkding, mealie, falco, monitoring) or a namespace.

Map argument to namespace using INFRA.md context (already loaded at session start). If no argument, ask which app.

Run this diagnostic sequence:

1. HelmRelease status (if applicable):
   `kubectl get helmrelease <name> -n <ns> -o jsonpath='{.status.conditions}'`

2. Pod status:
   `kubectl get pods -n <ns>`

3. Pod logs (last 30 lines):
   `kubectl logs <pod> -n <ns> --tail=30`
   If CrashLoopBackOff: also run `kubectl logs <pod> -n <ns> --previous --tail=30`

4. If CNPG database for this app exists: check cluster status:
   `kubectl get cluster -n <ns>`

Compress output:
- Logs: strip Java stack traces (keep only lines matching "ERROR|WARN|Caused by:|hostname|connection|password|failed")
- Pod table: name/status/restarts only
- HelmRelease: extract only the message field from conditions

Then reason against known traps from INFRA.md:
- "kc.sh [OPTIONS]" in logs → args:["start"] missing
- "hostname is not configured" → KC_HOSTNAME env missing
- "connection refused" + postgres → CNPG cluster down or wrong secret key
- HelmRelease "RetriesExceeded" → stalled, needs annotation
- ConfigMap shows old values → patch CM + delete pod

Output: 2-3 lines max. Problem identified + recommended fix command. No explanation of k8s concepts.
