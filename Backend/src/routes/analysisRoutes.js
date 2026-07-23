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
    misinformationStatistics
} = require("../controllers/analysisController");

const { requireAuth } = require("../middleware/authMiddleware");

/**
 * Dashboard Summary
 * GET /api/analysis/dashboard
 */
router.get("/dashboard", requireAuth, dashboardSummary);

/**
 * Dataset Summary
 * GET /api/analysis/dataset/:id
 */
router.get("/dataset/:id", requireAuth, datasetSummary);

/**
 * Top Influencers
 * GET /api/analysis/influencers
 */
router.get("/influencers", requireAuth, topInfluencers);

/**
 * Top Hashtags
 * GET /api/analysis/hashtags
 */
router.get("/hashtags", requireAuth, topHashtags);

/**
 * Timeline Analysis
 * GET /api/analysis/timeline
 */
router.get("/timeline", requireAuth, timelineAnalysis);

/**
 * Interaction Analysis
 * GET /api/analysis/interactions
 */
router.get("/interactions", requireAuth, interactionAnalysis);

/**
 * Network Statistics
 * GET /api/analysis/network
 */
router.get("/network", requireAuth, networkStatistics);

/**
 * Centrality Analysis
 * GET /api/analysis/centrality
 */
router.get("/centrality", requireAuth, centralityAnalysis);

/**
 * Misinformation Statistics
 * GET /api/analysis/misinformation
 */
router.get("/misinformation", requireAuth, misinformationStatistics);

module.exports = router;