const reportService = require("../services/reportService");

async function getReports(req, res, next) {
  try {
    const reports = await reportService.getAllReports();
    res.status(200).json({
      success: true,
      total: reports.length,
      data: reports,
    });
  } catch (error) {
    next(error);
  }
}

async function getReport(req, res, next) {
  try {
    const report = await reportService.getReportById(req.params.id);
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
    next(error);
  }
}

async function generatePDF(req, res, next) {
  try {
    await reportService.generatePdfReport(req.params.datasetId, res);
  } catch (error) {
    if (error.statusCode) {
      return res.status(error.statusCode).json({
        success: false,
        message: error.message,
      });
    }
    next(error);
  }
}

async function exportCSV(req, res, next) {
  try {
    await reportService.exportDatasetCsv(req.params.datasetId, res);
  } catch (error) {
    next(error);
  }
}

async function deleteReport(req, res, next) {
  try {
    await reportService.deleteReportById(req.params.id);
    res.status(200).json({
      success: true,
      message: "Report deleted successfully.",
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getReports,
  getReport,
  generatePDF,
  exportCSV,
  deleteReport,
};
