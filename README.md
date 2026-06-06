# homelab — Claude Code Plugin

Homelab ops assistant for a Talos/FluxCD Kubernetes cluster. Loads cluster context at session start and provides skills for status checks, debugging, rollbacks, and onboarding new apps.

## Install

```bash
claude plugin add https://github.com/FedericoSerini/homelab-plugin
```

## Setup

Open Claude Code inside your homelab repo, then run:

```
/hl-init
```

This scaffolds `.claude/INFRA.md` — fill in your cluster details. The plugin loads this file automatically at every session start.

## Skills

| Command | Description |
|---|---|
| `/hl-status` | Full cluster health check — compressed, issues first |
| `/hl-debug <app>` | Diagnose pod/HelmRelease failures |
| `/hl-fix [app]` | Apply fixes: stalled HelmRelease, ConfigMap patch, stuck StatefulSet |
| `/hl-logs <app>` | Compressed pod logs — strips noise, keeps errors |
| `/hl-init` | Scaffold `.claude/INFRA.md` template |
| `/hl-rollback [app]` | Git revert + push + watch Flux reconcile |
| `/hl-info <app>` | App config from INFRA.md + live pod/image status |
| `/hl-docs <component>` | Explain a cluster component with context + official docs link |
| `/hl-updates` | Show pending Renovate PRs (read-only) |
| `/homelab-new-app` | Full workflow to onboard a new app to the cluster |

## How It Works

At session start, the plugin loads `.claude/INFRA.md` from the project root into context. All skills use this to map app names to namespaces, identify DB types, and reason against known cluster traps — no need to specify namespaces manually.

`.claude/INFRA.md` lives in your homelab repo. It is not part of the plugin and is never committed by the plugin.
