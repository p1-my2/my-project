const fs = require("fs");
const csv = require("csv-parser");
const prisma = require("../config/prisma");
const { importPosts } = require("./importService");

async function parseCsvFile(filePath) {
  return new Promise((resolve, reject) => {
    const results = [];
    fs.createReadStream(filePath)
      .pipe(csv())
      .on("data", (data) => results.push(data))
      .on("end", () => resolve(results))
      .on("error", (error) => reject(error));
  });
}

async function processUpload(file, userId) {
  if (!file) {
    throw new Error("Please upload a CSV file.");
  }

  const rows = await parseCsvFile(file.path);

  const dataset = await prisma.dataset.create({
    data: {
      filename: file.originalname || file.filename,
      status: "Uploaded",
      uploadedById: userId,
    },
  });

  await prisma.report.create({
    data: {
      title: `Analysis Report - ${dataset.filename}`,
      datasetId: dataset.id,
    },
  });

  const importResult = await importPosts(dataset.id, rows);

  fs.unlink(file.path, (err) => {
    if (err) {
      console.error("Failed to delete uploaded file:", err);
    }
  });

  return {
    success: true,
    message: "Dataset uploaded successfully.",
    dataset,
    recordsImported: importResult.imported,
    preview: rows.slice(0, 5),
    summary: importResult,
  };
}

module.exports = {
  processUpload,
};
