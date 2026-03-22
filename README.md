# Claw_Rising – OpenClaw Instance Backups

This repository serves as a backup location for OpenClaw instance configurations, workspaces, and skills.

## Purpose

OpenClaw is a personal assistant agent that learns from your usage patterns, preferences, and workspace files. Backing up your instance ensures:

- **Continuity**: Your assistant's memory, identity, and configurations are preserved across migrations or re-installs.
- **Recovery**: If your primary machine fails or you switch devices, you can restore your OpenClaw instance exactly as it was.
- **Versioning**: Track changes to your workspace, skills, and configurations over time.

## What's Backed Up

Each backup archive contains:

- **`.openclaw/` directory** – Configuration files, workspace, credentials, logs, devices, memory, and cron jobs.
- **`skills/` directory** – OpenClaw skills installed via npm (excluding system-wide node_modules).
- **`README.md`** – This file, explaining the backup intent.

## How to Use

### Creating a Backup

```bash
# Clone this repository locally
gh repo clone Viper-OC/Claw_Rising

# Create a backup archive (example)
tar -czf openclaw_backup_$(date +%Y%m%d_%H%M%S).tar.gz ~/.openclaw ~/.npm-global/lib/node_modules/openclaw/skills

# Add, commit, push
git add openclaw_backup_*.tar.gz
git commit -m "Backup OpenClaw instance $(date +%Y-%m-%d)"
git push origin main
```

### Restoring a Backup

1. Extract the archive to a temporary location.
2. Restore `.openclaw` to `~/.openclaw` (merge or replace as needed).
3. Restore `skills` to the appropriate npm global location.
4. Restart OpenClaw gateway.

## Backup Schedule

Consider setting up a cron job or OpenClaw heartbeat to automate regular backups. Example cron:

```bash
# Weekly backup every Sunday at 2 AM
0 2 * * 0 cd /path/to/Claw_Rising && ./backup.sh
```

## Notes

- **Sensitive data**: Credentials and tokens are stored in `.openclaw/credentials/`. Ensure you trust the security of this repository.
- **Size**: Backups are compressed; typical instance size is 1–5 MB.
- **Versioning**: Each backup is a new tarball; previous versions remain in git history.

## Why "Claw_Rising"?

The name reflects the resilience of your OpenClaw instance – it can rise again from backup, even if the original falls.

---

*This repository was initialized and first backup created by OpenClaw on 2026-03-22.*