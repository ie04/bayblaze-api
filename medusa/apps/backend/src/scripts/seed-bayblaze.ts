import { MedusaContainer } from "@medusajs/framework";
import {
  ContainerRegistrationKeys,
  ProductStatus,
} from "@medusajs/framework/utils";
import {
  createApiKeysWorkflow,
  createProductCategoriesWorkflow,
  createProductsWorkflow,
  createSalesChannelsWorkflow,
  createStoresWorkflow,
  linkSalesChannelsToApiKeyWorkflow,
} from "@medusajs/medusa/core-flows";

export default async function seedBayblaze({
  container,
}: {
  container: MedusaContainer;
}) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER);
  const query = container.resolve(ContainerRegistrationKeys.QUERY);

  logger.info("Seeding Bayblaze store data...");

  const {
    result: [salesChannel],
  } = await createSalesChannelsWorkflow(container).run({
    input: {
      salesChannelsData: [
        {
          name: "Bayblaze Storefront",
          description: "Default sales channel for bayblaze-storefront",
        },
      ],
    },
  });

  const {
    result: [publishableApiKey],
  } = await createApiKeysWorkflow(container).run({
    input: {
      api_keys: [
        {
          title: "Bayblaze Storefront Publishable Key",
          type: "publishable",
          created_by: "",
        },
      ],
    },
  });

  await linkSalesChannelsToApiKeyWorkflow(container).run({
    input: {
      id: publishableApiKey.id,
      add: [salesChannel.id],
    },
  });

  await createStoresWorkflow(container).run({
    input: {
      stores: [
        {
          name: "Bayblaze",
          supported_currencies: [
            {
              currency_code: "usd",
              is_default: true,
            },
          ],
          default_sales_channel_id: salesChannel.id,
        },
      ],
    },
  });

  const { data: shippingProfiles } = await query.graph({
    entity: "shipping_profile",
    fields: ["id"],
  });
  const shippingProfileId = shippingProfiles[0]?.id;

  if (!shippingProfileId) {
    throw new Error("No shipping profile found. Run Medusa migrations first.");
  }

  const { result: categories } = await createProductCategoriesWorkflow(
    container
  ).run({
    input: {
      product_categories: [
        {
          name: "Vapes",
          handle: "vapes",
          is_active: true,
        },
        {
          name: "Accessories",
          handle: "accessories",
          is_active: true,
        },
      ],
    },
  });

  const vapesCategoryId = categories.find((cat) => cat.handle === "vapes")!.id;

  await createProductsWorkflow(container).run({
    input: {
      products: [
        {
          title: "RAZ LTX 25000 (Gush Edition)",
          handle: "raz-ltx-25000-gush-edition",
          description: "Top-selling disposable vape from RAZ.",
          status: ProductStatus.PUBLISHED,
          category_ids: [vapesCategoryId],
          shipping_profile_id: shippingProfileId,
          images: [
            {
              url: "https://bayblaze.net/wp-content/uploads/2026/03/raz-ltx-25000-gush-edition-blue-raz-gush.png",
            },
          ],
          options: [
            {
              title: "Flavor",
              values: ["Blue Raz Gush"],
            },
          ],
          variants: [
            {
              title: "Blue Raz Gush",
              sku: "RAZ-LTX-25000-BLUE-RAZ-GUSH",
              metadata: {
                inventoryState: "ON_VEHICLE",
                availableQuantity: 24,
              },
              options: {
                Flavor: "Blue Raz Gush",
              },
              prices: [
                {
                  amount: 1799,
                  currency_code: "usd",
                },
              ],
            },
          ],
          sales_channels: [{ id: salesChannel.id }],
        },
        {
          title: "Lost Mary MT35000 Turbo",
          handle: "lost-mary-mt35000-turbo",
          description: "Lost Mary MT35000 Turbo disposable vape.",
          status: ProductStatus.PUBLISHED,
          category_ids: [vapesCategoryId],
          shipping_profile_id: shippingProfileId,
          images: [
            {
              url: "https://bayblaze.net/wp-content/uploads/2026/03/LMMTK35K.png",
            },
          ],
          options: [
            {
              title: "Default",
              values: ["Default"],
            },
          ],
          variants: [
            {
              title: "Default",
              sku: "LOST-MARY-MT35000-TURBO",
              metadata: {
                inventoryState: "ON_VEHICLE",
                availableQuantity: 24,
              },
              options: {
                Default: "Default",
              },
              prices: [
                {
                  amount: 1799,
                  currency_code: "usd",
                },
              ],
            },
          ],
          sales_channels: [{ id: salesChannel.id }],
        },
        {
          title: "Wave",
          handle: "wave",
          description: "Wave disposable vape.",
          status: ProductStatus.PUBLISHED,
          category_ids: [vapesCategoryId],
          shipping_profile_id: shippingProfileId,
          images: [
            {
              url: "https://bayblaze.net/wp-content/uploads/2026/03/wave.png",
            },
          ],
          options: [
            {
              title: "Default",
              values: ["Default"],
            },
          ],
          variants: [
            {
              title: "Default",
              sku: "WAVE",
              metadata: {
                inventoryState: "ON_VEHICLE",
                availableQuantity: 24,
              },
              options: {
                Default: "Default",
              },
              prices: [
                {
                  amount: 1499,
                  currency_code: "usd",
                },
              ],
            },
          ],
          sales_channels: [{ id: salesChannel.id }],
        },
      ],
    },
  });

  logger.info(
    `Bayblaze publishable API key: ${publishableApiKey.token ?? publishableApiKey.id}`
  );
  logger.info("Finished seeding Bayblaze data.");
}
