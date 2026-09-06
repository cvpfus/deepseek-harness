FROM node:22-slim
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@11.7.0 --activate
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm run build
CMD ["pnpm", "dsh", "web", "--port", "3080"]
