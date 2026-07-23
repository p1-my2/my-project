const express = require("express");

const router = express.Router();

const { requireAuth } = require("../middleware/authMiddleware");

const {
  getReports,
  getReport,
  generatePDF,
  exportCSV,
  deleteReport,
} = require("../controllers/reportController");

// Get all reports
router.get("/", requireAuth, getReports);

// Get one report
router.get("/:id", requireAuth, getReport);

// Download PDF
router.get("/pdf/:datasetId", requireAuth, generatePDF);

// Export CSV
router.get("/csv/:datasetId", requireAuth, exportCSV);

// Delete report
router.delete("/:id", requireAuth, deleteReport);

module.exports = router;