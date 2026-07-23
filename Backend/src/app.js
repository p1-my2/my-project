require("dotenv").config();

const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/authRoutes");
const datasetRoutes = require("./routes/datasetRoutes");
const analysisRoutes = require("./routes/analysisRoutes");
const reportRoutes = require("./routes/reportRoutes");
const uploadRoutes = require("./routes/uploadRoutes");

const app = express();

/**
 * ===============================
 * Middlewares
 * ===============================
 */const path = require("path");

app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Enable Cross-Origin Resource Sharing
app.use(cors());

// Parse incoming JSON requests
app.use(express.json());

// Parse URL-encoded form data
app.use(express.urlencoded({ extended: true }));

/**
 * ===============================
 * Root Route
 * ===============================
 */
app.get("/", (req, res) => {
    res.status(200).json({
        success: true,
        message: "Misinformation Dashboard API is running successfully."
    });
});

/**
 * ===============================
 * API Routes
 * ===============================
 */

// Authentication
app.use("/api/auth", authRoutes);

// Dataset Management
app.use("/api/datasets", datasetRoutes);

// Analysis Module
app.use("/api/analysis", analysisRoutes);

// Report Module
app.use("/api/reports", reportRoutes);

app.use("/api/upload", uploadRoutes);

/**
 * ===============================
 * 404 Handler
 * ===============================
 */
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: "Route not found."
    });
});

/**
 * ===============================
 * Global Error Handler
 * ===============================
 */
app.use((err, req, res, next) => {
    console.error("Server Error:", err);

    res.status(err.status || 500).json({
        success: false,
        message: err.message || "Internal Server Error"
    });
});

module.exports = app;