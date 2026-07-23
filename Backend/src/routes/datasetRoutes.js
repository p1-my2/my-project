const express = require("express");
const upload = require("../middleware/uploadMiddleware");

const router = express.Router();

const {
  createDataset,
  getDatasets,
  getDataset,
  deleteDataset,
  uploadDataset,
  searchDatasets
} = require("../controllers/datasetController");

const {
  requireAuth
} = require("../middleware/authMiddleware");


router.post("/", requireAuth, createDataset);

router.get("/", requireAuth, getDatasets);

router.get("/search", requireAuth, searchDatasets);

router.get("/:id", requireAuth, getDataset);

router.delete("/:id", requireAuth, deleteDataset);

router.post("/upload", requireAuth, upload.single("file"),
  uploadDataset
);

module.exports = router;
