import { env } from "../config/env";
import {
  createBayblazeMedusaHeaders,
  getMedusaBackendUrl,
} from "./medusaServiceClient";

type MedusaCustomerSessionResponse = {
  customer: {
    email?: string | null;
    id: string;
  };
  token: string;
};

export async function createMedusaCustomerSession(input: {
  email: string;
  firstName?: string;
  googleSubject?: string;
  lastName?: string;
  metadata?: Record<string, unknown>;
}) {
  const response = await fetch(
    new URL(env.MEDUSA_CUSTOMER_SESSION_PATH, getMedusaBackendUrl()),
    {
      body: JSON.stringify({
        email: input.email,
        first_name: input.firstName,
        google_subject: input.googleSubject,
        last_name: input.lastName,
        metadata: input.metadata,
      }),
      headers: createBayblazeMedusaHeaders({
        acceptJson: true,
        contentTypeJson: true,
      }),
      method: "POST",
    },
  );
  const payload = (await response.json().catch(() => ({}))) as
    | MedusaCustomerSessionResponse
    | { message?: string };

  if (!response.ok || !("token" in payload) || !payload.token) {
    throw new Error(
      "message" in payload && payload.message
        ? payload.message
        : "Unable to create Medusa customer session.",
    );
  }

  return payload;
}
