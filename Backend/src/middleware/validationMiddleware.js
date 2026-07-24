const { z } = require("zod");

const registerSchema = z.object({
  name: z.string().min(1, "Name is required."),
  email: z.string().email("Invalid email format."),
  password: z.string().min(1, "Password is required."),
});

const loginSchema = z.object({
  email: z.string().email("Invalid email format."),
  password: z.string().min(1, "Password is required."),
});

const createDatasetSchema = z.object({
  filename: z.string().min(1, "Filename is required."),
  status: z.string().optional(),
});

function validateSchema(schema) {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      const issue = result.error.issues[0];
      return res.status(400).json({
        success: false,
        message: issue.message || "Invalid request payload.",
      });
    }
    req.body = result.data;
    next();
  };
}

function validateIdParam(paramName = "id") {
  return (req, res, next) => {
    const rawVal = req.params[paramName];
    const num = Number(rawVal);
    if (!rawVal || Number.isNaN(num) || !Number.isInteger(num) || num <= 0) {
      return res.status(400).json({
        success: false,
        message: `Invalid ${paramName}. Must be a positive integer.`,
      });
    }
    next();
  };
}

function validateDatasetIdQuery(req, res, next) {
  if (req.query.datasetId !== undefined && req.query.datasetId !== "") {
    const num = Number(req.query.datasetId);
    if (Number.isNaN(num) || !Number.isInteger(num) || num <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid datasetId query parameter.",
      });
    }
  }
  next();
}

function validateFileUpload(req, res, next) {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      message: "Please upload a CSV file.",
    });
  }
  next();
}

module.exports = {
  validateRegister: validateSchema(registerSchema),
  validateLogin: validateSchema(loginSchema),
  validateCreateDataset: validateSchema(createDatasetSchema),
  validateIdParam,
  validateDatasetIdQuery,
  validateFileUpload,
};
