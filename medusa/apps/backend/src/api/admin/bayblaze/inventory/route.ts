import crypto from "node:crypto";
import { copyFile, mkdir, readdir, stat, unlink, writeFile } from "node:fs/promises";
import path from "node:path";

import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { ContainerRegistrationKeys } from "@medusajs/framework/utils";
import {
  createProductVariantsWorkflow,
  createProductOptionsWorkflow,
  createProductsWorkflow,
  deleteProductsWorkflow,
  updateProductOptionsWorkflow,
  updateProductVariantsWorkflow,
  updateProductsWorkflow,
} from "@medusajs/medusa/core-flows";

import { assertBayblazeServiceToken } from "../../../../lib/bayblaze-service-auth";

export const AUTHENTICATE = false;

type InventoryState = "ON_VEHICLE" | "IN_WAREHOUSE";

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
    filters?: Record<string, unknown>;
  }) => Promise<{ data: T[] }>;
};

type ProductVariant = {
  id: string;
  product_id?: string | null;
  title?: string | null;
  sku?: string | null;
  barcode?: string | null;
  metadata?: Record<string, unknown> | null;
  updated_at?: string | Date | null;
  price_set?: {
    prices?: Array<{ amount?: number | null; currency_code?: string | null }> | null;
  } | null;
  options?: Array<{
    value?: string | null;
    option?: { title?: string | null } | null;
  }> | null;
};

type ProductOption = {
  id?: string | null;
  title?: string | null;
  values?: Array<{ value?: string | null } | string> | null;
};

type ProductImage = {
  id?: string | null;
  url?: string | null;
};

type Product = {
  id: string;
  collection?: { id?: string | null; title?: string | null; handle?: string | null } | null;
  collection_id?: string | null;
  description?: string | null;
  title?: string | null;
  handle?: string | null;
  status?: "draft" | "published" | string | null;
  thumbnail?: string | null;
  images?: ProductImage[] | null;
  metadata?: Record<string, unknown> | null;
  categories?: Array<{ id?: string | null; name?: string | null; handle?: string | null }> | null;
  options?: ProductOption[] | null;
  variants?: ProductVariant[] | null;
};

type ShippingProfile = {
  id: string;
};

type SalesChannel = {
  id: string;
  name?: string | null;
};

type ProductCollection = {
  id: string;
  title?: string | null;
  handle?: string | null;
};

type DeliveryVehicle = {
  id: string;
  label: string;
  plate?: string;
  active: boolean;
};

type ProductImageUploadDraft = {
  dataUrl?: string;
  fileName?: string;
  mimeType?: string;
};

type ProductDraft = {
  category?: string;
  collectionId?: string | null;
  description?: string;
  handle?: string;
  imageUrl?: string;
  imageUrls?: string[];
  imageUpload?: ProductImageUploadDraft;
  imageUploads?: ProductImageUploadDraft[];
  metadata?: Record<string, unknown>;
  status?: "draft" | "published";
  title?: string;
};

type VariantDraft = {
  barcode?: string;
  brand?: string;
  imageUrl?: string;
  imageUrls?: string[];
  imageUploads?: ProductImageUploadDraft[];
  inventoryState?: InventoryState;
  priceCents?: number;
  quantity?: number;
  sku?: string;
  title?: string;
  vehicleId?: string;
};

type ProductWithVariantDraft = ProductDraft & {
  variant?: VariantDraft;
};

const productFields = [
  "id",
  "collection.id",
  "collection.title",
  "collection.handle",
  "collection_id",
  "description",
  "title",
  "handle",
  "status",
  "thumbnail",
  "images.id",
  "images.url",
  "metadata",
  "categories.name",
  "categories.handle",
  "options.id",
  "options.title",
  "options.values.value",
  "variants.id",
  "variants.product_id",
  "variants.title",
  "variants.sku",
  "variants.barcode",
  "variants.metadata",
  "variants.updated_at",
  "variants.price_set.prices.amount",
  "variants.price_set.prices.currency_code",
  "variants.options.value",
  "variants.options.option.title",
];

export async function GET(req: MedusaRequest, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  try {
    await cleanupStaleTemporaryInventoryImages();
    return res.status(200).json(await getInventorySnapshot(req));
  } catch (caught) {
    console.error("BayBlaze inventory snapshot failed:", caught);

    return res.status(500).json({
      message: caught instanceof Error ? caught.message : "Inventory snapshot failed.",
    });
  }
}

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  const mutation = req.body as Record<string, unknown> | undefined;

  if (!mutation || typeof mutation.type !== "string") {
    return res.status(400).json({ message: "Inventory mutation type is required." });
  }

  try {
    if (mutation.type === "create-product") {
      await createProduct(req, mutation.draft as ProductDraft | undefined);
    } else if (mutation.type === "create-product-with-variant") {
      await createProductWithVariant(req, mutation.draft as ProductWithVariantDraft | undefined);
    } else if (mutation.type === "create-variant") {
      await createVariant(
        req,
        typeof mutation.productId === "string" ? mutation.productId : "",
        mutation.draft as VariantDraft | undefined,
      );
    } else if (mutation.type === "update-product-details") {
      await updateProductDetails(
        req,
        typeof mutation.productId === "string" ? mutation.productId : "",
        mutation.draft as ProductDraft | undefined,
      );
    } else if (mutation.type === "delete-product") {
      await deleteProduct(
        req,
        typeof mutation.productId === "string" ? mutation.productId : "",
      );
    } else if (mutation.type === "update-product-image") {
      await updateProductImage(
        req,
        typeof mutation.productId === "string" ? mutation.productId : "",
        readString(mutation.imageUrl),
      );
    } else if (mutation.type === "update-variant-details") {
      await updateVariantDetails(
        req,
        typeof mutation.variantId === "string" ? mutation.variantId : "",
        mutation.draft as VariantDraft | undefined,
      );
    } else if (mutation.type === "update-quantity") {
      await updateVariantMetadata(req, mutation, (metadata) => ({
        ...metadata,
        availableQuantity: readQuantity(mutation.quantity),
      }));
    } else if (mutation.type === "assign-vehicle") {
      const vehicleId = readString(mutation.vehicleId);
      await updateVariantMetadata(req, mutation, (metadata) => ({
        ...metadata,
        inventoryState: vehicleId === "warehouse" ? "IN_WAREHOUSE" : "ON_VEHICLE",
        assignedVehicleId: vehicleId === "warehouse" ? undefined : vehicleId,
      }));
    } else if (mutation.type === "set-state") {
      const state = readInventoryState(mutation.state);
      await updateVariantMetadata(req, mutation, (metadata) => ({
        ...metadata,
        inventoryState: state,
        assignedVehicleId: state === "IN_WAREHOUSE" ? undefined : metadata.assignedVehicleId,
      }));
    } else {
      return res.status(400).json({ message: `Unsupported inventory mutation: ${mutation.type}` });
    }
  } catch (caught) {
    console.error("BayBlaze inventory mutation failed:", caught);

    return res.status(400).json({
      message: getErrorMessage(caught, "Inventory mutation failed."),
    });
  }

  try {
    return res.status(200).json(await getInventorySnapshot(req));
  } catch (caught) {
    console.error("BayBlaze inventory snapshot after mutation failed:", caught);

    return res.status(500).json({
      message: caught instanceof Error ? caught.message : "Inventory snapshot after mutation failed.",
    });
  }
}

async function getInventorySnapshot(req: MedusaRequest) {
  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const [{ data: products }, { data: collections }] = await Promise.all([
    query.graph<Product>({
      entity: "product",
      fields: productFields,
    }),
    query.graph<ProductCollection>({
      entity: "product_collection",
      fields: ["id", "title", "handle"],
    }),
  ]);

  return {
    products: products.map(toInventoryProduct),
    collections: collections
      .map(toInventoryCollection)
      .sort((first, second) => first.title.localeCompare(second.title, undefined, { sensitivity: "base" })),
    vehicles: getVehicles(products),
    lastSyncedAt: new Date().toISOString(),
    source: "api",
  };
}

async function createProduct(req: MedusaRequest, draft?: ProductDraft) {
  const title = readString(draft?.title);
  const handle = readString(draft?.handle);

  if (!title || !handle) {
    throw new Error("Product title and handle are required.");
  }

  const shippingProfile = await getDefaultShippingProfile(req);
  const salesChannel = await getStorefrontSalesChannel(req);
  const imageUrls = await resolveProductImageUrls(req, draft);
  const imageUrl = imageUrls[0];
  const category = readString(draft?.category);
  const collectionId = readNullableString(draft?.collectionId);

  await createProductsWorkflow(req.scope).run({
    input: {
      products: [
        {
          title,
          handle,
          collection_id: collectionId,
          description: readNullableString(draft?.description),
          thumbnail: imageUrl || undefined,
          status: "draft",
          metadata: removeUndefined({
            inventoryCategory: category || undefined,
            ...readProductMetadataDraft(draft?.metadata),
          }),
          images: imageUrls.length ? imageUrls.map((url) => ({ url })) : undefined,
          shipping_profile_id: shippingProfile.id,
          sales_channels: salesChannel ? [{ id: salesChannel.id }] : undefined,
          options: [
            {
              title: "Default",
              values: ["Default"],
            },
          ],
        },
      ],
    },
  });
}

async function createProductWithVariant(
  req: MedusaRequest,
  draft?: ProductWithVariantDraft,
) {
  const title = readString(draft?.title);
  const handle = readString(draft?.handle);
  const variantDraft = draft?.variant;

  if (!title || !handle) {
    throw new Error("Product name and handle are required.");
  }

  if (!variantDraft) {
    throw new Error("First variant details are required.");
  }

  const shippingProfile = await getDefaultShippingProfile(req);
  const salesChannel = await getStorefrontSalesChannel(req);
  const imageUrls = await resolveProductImageUrls(req, draft);
  const imageUrl = imageUrls[0];
  const category = readString(draft?.category);
  const collectionId = readNullableString(draft?.collectionId);
  const inventoryState = readInventoryState(variantDraft.inventoryState);
  const variantTitle = readString(variantDraft.title);
  const sku = readString(variantDraft.sku);

  if (!variantTitle || !sku) {
    throw new Error("Variant name and SKU are required.");
  }

  await createProductsWorkflow(req.scope).run({
    input: {
      products: [
        {
          title,
          handle,
          collection_id: collectionId,
          description: readNullableString(draft?.description),
          thumbnail: imageUrl || undefined,
          status: "draft",
          metadata: removeUndefined({
            inventoryCategory: category || undefined,
            brand: readString(variantDraft.brand) || undefined,
            ...readProductMetadataDraft(draft?.metadata),
          }),
          images: imageUrls.length ? imageUrls.map((url) => ({ url })) : undefined,
          shipping_profile_id: shippingProfile.id,
          sales_channels: salesChannel ? [{ id: salesChannel.id }] : undefined,
          options: [
            {
              title: "Flavor",
              values: [variantTitle],
            },
          ],
          variants: [
            {
              title: variantTitle,
              sku,
              barcode: readString(variantDraft.barcode) || undefined,
              manage_inventory: true,
              metadata: toVariantMetadata(variantDraft, inventoryState, true),
              options: {
                Flavor: variantTitle,
              },
              prices: [
                {
                  amount: readPriceAmountForMedusa(variantDraft.priceCents),
                  currency_code: "usd",
                },
              ],
            },
          ],
        },
      ],
    },
  });
}

async function updateProductDetails(
  req: MedusaRequest,
  productId: string,
  draft?: ProductDraft,
) {
  if (!productId) {
    throw new Error("Product ID is required.");
  }

  const shouldUpdateImages = hasProductImageDraft(draft);
  const imageUrls = shouldUpdateImages ? await resolveProductImageUrls(req, draft) : [];
  const imageUrl = imageUrls[0];
  const shouldUpdateCategory = Boolean(
    draft && Object.prototype.hasOwnProperty.call(draft, "category"),
  );
  const shouldUpdateCollection = Boolean(
    draft && Object.prototype.hasOwnProperty.call(draft, "collectionId"),
  );
  const shouldUpdateDescription = Boolean(
    draft && Object.prototype.hasOwnProperty.call(draft, "description"),
  );
  const shouldUpdateMetadata = Boolean(
    draft && Object.prototype.hasOwnProperty.call(draft, "metadata"),
  );
  const category = shouldUpdateCategory ? readString(draft?.category) : "";
  const product = await getProduct(req, productId);
  const productStatus = readProductStatus(draft?.status);
  const nextProductStatus = productStatus ?? product.status;
  const salesChannel = nextProductStatus === "published" ? await getStorefrontSalesChannel(req) : undefined;

  const update: Record<string, unknown> = {
    id: productId,
    collection_id: shouldUpdateCollection ? readNullableString(draft?.collectionId) : undefined,
    description: shouldUpdateDescription ? readNullableString(draft?.description) : undefined,
    title: readString(draft?.title) || undefined,
    handle: readString(draft?.handle) || undefined,
    status: productStatus,
    sales_channels: salesChannel ? [{ id: salesChannel.id }] : undefined,
    thumbnail: shouldUpdateImages ? imageUrl || null : undefined,
    images: shouldUpdateImages && imageUrls.length ? imageUrls.map((url) => ({ url })) : undefined,
    metadata: shouldUpdateCategory || shouldUpdateMetadata
      ? {
          ...(product?.metadata ?? {}),
          ...(shouldUpdateCategory ? { inventoryCategory: category || null } : {}),
          ...(shouldUpdateMetadata ? readProductMetadataDraft(draft?.metadata) : {}),
        }
      : undefined,
  };

  await updateProductsWorkflow(req.scope).run({
    input: {
      products: [removeUndefined(update)],
    },
  });
}

async function deleteProduct(req: MedusaRequest, productId: string) {
  if (!productId) {
    throw new Error("Product ID is required.");
  }

  await deleteProductsWorkflow(req.scope).run({
    input: {
      ids: [productId],
    },
  });
}

async function updateProductImage(
  req: MedusaRequest,
  productId: string,
  imageUrl: string,
) {
  if (!productId) {
    throw new Error("Product ID is required.");
  }

  if (!imageUrl) {
    throw new Error("Product image URL is required.");
  }

  await updateProductsWorkflow(req.scope).run({
    input: {
      products: [
        {
          id: productId,
          thumbnail: imageUrl,
          images: [{ url: imageUrl }],
        },
      ],
    },
  });

  await syncPublishedProductStorefrontVisibility(req, productId);
}

async function createVariant(
  req: MedusaRequest,
  productId: string,
  draft?: VariantDraft,
) {
  if (!productId) {
    throw new Error("Product ID is required.");
  }

  const title = readString(draft?.title);
  const sku = readString(draft?.sku);

  if (!title || !sku) {
    throw new Error("Variant title and SKU are required.");
  }

  if (!draft) {
    throw new Error("Variant details are required.");
  }

  const product = await getProduct(req, productId);
  const { optionTitle, optionValue } = await ensureProductOptionValue(req, product, title);
  const inventoryState = readInventoryState(draft?.inventoryState);
  const variantImageUrls = await resolveVariantImageUrls(req, draft);

  await createProductVariantsWorkflow(req.scope).run({
    input: {
      product_variants: [
        {
          product_id: productId,
          title,
          sku,
          barcode: readString(draft?.barcode) || undefined,
          manage_inventory: true,
          metadata: toVariantMetadata(draft, inventoryState, true, variantImageUrls),
          options: {
            [optionTitle]: optionValue,
          },
          prices: [
            {
              amount: readPriceAmountForMedusa(draft?.priceCents),
              currency_code: "usd",
            },
          ],
        },
      ],
    },
  });

  await syncPublishedProductStorefrontVisibility(req, productId);
}

async function updateVariantMetadata(
  req: MedusaRequest,
  mutation: Record<string, unknown>,
  update: (metadata: Record<string, unknown>) => Record<string, unknown>,
) {
  const variantId = readString(mutation.variantId);

  if (!variantId) {
    throw new Error("Variant ID is required.");
  }

  const variant = await getVariant(req, variantId);
  const metadata = removeUndefined(update(variant.metadata ?? {}));

  await updateProductVariantsWorkflow(req.scope).run({
    input: {
      product_variants: [
        {
          id: variantId,
          metadata,
        },
      ],
    },
  });

  await syncPublishedProductStorefrontVisibility(req, variant.product_id);
}

async function updateVariantDetails(
  req: MedusaRequest,
  variantId: string,
  draft?: VariantDraft,
) {
  if (!variantId) {
    throw new Error("Variant ID is required.");
  }

  const variant = await getVariant(req, variantId);
  const inventoryState = readInventoryState(
    draft?.inventoryState ?? variant.metadata?.inventoryState,
  );
  const shouldUpdateImages = hasVariantImageDraft(draft);
  const imageUrls = shouldUpdateImages ? await resolveVariantImageUrls(req, draft) : undefined;
  const metadata = removeUndefined({
    ...(variant.metadata ?? {}),
    ...toVariantMetadata(draft ?? {}, inventoryState, false, imageUrls),
  });
  const update: Record<string, unknown> = {
    id: variantId,
    title: readString(draft?.title) || undefined,
    sku: readString(draft?.sku) || undefined,
    barcode: readString(draft?.barcode) || undefined,
    metadata,
    prices:
      draft?.priceCents === undefined
        ? undefined
        : [
            {
              amount: readPriceAmountForMedusa(draft.priceCents),
              currency_code: "usd",
            },
          ],
  };

  await updateProductVariantsWorkflow(req.scope).run({
    input: {
      product_variants: [removeUndefined(update)],
    },
  });

  await syncPublishedProductStorefrontVisibility(req, variant.product_id);
}

async function getProduct(req: MedusaRequest, productId: string) {
  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const { data: products } = await query.graph<Product>({
    entity: "product",
    fields: ["id", "status", "metadata", "options.id", "options.title", "options.values.value"],
    filters: { id: productId },
  });
  const product = products[0];

  if (!product) {
    throw new Error(`Product ${productId} was not found.`);
  }

  return product;
}

async function ensureProductOptionValue(
  req: MedusaRequest,
  product: Product,
  value: string,
) {
  const option = product.options?.[0];
  const optionTitle = readString(option?.title) || "Default";
  const optionValue = readString(value);

  if (!optionValue) {
    throw new Error("Variant option value is required.");
  }

  const existingValues = (option?.values ?? [])
    .map((item) => (typeof item === "string" ? item : item?.value))
    .map((item) => readString(item))
    .filter(Boolean);
  const existingValue = existingValues.find(
    (item) => item.toLowerCase() === optionValue.toLowerCase(),
  );

  if (existingValue) {
    return {
      optionTitle,
      optionValue: existingValue,
    };
  }

  if (option?.id) {
    await updateProductOptionsWorkflow(req.scope).run({
      input: {
        selector: { id: option.id },
        update: {
          values: [...existingValues, optionValue],
        },
      },
    });
  } else {
    await createProductOptionsWorkflow(req.scope).run({
      input: {
        product_options: [
          {
            product_id: product.id,
            title: optionTitle,
            values: [optionValue],
          },
        ],
      },
    });
  }

  return {
    optionTitle,
    optionValue,
  };
}

async function getVariant(req: MedusaRequest, variantId: string) {
  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const { data: variants } = await query.graph<ProductVariant>({
    entity: "product_variant",
    fields: ["id", "product_id", "metadata"],
    filters: { id: variantId },
  });
  const variant = variants[0];

  if (!variant) {
    throw new Error(`Variant ${variantId} was not found.`);
  }

  return variant;
}

async function getDefaultShippingProfile(req: MedusaRequest) {
  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const { data: shippingProfiles } = await query.graph<ShippingProfile>({
    entity: "shipping_profile",
    fields: ["id"],
  });
  const shippingProfile = shippingProfiles[0];

  if (!shippingProfile) {
    throw new Error("No shipping profile found.");
  }

  return shippingProfile;
}

async function syncPublishedProductStorefrontVisibility(
  req: MedusaRequest,
  productId?: string | null,
) {
  const normalizedProductId = readString(productId);

  if (!normalizedProductId) {
    return;
  }

  const product = await getProduct(req, normalizedProductId);

  if (product.status !== "published") {
    return;
  }

  const salesChannel = await getStorefrontSalesChannel(req);

  if (!salesChannel) {
    return;
  }

  await updateProductsWorkflow(req.scope).run({
    input: {
      products: [
        {
          id: normalizedProductId,
          sales_channels: [{ id: salesChannel.id }],
        },
      ],
    },
  });
}

async function getStorefrontSalesChannel(req: MedusaRequest) {
  const configuredSalesChannelId = readString(
    process.env.BAYBLAZE_STOREFRONT_SALES_CHANNEL_ID,
    process.env.STOREFRONT_SALES_CHANNEL_ID,
    process.env.MEDUSA_SALES_CHANNEL_ID,
  );
  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const { data: salesChannels } = await query.graph<SalesChannel>({
    entity: "sales_channel",
    fields: ["id", "name"],
  });

  if (!salesChannels.length) {
    return undefined;
  }

  if (configuredSalesChannelId) {
    const configured = salesChannels.find((salesChannel) => salesChannel.id === configuredSalesChannelId);

    if (configured) {
      return configured;
    }
  }

  return salesChannels.find((salesChannel) => {
    const name = readString(salesChannel.name).toLowerCase();
    return name.includes("bayblaze") || name.includes("storefront") || name.includes("default");
  }) ?? salesChannels[0];
}

function toInventoryProduct(product: Product) {
  const category =
    readString(product.metadata?.inventoryCategory) ||
    product.categories?.[0]?.name ||
    "Uncategorized";

  return {
    id: product.id,
    collectionId: readString(product.collection?.id, product.collection_id) || undefined,
    collectionTitle: readString(product.collection?.title) || undefined,
    description: readString(product.description),
    title: product.title || "Untitled product",
    handle: product.handle || product.id,
    metadata: toEditableProductMetadata(product.metadata ?? {}),
    status: product.status === "published" ? "published" : "draft",
    category,
    thumbnail: product.thumbnail || undefined,
    imageUrls: readProductImageUrls(product),
    images: readProductImageUrls(product).map((url) => ({ url })),
    variants: (product.variants ?? []).map((variant) => toInventoryVariant(product, variant)),
  };
}

function toInventoryCollection(collection: ProductCollection) {
  return {
    id: collection.id,
    title: collection.title || collection.id,
    handle: collection.handle || undefined,
  };
}

function readProductImageUrls(product: Product) {
  return Array.from(
    new Set(
      (product.images ?? [])
        .map((image) => readString(image?.url))
        .filter(Boolean),
    ),
  );
}

function toInventoryVariant(product: Product, variant: ProductVariant) {
  const metadata = variant.metadata ?? {};
  const inventoryState = readInventoryState(metadata.inventoryState);
  const availableQuantity = readQuantity(metadata.availableQuantity);
  const barcode = readString(metadata.barcode, variant.barcode);
  const brand = readString(metadata.brand, product.metadata?.brand);

  return {
    id: variant.id,
    productId: product.id,
    productTitle: product.title || "Untitled product",
    title: variant.title || "Default",
    sku: variant.sku || "",
    priceCents: readPriceCents(variant),
    imageUrl: readString(metadata.imageUrl) || undefined,
    imageUrls: readStringArray(metadata.imageUrls),
    metadata: removeUndefined({
      inventoryState,
      availableQuantity,
      assignedVehicleId:
        inventoryState === "ON_VEHICLE" ? readString(metadata.assignedVehicleId) || undefined : undefined,
      barcode: barcode || undefined,
      brand: brand || undefined,
    }),
    updatedAt: toIsoString(variant.updated_at),
  };
}

function toVariantMetadata(
  draft: VariantDraft,
  inventoryState: InventoryState,
  includeDefaults = false,
  imageUrls?: string[],
) {
  return removeUndefined({
    inventoryState,
    availableQuantity:
      draft.quantity === undefined && !includeDefaults
        ? undefined
        : readQuantity(draft.quantity),
    assignedVehicleId:
      inventoryState === "ON_VEHICLE" ? readString(draft.vehicleId) || undefined : undefined,
    barcode: readString(draft.barcode) || undefined,
    brand: readString(draft.brand) || undefined,
    imageUrl: imageUrls ? imageUrls[0] || null : undefined,
    imageUrls: imageUrls ?? undefined,
  });
}

function getVehicles(products: Product[]) {
  const configuredVehicles = readConfiguredVehicles();
  const vehiclesById = new Map<string, DeliveryVehicle>(
    configuredVehicles.map((vehicle) => [vehicle.id, vehicle]),
  );

  for (const product of products) {
    for (const variant of product.variants ?? []) {
      const vehicleId = readString(variant.metadata?.assignedVehicleId);

      if (vehicleId && !vehiclesById.has(vehicleId)) {
        vehiclesById.set(vehicleId, {
          id: vehicleId,
          label: vehicleId,
          active: true,
        });
      }
    }
  }

  return [
    { id: "warehouse", label: "Warehouse", active: true },
    ...Array.from(vehiclesById.values()).filter((vehicle) => vehicle.id !== "warehouse"),
  ];
}

function readConfiguredVehicles() {
  const raw = process.env.BAYBLAZE_INVENTORY_VEHICLES;

  if (!raw) {
    return [];
  }

  try {
    const parsed = JSON.parse(raw) as unknown;

    if (!Array.isArray(parsed)) {
      return [];
    }

    return parsed.flatMap((item) => {
      if (!item || typeof item !== "object") {
        return [];
      }

      const vehicle = item as Record<string, unknown>;
      const id = readString(vehicle.id);

      if (!id) {
        return [];
      }

      return [
        {
          id,
          label: readString(vehicle.label) || id,
          plate: readString(vehicle.plate) || undefined,
          active: vehicle.active !== false,
        },
      ];
    });
  } catch {
    return [];
  }
}

async function resolveProductImageUrls(req: MedusaRequest, draft?: ProductDraft) {
  const existingImageUrls = Array.isArray(draft?.imageUrls)
    ? draft.imageUrls.map((url) => readString(url)).filter((url) => url.length > 0)
    : [];

  if (existingImageUrls.length) {
    return promoteTemporaryInventoryImageUrls(req, existingImageUrls);
  }

  const uploads = Array.isArray(draft?.imageUploads)
    ? draft.imageUploads
    : draft?.imageUpload
      ? [draft.imageUpload]
      : [];

  const uploadedImageUrls = (
    await Promise.all(uploads.map((imageUpload) => saveProductImageUpload(req, imageUpload)))
  ).filter((url) => url.length > 0);

  const fallbackImageUrl = readString(draft?.imageUrl);

  return fallbackImageUrl && uploadedImageUrls.length === 0
    ? [fallbackImageUrl]
    : uploadedImageUrls;
}

async function resolveVariantImageUrls(req: MedusaRequest, draft?: VariantDraft) {
  const existingImageUrls = Array.isArray(draft?.imageUrls)
    ? draft.imageUrls.map((url) => readString(url)).filter((url) => url.length > 0)
    : [];

  if (existingImageUrls.length) {
    return promoteTemporaryInventoryImageUrls(req, existingImageUrls);
  }

  const uploads = Array.isArray(draft?.imageUploads) ? draft.imageUploads : [];
  const uploadedImageUrls = (
    await Promise.all(uploads.map((imageUpload) => saveProductImageUpload(req, imageUpload)))
  ).filter((url) => url.length > 0);
  const fallbackImageUrl = readString(draft?.imageUrl);

  return fallbackImageUrl && uploadedImageUrls.length === 0
    ? [fallbackImageUrl]
    : uploadedImageUrls;
}

function hasProductImageDraft(draft?: ProductDraft) {
  if (!draft) {
    return false;
  }

  return (
    Object.prototype.hasOwnProperty.call(draft, "imageUrl") ||
    Object.prototype.hasOwnProperty.call(draft, "imageUrls") ||
    Object.prototype.hasOwnProperty.call(draft, "imageUpload") ||
    Object.prototype.hasOwnProperty.call(draft, "imageUploads")
  );
}

function hasVariantImageDraft(draft?: VariantDraft) {
  if (!draft) {
    return false;
  }

  return (
    Object.prototype.hasOwnProperty.call(draft, "imageUrl") ||
    Object.prototype.hasOwnProperty.call(draft, "imageUrls") ||
    Object.prototype.hasOwnProperty.call(draft, "imageUploads")
  );
}

async function promoteTemporaryInventoryImageUrls(req: MedusaRequest, imageUrls: string[]) {
  const promotedUrls: string[] = [];

  for (const imageUrl of imageUrls) {
    const temporaryFileName = getTemporaryInventoryImageFileName(imageUrl);

    if (!temporaryFileName) {
      promotedUrls.push(imageUrl);
      continue;
    }

    const extension = path.extname(temporaryFileName).replace(/^\./, "") || "jpg";
    const promotedFileName = `product-${Date.now()}-${crypto.randomUUID()}.${extension}`;
    const uploadDir = getInventoryImageUploadDir();

    try {
      await copyFile(
        path.join(uploadDir, temporaryFileName),
        path.join(uploadDir, promotedFileName),
      );
    } catch (caught) {
      console.error("BayBlaze inventory image promotion failed:", {
        error: caught,
        temporaryFileName,
        promotedFileName,
      });

      throw new Error("Uploaded product image is no longer available. Please re-add the photo.");
    }

    promotedUrls.push(`${getPublicOrigin(req)}/bayblaze/inventory-images/${promotedFileName}`);
  }

  return promotedUrls;
}

async function cleanupStaleTemporaryInventoryImages() {
  const uploadDir = getInventoryImageUploadDir();
  const maxAgeMs = Number(process.env.BAYBLAZE_INVENTORY_TEMP_IMAGE_MAX_AGE_MS ?? 24 * 60 * 60 * 1000);
  const cutoff = Date.now() - maxAgeMs;

  let entries: string[] = [];

  try {
    entries = await readdir(uploadDir);
  } catch {
    return;
  }

  await Promise.all(
    entries
      .filter((entry) => isTemporaryInventoryImageFileName(entry))
      .map(async (entry) => {
        const filePath = path.join(uploadDir, entry);

        try {
          const fileStat = await stat(filePath);

          if (fileStat.mtimeMs < cutoff) {
            await unlink(filePath);
          }
        } catch {
          // Best-effort cleanup only.
        }
      }),
  );
}

function getTemporaryInventoryImageFileName(url: string) {
  if (!url) {
    return "";
  }

  let fileName = "";

  try {
    const parsed = new URL(url);
    fileName = path.basename(parsed.pathname);
  } catch {
    fileName = path.basename(url);
  }

  return isTemporaryInventoryImageFileName(fileName) ? fileName : "";
}

function isTemporaryInventoryImageFileName(fileName: string) {
  return /^tmp-[a-zA-Z0-9._-]+\.(jpg|jpeg|png|webp|gif)$/i.test(fileName);
}

async function saveProductImageUpload(req: MedusaRequest, imageUpload?: ProductImageUploadDraft) {
  if (!imageUpload) {
    return "";
  }

  const dataUrl = readString(imageUpload.dataUrl);
  const match = dataUrl.match(/^data:(image\/[a-zA-Z0-9.+-]+);base64,([a-zA-Z0-9+/=\r\n]+)$/);

  if (!match) {
    throw new Error("Product image upload must be a base64 image data URL.");
  }

  const mimeType = readString(imageUpload.mimeType, match[1]);
  const extension = getImageExtension(mimeType);

  if (!extension) {
    throw new Error("Product image must be a JPG, PNG, WebP, or GIF file.");
  }

  const bytes = Buffer.from(match[2].replace(/\s/g, ""), "base64");
  const maxBytes = Number(process.env.BAYBLAZE_INVENTORY_IMAGE_MAX_BYTES ?? 8 * 1024 * 1024);

  if (bytes.length > maxBytes) {
    throw new Error("Product image is too large.");
  }

  const fileName = `${Date.now()}-${crypto.randomUUID()}.${extension}`;
  const uploadDir = getInventoryImageUploadDir();

  await mkdir(uploadDir, { recursive: true });
  await writeFile(path.join(uploadDir, fileName), bytes);

  const publicOrigin = getPublicOrigin(req);

  if (!publicOrigin) {
    throw new Error("Unable to determine public Medusa URL for uploaded product image.");
  }

  return `${publicOrigin}/bayblaze/inventory-images/${fileName}`;
}

function getInventoryImageUploadDir() {
  return process.env.BAYBLAZE_INVENTORY_IMAGE_UPLOAD_DIR || path.join(process.cwd(), "uploads", "bayblaze-inventory");
}

function getPublicOrigin(req: MedusaRequest) {
  const configuredOrigin = readString(
    process.env.BAYBLAZE_PUBLIC_MEDUSA_URL,
    process.env.MEDUSA_PUBLIC_URL,
    process.env.BACKEND_URL,
    process.env.MEDUSA_BACKEND_URL,
  );

  if (configuredOrigin) {
    return configuredOrigin.replace(/\/$/, "");
  }

  const host = readString(req.headers["x-forwarded-host"], req.headers.host);
  const protocol = readString(req.headers["x-forwarded-proto"]) || "https";

  return host ? `${protocol}://${host}` : "";
}

function getImageExtension(mimeType: string) {
  const normalized = mimeType.toLowerCase();

  if (normalized === "image/jpeg" || normalized === "image/jpg") {
    return "jpg";
  }

  if (normalized === "image/png") {
    return "png";
  }

  if (normalized === "image/webp") {
    return "webp";
  }

  if (normalized === "image/gif") {
    return "gif";
  }

  return "";
}

function readInventoryState(value: unknown): InventoryState {
  return value === "ON_VEHICLE" ? "ON_VEHICLE" : "IN_WAREHOUSE";
}

function readProductStatus(value: unknown) {
  return value === "draft" || value === "published" ? value : undefined;
}

function readProductMetadataDraft(value: unknown) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return {};
  }

  return Object.fromEntries(
    Object.entries(value as Record<string, unknown>).flatMap(([rawKey, rawValue]) => {
      const key = rawKey.trim();

      if (!key) {
        return [];
      }

      if (rawValue === null) {
        return [[key, null]];
      }

      const metadataValue = readString(rawValue);

      return [[key, metadataValue || null]];
    }),
  );
}

function toEditableProductMetadata(metadata: Record<string, unknown>) {
  return Object.fromEntries(
    Object.entries(metadata).flatMap(([key, value]) => {
      if (value === null || value === undefined) {
        return [];
      }

      if (typeof value === "string" || typeof value === "number" || typeof value === "boolean") {
        return [[key, String(value)]];
      }

      return [];
    }),
  );
}

function getErrorMessage(caught: unknown, fallback: string) {
  if (caught instanceof Error && caught.message.trim()) {
    return caught.message.trim();
  }

  if (caught && typeof caught === "object") {
    const message = (caught as { message?: unknown }).message;

    if (typeof message === "string" && message.trim()) {
      return message.trim();
    }
  }

  if (typeof caught === "string" && caught.trim()) {
    return caught.trim();
  }

  return fallback;
}

function readQuantity(value: unknown) {
  const numberValue = typeof value === "number" ? value : Number(value);

  if (!Number.isFinite(numberValue) || numberValue < 0) {
    return 0;
  }

  return Math.floor(numberValue);
}

function readPriceCents(variant: ProductVariant) {
  const amount = variant.price_set?.prices?.find((price) => price.currency_code === "usd")
    ?.amount ?? variant.price_set?.prices?.[0]?.amount;

  return normalizeMedusaPriceToCents(amount);
}

function normalizeMedusaPriceToCents(value: unknown) {
  const amount = typeof value === "number" ? value : Number(value);

  if (!Number.isFinite(amount) || amount <= 0) {
    return 0;
  }

  if (amount < 1000) {
    return Math.round(amount * 100);
  }

  return Math.round(amount);
}

function readPriceAmountForMedusa(value: unknown) {
  const cents = readQuantity(value);

  return Number((cents / 100).toFixed(2));
}

function readString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }
  }

  return "";
}

function readStringArray(value: unknown) {
  if (!Array.isArray(value)) {
    return undefined;
  }

  const strings = value
    .map((item) => readString(item))
    .filter(Boolean);

  return strings.length ? strings : undefined;
}

function readNullableString(value: unknown) {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function removeUndefined<T extends Record<string, unknown>>(value: T) {
  return Object.fromEntries(
    Object.entries(value).filter(([, entryValue]) => entryValue !== undefined),
  ) as T;
}

function toIsoString(value?: string | Date | null) {
  if (value instanceof Date) {
    return value.toISOString();
  }

  return value || new Date().toISOString();
}
