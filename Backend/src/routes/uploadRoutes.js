const express = require("express");
const router = express.Router();

const { uploadDataset } = require("../controllers/uploadController");
const upload = require("../middleware/uploadMiddleware");
const { requireAuth } = require("../middleware/authMiddleware");

router.post(
  "/",
  requireAuth,
  upload.single("file"),
  uploadDataset
);

module.exports = router;