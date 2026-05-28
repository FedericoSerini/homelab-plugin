---
name: hl-status
description: Full cluster health check — compressed output, issues first
---

Run these commands to get full cluster health:

```bash
kubectl get helmrelease -A
kubectl get kustomization -A
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded 2>/dev/null || kubectl get pods -A | grep -v "Running\|Completed\|NAME"
```

Output rules (compress heavily):
- HelmReleases: show only name / ready(✅❌) / status message (strip "Helm install/upgrade succeeded/failed for release")
- Kustomizations: show name / ready / revision sha (last 8 chars only)
- Pods: show only non-Running/non-Completed pods with ns/name/status/restarts
- If everything healthy: "All systems ✅"
- Group by: ❌ issues first, then ✅ healthy

Do NOT show: AGE columns, full timestamps, full SHAs, controller-manager internal pods.
