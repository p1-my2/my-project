/**
 * Standardized API Response Envelopes
 * Standardizes success and error outputs across all Express controller endpoints.
 */

function successResponse(res, data, meta = {}, statusCode = 200) {
  return res.status(statusCode).json({
    success: true,
    data,
    meta: {
      timestamp: new Date().toISOString(),
      executionTimeMs: meta.executionTimeMs || 0,
      totalRecords: Array.isArray(data) ? data.length : (meta.totalRecords || 1),
      ...meta,
    },
  });
}

function errorResponse(res, message, code = 'INTERNAL_SERVER_ERROR', statusCode = 500, details = null) {
  return res.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
      details,
      timestamp: new Date().toISOString(),
    },
  });
}

module.exports = { successResponse, errorResponse };
