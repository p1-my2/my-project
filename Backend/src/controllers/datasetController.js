const datasetService = require("../services/datasetService");
const { processUpload } = require("../services/uploadService");

async function createDataset(req, res, next) {
  try {
    const dataset = await datasetService.createDataset({
      filename: req.body.filename,
      status: req.body.status,
      userId: req.user.id,
    });

    res.status(201).json({
      success: true,
      message: "Dataset created successfully.",
      data: dataset,
    });
  } catch (error) {
    next(error);
  }
}

async function uploadDataset(req, res, next) {
  try {
    const result = await processUpload(req.file, req.user.id);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
}

async function getDatasets(req, res, next) {
  try {
    const search = req.query.search || "";
    const datasets = await datasetService.getDatasets({ search });

    res.status(200).json({
      success: true,
      total: datasets.length,
      data: datasets,
    });
  } catch (error) {
    next(error);
  }
}

async function searchDatasets(req, res, next) {
  try {
    const keyword = req.query.keyword || "";
    const datasets = await datasetService.searchDatasets(keyword);

    res.status(200).json({
      success: true,
      total: datasets.length,
      data: datasets,
    });
  } catch (error) {
    next(error);
  }
}

async function getDataset(req, res, next) {
  try {
    const id = Number(req.params.id);
    const dataset = await datasetService.getDataset(id);

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
    next(error);
  }
}

async function deleteDataset(req, res, next) {
  try {
    const id = Number(req.params.id);
    await datasetService.deleteDataset(id);

    res.status(200).json({
      success: true,
      message: "Dataset deleted successfully.",
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  createDataset,
  uploadDataset,
  getDatasets,
  searchDatasets,
  getDataset,
  deleteDataset,
};