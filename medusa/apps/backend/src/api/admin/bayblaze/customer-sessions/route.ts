import type {
  MedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http";
import {
  ContainerRegistrationKeys,
  Modules,
  generateJwtToken,
} from "@medusajs/framework/utils";
import {
  createCustomerAccountWorkflow,
  setAuthAppMetadataWorkflow,
} from "@medusajs/medusa/core-flows";

import { assertBayblazeServiceToken } from "../../../../lib/bayblaze-service-auth";

export const AUTHENTICATE = false;

type AuthIdentity = {
  app_metadata?: Record<string, unknown> | null;
  id: string;
  provider_identities?: ProviderIdentity[];
};

type ProviderIdentity = {
  auth_identity?: AuthIdentity;
  auth_identity_id?: string;
  entity_id?: string;
  provider?: string;
  provider_metadata?: Record<string, unknown> | null;
  user_metadata?: Record<string, unknown> | null;
};

type AuthModule = {
  createAuthIdentities: (data: {
    provider_identities: Array<{
      entity_id: string;
      provider: string;
      provider_metadata?: Record<string, unknown>;
      user_metadata?: Record<string, unknown>;
    }>;
  }) => Promise<AuthIdentity>;

  listProviderIdentities: (
    filters: {
      entity_id?: string;
      provider?: string;
    },
    config?: {
      relations?: string[];
    },
  ) => Promise<ProviderIdentity[]>;

  retrieveAuthIdentity: (
    id: string,
    config?: {
      relations?: string[];
    },
  ) => Promise<AuthIdentity>;
};

type CustomerModule = {
  listCustomers: (
    filters: {
      email?: string;
    },
  ) => Promise<BayblazeCustomer[]>;
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
  metadata?: unknown;
};

const authProvider = "bayblaze_google";
const tokenTtl = "30d";

export async function POST(
  req: MedusaRequest<CustomerSessionBody>,
  res: MedusaResponse,
) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  try {
    const email = readEmail(req.body?.email);
    const googleSubject =
      readString(req.body?.google_subject) ||
      email;

    const firstName =
      readString(req.body?.first_name) ||
      "BayBlaze";

    const lastName =
      readString(req.body?.last_name) ||
      "Customer";

    const metadata =
      readMetadata(req.body?.metadata);

    let authIdentity =
      await ensureAuthIdentity(req, {
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
      metadata,
    });

    /*
     * createCustomerAccountWorkflow and
     * setAuthAppMetadataWorkflow update the stored identity, but the
     * object returned before those workflows is stale. Retrieve it
     * again so app_metadata and provider identities are current.
     */
    authIdentity =
      await retrieveAuthIdentity(
        req,
        authIdentity.id,
      );

    const token = createCustomerToken(req, {
      authIdentity,
      customer,
      email,
    });

    return res.status(200).json({
      customer,
      token,
    });
  } catch (caught) {
    console.error(
      "[BayBlaze] Medusa customer-session creation failed:",
      caught,
    );

    return res.status(
      getErrorStatus(caught),
    ).json({
      message: getErrorMessage(caught),
    });
  }
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
  const authModule =
    req.scope.resolve<AuthModule>(
      Modules.AUTH,
    );

  /*
   * Query provider identities directly rather than applying a
   * relation filter through listAuthIdentities. This is simpler and
   * avoids relation-filter differences between Medusa versions.
   */
  const [providerIdentity] =
    await authModule.listProviderIdentities(
      {
        entity_id: input.googleSubject,
        provider: authProvider,
      },
      {
        relations: [
          "auth_identity",
          "auth_identity.provider_identities",
        ],
      },
    );

  if (providerIdentity?.auth_identity) {
    return providerIdentity.auth_identity;
  }

  if (providerIdentity?.auth_identity_id) {
    return retrieveAuthIdentity(
      req,
      providerIdentity.auth_identity_id,
    );
  }

  return authModule.createAuthIdentities({
    provider_identities: [
      {
        entity_id: input.googleSubject,
        provider: authProvider,
        provider_metadata: {
          email: input.email,
        },
        user_metadata: {
          email: input.email,
          family_name: input.lastName,
          given_name: input.firstName,
          name: [
            input.firstName,
            input.lastName,
          ]
            .filter(Boolean)
            .join(" "),
        },
      },
    ],
  });
}

async function retrieveAuthIdentity(
  req: MedusaRequest,
  authIdentityId: string,
) {
  const authModule =
    req.scope.resolve<AuthModule>(
      Modules.AUTH,
    );

  return authModule.retrieveAuthIdentity(
    authIdentityId,
    {
      relations: ["provider_identities"],
    },
  );
}

async function ensureCustomer(
  req: MedusaRequest,
  input: {
    authIdentityId: string;
    email: string;
    firstName: string;
    lastName: string;
    metadata?: Record<string, unknown>;
  },
) {
  const customerModule =
    req.scope.resolve<CustomerModule>(
      Modules.CUSTOMER,
    );

  const [existing] =
    await customerModule.listCustomers({
      email: input.email,
    });

  if (existing) {
    const authIdentity =
      await retrieveAuthIdentity(
        req,
        input.authIdentityId,
      );

    const currentCustomerId =
      readString(
        authIdentity.app_metadata
          ?.customer_id,
      );

    if (
      currentCustomerId &&
      currentCustomerId !== existing.id
    ) {
      throw new Error(
        "This Google identity is already linked to another customer.",
      );
    }

    if (!currentCustomerId) {
      await setAuthAppMetadataWorkflow(
        req.scope,
      ).run({
        input: {
          actorType: "customer",
          authIdentityId:
            input.authIdentityId,
          value: existing.id,
        },
      });
    }

    return existing;
  }

  const { result } =
    await createCustomerAccountWorkflow(
      req.scope,
    ).run({
      input: {
        authIdentityId:
          input.authIdentityId,
        customerData: {
          email: input.email,
          first_name: input.firstName,
          last_name: input.lastName,
          metadata: input.metadata,
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

function createCustomerToken(
  req: MedusaRequest,
  input: {
    authIdentity: AuthIdentity;
    customer: BayblazeCustomer;
    email: string;
  },
) {
  const config = req.scope.resolve(
    ContainerRegistrationKeys.CONFIG_MODULE,
  );

  const httpConfig =
    config.projectConfig.http;

  if (!httpConfig.jwtSecret) {
    throw new Error(
      "Medusa JWT_SECRET is not configured.",
    );
  }

  return generateJwtToken(
    {
      actor_id: input.customer.id,
      actor_type: "customer",
      auth_identity_id:
        input.authIdentity.id,
      auth_provider: authProvider,
      app_metadata: {
        ...(
          input.authIdentity
            .app_metadata ?? {}
        ),
        customer_id:
          input.customer.id,
      },
      user_metadata: {
        email: input.email,
      },
    },
    {
      expiresIn: tokenTtl,
      jwtOptions:
        httpConfig.jwtOptions,
      secret: httpConfig.jwtSecret,
    },
  );
}

function readEmail(value: unknown) {
  const email =
    readString(value).toLowerCase();

  if (
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(
      email,
    )
  ) {
    throw new Error(
      "A valid customer email is required.",
    );
  }

  return email;
}

function readString(value: unknown) {
  return typeof value === "string"
    ? value.trim()
    : "";
}

function readMetadata(value: unknown) {
  return (
    value &&
    typeof value === "object" &&
    !Array.isArray(value)
  )
    ? value as Record<string, unknown>
    : undefined;
}

function getErrorMessage(value: unknown) {
  if (
    value instanceof Error &&
    value.message
  ) {
    return value.message;
  }

  return "Medusa could not create the customer session.";
}

function getErrorStatus(value: unknown) {
  const message =
    getErrorMessage(value).toLowerCase();

  if (
    message.includes("already has an account") ||
    message.includes("duplicate")
  ) {
    return 409;
  }

  if (
    message.includes("required") ||
    message.includes("invalid")
  ) {
    return 400;
  }

  return 500;
}
