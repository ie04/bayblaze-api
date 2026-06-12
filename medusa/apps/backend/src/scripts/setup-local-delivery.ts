import { MedusaContainer } from "@medusajs/framework";
import {
  ContainerRegistrationKeys,
  ModuleRegistrationName,
  Modules,
} from "@medusajs/framework/utils";
import {
  createRegionsWorkflow,
  createShippingOptionsWorkflow,
  createStockLocationsWorkflow,
  createTaxRegionsWorkflow,
  linkSalesChannelsToStockLocationWorkflow,
  updateRegionsWorkflow,
} from "@medusajs/medusa/core-flows";

const REGION_NAME = "Bayblaze Local Delivery";
const STOCK_LOCATION_NAME = "Bayblaze Local Delivery Hub";
const FULFILLMENT_SET_NAME = "Bayblaze Local Delivery";
const SERVICE_ZONE_NAME = "Bayblaze Local Delivery Zone";
const SHIPPING_OPTION_NAME = "Bayblaze Local Delivery";
const SHIPPING_OPTION_CODE = "bayblaze_local_delivery";

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
  }) => Promise<{ data: T[] }>;
};

type Region = {
  id: string;
  name?: string;
  currency_code?: string;
  countries?: { iso_2?: string | null }[];
  payment_providers?: { id?: string | null }[];
};

type ShippingProfile = {
  id: string;
};

type StockLocation = {
  id: string;
  name?: string;
};

type SalesChannel = {
  id: string;
  name?: string;
};

type FulfillmentSet = {
  id: string;
  name?: string;
  service_zones?: { id: string; name?: string }[];
};

type ShippingOption = {
  id: string;
  name?: string;
  type?: {
    code?: string;
  };
};

export default async function setupLocalDelivery({
  container,
}: {
  container: MedusaContainer;
}) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER);
  const link = container.resolve(ContainerRegistrationKeys.LINK);
  const query = container.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const fulfillmentModuleService = container.resolve(
    ModuleRegistrationName.FULFILLMENT,
  );

  logger.info("Setting up Bayblaze local delivery...");

  const region = await ensureRegion(container, query, logger);
  await ensureUsTaxRegion(container, logger);

  const shippingProfile = await getDefaultShippingProfile(query);
  const stockLocation = await ensureStockLocation(container, query, logger);
  const fulfillmentSet = await ensureFulfillmentSet(
    fulfillmentModuleService,
    query,
    logger,
  );
  const serviceZoneId = fulfillmentSet.service_zones?.[0]?.id;

  if (!serviceZoneId) {
    throw new Error("Local delivery fulfillment set has no service zone.");
  }

  await createLinkIfMissing(
    () =>
      link.create({
        [Modules.STOCK_LOCATION]: {
          stock_location_id: stockLocation.id,
        },
        [Modules.FULFILLMENT]: {
          fulfillment_provider_id: "manual_manual",
        },
      }),
    logger,
    "manual fulfillment provider",
  );

  await createLinkIfMissing(
    () =>
      link.create({
        [Modules.STOCK_LOCATION]: {
          stock_location_id: stockLocation.id,
        },
        [Modules.FULFILLMENT]: {
          fulfillment_set_id: fulfillmentSet.id,
        },
      }),
    logger,
    "local delivery fulfillment set",
  );

  await linkStockLocationToSalesChannels(
    container,
    query,
    stockLocation.id,
    logger,
  );

  const shippingOption = await ensureShippingOption(container, query, {
    logger,
    regionId: region.id,
    serviceZoneId,
    shippingProfileId: shippingProfile.id,
  });

  logger.info("Finished setting up Bayblaze local delivery.");
  logger.info(`Region ID: ${region.id}`);
  logger.info(`Shipping option ID: ${shippingOption.id}`);
  logger.info("Payment method: pay on delivery via Cash, Cash App, or Zelle.");
}

async function ensureRegion(
  container: MedusaContainer,
  query: Query,
  logger: { info: (message: string) => void },
) {
  const { data: regions } = await query.graph<Region>({
    entity: "region",
    fields: [
      "id",
      "name",
      "currency_code",
      "countries.iso_2",
      "payment_providers.id",
    ],
  });
  const existingRegion =
    regions.find((region) => region.name === REGION_NAME) ??
    regions.find((region) => region.currency_code === "usd");

  if (existingRegion) {
    logger.info(`Using region: ${existingRegion.name ?? existingRegion.id}`);
    return ensureRegionSupportsLocalDelivery(container, existingRegion, logger);
  }

  const {
    result: [region],
  } = await createRegionsWorkflow(container).run({
    input: {
      regions: [
        {
          name: REGION_NAME,
          currency_code: "usd",
          countries: ["us"],
          payment_providers: ["pp_system_default"],
        },
      ],
    },
  });

  logger.info(`Created region: ${region.id}`);
  return region;
}

async function ensureRegionSupportsLocalDelivery(
  container: MedusaContainer,
  region: Region,
  logger: { info: (message: string) => void },
) {
  const countryCodes = (region.countries ?? [])
    .map((country) => country.iso_2?.toLowerCase())
    .filter((countryCode): countryCode is string => Boolean(countryCode));
  const paymentProviderIds = (region.payment_providers ?? [])
    .map((provider) => provider.id)
    .filter((providerId): providerId is string => Boolean(providerId));
  const needsUsCountry = !countryCodes.includes("us");
  const needsManualPaymentProvider =
    !paymentProviderIds.includes("pp_system_default");

  if (!needsUsCountry && !needsManualPaymentProvider) {
    return region;
  }

  const { result } = await updateRegionsWorkflow(container).run({
    input: {
      selector: {
        id: region.id,
      },
      update: {
        countries: needsUsCountry ? [...countryCodes, "us"] : countryCodes,
        payment_providers: needsManualPaymentProvider
          ? [...paymentProviderIds, "pp_system_default"]
          : paymentProviderIds,
      },
    },
  });
  const updatedRegion = result[0];

  logger.info(
    `Updated region for local delivery and pay-on-delivery: ${updatedRegion.id}`,
  );

  return updatedRegion;
}

async function ensureUsTaxRegion(
  container: MedusaContainer,
  logger: { info: (message: string) => void; warn?: (message: string) => void },
) {
  try {
    await createTaxRegionsWorkflow(container).run({
      input: [
        {
          country_code: "us",
          provider_id: "tp_system",
        },
      ],
    });
    logger.info("Created US tax region.");
  } catch (error) {
    const message = getErrorMessage(error);
    logger.info(`Skipped US tax region setup: ${message}`);
  }
}

async function getDefaultShippingProfile(query: Query) {
  const { data: shippingProfiles } = await query.graph<ShippingProfile>({
    entity: "shipping_profile",
    fields: ["id"],
  });
  const shippingProfile = shippingProfiles[0];

  if (!shippingProfile) {
    throw new Error("No shipping profile found. Run Medusa migrations first.");
  }

  return shippingProfile;
}

async function ensureStockLocation(
  container: MedusaContainer,
  query: Query,
  logger: { info: (message: string) => void },
) {
  const { data: stockLocations } = await query.graph<StockLocation>({
    entity: "stock_location",
    fields: ["id", "name"],
  });
  const existingStockLocation = stockLocations.find(
    (location) => location.name === STOCK_LOCATION_NAME,
  );

  if (existingStockLocation) {
    logger.info(`Using stock location: ${existingStockLocation.id}`);
    return existingStockLocation;
  }

  const {
    result: [stockLocation],
  } = await createStockLocationsWorkflow(container).run({
    input: {
      locations: [
        {
          name: STOCK_LOCATION_NAME,
          address: {
            address_1: "Local delivery dispatch",
            city: "Tampa",
            country_code: "US",
            province: "FL",
          },
        },
      ],
    },
  });

  logger.info(`Created stock location: ${stockLocation.id}`);
  return stockLocation;
}

async function ensureFulfillmentSet(
  fulfillmentModuleService: {
    createFulfillmentSets: (input: unknown) => Promise<FulfillmentSet>;
  },
  query: Query,
  logger: { info: (message: string) => void },
) {
  const { data: fulfillmentSets } = await query.graph<FulfillmentSet>({
    entity: "fulfillment_set",
    fields: ["id", "name", "service_zones.id", "service_zones.name"],
  });
  const existingFulfillmentSet = fulfillmentSets.find(
    (set) => set.name === FULFILLMENT_SET_NAME,
  );

  if (existingFulfillmentSet) {
    logger.info(`Using fulfillment set: ${existingFulfillmentSet.id}`);
    return existingFulfillmentSet;
  }

  const fulfillmentSet =
    await fulfillmentModuleService.createFulfillmentSets({
      name: FULFILLMENT_SET_NAME,
      type: "shipping",
      service_zones: [
        {
          name: SERVICE_ZONE_NAME,
          geo_zones: [
            {
              country_code: "us",
              type: "country",
            },
          ],
        },
      ],
    });

  logger.info(`Created fulfillment set: ${fulfillmentSet.id}`);
  return fulfillmentSet;
}

async function ensureShippingOption(
  container: MedusaContainer,
  query: Query,
  {
    logger,
    regionId,
    serviceZoneId,
    shippingProfileId,
  }: {
    logger: { info: (message: string) => void };
    regionId: string;
    serviceZoneId: string;
    shippingProfileId: string;
  },
) {
  const { data: shippingOptions } = await query.graph<ShippingOption>({
    entity: "shipping_option",
    fields: ["id", "name", "type.code"],
  });
  const existingShippingOption = shippingOptions.find((option) => {
    return (
      option.name === SHIPPING_OPTION_NAME ||
      option.type?.code === SHIPPING_OPTION_CODE
    );
  });

  if (existingShippingOption) {
    logger.info(`Using shipping option: ${existingShippingOption.id}`);
    return existingShippingOption;
  }

  const {
    result: [shippingOption],
  } = await createShippingOptionsWorkflow(container).run({
    input: [
      {
        name: SHIPPING_OPTION_NAME,
        price_type: "flat",
        provider_id: "manual_manual",
        service_zone_id: serviceZoneId,
        shipping_profile_id: shippingProfileId,
        type: {
          label: "Local Delivery",
          description:
            "Local Bayblaze delivery. Cash, Cash App, or Zelle accepted on delivery.",
          code: SHIPPING_OPTION_CODE,
        },
        prices: [
          {
            currency_code: "usd",
            amount: 0,
          },
          {
            region_id: regionId,
            amount: 0,
          },
        ],
        rules: [
          {
            attribute: "enabled_in_store",
            value: "true",
            operator: "eq",
          },
          {
            attribute: "is_return",
            value: "false",
            operator: "eq",
          },
        ],
      },
    ],
  });

  logger.info(`Created shipping option: ${shippingOption.id}`);
  return shippingOption;
}

async function linkStockLocationToSalesChannels(
  container: MedusaContainer,
  query: Query,
  stockLocationId: string,
  logger: { info: (message: string) => void },
) {
  const { data: salesChannels } = await query.graph<SalesChannel>({
    entity: "sales_channel",
    fields: ["id", "name"],
  });

  if (!salesChannels.length) {
    logger.info("No sales channels found to link to the stock location.");
    return;
  }

  try {
    await linkSalesChannelsToStockLocationWorkflow(container).run({
      input: {
        id: stockLocationId,
        add: salesChannels.map((salesChannel) => salesChannel.id),
      },
    });
    logger.info("Linked local delivery stock location to sales channels.");
  } catch (error) {
    logger.info(`Skipped sales channel link: ${getErrorMessage(error)}`);
  }
}

async function createLinkIfMissing(
  createLink: () => Promise<unknown>,
  logger: { info: (message: string) => void },
  label: string,
) {
  try {
    await createLink();
    logger.info(`Linked stock location to ${label}.`);
  } catch (error) {
    logger.info(`Skipped ${label} link: ${getErrorMessage(error)}`);
  }
}

function getErrorMessage(error: unknown) {
  return error instanceof Error ? error.message : "already exists";
}
