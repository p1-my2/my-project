const express = require("express");
const router = express.Router();

const { requireAuth } = require("../middleware/authMiddleware");
const { validateIdParam } = require("../middleware/validationMiddleware");

const {
  getReports,
  getReport,
  generatePDF,
  exportCSV,
  deleteReport,
} = require("../controllers/reportController");

router.get("/", requireAuth, getReports);
router.get("/:id", requireAuth, validateIdParam("id"), getReport);
router.get("/pdf/:datasetId", requireAuth, validateIdParam("datasetId"), generatePDF);
router.get("/csv/:datasetId", requireAuth, validateIdParam("datasetId"), exportCSV);
router.delete("/:id", requireAuth, validateIdParam("id"), deleteReport);

module.exports = router;