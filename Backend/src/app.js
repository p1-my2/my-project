const config = require("./config/env");

const fs = require("fs");
const path = require("path");
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const compression = require("compression");
const rateLimit = require("express-rate-limit");
const swaggerUi = require("swagger-ui-express");
const swaggerDocument = require("./docs/swagger.json");

const prisma = require("./config/prisma");
const authRoutes = require("./routes/authRoutes");
const datasetRoutes = require("./routes/datasetRoutes");
const analysisRoutes = require("./routes/analysisRoutes");
const reportRoutes = require("./routes/reportRoutes");
const uploadRoutes = require("./routes/uploadRoutes");
const requestLogger = require("./middleware/requestLogger");

const app = express();

/**
 * Ensure uploads directory exists on boot
 */
const uploadsDir = path.join(__dirname, "uploads");
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

/**
 * Security & Performance Middlewares
 */
app.use(helmet({ contentSecurityPolicy: false }));
app.use(compression());
app.use(requestLogger);

// Rate Limiter: 300 requests per 15 minutes window
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many requests from this IP, please try again after 15 minutes.",
  },
});
app.use("/api/", limiter);

/**
 * Robust CORS Configuration
 */
const defaultLocalOrigins = [
  "http://localhost:3000",
  "http://localhost:5000",
  "http://localhost:5173",
  "http://localhost:8080",
  "http://127.0.0.1:3000",
  "http://127.0.0.1:5000",
  "http://127.0.0.1:5173",
  "http://127.0.0.1:8080",
];

const configuredOrigins = new Set(defaultLocalOrigins);

if (config.CORS_ORIGIN) {
  config.CORS_ORIGIN.split(",").forEach((origin) => {
    const trimmed = origin.trim();
    if (trimmed) configuredOrigins.add(trimmed);
  });
}

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, curl, postman)
      if (!origin) return callback(null, true);
      
      if (
        configuredOrigins.has(origin) ||
        origin.endsWith(".netlify.app") ||
        origin.endsWith(".railway.app") ||
        origin.endsWith(".onrender.com") ||
        config.NODE_ENV !== "production"
      ) {
        return callback(null, true);
      }
      return callback(null, true); // Permissive fallback for release deployment
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));
app.use("/uploads", express.static(uploadsDir));

/**
 * Dynamic Interactive API Documentation (Swagger)
 */
app.use("/api/docs", (req, res, next) => {
  const protocol = req.headers["x-forwarded-proto"] || req.protocol || "http";
  const host = req.headers["x-forwarded-host"] || req.get("host");
  const dynamicServerUrl = `${protocol}://${host}/api`;

  const dynamicSwaggerDoc = {
    ...swaggerDocument,
    servers: [
      { url: dynamicServerUrl, description: "Active Environment Server" },
      { url: "http://localhost:5000/api", description: "Local Development Server" },
    ],
  };

  swaggerUi.setup(dynamicSwaggerDoc)(req, res, next);
}, swaggerUi.serve);

/**
 * Health Check Endpoint (Clean non-stacktrace DB check)
 */
app.get("/health", async (req, res) => {
  let isDbConnected = false;

  try {
    await prisma.$queryRaw`SELECT 1`;
    isDbConnected = true;
  } catch (err) {
    isDbConnected = false;
  }

  const status = isDbConnected ? "ok" : "degraded";
  const statusCode = isDbConnected ? 200 : 503;

  res.status(statusCode).json({
    status: status,
    uptime: Math.floor(process.uptime()),
    environment: config.NODE_ENV,
    version: config.API_VERSION,
    database: isDbConnected ? "connected" : "disconnected",
    timestamp: new Date().toISOString(),
  });
});

/**
 * Root Endpoint
 */
app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Misinformation Research Intelligence API is running.",
    health: "/health",
    docs: "/api/docs",
  });
});

/**
 * API Routes
 */
app.use("/api/auth", authRoutes);
app.use("/api/datasets", datasetRoutes);
app.use("/api/analysis", analysisRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/upload", uploadRoutes);

/**
 * 404 Handler
 */
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found.",
  });
});

/**
 * Global Error Handler
 */
app.use((err, req, res, next) => {
  console.error("Server Error:", err.message);
  const statusCode = err.status || err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    message: err.message || "Internal Server Error",
    ...(config.NODE_ENV !== "production" ? { stack: err.stack } : {}),
  });
});

module.exports = app;