---
name: hl-logs
description: Compressed pod logs. Strips Java stack traces to Caused by, drops INFO noise, keeps errors and meaningful events.
---

Get compressed logs for an app. Argument: app name or namespace.

Map to pod/namespace using INFRA.md. If multiple pods, get the main app pod (not cloudflared).

Run:
```bash
kubectl logs <pod> -n <ns> --tail=50
```
If pod is CrashLoopBackOff, also run with `--previous`.

Compress output aggressively:
- DROP: INFO lines unless they contain "started" / "listening" / "ready"
- DROP: full Java stack traces — keep only the FIRST "Caused by:" line per exception
- DROP: Quarkus augmentation/build lines
- DROP: repeated identical lines (show "above repeated N times")
- KEEP: all ERROR lines
- KEEP: all WARN lines
- KEEP: lines matching: failed|refused|timeout|unauthorized|forbidden|hostname|password|certificate|crash
- KEEP: last 3 INFO lines (startup confirmation or shutdown sequence)

Format output as:
```
[LEVEL] message
```
One line per entry. No timestamps. No thread names. No class paths.

If nothing concerning: "Logs clean — last event: <last meaningful line>"
