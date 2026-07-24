# Stage 1: Build & Prisma Client Generation
FROM node:22-alpine AS builder
WORKDIR /app

# Copy dependency manifests and Prisma schema to leverage Docker cache layers
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies and generate Prisma client binaries
RUN npm ci
RUN npx prisma generate

# Copy source application files
COPY . .

# Stage 2: Production Runner
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Copy production artifacts with ownership assigned to system user 'node'
COPY --chown=node:node --from=builder /app/package*.json ./
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node --from=builder /app/prisma ./prisma
COPY --chown=node:node --from=builder /app/src ./src
COPY --chown=node:node --from=builder /app/docker-entrypoint.sh ./docker-entrypoint.sh

# Run as non-root built-in system user 'node'
USER node

EXPOSE 5000

# Execute migrations and start server via entrypoint script
ENTRYPOINT ["/app/docker-entrypoint.sh"]
