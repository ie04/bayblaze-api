import { calculateRouteDuration, geocodeAddress, type LatLng } from "./googleMapsService";

const inventoryStates = {
  inWarehouse: "IN_WAREHOUSE",
  onVehicle: "ON_VEHICLE",
} as const;

const fulfillmentModes = {
  onVehicle: "ON_VEHICLE",
  partialOnVehicle: "PARTIAL_ON_VEHICLE",
  warehousePickupRequired: "WAREHOUSE_PICKUP_REQUIRED",
} as const;

const warehouseProfile = {
  address: "13702 42nd St Tampa, FL, 33613",
  label: "BayBlaze Warehouse 1",
  warehouseId: "WH1",
};

const driverProfile = {
  activeVehicleId: "OWNER_VEHICLE_1",
  displayName: "BayBlaze Owner Driver",
  driverId: "OWNER_DRIVER_1",
};

const vehicleProfile = {
  driverId: "OWNER_DRIVER_1",
  label: "Owner Vehicle",
  vehicleId: "OWNER_VEHICLE_1",
};

const thresholds = {
  expressMaxMinutes: 35,
  manualReviewMaxMinutes: 75,
  normalMaxMinutes: 55,
  wh1RoundTripMaxMinutes: 60,
};

type RoutingItem = {
  availableQuantity?: unknown;
  inventoryState?: unknown;
  itemId?: unknown;
  productId?: unknown;
  requestedQuantity?: unknown;
  title?: unknown;
  variantId?: unknown;
};

type EligibilityCandidate = {
  checkoutId?: unknown;
  createdAt?: unknown;
  customerId?: unknown;
  destination?: unknown;
  items?: RoutingItem[];
  priority?: unknown;
  promisedWindowMinutes?: unknown;
  requestedDeliveryMode?: unknown;
};

type NormalizedRoutingItem = {
  availableQuantity: number;
  inventoryState: "ON_VEHICLE" | "IN_WAREHOUSE";
  itemId: string;
  productId: string;
  requestedQuantity: number;
  title?: string;
  variantId: string;
};

export async function evaluatePreCheckoutEligibility(candidate: EligibilityCandidate) {
  const itemValidation = validateNormalizedCartItems(candidate.items);
  if (itemValidation.errors.length > 0) {
    return rejectionResponse({
      candidate,
      errors: itemValidation.errors,
      message:
        "Sorry, one or more cart items are not currently available for delivery. Please adjust your cart and try again.",
      reason: "INVALID_NORMALIZED_VARIANT_INVENTORY",
    });
  }

  const destination = await resolveDestination(candidate.destination);
  const warehouse = await resolveWarehouse();
  const wh1Coverage = await evaluateWh1RoundTripCoverage(destination.location, warehouse.location);

  if (!wh1Coverage.accepted) {
    return rejectionResponse({
      candidate,
      message:
        "Sorry, BayBlaze cannot reasonably fulfill this delivery yet. We are actively working to expand our coverage area.",
      reason: "OUTSIDE_WH1_ONE_HOUR_ROUND_TRIP_ISOCHRONE",
    });
  }

  const fulfillmentMode = getFulfillmentMode(itemValidation.items);
  const origin = warehouse.location;
  const routeStops =
    fulfillmentMode === fulfillmentModes.onVehicle
      ? [{ type: "CUSTOMER", checkoutId: readString(candidate.checkoutId), location: destination.location }]
      : [
          {
            checkoutIds: readString(candidate.checkoutId) ? [readString(candidate.checkoutId)] : [],
            location: warehouse.location,
            reason: "MISSING_VEHICLE_INVENTORY",
            type: "WAREHOUSE_PICKUP",
            warehouseId: warehouse.warehouseId,
          },
          { type: "CUSTOMER", checkoutId: readString(candidate.checkoutId), location: destination.location },
        ];
  const routeCoordinates = [origin, ...routeStops.map((stop) => stop.location)];
  const routeScore = await calculateRouteDuration(routeCoordinates);
  const classification = classifyRoute(
    routeScore.durationMinutes,
    readString(candidate.requestedDeliveryMode) === "SCHEDULED",
  );

  if (classification.decision === "REJECTED") {
    return rejectionResponse({
      candidate,
      message:
        "Sorry, BayBlaze cannot reasonably fulfill this delivery yet. We are actively working to expand our coverage area.",
      reason: "OUTSIDE_REASONABLE_DELIVERY_RANGE",
    });
  }

  return {
    accepted: true,
    checkoutId: readString(candidate.checkoutId),
    classification: classification.classification,
    confirmation: {
      buttons: ["I Confirm", "Go Back"],
      required: true,
      requirements: [
        "Confirm the delivery address is correct.",
        "Confirm you will be present at the estimated delivery time.",
        "Confirm you will have your physical ID on hand when the driver arrives.",
      ],
      title: "Confirm delivery details",
    },
    customerMessage:
      "BayBlaze can accept this checkout if you confirm the delivery details before age verification.",
    decision: classification.decision,
    nextStep: "SHOW_CONFIRMATION_BEFORE_AGECHECKER",
    normalizedCandidate: {
      checkoutId: readString(candidate.checkoutId),
      createdAt: readString(candidate.createdAt),
      customerId: readString(candidate.customerId),
      destination: {
        address: destination.address,
        location: destination.location,
      },
      items: itemValidation.items,
      priority: readString(candidate.priority) || "NORMAL",
      promisedWindowMinutes: readNumber(candidate.promisedWindowMinutes),
      requestedDeliveryMode: readString(candidate.requestedDeliveryMode) || "NOW",
    },
    requiresCustomerConfirmation: true,
    routingContext: {
      driverProfile,
      fulfillmentMode,
      origin,
      requiresWarehousePickup: fulfillmentMode !== fulfillmentModes.onVehicle,
      routeDuration: routeScore,
      routeScore,
      routeStops,
      vehicleProfile,
      warehouseProfile: warehouse,
      wh1Coverage,
    },
  };
}

function validateNormalizedCartItems(items: RoutingItem[] | undefined) {
  const errors: Array<{ field: string; itemId?: unknown; message: string; productId?: unknown; variantId?: unknown }> = [];

  if (!items?.length) {
    return {
      errors: [{ field: "items", message: "At least one normalized variant-level cart item is required." }],
      items: [] as NormalizedRoutingItem[],
    };
  }

  const normalizedItems = items.flatMap((item) => {
    const itemId = readString(item.itemId);
    const productId = readString(item.productId);
    const variantId = readString(item.variantId);
    const requestedQuantity = readInteger(item.requestedQuantity);
    const availableQuantity = readInteger(item.availableQuantity);
    const inventoryState = readString(item.inventoryState);

    if (!itemId) addItemError(errors, item, "itemId", "itemId is required.");
    if (!productId) addItemError(errors, item, "productId", "productId is required.");
    if (!variantId) addItemError(errors, item, "variantId", "variantId is required for every sellable unit.");
    if (inventoryState !== inventoryStates.onVehicle && inventoryState !== inventoryStates.inWarehouse) {
      addItemError(errors, item, "inventoryState", "inventoryState must be exactly ON_VEHICLE or IN_WAREHOUSE.");
    }
    if (availableQuantity === null || availableQuantity < 0) {
      addItemError(errors, item, "availableQuantity", "availableQuantity must be an integer greater than or equal to 0.");
    }
    if (requestedQuantity === null || requestedQuantity < 1) {
      addItemError(errors, item, "requestedQuantity", "requestedQuantity must be a positive integer.");
    }
    if (
      requestedQuantity !== null &&
      availableQuantity !== null &&
      requestedQuantity > availableQuantity
    ) {
      addItemError(errors, item, "requestedQuantity", "requestedQuantity cannot exceed availableQuantity.");
    }

    if (!itemId || !productId || !variantId || requestedQuantity === null || availableQuantity === null) {
      return [];
    }

    return [{
      availableQuantity,
      inventoryState: inventoryState as NormalizedRoutingItem["inventoryState"],
      itemId,
      productId,
      requestedQuantity,
      title: readString(item.title) || undefined,
      variantId,
    }];
  });

  return { errors, items: normalizedItems };
}

function addItemError(
  errors: Array<{ field: string; itemId?: unknown; message: string; productId?: unknown; variantId?: unknown }>,
  item: RoutingItem,
  field: string,
  message: string,
) {
  errors.push({
    field,
    itemId: item.itemId,
    message,
    productId: item.productId,
    variantId: item.variantId,
  });
}

async function resolveDestination(destination: unknown) {
  const record = readRecord(destination);
  const location = readLatLng(record.location ?? destination);

  if (location) {
    return {
      address: readString(record.address),
      location,
    };
  }

  const address = readString(record.address);
  if (!address) {
    return rejectionThrow("A delivery address or destination location is required.");
  }

  const geocode = await geocodeAddress(address);
  return {
    address,
    location: { lat: geocode.lat, lng: geocode.lng },
  };
}

async function resolveWarehouse() {
  const geocode = await geocodeAddress(warehouseProfile.address);

  return {
    ...warehouseProfile,
    location: { lat: geocode.lat, lng: geocode.lng },
  };
}

async function evaluateWh1RoundTripCoverage(destination: LatLng, warehouse: LatLng) {
  const outbound = await calculateRouteDuration([warehouse, destination]);
  const inbound = await calculateRouteDuration([destination, warehouse]);
  const durationMinutes = outbound.durationMinutes + inbound.durationMinutes;

  return {
    accepted: durationMinutes <= thresholds.wh1RoundTripMaxMinutes,
    durationMinutes,
    maxRoundTripMinutes: thresholds.wh1RoundTripMaxMinutes,
  };
}

function getFulfillmentMode(items: NormalizedRoutingItem[]) {
  const warehouseItems = items.filter((item) => item.inventoryState === inventoryStates.inWarehouse);
  const vehicleItems = items.filter((item) => item.inventoryState === inventoryStates.onVehicle);

  if (warehouseItems.length === 0) return fulfillmentModes.onVehicle;
  if (vehicleItems.length === 0) return fulfillmentModes.warehousePickupRequired;
  return fulfillmentModes.partialOnVehicle;
}

function classifyRoute(minutes: number, scheduled: boolean) {
  if (scheduled) {
    return { classification: "SCHEDULED", decision: "CONDITIONALLY_ACCEPTED" };
  }

  if (minutes <= thresholds.expressMaxMinutes) {
    return { classification: "EXPRESS", decision: "ACCEPTED" };
  }

  if (minutes <= thresholds.normalMaxMinutes) {
    return { classification: "NORMAL", decision: "CONDITIONALLY_ACCEPTED" };
  }

  if (minutes <= thresholds.manualReviewMaxMinutes) {
    return { classification: "BORDERLINE", decision: "MANUAL_REVIEW" };
  }

  return { classification: "REJECTED", decision: "REJECTED" };
}

function rejectionResponse({
  candidate,
  errors = [],
  message,
  reason,
}: {
  candidate?: EligibilityCandidate;
  errors?: unknown[];
  message: string;
  reason: string;
}) {
  return {
    accepted: false,
    checkoutId: readString(candidate?.checkoutId),
    classification: "REJECTED",
    customerMessage: message,
    decision: "REJECTED",
    nextStep: "DO_NOT_TRIGGER_AGECHECKER_OR_CREATE_ORDER",
    reason,
    requiresCustomerConfirmation: false,
    validationErrors: errors,
  };
}

function rejectionThrow(message: string): never {
  throw new Error(message);
}

function readRecord(value: unknown) {
  return typeof value === "object" && value !== null ? value as Record<string, unknown> : {};
}

function readLatLng(value: unknown): LatLng | null {
  const record = readRecord(value);
  const lat = readNumber(record.lat ?? record.latitude);
  const lng = readNumber(record.lng ?? record.longitude);

  return lat === null || lng === null ? null : { lat, lng };
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function readNumber(value: unknown) {
  const number = typeof value === "number" ? value : Number(value);
  return Number.isFinite(number) ? number : null;
}

function readInteger(value: unknown) {
  const number = readNumber(value);
  return number !== null && Number.isInteger(number) ? number : null;
}
