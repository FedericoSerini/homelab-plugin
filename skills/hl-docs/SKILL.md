---
name: hl-docs
description: Explain a cluster component or answer a homelab infrastructure question. Uses INFRA.md context + official documentation links.
---

Answer a question about the homelab infrastructure. Argument: component name or free-form question.

1. Identify the component from input. Official docs map:

   | Component | URL |
   |---|---|
   | flux / fluxcd | https://fluxcd.io/flux/ |
   | cnpg / cloudnative-pg / postgres | https://cloudnative-pg.io/documentation/ |
   | sops / age / secrets | https://getsops.io/docs/ |
   | talos / talosctl | https://www.talos.dev/latest/ |
   | cloudflared / tunnel | https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/ |
   | keycloak / keycloakx | https://www.keycloak.org/documentation |
   | mariadb / mariadb-operator | https://mariadb.com/kb/en/mariadb-operator/ |
   | renovate | https://docs.renovatebot.com/ |

2. Answer contextually using INFRA.md:
   - How THIS cluster uses the component (versions, storage class, patterns visible in INFRA.md)
   - Relevant KNOWN TRAPS from INFRA.md that apply to this component
   - Max 6 lines of context

3. End response with:
   `Docs: <url>`

Rules:
- No generic Kubernetes explanations — user knows k8s
- Focus on THIS cluster's setup and constraints
- If input is a free-form question: answer from INFRA.md context + Claude knowledge, include the most relevant link if a component is clearly involved
- If component not in the map: answer from INFRA.md + Claude knowledge only, no link
