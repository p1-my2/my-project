const prisma = require("../config/prisma");
const { importPosts } = require("../services/importService");
const fs = require("fs");
const csv = require("csv-parser");

// =====================================
// Create Dataset (Manual)
// =====================================
async function createDataset(req, res) {
  try {
    const { filename, status } = req.body;

    const dataset = await prisma.dataset.create({
      data: {
        filename,
        status: status || "Uploaded",
        uploadedById: req.user.id,
      },
    });

    res.status(201).json({
      success: true,
      message: "Dataset created successfully.",
      data: dataset,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to create dataset.",
      error: error.message,
    });
  }
}

// =====================================
// Upload Dataset (CSV)
// =====================================
async function uploadDataset(req, res) {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Please upload a CSV file.",
      });
    }

    const results = [];

    fs.createReadStream(req.file.path)
      .pipe(csv())
      .on("data", (row) => {
        results.push(row);
      })
      .on("end", async () => {
        try {
          // Create dataset
          const dataset = await prisma.dataset.create({
            data: {
              filename: req.file.originalname,
              status: "Uploaded",
              uploadedById: req.user.id,
            },
          });

          // Create report record
          await prisma.report.create({
            data: {
              title: `Analysis Report - ${dataset.filename}`,
              datasetId: dataset.id,
            },
          });

          // Import posts
          await importPosts(dataset.id, results);

          // Delete uploaded CSV
          fs.unlink(req.file.path, (err) => {
            if (err) {
              console.error("Failed to delete uploaded file:", err);
            }
          });

          res.status(201).json({
            success: true,
            message: "Dataset uploaded successfully.",
            dataset,
            recordsImported: results.length,
            preview: results.slice(0, 5),
          });
        } catch (error) {
          console.error(error);

          res.status(500).json({
            success: false,
            message: "Failed to import dataset.",
            error: error.message,
          });
        }
      });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Upload failed.",
      error: error.message,
    });
  }
}

// =====================================
// Get All Datasets (supports ?search=)
// =====================================
async function getDatasets(req, res) {
  try {
    const search = req.query.search || "";

    const datasets = await prisma.dataset.findMany({
      where: {
        filename: {
          contains: search,
        },
      },
      include: {
        uploadedBy: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true,
          },
        },
        _count: {
          select: {
            posts: true,
          },
        },
      },
      orderBy: {
        uploadDate: "desc",
      },
    });

    res.status(200).json({
      success: true,
      total: datasets.length,
      data: datasets,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch datasets.",
      error: error.message,
    });
  }
}

// =====================================
// Search Datasets
// GET /api/datasets/search?keyword=twitter
// =====================================
async function searchDatasets(req, res) {
  try {
    const keyword = req.query.keyword || "";

    const datasets = await prisma.dataset.findMany({
      where: {
        filename: {
          contains: keyword,
        },
      },
      include: {
        uploadedBy: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true,
          },
        },
      },
      orderBy: {
        uploadDate: "desc",
      },
    });

    res.status(200).json({
      success: true,
      total: datasets.length,
      data: datasets,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Search failed.",
      error: error.message,
    });
  }
}

// =====================================
// Get Single Dataset
// =====================================
async function getDataset(req, res) {
  try {
    const id = Number(req.params.id);

    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid dataset ID.",
      });
    }

    const dataset = await prisma.dataset.findUnique({
      where: {
        id,
      },
      include: {
        uploadedBy: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true,
          },
        },
        posts: {
          include: {
            hashtags: true,
            interactions: true,
          },
          orderBy: {
            createdAt: "asc",
          },
        },
        reports: true,
      },
    });

    if (!dataset) {
      return res.status(404).json({
        success: false,
        message: "Dataset not found.",
      });
    }

    res.status(200).json({
      success: true,
      data: dataset,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch dataset.",
      error: error.message,
    });
  }
}

// =====================================
// Delete Dataset
// =====================================
async function deleteDataset(req, res) {
  try {
    const id = Number(req.params.id);

    // Delete related records first
    await prisma.interaction.deleteMany({
      where: {
        post: {
          datasetId: id,
        },
      },
    });

    await prisma.hashtag.deleteMany({
      where: {
        post: {
          datasetId: id,
        },
      },
    });

    await prisma.post.deleteMany({
      where: {
        datasetId: id,
      },
    });

    await prisma.report.deleteMany({
      where: {
        datasetId: id,
      },
    });

    await prisma.analysisResult.deleteMany({
      where: {
        datasetId: id,
      },
    });

    await prisma.dataset.delete({
      where: {
        id,
      },
    });

    res.status(200).json({
      success: true,
      message: "Dataset deleted successfully.",
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to delete dataset.",
      error: error.message,
    });
  }
}

// =====================================
// Export Controllers
// =====================================
module.exports = {
  createDataset,
  uploadDataset,
  getDatasets,
  searchDatasets,
  getDataset,
  deleteDataset,
};