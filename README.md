# Misinformation Diffusion Dashboard & Social Network Analysis (SNA) Platform

A professional, full-stack, mobile-first platform for analyzing social network structures, tracking misinformation propagation, computing degree centrality metrics, and generating automated intelligence reports.

---

## 📌 Research Problem & Objectives

### Research Problem
The rapid spread of online misinformation across social platforms threatens public discourse, public health, and social stability. Understanding how false narratives diffuse requires analyzing user interaction networks, identifying key superspreader hubs, and tracking narrative timelines across datasets.

### Primary Objectives
1. **Social Network Analysis (SNA)**: Map user interactions (retweets, mentions, replies) into directed graphs to compute degree centrality, network density, and influence rankings.
2. **Superspreader Hub Identification**: Detect high-centrality accounts responsible for driving misinformation diffusion.
3. **Timeline & Narrative Analysis**: Measure volume spikes and misinformation ratios over time.
4. **Automated Intelligence Reports**: Generate exportable PDF and CSV analysis reports for academic and forensic auditing.

---

## 🚀 Key Features

- **Mobile-First Interactive Graph Canvas**: Zoomable, pannable network graph with node size proportional to degree centrality and color-coded influence risk tiers.
- **Real-Time Reactive Filtering**: Filter graph nodes by degree thresholds, interaction types, search terms, and misinformation hub status.
- **Batch CSV Dataset Import**: High-performance $O(1)$ batch database insertion for multi-thousand row social datasets.
- **Automated PDF & CSV Exporting**: On-demand generation of formatted executive summary PDFs and structured CSV dataset downloads.
- **Swagger / OpenAPI 3.0 Documentation**: Embedded interactive API documentation served directly at `/api/docs`.
- **Cross-Platform Responsive UI**: Seamless progressive layout scaling across Mobile (<600dp), Tablet (600dp–1024dp), and Desktop (>1024dp).
- **High-Density Container Orchestration**: Fully containerized stack powered by Docker Compose, featuring healthcheck-gated startup and automated Prisma database migration bootstrapping.

---

## 🛠️ Technology Stack

### Backend Architecture & Infrastructure
- **Runtime**: Node.js v22+ (`node:22-alpine`)
- **Framework**: Express.js v5.2
- **Database & ORM**: MySQL 8.4 LTS with Prisma ORM v6.19
- **Containerization**: Docker Multi-Stage Build & Docker Compose (v2)
- **Validation**: Zod schema validation
- **Authentication**: JSON Web Tokens (JWT) with bcrypt password hashing
- **File Uploads**: Multer middleware with `csv-parser`
- **PDF Generation**: PDFKit stream builder
- **Documentation**: Swagger UI Express / OpenAPI 3.0

### Frontend Architecture
- **Framework**: Flutter 3.12+ (Dart SDK 3.12+)
- **State Management**: Provider / Stateful Reactive Architecture
- **Data Visualization**: Custom Canvas Graphics Engine + `fl_chart` + `graphview`
- **Networking**: HTTP package with JWT Authorization headers & `--dart-define` IP binding
- **Local Storage**: SharedPreferences

---

## 📁 System Folder Structure

```
my-project/
├── docker-compose.yml              # Root Multi-Container Orchestration (MySQL 8.4 + Node.js)
├── Backend/
│   ├── Dockerfile                  # Multi-Stage Production Dockerfile (node:22-alpine)
│   ├── docker-entrypoint.sh        # Container Boot Script (Prisma Migrations + Express)
│   ├── .dockerignore               # Docker Build Exclusion Rules
│   ├── prisma/
│   │   ├── migrations/             # SQL Migration History
│   │   └── schema.prisma           # Prisma Relational Model & Indexes
│   ├── src/
│   │   ├── config/                 # Prisma Client Connection
│   │   ├── controllers/            # Request Controllers
│   │   ├── docs/                   # Swagger Specs
│   │   ├── middleware/             # Auth & Zod Validation Middleware
│   │   ├── routes/                 # Express API Routes
│   │   ├── services/               # Core Domain Logic
│   │   ├── utils/                  # JWT & Helper Utilities
│   │   ├── app.js                  # Express App Instance
│   │   └── server.js               # Server Entry Point
│   ├── .env.example                # Environment Template
│   └── package.json                # Node Dependencies
└── frontend/
    ├── lib/
    │   ├── config/                 # API Endpoint Configuration
    │   ├── models/                 # Dart Models
    │   ├── screens/                # Mobile-First Flutter Screens
    │   ├── services/               # REST HTTP Services
    │   ├── widgets/                # Reusable UI & Graph Painter Widgets
    │   └── main.dart               # Flutter Application Entry Point
    └── pubspec.yaml                # Flutter Dependencies
```

---

## 🐳 Containerized Deployment (Recommended)

The platform includes a production-grade multi-stage container deployment setup via Docker Compose.

### 1. Launch Full Stack with Docker Compose
From the project root directory, run:

```bash
docker compose up --build -d
```

This single command:
1. Provisions a **MySQL 8.4 LTS** container with isolated volume persistence (`mysql_data`).
2. Runs healthchecks on the database until it reports `healthy`.
3. Builds the minimal `node:22-alpine` production image for the backend.
4. Executes `npx prisma migrate deploy` automatically via `docker-entrypoint.sh`.
5. Starts the Express API server on `http://localhost:5000`.

### 2. Monitoring Services & Logs
```bash
# View active container status
docker compose ps

# Tail backend application logs
docker compose logs -f backend

# Tail database logs
docker compose logs -f db
```

### 3. Stop Containers
```bash
docker compose down
```

---

## 📱 Mobile Device Testing over Local Wi-Fi

To connect a physical mobile device running the Flutter application to the backend over local Wi-Fi:

### 1. Determine Host IP Address
On your host system, check your LAN IP address:
```bash
hostname -I
```
*(Example Host IP: `10.83.21.88`)*

### 2. Configure Firewall (Ubuntu UFW)
Ensure port `5000` is allowed through the firewall:
```bash
sudo ufw allow 5000/tcp
sudo ufw reload
```

### 3. Launch Flutter App Target
Run the Flutter application targeting your host machine's IP address:
```bash
cd frontend
flutter run -d <device-id> --dart-define=API_BASE_URL=http://<HOST_IP>:5000/api
```

---

## 💻 Manual / Local Development Setup

If you prefer running services directly on your host machine without Docker:

### 1. Database Setup
Ensure MySQL 8.4 is running locally and set up the target database:
```sql
CREATE DATABASE misinformation_dashboard;
```

### 2. Backend Setup
Create `Backend/.env`:
```env
PORT=5000
DATABASE_URL="mysql://root:Kimani@localhost:3306/misinformation_dashboard"
JWT_SECRET=your_jwt_secret_key_here
```

Install dependencies and start the dev server:
```bash
cd Backend
npm install
npx prisma migrate dev
npm run dev
```

### 3. Frontend Setup
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

---

## 📑 Interactive API Documentation

Access the live Swagger UI when the backend is running at:
```
http://localhost:5000/api/docs
```

---

## 📄 License
This project is developed for academic research and educational evaluation under the MIT License.
