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
- **Structured JSON Audit Logging & Standardized API Envelopes**: Backend middleware emitting JSON audit metrics and `{ success: true, data, meta }` response envelopes.
- **Swagger / OpenAPI 3.0 Documentation**: Embedded interactive API documentation served directly at `/api/docs`.

---

## 🛠️ Technology Stack

### Backend Architecture & Infrastructure
- **Runtime**: Node.js v22+ (`node:22-alpine`)
- **Framework**: Express.js v5.2
- **Database & ORM**: MySQL 8.4 LTS with Prisma ORM v6.19
- **Containerization**: Docker Multi-Stage Build & Docker Compose (v2)
- **Logging**: Structured JSON Audit Logger
- **API Envelope**: Standardized `{ success, data, meta }` Response Envelopes
- **Documentation**: Swagger UI Express / OpenAPI 3.0

### Frontend Architecture
- **Framework**: Flutter 3.12+ (Dart SDK 3.12+)
- **State Management**: Centralized Provider (`DashboardProvider`)
- **Design System**: Research Theme (`ResearchTheme`) supporting Light & Dark modes
- **Data Visualization**: Custom Canvas Network Painter + `fl_chart` + `graphview`
- **Networking**: HTTP package with JWT Authorization headers & `--dart-define` IP binding

---

## 📁 System Folder Structure

```
my-project/
├── docker-compose.yml              # Root Multi-Container Orchestration (MySQL 8.4 + Node.js)
├── Backend/
│   ├── Dockerfile                  # Multi-Stage Production Dockerfile (node:22-alpine)
│   ├── docker-entrypoint.sh        # Container Boot Script (Prisma Migrations + Express)
│   ├── prisma/
│   │   ├── migrations/             # SQL Migration History
│   │   └── schema.prisma           # Prisma Relational Model & Indexes
│   └── src/
│       ├── config/                 # Prisma Client Connection
│       ├── controllers/            # Request Controllers
│       ├── middleware/             # Auth & Structured Request Logger Middleware
│       ├── routes/                 # Express API Routes
│       ├── services/               # Core Domain & SNA Services
│       ├── utils/                  # API Response Envelopes & Helpers
│       ├── app.js                  # Express App Instance
│       └── server.js               # Server Entry Point
└── frontend/
    └── lib/
        ├── config/                 # API & ResearchTheme Configuration
        ├── models/                 # Dart Models (Network, Timeline, Summary)
        ├── providers/              # DashboardProvider State Engine
        ├── screens/                # Mobile-First & Desktop Flutter Screens
        ├── services/               # REST HTTP Services
        ├── widgets/                # Reusable UI & Graph Painter Widgets
        └── main.dart               # Flutter Application Entry Point
```

---

## 💻 Running the Application

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

Access live Swagger UI when the backend is running at:
```
http://localhost:5000/api/docs
```

---

## 📄 License
This project is developed for academic research and educational evaluation under the MIT License.
