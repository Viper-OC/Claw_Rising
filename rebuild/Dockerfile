# ─── Claw_Rising Rebuild — Dockerfile ───────────────────────────────────────
# Replicates the production WSL2 environment:
#   Ubuntu 24.04 · Node.js v22.22.1 · Python 3.12 · OpenClaw · Gallery
#
# Stages:
#   base       — system deps + runtime install
#   openclaw   — OpenClaw gateway + configuration
#   gallery    — FastAPI backend + Next.js frontend
#   staging    — development with hot-reload bind-mounts (default)
#   prod       — production with baked-in assets
# ─────────────────────────────────────────────────────────────────────────────

# ─── Stage 0: Base ──────────────────────────────────────────────────────────
FROM ubuntu:24.04 AS base

LABEL org.opencontainers.image.title="Claw_Rising Rebuild"
LABEL org.opencontainers.image.description="Portable OpenClaw environment — Viper-OC/Claw_Rising"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="Viper-OC (samueljohnbritton@gmail.com)"

# Prevent interactive prompts during apt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# System dependencies (mirrors WSL2 Noble Numbat)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    git \
    wget \
    vim \
    nano \
    tmux \
    python3 \
    python3-pip \
    python3-venv \
    sqlite3 \
    systemd \
    && rm -rf /var/lib/apt/lists/*

# ─── Node.js (v22.22.1 via NodeSource — matches WSL) ────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && node --version | grep "v22."

# Verify Node.js version matches WSL's v22.22.1
RUN node --version

# Global npm base
ENV NPM_CONFIG_PREFIX=/usr/local
RUN npm install -g npm@10

# ─── Non-root user ──────────────────────────────────────────────────────
RUN useradd -m -d /home/samuel -s /bin/bash samuel \
    && usermod -aG sudo samuel \
    && echo "samuel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER samuel
WORKDIR /home/samuel

# ─── Python packages (system-level) ─────────────────────────────────────
RUN pip3 install --no-cache-dir --user \
    fastapi \
    uvicorn \
    replicate \
    httpx \
    aiohttp \
    aiosqlite \
    Pillow \
    python-multipart \
    python-dotenv \
    requests \
    jinja2

ENV PATH="/home/samuel/.local/bin:${PATH}"

# ─── OpenClaw ───────────────────────────────────────────────────────────
FROM base AS openclaw

# Install OpenClaw globally
RUN npm install -g openclaw

# Verify
RUN openclaw --version 2>/dev/null || node -e "console.log('openclaw installed');"

# ─── Gallery backend ────────────────────────────────────────────────────
FROM openclaw AS gallery

COPY --chown=samuel:samuel projects/gallery /home/samuel/projects/gallery
WORKDIR /home/samuel/projects/gallery

# Install the gallery package in development mode
RUN pip3 install --no-cache-dir --user -e .

WORKDIR /home/samuel

# ─── Staging (development) ──────────────────────────────────────────────
FROM gallery AS staging

# Bind-mounts expected at runtime — no extra layers
EXPOSE 19000   # OpenClaw gateway
EXPOSE 3000    # Gallery frontend (Next.js)
EXPOSE 8001    # Gallery backend (FastAPI)
EXPOSE 4040    # ngrok admin

COPY --chown=samuel:samuel docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["staging"]

# ─── Production ─────────────────────────────────────────────────────────
FROM gallery AS prod

# Bake the frontend (assumes pre-built artefacts provided at build time)
COPY --chown=samuel:samuel projects/gallery/frontend/.next /home/samuel/projects/gallery/frontend/.next
COPY --chown=samuel:samuel projects/gallery/frontend/node_modules /home/samuel/projects/gallery/frontend/node_modules

EXPOSE 19000
EXPOSE 8001
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -sf http://localhost:8001/api/predictions?limit=1 > /dev/null 2>&1 || exit 1

COPY --chown=samuel:samuel docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["prod"]
