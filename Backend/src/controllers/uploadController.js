const { processUpload } = require("../services/uploadService");

async function uploadDataset(req, res, next) {
  try {
    const result = await processUpload(req.file, req.user.id);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  uploadDataset,
};