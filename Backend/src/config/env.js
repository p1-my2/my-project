const { z } = require("zod");
require("dotenv").config();

/**
 * 1. DATABASE_URL Fallback for Railway & Cloud Providers
 * Ensures process.env.DATABASE_URL is populated before Prisma Client is initialized.
 */
if (!process.env.DATABASE_URL && process.env.MYSQL_URL) {
  process.env.DATABASE_URL = process.env.MYSQL_URL;
}

/**
 * 2. Environment Variable Schema Validation using Zod
 */
const envSchema = z.object({
  PORT: z
    .string()
    .default("5000")
    .transform((val) => {
      const parsed = parseInt(val, 10);
      if (isNaN(parsed)) throw new Error("PORT must be a valid number");
      return parsed;
    }),
  JWT_SECRET: z.string().min(1, "JWT_SECRET environment variable is required"),
  DATABASE_URL: z.string().min(1, "DATABASE_URL or MYSQL_URL environment variable is required"),
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
  CORS_ORIGIN: z.string().optional(),
  API_VERSION: z.string().default("1.0.0-rc1"),
});

let config;

try {
  config = envSchema.parse(process.env);
} catch (error) {
  if (error instanceof z.ZodError) {
    console.error("\n=======================================================");
    console.error("❌ ENVIRONMENT VALIDATION FAILURE");
    console.error("=======================================================");
    error.errors.forEach((err) => {
      console.error(` • Parameter : ${err.path.join(".")}`);
      console.error(`   Error     : ${err.message}`);
    });
    console.error("=======================================================\n");
  } else {
    console.error("❌ Fatal Environment Error:", error.message);
  }
  process.exit(1);
}

module.exports = config;
