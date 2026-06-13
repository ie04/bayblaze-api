import { createCustomerAccountWorkflow, setAuthAppMetadataWorkflow } from "@medusajs/core-flows";
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import {
  ContainerRegistrationKeys,
  Modules,
  generateJwtToken,
} from "@medusajs/framework/utils";

import { assertBayblazeServiceToken } from "../../../../lib/bayblaze-service-auth";

export const AUTHENTICATE = false;

type AuthModule = {
  createAuthIdentities: (data: {
    provider_identities: Array<{
      entity_id: string;
      provider: string;
      provider_metadata?: Record<string, unknown>;
      user_metadata?: Record<string, unknown>;
    }>;
  }) => Promise<AuthIdentity>;
  listAuthIdentities: (
    filters: Record<string, unknown>,
    config?: Record<string, unknown>,
  ) => Promise<AuthIdentity[]>;
};

type AuthIdentity = {
  app_metadata?: Record<string, unknown> | null;
  id: string;
  provider_identities?: Array<{
    entity_id?: string;
    provider?: string;
    provider_metadata?: Record<string, unknown> | null;
    user_metadata?: Record<string, unknown> | null;
  }>;
};

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
    filters?: Record<string, unknown>;
  }) => Promise<{ data: T[] }>;
};

type BayblazeCustomer = {
  email?: string | null;
  first_name?: string | null;
  id: string;
  last_name?: string | null;
};

type CustomerSessionBody = {
  email?: unknown;
  first_name?: unknown;
  google_subject?: unknown;
  last_name?: unknown;
};

const tokenTtl = "30d";

export async function POST(req: MedusaRequest<CustomerSessionBody>, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  const email = readEmail(req.body?.email);
  const googleSubject = readString(req.body?.google_subject) || email;
  const firstName = readString(req.body?.first_name) || "BayBlaze";
  const lastName = readString(req.body?.last_name) || "Customer";
  const authIdentity = await ensureAuthIdentity(req, {
    email,
    firstName,
    googleSubject,
    lastName,
  });
  const customer = await ensureCustomer(req, {
    authIdentityId: authIdentity.id,
    email,
    firstName,
    lastName,
  });
  const token = createCustomerToken(req, {
    authIdentity,
    customer,
    email,
  });

  return res.status(200).json({
    customer,
    token,
  });
}

async function ensureAuthIdentity(
  req: MedusaRequest,
  input: {
    email: string;
    firstName: string;
    googleSubject: string;
    lastName: string;
  },
) {
  const authModule = req.scope.resolve<AuthModule>(Modules.AUTH);
  const [existing] = await authModule.listAuthIdentities(
    {
      provider_identities: {
        entity_id: input.googleSubject,
        provider: "bayblaze_google",
      },
    },
    {
      relations: ["provider_identities"],
    },
  );

  if (existing) {
    return existing;
  }

  return authModule.createAuthIdentities({
    provider_identities: [
      {
        entity_id: input.googleSubject,
        provider: "bayblaze_google",
        provider_metadata: {
          email: input.email,
        },
        user_metadata: {
          email: input.email,
          family_name: input.lastName,
          given_name: input.firstName,
          name: `${input.firstName} ${input.lastName}`.trim(),
        },
      },
    ],
  });
}

async function ensureCustomer(
  req: MedusaRequest,
  input: {
    authIdentityId: string;
    email: string;
    firstName: string;
    lastName: string;
  },
) {
  const existing = await findCustomerByEmail(req, input.email);

  if (existing) {
    await setAuthAppMetadataWorkflow(req.scope).run({
      input: {
        actorType: "customer",
        authIdentityId: input.authIdentityId,
        value: existing.id,
      },
    });

    return existing;
  }

  const { result } = await createCustomerAccountWorkflow(req.scope).run({
    input: {
      authIdentityId: input.authIdentityId,
      customerData: {
        email: input.email,
        first_name: input.firstName,
        last_name: input.lastName,
      },
    },
  });

  return {
    email: result.email,
    first_name: result.first_name,
    id: result.id,
    last_name: result.last_name,
  };
}

async function findCustomerByEmail(req: MedusaRequest, email: string) {
  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const { data } = await query.graph<BayblazeCustomer>({
    entity: "customer",
    fields: ["id", "email", "first_name", "last_name"],
    filters: {
      email,
    },
  });

  return data[0] ?? null;
}

function createCustomerToken(
  req: MedusaRequest,
  input: {
    authIdentity: AuthIdentity;
    customer: BayblazeCustomer;
    email: string;
  },
) {
  const config = req.scope.resolve(ContainerRegistrationKeys.CONFIG_MODULE);
  const jwtSecret = config.projectConfig.http.jwtSecret;

  return generateJwtToken(
    {
      actor_id: input.customer.id,
      actor_type: "customer",
      auth_identity_id: input.authIdentity.id,
      auth_provider: "bayblaze_google",
      app_metadata: {
        ...(input.authIdentity.app_metadata ?? {}),
        customer_id: input.customer.id,
      },
      user_metadata: {
        email: input.email,
      },
    },
    {
      expiresIn: tokenTtl,
      secret: jwtSecret,
    },
  );
}

function readEmail(value: unknown) {
  const email = readString(value).toLowerCase();

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new Error("A valid customer email is required.");
  }

  return email;
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}
