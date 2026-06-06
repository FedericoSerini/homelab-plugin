---
name: hl-rollback
description: Revert the last git commit and push to main so Flux reconciles the previous cluster state.
---

Roll back the cluster to the previous git state.

1. Show recent commits to orient:
   ```bash
   git log --oneline -5
   ```

2. Determine target:
   - If app name given (e.g. `/hl-rollback mealie`): find the most recent commit touching `apps/base/<name>/` or `apps/staging/<name>/` from the log.
   - If no argument: ask the user which commit to revert before proceeding.

3. Revert and push:
   ```bash
   git revert HEAD --no-edit
   git push origin main
   ```

4. Watch Flux reconcile:
   ```bash
   flux get kustomizations --watch
   ```
   Stop watching once the target kustomization (apps or databases) shows a new revision SHA.

Output:
- Which commit was reverted (hash + subject line), one line
- Final Flux kustomization status (name / ready / revision), one line
- No commentary.

Constraints:
- NEVER use `git push --force`
- NEVER decode SOPS secrets
- If `git revert` fails due to merge conflicts: stop immediately and report the conflict — do not attempt to resolve automatically
