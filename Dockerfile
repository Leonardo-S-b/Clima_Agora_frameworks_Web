# syntax=docker/dockerfile:1.7

# Este Dockerfile único cobre os dois serviços do projeto:
# - backend Node/Express em /backend
# - frontend Flutter Web na raiz
# Cada serviço usa um target diferente no docker-compose.

ARG NODE_VERSION=22
ARG FLUTTER_IMAGE=ghcr.io/cirruslabs/flutter:stable
ARG NGINX_IMAGE=nginxinc/nginx-unprivileged:1.27-alpine

# -----------------------------------------------------------------------------
# Backend: dependências base para dev e build
# -----------------------------------------------------------------------------
FROM node:${NODE_VERSION}-alpine AS backend-base
WORKDIR /workspace/backend

# curl fica disponível para healthcheck e depuração local.
RUN apk add --no-cache curl su-exec

# Copiamos só o manifesto primeiro para aproveitar cache de camada.
COPY backend/package*.json ./
RUN npm ci

FROM backend-base AS backend-dev
ENV NODE_ENV=development
EXPOSE 8787
CMD ["sh", "-c", "chown -R node:node /workspace/backend /workspace/backend/node_modules 2>/dev/null || true; exec su-exec node npm run dev"]

FROM backend-base AS backend-build
ENV NODE_ENV=production
COPY backend/ ./
RUN npm prune --omit=dev

FROM node:${NODE_VERSION}-alpine AS backend-prod
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=8787

# Runtime final com usuário não-root.
RUN apk add --no-cache curl \
  && addgroup -S app \
  && adduser -S app -G app

COPY --from=backend-build --chown=app:app /workspace/backend /app
COPY docker/healthchecks/backend.sh /usr/local/bin/healthcheck.sh
RUN sed -i 's/\r$//' /usr/local/bin/healthcheck.sh \
  && chmod 755 /usr/local/bin/healthcheck.sh

USER app
EXPOSE 8787
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["sh", "/usr/local/bin/healthcheck.sh"]
CMD ["node", "src/server.js"]

# -----------------------------------------------------------------------------
# Frontend: build do Flutter Web e runtime estático
# -----------------------------------------------------------------------------
FROM ${FLUTTER_IMAGE} AS web-base
WORKDIR /workspace
ENV FLUTTER_SUPPRESS_ANALYTICS=true

# Habilita Web no SDK do Flutter do container.
RUN flutter config --enable-web

FROM web-base AS web-dev
ENV PORT=5173
ENV AI_BACKEND_URL=http://localhost:8787
EXPOSE 5173

# Mantém o fluxo de hot reload via bind mount + flutter run.
CMD ["sh", "-c", "flutter pub get && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5173 --dart-define=AI_BACKEND_URL=$AI_BACKEND_URL"]

FROM web-base AS web-build
ARG AI_BACKEND_URL
ENV AI_BACKEND_URL=${AI_BACKEND_URL}

# Copia apenas os arquivos que o build web precisa.
COPY pubspec.yaml ./
COPY pubspec.lock ./
COPY lib ./lib
COPY web ./web

RUN flutter pub get \
  && test -n "${AI_BACKEND_URL}" \
  && case "${AI_BACKEND_URL}" in \
    http://localhost*|https://localhost*|http://127.0.0.1*|https://127.0.0.1*) \
      echo "AI_BACKEND_URL inválida para build de produção: ${AI_BACKEND_URL}" && exit 1 ;; \
    *) true ;; \
  esac \
  && flutter build web --release --pwa-strategy=none --dart-define=AI_BACKEND_URL=${AI_BACKEND_URL}

FROM ${NGINX_IMAGE} AS web-prod
WORKDIR /usr/share/nginx/html
ENV PORT=8080

# O runtime final é um nginx unprivileged em Alpine.
COPY --from=web-build /workspace/build/web/ ./
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY docker/healthchecks/frontend.sh /usr/local/bin/healthcheck.sh

USER root
RUN sed -i 's/\r$//' /usr/local/bin/healthcheck.sh \
  && apk add --no-cache curl \
  && chmod 755 /usr/local/bin/healthcheck.sh
USER 101

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["sh", "/usr/local/bin/healthcheck.sh"]
CMD ["nginx", "-g", "daemon off;"]
