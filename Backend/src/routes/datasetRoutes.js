const express = require("express");
const upload = require("../middleware/uploadMiddleware");
const { requireAuth } = require("../middleware/authMiddleware");
const {
  validateCreateDataset,
  validateIdParam,
  validateFileUpload,
} = require("../middleware/validationMiddleware");

const {
  createDataset,
  getDatasets,
  getDataset,
  deleteDataset,
  uploadDataset,
  searchDatasets,
} = require("../controllers/datasetController");

const router = express.Router();

router.post("/", requireAuth, validateCreateDataset, createDataset);
router.get("/", requireAuth, getDatasets);
router.get("/search", requireAuth, searchDatasets);
router.get("/:id", requireAuth, validateIdParam("id"), getDataset);
router.delete("/:id", requireAuth, validateIdParam("id"), deleteDataset);
router.post(
  "/upload",
  requireAuth,
  upload.single("file"),
  validateFileUpload,
  uploadDataset
);

module.exports = router;
