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

export class MedusaCustomerSessionError extends Error {
  readonly status: number;
  readonly responseBody: string;

  constructor(
    message: string,
    status: number,
    responseBody: string,
  ) {
    super(message);
    this.name = "MedusaCustomerSessionError";
    this.status = status;
    this.responseBody = responseBody;
  }
}

export async function createMedusaCustomerSession(input: {
  email: string;
  firstName?: string;
  googleSubject?: string;
  lastName?: string;
  metadata?: Record<string, unknown>;
}) {
  const url = new URL(
    env.MEDUSA_CUSTOMER_SESSION_PATH,
    getMedusaBackendUrl(),
  );

  const response = await fetch(url, {
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
  });

  const rawBody = await response.text();
  const payload = parseJson(rawBody);

  if (
    !response.ok ||
    !isCustomerSessionResponse(payload)
  ) {
    throw new MedusaCustomerSessionError(
      readErrorMessage(
        payload,
        response.status,
      ),
      response.status,
      rawBody,
    );
  }

  return payload;
}

function parseJson(value: string): unknown {
  if (!value) {
    return {};
  }

  try {
    return JSON.parse(value);
  } catch {
    return {
      message: value.slice(0, 500),
    };
  }
}

function isCustomerSessionResponse(
  value: unknown,
): value is MedusaCustomerSessionResponse {
  if (
    !value ||
    typeof value !== "object" ||
    !("token" in value) ||
    !("customer" in value)
  ) {
    return false;
  }

  const token = value.token;
  const customer = value.customer;

  if (
    typeof token !== "string" ||
    !token.trim() ||
    typeof customer !== "object" ||
    customer === null ||
    !("id" in customer)
  ) {
    return false;
  }

  return (
    typeof customer.id === "string" &&
    Boolean(customer.id.trim())
  );
}

function readErrorMessage(
  payload: unknown,
  status: number,
) {
  if (
    payload &&
    typeof payload === "object" &&
    "message" in payload &&
    typeof payload.message === "string" &&
    payload.message.trim()
  ) {
    return payload.message.trim();
  }

  return `Medusa customer-session request failed with HTTP ${status}.`;
}
