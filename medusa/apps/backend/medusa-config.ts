import {
  ContainerRegistrationKeys,
  Modules,
  defineConfig,
  loadEnv,
} from '@medusajs/framework/utils'
import { generateBayblazeOrderNumber } from "./src/lib/bayblaze-order-number"

loadEnv(process.env.NODE_ENV || 'development', process.cwd())

const authProviders: {
  resolve: string
  id: string
  options?: Record<string, string | undefined>
}[] = [
  {
    resolve: "@medusajs/medusa/auth-emailpass",
    id: "emailpass",
  },
]

if (
  process.env.GOOGLE_CLIENT_ID &&
  process.env.GOOGLE_CLIENT_SECRET &&
  process.env.GOOGLE_CALLBACK_URL
) {
  authProviders.push({
    resolve: "@medusajs/medusa/auth-google",
    id: "google",
    options: {
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackUrl: process.env.GOOGLE_CALLBACK_URL,
    },
  })
}

module.exports = defineConfig({
  admin: {
    maxUploadFileSize: 10 * 1024 * 1024,
  },

  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    redisUrl: process.env.REDIS_URL,
    http: {
      storeCors: process.env.STORE_CORS!,
      adminCors: process.env.ADMIN_CORS!,
      authCors: process.env.AUTH_CORS!,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    }
  },

  modules: [
    {
      resolve: "@medusajs/medusa/auth",
      dependencies: [Modules.CACHE, ContainerRegistrationKeys.LOGGER],
      options: {
        providers: authProviders,
      },
    },
    {
      resolve: "@medusajs/medusa/order",
      options: {
        generateCustomDisplayId: generateBayblazeOrderNumber,
      },
    },
  ],
})
