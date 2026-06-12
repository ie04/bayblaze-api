import type { Context } from "@medusajs/types";

const BAYBLAZE_ORDER_PREFIX = "BB-";
const BAYBLAZE_ORDER_DIGITS = 5;
const BAYBLAZE_ORDER_RADIX = 36;
const BAYBLAZE_ORDER_SEQUENCE = "bayblaze_order_number_seq";
const BAYBLAZE_MAX_ORDER_NUMBER =
  BAYBLAZE_ORDER_RADIX ** BAYBLAZE_ORDER_DIGITS - 1;
const BAYBLAZE_ORDER_NUMBER_PATTERN = /^BB-[0-9A-Z]{5}$/;

type SqlExecutor = {
  execute?: (sql: string, params?: unknown[]) => Promise<unknown>;
  query?: (sql: string, params?: unknown[]) => Promise<unknown>;
  getConnection?: () => SqlExecutor;
};

export function formatBayblazeOrderNumber(value: number) {
  if (
    !Number.isSafeInteger(value) ||
    value < 0 ||
    value > BAYBLAZE_MAX_ORDER_NUMBER
  ) {
    throw new Error(
      `Bayblaze order number value must be between 0 and ${BAYBLAZE_MAX_ORDER_NUMBER}.`,
    );
  }

  return `${BAYBLAZE_ORDER_PREFIX}${value
    .toString(BAYBLAZE_ORDER_RADIX)
    .toUpperCase()
    .padStart(BAYBLAZE_ORDER_DIGITS, "0")}`;
}

export function parseBayblazeOrderNumber(value: string | null | undefined) {
  const normalized = value?.trim().toUpperCase();

  if (!normalized || !BAYBLAZE_ORDER_NUMBER_PATTERN.test(normalized)) {
    return null;
  }

  return Number.parseInt(
    normalized.slice(BAYBLAZE_ORDER_PREFIX.length),
    BAYBLAZE_ORDER_RADIX,
  );
}

export function isBayblazeOrderNumber(value: string | null | undefined) {
  return parseBayblazeOrderNumber(value) !== null;
}

export async function generateBayblazeOrderNumber(
  _order: unknown,
  sharedContext: Context = {},
) {
  await ensureBayblazeOrderNumberSequence(sharedContext);

  const rows = await executeSql(
    sharedContext,
    `SELECT nextval('${BAYBLAZE_ORDER_SEQUENCE}') AS value`,
  );
  const value = Number(readFirstRowValue(rows, "value"));

  return formatBayblazeOrderNumber(value);
}

export async function syncBayblazeOrderNumberSequence(
  orderNumbers: Array<string | null | undefined>,
  sharedContext: Context = {},
) {
  await ensureBayblazeOrderNumberSequence(sharedContext);

  const maxOrderNumber = orderNumbers.reduce((max, orderNumber) => {
    const parsed = parseBayblazeOrderNumber(orderNumber);

    return parsed === null ? max : Math.max(max, parsed);
  }, -1);
  const nextValue = maxOrderNumber + 1;

  if (nextValue > BAYBLAZE_MAX_ORDER_NUMBER) {
    throw new Error("Bayblaze order number range has been exhausted.");
  }

  await executeSql(
    sharedContext,
    `SELECT setval('${BAYBLAZE_ORDER_SEQUENCE}', ${nextValue}, false)`,
  );

  return formatBayblazeOrderNumber(nextValue);
}

async function ensureBayblazeOrderNumberSequence(sharedContext: Context = {}) {
  await executeSql(
    sharedContext,
    [
      `CREATE SEQUENCE IF NOT EXISTS ${BAYBLAZE_ORDER_SEQUENCE}`,
      "AS integer",
      "MINVALUE 0",
      `MAXVALUE ${BAYBLAZE_MAX_ORDER_NUMBER}`,
      "START WITH 0",
      "INCREMENT BY 1",
      "NO CYCLE",
    ].join(" "),
  );
}

async function executeSql(sharedContext: Context, sql: string) {
  const manager = (sharedContext.transactionManager ??
    sharedContext.manager) as SqlExecutor | undefined;
  const connection = manager?.getConnection?.();

  if (manager?.execute) {
    return manager.execute(sql);
  }

  if (connection?.execute) {
    return connection.execute(sql);
  }

  if (manager?.query) {
    return manager.query(sql);
  }

  if (connection?.query) {
    return connection.query(sql);
  }

  return executeSqlWithDatabaseUrl(sql);
}

async function executeSqlWithDatabaseUrl(sql: string) {
  const databaseUrl = process.env.DATABASE_URL?.trim();

  if (!databaseUrl) {
    throw new Error("DATABASE_URL is required for Bayblaze order numbers.");
  }

  const { Client } = require("pg") as typeof import("pg");
  const client = new Client({ connectionString: databaseUrl });

  await client.connect();

  try {
    const result = await client.query(sql);

    return result.rows;
  } finally {
    await client.end();
  }
}

function readFirstRowValue(rows: unknown, key: string) {
  if (Array.isArray(rows)) {
    const first = rows[0];

    if (first && typeof first === "object" && key in first) {
      return (first as Record<string, unknown>)[key];
    }
  }

  if (
    rows &&
    typeof rows === "object" &&
    "rows" in rows &&
    Array.isArray((rows as { rows: unknown[] }).rows)
  ) {
    return readFirstRowValue((rows as { rows: unknown[] }).rows, key);
  }

  throw new Error("Could not read Bayblaze order sequence value.");
}
