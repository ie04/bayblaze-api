import { cert, getApps, initializeApp, type App } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

import { env } from "../config/env";

let app: App | null = null;

function getFirebaseApp() {
  if (app) {
    return app;
  }

  const existing = getApps()[0];
  if (existing) {
    app = existing;
    return app;
  }

  const credential = readServiceAccountCredential();
  app = initializeApp({
    credential,
    projectId: env.FIREBASE_PROJECT_ID || undefined,
    storageBucket: env.FIREBASE_STORAGE_BUCKET || undefined,
  });

  return app;
}

export function getBayblazeAuth() {
  return getAuth(getFirebaseApp());
}

export function getBayblazeFirestore() {
  const databaseId = env.FIRESTORE_DATABASE_ID;
  const firebaseApp = getFirebaseApp();

  return databaseId && databaseId !== "(default)"
    ? getFirestore(firebaseApp, databaseId)
    : getFirestore(firebaseApp);
}

export function getBayblazeStorage() {
  return getStorage(getFirebaseApp());
}

function readServiceAccountCredential() {
  const json = env.FIREBASE_SERVICE_ACCOUNT_JSON || decodeBase64Json(env.FIREBASE_SERVICE_ACCOUNT_JSON_BASE64);

  if (!json) {
    return undefined;
  }

  return cert(JSON.parse(json));
}

function decodeBase64Json(value?: string) {
  if (!value) {
    return "";
  }

  return Buffer.from(value, "base64").toString("utf8");
}
