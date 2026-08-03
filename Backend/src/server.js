const config = require("./config/env");
const app = require("./app");
const prisma = require("./config/prisma");

const PORT = config.PORT;

const server = app.listen(PORT, async () => {
  let dbStatus = "Disconnected";
  try {
    await prisma.$queryRaw`SELECT 1`;
    dbStatus = "Connected";
  } catch (err) {
    dbStatus = "Disconnected (Check credentials)";
  }

  console.log("\n---------------------------------------");
  console.log(`Environment : ${config.NODE_ENV}`);
  console.log(`Port        : ${PORT}`);
  console.log(`Database    : ${dbStatus}`);
  console.log(`Swagger     : Enabled (/api/docs)`);
  console.log(`Version     : ${config.API_VERSION}`);
  console.log("---------------------------------------\n");
});

const gracefulShutdown = (signal) => {
  console.log(`\n⚠️  Received ${signal}. Shutting down gracefully...`);
  server.close(async () => {
    console.log("HTTP server closed.");
    try {
      await prisma.$disconnect();
      console.log("Prisma client disconnected successfully.");
    } catch (err) {
      console.error("Error disconnecting Prisma:", err.message);
    }
    process.exit(0);
  });
};

process.on("SIGINT", () => gracefulShutdown("SIGINT"));
process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));