FROM node:22-slim
WORKDIR /app

# python3 + build-essential: fs-ext has no prebuilt binary and compiles via node-gyp.
# git: quiets lefthook's postinstall and covers anything else that shells out to git.
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    build-essential \
    git \
    socat \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@11.7.0 --activate

COPY . .
RUN pnpm install --frozen-lockfile

# The build embeds a commit hash into the frontend via `git rev-parse HEAD`.
# The build context here has no .git, so provide it explicitly instead.
ARG DSH_CLIENT_COMMIT_HASH=0000000
ENV DSH_CLIENT_COMMIT_HASH=$DSH_CLIENT_COMMIT_HASH

RUN pnpm run build

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 8080 is what Coolify's proxy talks to; dsh itself only ever binds 127.0.0.1:3080.
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
