const prisma = require("../config/prisma");
const PDFDocument = require("pdfkit");
const { getReportData } = require("./analyticsService");

async function getAllReports() {
  return prisma.report.findMany({
    include: {
      dataset: true,
    },
    orderBy: {
      generatedAt: "desc",
    },
  });
}

async function getReportById(id) {
  return prisma.report.findUnique({
    where: {
      id: Number(id),
    },
    include: {
      dataset: true,
    },
  });
}

async function generatePdfReport(datasetId, res) {
  const reportData = await getReportData(datasetId);
  if (!reportData) {
    const error = new Error("Dataset not found.");
    error.statusCode = 404;
    throw error;
  }

  const {
    dataset,
    totalPosts,
    misinformationPosts,
    totalUsers,
    totalInteractions,
    totalHashtags,
    influencers,
    hashtags,
  } = reportData;

  const doc = new PDFDocument({ margin: 50 });

  res.setHeader("Content-Type", "application/pdf");
  res.setHeader(
    "Content-Disposition",
    `attachment; filename=Analysis_Report_${dataset.id}.pdf`
  );

  doc.pipe(res);

  doc.fontSize(22).text("MISINFORMATION DIFFUSION DASHBOARD", { align: "center" });
  doc.moveDown();
  doc.fontSize(18).text("Analysis Report", { align: "center" });
  doc.moveDown();
  doc.fontSize(12);

  doc.text(`Dataset: ${dataset.filename}`);
  doc.text(`Generated: ${new Date().toLocaleString()}`);
  doc.moveDown();

  doc.fontSize(16).text("Summary");
  doc.moveDown(0.5);
  doc.fontSize(12);

  doc.text(`Total Posts: ${totalPosts}`);
  doc.text(`Network Users: ${totalUsers}`);
  doc.text(`Total Hashtags: ${totalHashtags}`);
  doc.text(`Total Interactions: ${totalInteractions}`);
  doc.text(`Misinformation Posts: ${misinformationPosts}`);
  doc.moveDown();

  doc.fontSize(16).text("Top Influencers");
  influencers.forEach((item, index) => {
    doc.text(`${index + 1}. ${item.sourceUser} (${item._count.sourceUser} interactions)`);
  });
  doc.moveDown();

  doc.fontSize(16).text("Trending Hashtags");
  hashtags.forEach((item, index) => {
    doc.text(`${index + 1}. ${item.hashtag} (${item._count.hashtag})`);
  });
  doc.moveDown(2);

  doc.fontSize(10).text("Generated automatically by the Misinformation Diffusion Dashboard.", { align: "center" });

  doc.end();
}

async function exportDatasetCsv(datasetId, res) {
  const posts = await prisma.post.findMany({
    where: {
      datasetId: Number(datasetId),
    },
    include: {
      hashtags: true,
    },
  });

  let csv = "Post ID,Author,Content,Date,Misinformation,Hashtags\n";
  posts.forEach((post) => {
    const hashtagStr = post.hashtags.map((h) => h.hashtag).join(" ");
    const safeContent = post.content.replace(/"/g, '""');
    csv += `"${post.postId}","${post.author}","${safeContent}","${post.createdAt.toISOString()}","${post.isMisinformation}","${hashtagStr}"\n`;
  });

  res.header("Content-Type", "text/csv");
  res.attachment(`dataset_${datasetId}.csv`);
  res.send(csv);
}

async function deleteReportById(id) {
  return prisma.report.delete({
    where: {
      id: Number(id),
    },
  });
}

module.exports = {
  getAllReports,
  getReportById,
  generatePdfReport,
  exportDatasetCsv,
  deleteReportById,
};
