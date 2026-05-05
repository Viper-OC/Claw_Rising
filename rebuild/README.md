# Claw_Rising — Rebuild Package

Portable, Dockerised recreation of the WSL2 production environment. Spin up an
identical copy of the OpenClaw workstation on any machine with Docker.

## Contents

| File/Dir | Purpose |
|----------|---------|
| `Dockerfile` | Multi-stage build (base → openclaw → gallery → staging → prod) |
| `docker-compose.yml` | Dual-lane: `staging` (hot-reload) + `prod` (baked) |
| `docker-entrypoint.sh` | Entrypoint orchestrating gateway + gallery services |
| `.env.example` | All environment variables with inline docs |
| `audit-2026-05-05.md` | WSL2 environment audit used to build this package |

## Quick Start

```bash
# 1. Clone
git clone https://github.com/Viper-OC/Claw_Rising.git
cd Claw_Rising/rebuild

# 2. Configure
cp .env.example .env
# Edit .env with your API keys

# 3. Launch staging (development)
docker compose up staging

# 4. Or launch prod
docker compose up -d prod
```

## What You Get

| Service | Port | Description |
|---------|------|-------------|
| OpenClaw Gateway | 19000 | Core AI assistant daemon |
| Gallery Backend | 8001 | FastAPI image gallery API (SQLite) |
| Gallery Frontend | 3000 | Next.js web UI for the gallery |

## Lanes

| Lane | Image Target | Reload | Use Case |
|------|-------------|--------|----------|
| `staging` | `staging` | Hot-reload (bind-mount) | Active development |
| `prod` | `prod` | Static assets baked in | Production deployment |

## Environment Footprint (from WSL2 audit)

- **OS**: Ubuntu 24.04.1 LTS (Noble Numbat)
- **Kernel**: 6.6.87.2-microsoft-standard-WSL2 (x86_64)
- **CPU**: Intel i5-6600K @ 3.50GHz (4 cores)
- **RAM**: 7.7 GB (5.9 GB available)
- **Disk**: 1007 GB (938 GB available)
- **Node.js**: v22.22.1
- **npm**: 10.9.4
- **Python**: 3.12.3 / pip 26.0.1
- **OpenClaw**: v2026.4.24
- **Git**: 2.43.0
- **Shell**: bash (zsh also available)
- **Editor**: vim, nano
- **Process Manager**: systemd (user services)
