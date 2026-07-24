const express = require("express");
const router = express.Router();

const { uploadDataset } = require("../controllers/uploadController");
const upload = require("../middleware/uploadMiddleware");
const { requireAuth } = require("../middleware/authMiddleware");
const { validateFileUpload } = require("../middleware/validationMiddleware");

router.post(
  "/",
  requireAuth,
  upload.single("file"),
  validateFileUpload,
  uploadDataset
);

module.exports = router;