FROM node:22-slim
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    build-essential \
    git \
    socat \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@11.7.0 --activate

# scripts/install-lefthook.mjs (the repo's postinstall) skips itself under
# CI/GITHUB_ACTIONS — set here since Docker builds don't inherit that from
# the runner automatically.
ENV CI=true

COPY . .
RUN pnpm install --frozen-lockfile

ARG DSH_CLIENT_COMMIT_HASH=0000000
ENV DSH_CLIENT_COMMIT_HASH=$DSH_CLIENT_COMMIT_HASH

RUN pnpm run build

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
