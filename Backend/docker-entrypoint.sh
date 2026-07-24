#!/bin/sh
set -e

echo "=== [Bootstrap] Running Prisma Migrations ==="
npx prisma migrate deploy

echo "=== [Bootstrap] Migrations Complete. Starting Server ==="
exec node src/server.js
