# Production Deployment Guide & Implementation Blueprint
## Misinformation Research Intelligence Dashboard (v1.0.0-rc1)

This guide provides step-by-step production deployment instructions for the **Research Intelligence Dashboard**, deploying the **Flutter Web frontend on Netlify (Free Tier)**, the **Express.js API on Render (Free Tier)**, and the **MySQL 8 Database on Railway**.

---

## 🏗️ Architecture Overview

```
 ┌───────────────────────────┐         ┌───────────────────────────┐         ┌───────────────────────────┐
 │     Netlify (Frontend)    │         │      Render (Backend)     │         │     Railway (Database)    │
 │                           │  HTTP   │                           │  MySQL  │                           │
 │ • Flutter 3.x Web Release │ ──────► │ • Express.js (Node 22)    │ ──────► │ • MySQL 8.4 LTS           │
 │ • SPA Routing (`/*`)      │  REST   │ • Prisma ORM              │ Socket  │ • Managed Storage Volume  │
 │ • Static Asset CDN        │  JSON   │ • CORS & Rate Limiting    │  3306   │ • SSL Connection          │
 └───────────────────────────┘         └───────────────────────────┘         └───────────────────────────┘
```

---

## 1. Step 1: Database Provisioning on Railway

1. **Create Railway Account**: Sign in to [Railway.app](https://railway.app).
2. **Provision MySQL Database**:
   * Click **New Project** $\rightarrow$ **Provision MySQL**.
   * Under database **Variables**, locate the connection credentials:
     * `MYSQLHOST`, `MYSQLPORT` (3306), `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE`.
3. **Construct Production `DATABASE_URL`**:
   ```env
   DATABASE_URL="mysql://<MYSQLUSER>:<MYSQLPASSWORD>@<MYSQLHOST>:<MYSQLPORT>/<MYSQLDATABASE>"
   ```
4. **Deploy Initial Schema**:
   From your local environment, run:
   ```bash
   cd Backend
   DATABASE_URL="mysql://..." npx prisma migrate deploy
   DATABASE_URL="mysql://..." node prisma/seed.js
   ```

---

## 2. Step 2: Backend API Deployment on Render

1. **Create Render Account**: Sign in to [Render.com](https://render.com).
2. **Create New Web Service**:
   * Connect your GitHub repository.
   * Root Directory: `Backend`
   * Environment: `Node`
   * Build Command: `npm run build` *(executes `prisma generate`)*
   * Start Command: `npm start` *(executes `node src/server.js`)*
3. **Configure Environment Variables**:
   Add the following environment variables in Render dashboard:
   * `PORT`: `5000` *(Render overrides this dynamically; code respects `process.env.PORT`)*
   * `NODE_ENV`: `production`
   * `DATABASE_URL`: `mysql://<MYSQLUSER>:<MYSQLPASSWORD>@<MYSQLHOST>:<MYSQLPORT>/<MYSQLDATABASE>`
   * `JWT_SECRET`: `<your-random-secure-secret-key>`
   * `CORS_ORIGIN`: `https://<your-app-name>.netlify.app`
   * `API_VERSION`: `1.0.0-rc1`
4. **Post-Deployment Migration Step**:
   * Render automatically installs dependencies and runs `npm run build` (`prisma generate`).
   * To apply database migrations on Render, add a pre-start step or run from Render Shell:
     ```bash
     npx prisma migrate deploy
     ```
5. **Verify Backend Health**:
   Test the endpoint in your browser:
   ```http
   GET https://<your-render-service-name>.onrender.com/health
   ```
   *Expected Response:*
   ```json
   {
     "status": "ok",
     "uptime": 45.2,
     "database": "connected",
     "timestamp": "2026-08-03T20:45:00.000Z",
     "version": "1.0.0-rc1",
     "environment": "production"
   }
   ```

---

## 3. Step 3: Frontend Web Deployment on Netlify

1. **Create Netlify Account**: Sign in to [Netlify.com](https://netlify.com).
2. **Connect Repository & Configure Build**:
   * Base directory: `frontend`
   * Build command:
     ```bash
     flutter build web --release --dart-define=API_BASE_URL=https://<your-render-service-name>.onrender.com/api
     ```
   * Publish directory: `frontend/build/web`
3. **Netlify File Routing**:
   * Netlify automatically reads `frontend/netlify.toml` which redirects `/*` to `/index.html` for single-page web navigation.
4. **Deploy Site**:
   * Click **Deploy Site**. Netlify will build the Flutter Web application and publish it to a global CDN (`https://<your-site-name>.netlify.app`).

---

## 4. Local Docker Container Deployment (Alternative)

For local demonstration or self-hosted container environments:

```bash
# 1. Build and start full stack in background
docker compose up --build -d

# 2. Verify running containers
docker compose ps

# 3. View API logs
docker compose logs -f backend

# 4. Stop stack
docker compose down
```

---

## 5. Troubleshooting & Diagnostic Guide

| Symptom | Root Cause | Solution |
| :--- | :--- | :--- |
| **`CORS Error` in Browser Console** | Backend `CORS_ORIGIN` does not include Netlify URL. | Update `CORS_ORIGIN` on Render to match `https://<your-site>.netlify.app`. |
| **`PrismaClientInitializationError`** | Railway database is unreachable or credentials wrong. | Verify `DATABASE_URL` format and test connectivity via `GET /health`. |
| **`404 Page Not Found` on Page Refresh** | Netlify missing SPA rewrite rule. | Ensure `frontend/netlify.toml` is present with `from = "/*"` `to = "/index.html"`. |
| **Render Web Service Timeout** | Database migration hanging on startup. | Ensure `npx prisma migrate deploy` is used instead of `npx prisma migrate dev`. |

---
*Deployment Blueprint Complete & Release Candidate 1 Ready.*
