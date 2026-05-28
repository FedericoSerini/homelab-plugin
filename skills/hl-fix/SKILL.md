---
name: hl-fix
description: Apply cluster fixes. Knows the correct sequence for stalled HelmReleases, ConfigMap patches, StatefulSet pod restarts.
---

Apply a fix to the cluster. Use context from INFRA.md (already loaded) + current conversation to determine what needs fixing.

If no argument given: check current state with `kubectl get helmrelease -A | grep -v True` to find broken resources.

Fix playbook — apply the right sequence based on the situation:

**Stalled HelmRelease:**
```bash
kubectl annotate helmrelease <name> -n <ns> reconcile.fluxcd.io/requestedAt="$(date -u +%Y-%m-%dT%H:%M:%SZ)" --overwrite
```

**ConfigMap values not applied (StatefulSet):**
1. Patch the hash-named ConfigMap with new values
2. Delete pod: `kubectl delete pod <pod> -n <ns>`

**HelmRelease upgrade stuck (pods keep crashing):**
1. Fix StatefulSet spec directly: `kubectl patch statefulset <name> -n <ns> --type=json -p='[...]'`
2. Delete pod

**CNPG cluster not ready:**
`kubectl get cluster -n <ns>` → check events → `kubectl describe cluster <name> -n <ns>`

**After applying fix, always watch result:**
```bash
until kubectl get pod <pod> -n <ns> -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null | grep -q true || kubectl get pod <pod> -n <ns> -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}' 2>/dev/null | grep -q CrashLoop; do sleep 5; done && kubectl get pod <pod> -n <ns>
```

Output: show only what you did + final pod status. No commentary.

Remember: NEVER decode SOPS secrets in terminal output.
