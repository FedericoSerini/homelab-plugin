---
name: hl-updates
description: Show pending Renovate PRs — available image and chart updates detected for this cluster. Read-only.
---

Show pending dependency updates from Renovate.

Run:
```bash
gh pr list --state open --author "renovate[bot]" --json number,title,url --jq '.[] | "#\(.number)  \(.title)  \(.url)"'
```

Output format — one line per PR:
```
#42  mealie: v3.19.1 → v3.20.0  https://github.com/...
#41  linkding: 1.45.0 → 1.46.0  https://github.com/...
```

If no open PRs:
```
No pending Renovate updates ✅
```

Constraints:
- Read-only — never merge, approve, close, or comment on PRs
- Renovate owns the update lifecycle; this skill only surfaces what it found
