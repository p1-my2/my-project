# Research Intelligence Dashboard for Misinformation Diffusion Analysis

An academic, full-stack, mobile-first research intelligence artifact for analyzing social network structures, tracking misinformation propagation, computing Reach Score amplification metrics, and generating automated academic reports.

---

## 📌 Research Problem & Academic Objectives

### Research Problem
The rapid spread of online misinformation across social platforms threatens public discourse, public health, and social stability. Understanding how false narratives diffuse requires analyzing user interaction networks, identifying key superspreader hubs, and tracking narrative timelines across datasets.

### Primary Objectives
1. **Social Network Analysis (SNA)**: Map user interactions (retweets, mentions, replies) into directed graphs to compute centrality, network density, and influence rankings.
2. **Superspreader & Reach Score Identification**: Detect high-centrality accounts and rank them using **Reach Score** ($\text{Followers} \times \text{Spread Count}$).
3. **Propagation Velocity Timeline**: Measure volume spikes and misinformation ratios over time.
4. **Automated Intelligence Reports**: Generate exportable PDF and CSV analysis reports for academic and forensic auditing.

---

## 🚀 Key Features

- **Responsive Research Intelligence Workspace**: 12-column desktop intelligence grid where the **Network Graph is the central research artifact**, flanked by propagation velocity timelines and top spreader leaderboards.
- **Provider Central State Engine**: Centralized reactive state (`DashboardProvider`) ensuring dataset selection updates graphs, timelines, spreaders, hashtags, and reports reactively without state desynchronization.
- **Research Design System (Light & Dark Themes)**: Academic slate visual identity with monospace numerical metric displays, color-coded claim badges, and light/dark theme switching.
- **Mobile-First Touch Architecture**: Progressive responsive design supporting phone drawer navigation & bottom sheet inspectors, tablet split views, and desktop navigation rails.
- **Resilient Cloud & Railway Hardening**: Centralized Zod environment validation with automatic `MYSQL_URL` $\rightarrow$ `DATABASE_URL` mapping for Railway, Render, Fly.io, Docker, and Localhost.
- **Swagger / OpenAPI 3.0 Documentation**: Embedded interactive API documentation served dynamically at `/api/docs`.

---

## 🛠️ Technology Stack

### Backend Architecture & Infrastructure
- **Runtime**: Node.js v22+ (`node:22-alpine`)
- **Framework**: Express.js v5.2
- **Database & ORM**: MySQL 8.4 LTS with Prisma ORM v6.19
- **Validation & Environment**: Zod v4.4 & Dotenv
- **Containerization**: Docker Multi-Stage Build & Docker Compose (v2)
- **Logging**: Structured JSON Audit Logger
- **API Envelope**: Standardized `{ success, data, meta }` Response Envelopes
- **Documentation**: Dynamic Swagger UI Express / OpenAPI 3.0

### Frontend Architecture
- **Framework**: Flutter 3.12+ (Dart SDK 3.12+)
- **State Management**: Centralized Provider (`DashboardProvider`)
- **Design System**: Research Theme (`ResearchTheme`) supporting Light & Dark modes
- **Data Visualization**: Custom Canvas Network Painter + `fl_chart` + `graphview`
- **Networking**: HTTP package with JWT Authorization headers & `--dart-define` IP binding

---

## ☁️ Cloud Deployment Configuration (Railway, Render, Fly.io)

### Railway Deployment & Environment Variables

When deploying the backend on **Railway.app**, Railway automatically provisions MySQL and sets the connection environment variable `MYSQL_URL`.

The backend includes an automatic fallback module (`src/config/env.js`) that checks for `MYSQL_URL` before initializing Prisma:
```javascript
if (!process.env.DATABASE_URL && process.env.MYSQL_URL) {
  process.env.DATABASE_URL = process.env.MYSQL_URL;
}
```

#### Required Railway Environment Variables

| Variable Name | Required | Description | Example |
| :--- | :---: | :--- | :--- |
| `DATABASE_URL` | **Yes** *(or `MYSQL_URL`)* | Connection string for MySQL 8 | `mysql://root:pass@host:3306/db` |
| `MYSQL_URL` | *Auto* | Automatically provided by Railway MySQL service | `mysql://root:pass@host:3306/railway` |
| `JWT_SECRET` | **Yes** | Secret key for JWT token signing | `openssl rand -base64 32` |
| `PORT` | *Auto* | Internal service port (Railway sets this dynamically) | `8080` / `5000` |
| `NODE_ENV` | Optional | Set to `production` for cloud deployment | `production` |
| `CORS_ORIGIN` | Optional | Comma-separated list of allowed Netlify/Frontend URLs | `https://my-app.netlify.app` |

> **Recommendation**: While the code automatically handles `MYSQL_URL`, creating a variable reference `DATABASE_URL=${{MySQL.MYSQL_URL}}` in Railway settings is recommended for explicit configuration.

---

## 💻 Running the Application Locally

### 1. Backend Service
```bash
cd Backend
npm install
npx prisma migrate dev
npm run dev
```

### 2. Frontend Application (Flutter)
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

---

## 📑 Interactive API Documentation

Access live Swagger UI dynamically at:
```
http://localhost:5000/api/docs
```
*(In production, Swagger automatically updates server URLs to reflect your live cloud domain, e.g. `https://<your-railway-app>.up.railway.app/api`).*

---

## 📄 License
This project is developed for academic research and educational evaluation under the MIT License.
