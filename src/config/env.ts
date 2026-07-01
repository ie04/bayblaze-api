import dotenv from "dotenv";
import { z } from "zod";

dotenv.config({
  path: process.env.ENV_FILE || ".env",
});

const envSchema = z
  .object({
    NODE_ENV: z.string().default("development"),
    PORT: z.coerce.number().int().positive().default(3040),
    CORS_ORIGINS: z.string().optional().default(""),

    BAYBLAZE_API_SERVICE_TOKEN: z.string().optional(),
    BAYBLAZE_MEDUSA_SERVICE_TOKEN: z.string().optional(),
    ACCOUNT_SESSION_SECRET: z.string().optional(),
    ACCOUNT_SESSION_TTL_SECONDS: z.coerce.number().int().positive().optional().default(60 * 60 * 24 * 14),
    DRIVER_SESSION_SECRET: z.string().optional(),
    DRIVER_SESSION_TTL_SECONDS: z.coerce.number().int().positive().optional().default(60 * 60 * 24 * 14),

    MEDUSA_BACKEND_URL: z.string().optional(),
    MEDUSA_ADMIN_API_TOKEN: z.string().optional(),
    BAYBLAZE_INVENTORY_SERVICE_TOKEN: z.string().optional(),
    BAYBLAZE_DRIVER_SERVICE_TOKEN: z.string().optional(),

    MEDUSA_DRIVER_QUEUE_PATH: z.string().optional().default("/admin/bayblaze/driver-queues/{uid}"),
    MEDUSA_DELIVERY_ATTEMPT_PATH: z.string().optional().default("/admin/bayblaze/delivery-attempts"),
    MEDUSA_REPRINT_LABELS_PATH: z.string().optional().default("/admin/bayblaze/orders/{orderId}/reprint-labels"),
    MEDUSA_ADMIN_ORDERS_PATH: z.string().optional().default("/admin/bayblaze/orders"),
    MEDUSA_CUSTOMER_SESSION_PATH: z.string().optional().default("/admin/bayblaze/customer-sessions"),

    BAYBLAZE_STOREFRONT_URL: z.string().optional().default("https://bayblaze.net"),

    GOOGLE_MAPS_API_KEY: z.string().optional(),
    GOOGLE_OAUTH_CLIENT_ID: z.string().optional(),
    GOOGLE_OAUTH_CLIENT_SECRET: z.string().optional(),
    GOOGLE_OAUTH_REDIRECT_URL: z.string().optional(),

    FIREBASE_PROJECT_ID: z.string().optional(),
    FIRESTORE_DATABASE_ID: z.string().optional(),
    FIREBASE_SERVICE_ACCOUNT_JSON: z.string().optional(),
    FIREBASE_SERVICE_ACCOUNT_JSON_BASE64: z.string().optional(),
    FIREBASE_STORAGE_BUCKET: z.string().optional(),
    FIREBASE_WEB_API_KEY: z.string().optional(),

    RESEND_API_KEY: z.string().optional(),
    DRIVER_EMAIL_FROM: z.string().optional(),
    DRIVER_EMAIL_REPLY_TO: z.string().optional(),
    DRIVER_SIGNUP_CODE_TTL_MINUTES: z.coerce.number().int().positive().optional().default(15),
    DRIVER_WEB_PUSH_PUBLIC_KEY: z.string().optional(),
    DRIVER_WEB_PUSH_PRIVATE_KEY: z.string().optional(),
    DRIVER_WEB_PUSH_SUBJECT: z.string().optional(),

    DRIVER_FIREBASE_PROJECT_ID: z.string().optional(),
    DRIVER_FIRESTORE_DATABASE_ID: z.string().optional(),
    DRIVER_FIREBASE_SERVICE_ACCOUNT_JSON_BASE64: z.string().optional(),

    TWILIO_ACCOUNT_SID: z.string().optional(),
    TWILIO_AUTH_TOKEN: z.string().optional(),
    TWILIO_FROM_NUMBER: z.string().optional(),

    BAYBLAZE_STORAGE_MODE: z.string().optional().default("local"),
    BAYBLAZE_UPLOAD_DIR: z.string().optional().default("/app/uploads"),
    BAYBLAZE_PUBLIC_API_URL: z.string().optional(),
  })
  .passthrough();

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error("Invalid bayblaze-api environment:", parsed.error.flatten().fieldErrors);
  throw new Error("Invalid bayblaze-api environment.");
}

function parseList(value: string) {
  return value
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);
}

export const env = {
  ...parsed.data,
  CORS_ORIGINS_LIST: parseList(parsed.data.CORS_ORIGINS),
};
