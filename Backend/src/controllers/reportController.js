const prisma = require("../config/prisma");
const PDFDocument = require("pdfkit");

// =====================================
// Get All Reports
// =====================================
async function getReports(req, res) {
  try {
    const reports = await prisma.report.findMany({
      include: {
        dataset: true,
      },
      orderBy: {
        generatedAt: "desc",
      },
    });

    res.status(200).json({
      success: true,
      total: reports.length,
      data: reports,
    });

  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
}

// =====================================
// Get Single Report
// =====================================
async function getReport(req, res) {
  try {
    const report = await prisma.report.findUnique({
      where: {
        id: Number(req.params.id),
      },
      include: {
        dataset: true,
      },
    });

    if (!report) {
      return res.status(404).json({
        success: false,
        message: "Report not found.",
      });
    }

    res.status(200).json({
      success: true,
      data: report,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
}

// =====================================
// Generate PDF Report
// =====================================
async function generatePDF(req, res) {
  try {

    const datasetId = Number(req.params.datasetId);

    const dataset = await prisma.dataset.findUnique({
      where: {
        id: datasetId,
      },
    });

    if (!dataset) {
      return res.status(404).json({
        success: false,
        message: "Dataset not found.",
      });
    }

    const totalPosts = await prisma.post.count({
      where: {
        datasetId,
      },
    });

    const misinformationPosts = await prisma.post.count({
      where: {
        datasetId,
        isMisinformation: true,
      },
    });

    const totalUsers = await prisma.post.groupBy({ where: { datasetId }, by: ["author"] });

    const totalInteractions = await prisma.interaction.count({ where: { post: { datasetId } } });

    const totalHashtags = await prisma.hashtag.count({ where: { post: { datasetId } } });

    const influencers = await prisma.interaction.groupBy({
      where: { post: { datasetId } },
      by: ["sourceUser"],
      _count: {
        sourceUser: true,
      },
      orderBy: {
        _count: {
          sourceUser: "desc",
        },
      },
      take: 5,
    });

    const hashtags = await prisma.hashtag.groupBy({
      where: { post: { datasetId } },
      by: ["hashtag"],
      _count: {
        hashtag: true,
      },
      orderBy: {
        _count: {
          hashtag: "desc",
        },
      },
      take: 5,
    });

    const doc = new PDFDocument({
      margin: 50,
    });

    res.setHeader("Content-Type", "application/pdf");

    res.setHeader(
      "Content-Disposition",
      `attachment; filename=Analysis_Report_${dataset.id}.pdf`
    );

    doc.pipe(res);

    doc
      .fontSize(22)
      .text("MISINFORMATION DIFFUSION DASHBOARD", {
        align: "center",
      });

    doc.moveDown();

    doc
      .fontSize(18)
      .text("Analysis Report", {
        align: "center",
      });

    doc.moveDown();

    doc.fontSize(12);

    doc.text(`Dataset: ${dataset.filename}`);
    doc.text(`Generated: ${new Date().toLocaleString()}`);

    doc.moveDown();

    doc.fontSize(16).text("Summary");

    doc.moveDown(0.5);

    doc.fontSize(12);

    doc.text(`Total Posts: ${totalPosts}`);
    doc.text(`Network Users: ${totalUsers.length}`);
    doc.text(`Total Hashtags: ${totalHashtags}`);
    doc.text(`Total Interactions: ${totalInteractions}`);
    doc.text(`Misinformation Posts: ${misinformationPosts}`);

    doc.moveDown();

    doc.fontSize(16).text("Top Influencers");

    influencers.forEach((item, index) => {
      doc.text(
        `${index + 1}. ${item.sourceUser} (${item._count.sourceUser} interactions)`
      );
    });

    doc.moveDown();

    doc.fontSize(16).text("Trending Hashtags");

    hashtags.forEach((item, index) => {
      doc.text(
        `${index + 1}. ${item.hashtag} (${item._count.hashtag})`
      );
    });

    doc.moveDown(2);

    doc
      .fontSize(10)
      .text(
        "Generated automatically by the Misinformation Diffusion Dashboard.",
        {
          align: "center",
        }
      );

    doc.end();

  } catch (error) {

    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message,
    });

  }
}

// =====================================
// Export CSV
// =====================================
async function exportCSV(req, res) {

  try {

    const datasetId = Number(req.params.datasetId);

    const posts = await prisma.post.findMany({
      where: {
        datasetId,
      },
      include: {
        hashtags: true,
      },
    });

    let csv =
      "Post ID,Author,Content,Date,Misinformation,Hashtags\n";

    posts.forEach((post) => {

      const hashtags = post.hashtags
        .map((h) => h.hashtag)
        .join(" ");

      csv += `"${post.postId}","${post.author}","${post.content.replace(/"/g,'""')}","${post.createdAt.toISOString()}","${post.isMisinformation}","${hashtags}"\n`;

    });

    res.header("Content-Type", "text/csv");

    res.attachment(`dataset_${datasetId}.csv`);

    res.send(csv);

  } catch (error) {

    res.status(500).json({
      success: false,
      message: error.message,
    });

  }

}

// =====================================
// Delete Report
// =====================================
async function deleteReport(req, res) {

  try {

    await prisma.report.delete({
      where: {
        id: Number(req.params.id),
      },
    });

    res.status(200).json({
      success: true,
      message: "Report deleted successfully.",
    });

  } catch (error) {

    res.status(500).json({
      success: false,
      message: error.message,
    });

  }

}

module.exports = {
  getReports,
  getReport,
  generatePDF,
  exportCSV,
  deleteReport,
};
