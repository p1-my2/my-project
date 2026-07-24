const express = require("express");
const router = express.Router();

const {
  dashboardSummary,
  datasetSummary,
  topInfluencers,
  topHashtags,
  timelineAnalysis,
  interactionAnalysis,
  networkStatistics,
  centralityAnalysis,
  misinformationStatistics,
} = require("../controllers/analysisController");

const { requireAuth } = require("../middleware/authMiddleware");
const { validateDatasetIdQuery, validateIdParam } = require("../middleware/validationMiddleware");

router.get("/dashboard", requireAuth, validateDatasetIdQuery, dashboardSummary);
router.get("/dataset/:id", requireAuth, validateIdParam("id"), datasetSummary);
router.get("/influencers", requireAuth, validateDatasetIdQuery, topInfluencers);
router.get("/hashtags", requireAuth, validateDatasetIdQuery, topHashtags);
router.get("/timeline", requireAuth, validateDatasetIdQuery, timelineAnalysis);
router.get("/interactions", requireAuth, validateDatasetIdQuery, interactionAnalysis);
router.get("/network", requireAuth, validateDatasetIdQuery, networkStatistics);
router.get("/centrality", requireAuth, validateDatasetIdQuery, centralityAnalysis);
router.get("/misinformation", requireAuth, validateDatasetIdQuery, misinformationStatistics);

module.exports = router;