export type DriverProfile = {
  uid: string;
  email: string;
  firstName: string;
  lastName: string;
  phoneNumber: string;
  profilePhotoPath?: string;
  profilePhotoUrl?: string;
  bio: string;
  onboardingComplete: boolean;
  activeVehicleId?: string;
  clockedIn: boolean;
  clockedInAt?: unknown;
  clockedOutAt?: unknown;
  createdAt?: unknown;
  updatedAt?: unknown;
};

export type VehicleRecord = {
  vehicleId: string;
  label: string;
  plateNumber?: string;
  make?: string;
  model?: string;
  color?: string;
  active: boolean;
  linkedDriverUid?: string;
  linkedAt?: unknown;
  updatedAt?: unknown;
};

export type DriverDeliveryItem = {
  id: string;
  productId?: string;
  variantId?: string;
  name: string;
  variant: string;
  quantity: number;
  imageUrl: string;
  inventoryLocation: "vehicle" | "warehouse";
};

export type DriverDeliveryStop = {
  orderId: string;
  medusaOrderId?: string;
  orderReference?: string;
  customerPhone?: string;
  customerName: string;
  customerAddress: string;
  status: "current" | "locked" | "scored";
  locked: boolean;
  score?: number;
  eta?: string;
  items: DriverDeliveryItem[];
};

export type DriverDeliveryQueue = {
  uid: string;
  activeOrderId?: string;
  stops: DriverDeliveryStop[];
  updatedAt?: unknown;
};

export type DeliveryAttemptLog = {
  uid: string;
  orderId: string;
  type:
    | "warehouse_arrival"
    | "out_for_delivery"
    | "customer_arrival"
    | "id_photo"
    | "merchant_invoice_photo"
    | "cancelled"
    | "completed";
  note?: string | null;
  photoPath?: string | null;
  photoUrl?: string | null;
};

export type DriverLocationSnapshot = {
  uid: string;
  vehicleId: string;
  lat: number;
  lng: number;
  accuracy: number;
  heading: number | null;
  speed: number | null;
  clockedIn: true;
  source: "driver-pwa";
  clientCapturedAt: number;
};
