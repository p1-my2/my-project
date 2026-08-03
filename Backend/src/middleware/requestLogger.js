/**
 * Structured JSON Request Logger Middleware
 * Emits structured audit JSON logs for all HTTP API calls.
 */

function requestLogger(req, res, next) {
  const startTime = Date.now();
  res.on('finish', () => {
    const durationMs = Date.now() - startTime;
    const logPayload = {
      timestamp: new Date().toISOString(),
      level: res.statusCode >= 400 ? 'WARN' : 'INFO',
      type: 'HTTP_REQUEST',
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      durationMs,
    };
    console.log(JSON.stringify(logPayload));
  });
  next();
}

module.exports = requestLogger;
