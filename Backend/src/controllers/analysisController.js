const analyticsService = require("../services/analyticsService");

async function dashboardSummary(req, res, next) {
  try {
    const data = await analyticsService.getDashboardSummary({ datasetId: req.query.datasetId });
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

async function datasetSummary(req, res, next) {
  try {
    const dataset = await analyticsService.getDatasetSummary(req.params.id);
    if (!dataset) {
      return res.status(404).json({ success: false, message: "Dataset not found." });
    }
    res.status(200).json({ success: true, data: dataset });
  } catch (error) {
    next(error);
  }
}

async function topInfluencers(req, res, next) {
  try {
    const data = await analyticsService.getTopInfluencers({ datasetId: req.query.datasetId, limit: 10 });
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

async function topHashtags(req, res, next) {
  try {
    const data = await analyticsService.getTopHashtags({ datasetId: req.query.datasetId, limit: 10 });
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

async function timelineAnalysis(req, res, next) {
  try {
    const result = await analyticsService.getTimelineAnalysis({ datasetId: req.query.datasetId });
    res.status(200).json({
      success: true,
      totalDays: result.totalDays,
      totalPosts: result.totalPosts,
      data: result.data,
    });
  } catch (error) {
    next(error);
  }
}

async function interactionAnalysis(req, res, next) {
  try {
    const result = await analyticsService.getInteractionAnalysis({ datasetId: req.query.datasetId });
    res.status(200).json({
      success: true,
      totalInteractions: result.totalInteractions,
      data: result.data,
    });
  } catch (error) {
    next(error);
  }
}

async function networkStatistics(req, res, next) {
  try {
    const data = await analyticsService.getNetworkStatistics({ datasetId: req.query.datasetId });
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

async function centralityAnalysis(req, res, next) {
  try {
    const result = await analyticsService.getCentralityAnalysis({ datasetId: req.query.datasetId });
    res.status(200).json({
      success: true,
      totalResults: result.totalResults,
      data: result.data,
      network: result.network,
    });
  } catch (error) {
    next(error);
  }
}

async function misinformationStatistics(req, res, next) {
  try {
    const data = await analyticsService.getMisinformationStatistics({ datasetId: req.query.datasetId });
    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  dashboardSummary,
  datasetSummary,
  topInfluencers,
  topHashtags,
  timelineAnalysis,
  interactionAnalysis,
  networkStatistics,
  centralityAnalysis,
  misinformationStatistics,
};
