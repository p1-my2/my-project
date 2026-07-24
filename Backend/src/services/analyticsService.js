const prisma = require("../config/prisma");
const { buildNetwork } = require("./networkAnalysisService");

function getDatasetFilter(datasetId) {
  const id = Number(datasetId);
  return Number.isInteger(id) && id > 0 ? { datasetId: id } : {};
}

function getRelatedPostFilter(datasetId) {
  return { post: getDatasetFilter(datasetId) };
}

async function getDashboardSummary({ datasetId } = {}) {
  const filter = getDatasetFilter(datasetId);
  const relatedFilter = getRelatedPostFilter(datasetId);

  const [totalUsers, totalDatasets, totalPosts, totalHashtags, totalReports, misinformationPosts] = await Promise.all([
    prisma.user.count(),
    prisma.dataset.count(),
    prisma.post.count({ where: filter }),
    prisma.hashtag.count({ where: relatedFilter }),
    prisma.report.count(),
    prisma.post.count({ where: { ...filter, isMisinformation: true } }),
  ]);

  return {
    totalUsers,
    totalDatasets,
    totalPosts,
    totalHashtags,
    totalReports,
    misinformationPosts,
  };
}

async function getDatasetSummary(id) {
  return prisma.dataset.findUnique({
    where: { id: Number(id) },
    include: {
      uploadedBy: { select: { id: true, name: true, email: true } },
      posts: true,
      reports: true,
    },
  });
}

async function getTopInfluencers({ datasetId, limit = 10 } = {}) {
  return prisma.interaction.groupBy({
    where: getRelatedPostFilter(datasetId),
    by: ["sourceUser"],
    _count: { sourceUser: true },
    orderBy: { _count: { sourceUser: "desc" } },
    take: Number(limit),
  });
}

async function getTopHashtags({ datasetId, limit = 10 } = {}) {
  return prisma.hashtag.groupBy({
    where: getRelatedPostFilter(datasetId),
    by: ["hashtag"],
    _count: { hashtag: true },
    orderBy: { _count: { hashtag: "desc" } },
    take: Number(limit),
  });
}

async function getTimelineAnalysis({ datasetId } = {}) {
  const posts = await prisma.post.findMany({
    where: getDatasetFilter(datasetId),
    orderBy: { createdAt: "asc" },
    select: { createdAt: true, isMisinformation: true },
  });

  const grouped = {};
  posts.forEach(({ createdAt, isMisinformation }) => {
    const date = createdAt.toISOString().slice(0, 10);
    grouped[date] ??= { posts: 0, misinformationPosts: 0 };
    grouped[date].posts += 1;
    if (isMisinformation) grouped[date].misinformationPosts += 1;
  });

  const data = Object.entries(grouped).map(([date, values]) => ({ date, ...values }));
  return { totalDays: data.length, totalPosts: posts.length, data };
}

async function getInteractionAnalysis({ datasetId } = {}) {
  const data = await prisma.interaction.findMany({
    where: getRelatedPostFilter(datasetId),
    include: { post: { select: { id: true, postId: true, author: true } } },
  });
  return { totalInteractions: data.length, data };
}

async function getNetworkStatistics({ datasetId } = {}) {
  const filter = getDatasetFilter(datasetId);
  const interactions = await prisma.interaction.findMany({
    where: { post: filter },
    include: { post: { select: { postId: true } } },
  });
  const network = buildNetwork(interactions);
  const totalPosts = await prisma.post.count({ where: filter });

  return {
    ...network.summary,
    totalPosts,
    nodes: network.nodes,
    edges: network.edges,
  };
}

async function getCentralityAnalysis({ datasetId } = {}) {
  const interactions = await prisma.interaction.findMany({
    where: getRelatedPostFilter(datasetId),
    include: { post: { select: { postId: true } } },
  });
  const network = buildNetwork(interactions);
  return {
    totalResults: network.nodes.length,
    data: network.nodes,
    network: network.summary,
  };
}

async function getMisinformationStatistics({ datasetId } = {}) {
  const filter = getDatasetFilter(datasetId);
  const [totalPosts, misinformationPosts] = await Promise.all([
    prisma.post.count({ where: filter }),
    prisma.post.count({ where: { ...filter, isMisinformation: true } }),
  ]);
  const normalPosts = totalPosts - misinformationPosts;
  const misinformationPercentage = totalPosts ? Number(((misinformationPosts / totalPosts) * 100).toFixed(2)) : 0;

  return {
    totalPosts,
    misinformationPosts,
    normalPosts,
    misinformationPercentage,
  };
}

async function getReportData(datasetId) {
  const dataset = await prisma.dataset.findUnique({
    where: { id: Number(datasetId) },
  });

  if (!dataset) return null;

  const [
    totalPosts,
    misinformationPosts,
    userGroups,
    totalInteractions,
    totalHashtags,
    influencers,
    hashtags,
  ] = await Promise.all([
    prisma.post.count({ where: { datasetId } }),
    prisma.post.count({ where: { datasetId, isMisinformation: true } }),
    prisma.post.groupBy({ where: { datasetId }, by: ["author"] }),
    prisma.interaction.count({ where: { post: { datasetId } } }),
    prisma.hashtag.count({ where: { post: { datasetId } } }),
    getTopInfluencers({ datasetId, limit: 5 }),
    getTopHashtags({ datasetId, limit: 5 }),
  ]);

  return {
    dataset,
    totalPosts,
    misinformationPosts,
    totalUsers: userGroups.length,
    totalInteractions,
    totalHashtags,
    influencers,
    hashtags,
  };
}

module.exports = {
  getDashboardSummary,
  getDatasetSummary,
  getTopInfluencers,
  getTopHashtags,
  getTimelineAnalysis,
  getInteractionAnalysis,
  getNetworkStatistics,
  getCentralityAnalysis,
  getMisinformationStatistics,
  getReportData,
};
