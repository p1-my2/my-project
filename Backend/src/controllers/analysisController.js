const prisma = require("../config/prisma");
const { buildNetwork } = require("../services/networkAnalysisService");

function datasetFilter(req) {
  const id = Number(req.query.datasetId);
  return Number.isInteger(id) && id > 0 ? { datasetId: id } : {};
}

function relatedPostFilter(req) {
  return { post: datasetFilter(req) };
}

async function dashboardSummary(req, res) {
  try {
    const filter = datasetFilter(req);
    const [totalUsers, totalDatasets, totalPosts, totalHashtags, totalReports, misinformationPosts] = await Promise.all([
      prisma.user.count(), prisma.dataset.count(), prisma.post.count({ where: filter }),
      prisma.hashtag.count({ where: relatedPostFilter(req) }), prisma.report.count(),
      prisma.post.count({ where: { ...filter, isMisinformation: true } }),
    ]);
    res.json({ success: true, data: { totalUsers, totalDatasets, totalPosts, totalHashtags, totalReports, misinformationPosts } });
  } catch (error) { res.status(500).json({ success: false, message: "Failed to retrieve dashboard summary." }); }
}

async function datasetSummary(req, res) {
  try {
    const dataset = await prisma.dataset.findUnique({ where: { id: Number(req.params.id) }, include: {
      uploadedBy: { select: { id: true, name: true, email: true } }, posts: true, reports: true,
    }});
    if (!dataset) return res.status(404).json({ success: false, message: "Dataset not found." });
    res.json({ success: true, data: dataset });
  } catch (error) { res.status(500).json({ success: false, message: "Failed to retrieve dataset summary." }); }
}

async function topInfluencers(req, res) {
  try {
    const data = await prisma.interaction.groupBy({ where: relatedPostFilter(req), by: ["sourceUser"],
      _count: { sourceUser: true }, orderBy: { _count: { sourceUser: "desc" } }, take: 10 });
    res.json({ success: true, data });
  } catch (error) { res.status(500).json({ success: false, message: "Failed to retrieve top influencers." }); }
}

async function topHashtags(req, res) {
  try {
    const data = await prisma.hashtag.groupBy({ where: relatedPostFilter(req), by: ["hashtag"],
      _count: { hashtag: true }, orderBy: { _count: { hashtag: "desc" } }, take: 10 });
    res.json({ success: true, data });
  } catch (error) { res.status(500).json({ success: false, message: "Failed to retrieve top hashtags." }); }
}

async function timelineAnalysis(req, res) {
  try {
    const posts = await prisma.post.findMany({ where: datasetFilter(req), orderBy: { createdAt: "asc" }, select: { createdAt: true, isMisinformation: true } });
    const grouped = {};
    posts.forEach(({ createdAt, isMisinformation }) => {
      const date = createdAt.toISOString().slice(0, 10);
      grouped[date] ??= { posts: 0, misinformationPosts: 0 };
      grouped[date].posts += 1;
      if (isMisinformation) grouped[date].misinformationPosts += 1;
    });
    const data = Object.entries(grouped).map(([date, values]) => ({ date, ...values }));
    res.json({ success: true, totalDays: data.length, totalPosts: posts.length, data });
  } catch (error) { res.status(500).json({ success: false, message: "Failed to retrieve timeline analysis." }); }
}

async function interactionAnalysis(req, res) {
  try {
    const data = await prisma.interaction.findMany({ where: relatedPostFilter(req), include: { post: { select: { id: true, postId: true, author: true } } } });
    res.json({ success: true, totalInteractions: data.length, data });
  } catch (error) { res.status(500).json({ success: false, message: "Failed to retrieve interaction analysis." }); }
}

async function networkStatistics(req, res) {
  try {
    const filter = datasetFilter(req);
    const interactions = await prisma.interaction.findMany({ where: { post: filter }, include: { post: { select: { postId: true } } } });
    const network = buildNetwork(interactions);
    const totalPosts = await prisma.post.count({ where: filter });
    res.json({ success: true, data: { ...network.summary, totalPosts, nodes: network.nodes, edges: network.edges } });
  } catch (error) { res.status(500).json({ success: false, message: "Failed to retrieve network statistics." }); }
}

async function centralityAnalysis(req, res) {
  try {
    const interactions = await prisma.interaction.findMany({ where: relatedPostFilter(req), include: { post: { select: { postId: true } } } });
    const network = buildNetwork(interactions);
    res.json({ success: true, totalResults: network.nodes.length, data: network.nodes, network: network.summary });
  } catch (error) { res.status(500).json({ success: false, message: "Failed to retrieve centrality analysis." }); }
}

async function misinformationStatistics(req, res) {
  try {
    const filter = datasetFilter(req);
    const [totalPosts, misinformationPosts] = await Promise.all([
      prisma.post.count({ where: filter }), prisma.post.count({ where: { ...filter, isMisinformation: true } }),
    ]);
    const normalPosts = totalPosts - misinformationPosts;
    const misinformationPercentage = totalPosts ? Number(((misinformationPosts / totalPosts) * 100).toFixed(2)) : 0;
    res.json({ success: true, data: { totalPosts, misinformationPosts, normalPosts, misinformationPercentage } });
  } catch (error) { res.status(500).json({ success: false, message: "Failed to retrieve misinformation statistics." }); }
}

module.exports = { dashboardSummary, datasetSummary, topInfluencers, topHashtags, timelineAnalysis, interactionAnalysis, networkStatistics, centralityAnalysis, misinformationStatistics };
