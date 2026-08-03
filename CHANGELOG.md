# Changelog

All notable changes to the **Misinformation Diffusion Research Intelligence Dashboard** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0-rc1] - 2026-08-03

### Release Candidate 1 (RC1) — Production Readiness Release

#### Added
- **Netlify & Render Deployment Architecture**:
  - Netlify SPA routing fallback (`netlify.toml` with `/*` redirect).
  - Production Express configuration in `app.js` and `server.js`.
  - Added `GET /health` endpoint for uptime monitoring and database connectivity verification.
  - Added `helmet`, `compression`, and `express-rate-limit` middleware.
  - Added CORS configuration supporting `process.env.CORS_ORIGIN`, local environments, and `*.netlify.app`.
- **Flutter Web Build System**:
  - Standardized `API_BASE_URL` parsing via `--dart-define` in `lib/config/api_config.dart`.
  - Added cache-control headers in `netlify.toml` for CanvasKit and compiled JS assets.
- **Provider State Centralization**:
  - `DashboardProvider` centralizing dataset selection, network data, timeline series, hashtags, and top spreaders.
- **Academic Research Design System**:
  - `ResearchTheme` with Light (`#F8FAFC`) and Dark (`#0F172A`) palettes.
  - Monospace numeric metric formatting across summary cards and tables.
  - Risk-tier color tokens (Crimson High Risk, Amber Warning, Emerald Factual, Sky Blue Active).
- **Responsive 12-Column Desktop Grid**:
  - Primary network graph canvas occupies 60% of desktop layout width.
  - Mobile touch drawer and bottom sheet inspector support.
- **Synthetic Research Dataset Seeder**:
  - `prisma/seed.js` script populating 500 users, 6 datasets, 25,000 posts, and 60,000 interactions with power-law hashtag distribution.
- **Deployment Documentation & CI**:
  - Created `DEPLOYMENT.md` guide covering Railway, Render, Netlify, and Docker deployment.
  - Created `.github/workflows/deploy-ci.yml` GitHub Actions workflow.
  - Added root `.gitignore` ensuring environment secrets and build artifacts remain isolated.

#### Changed
- Updated Express backend scripts in `package.json` to include `"build": "prisma generate"` and `"postinstall": "prisma generate"`.
- Enhanced `NetworkGraphPainter` with directional arrowheads, Reach Score radial node sizing, and risk coloring.

#### Security
- Removed hardcoded credentials in codebase; externalized environment settings to `.env.example`.
- Configured Express rate limiting (300 requests per 15 mins per IP).
