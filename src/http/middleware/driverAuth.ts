import type { NextFunction, Request, Response } from "express";

import { getBayblazeAuth } from "../../clients/firebaseAdminClient";
import { getAccount } from "../../modules/accounts/accountService";
import { verifyDriverSessionToken } from "../../modules/drivers/driverSession";

export type DriverAuthedRequest = Request & {
  driverAuth?: {
    uid: string;
    email: string;
  };
};

export async function requireDriverAuth(
  req: DriverAuthedRequest,
  res: Response,
  next: NextFunction,
) {
  const token = readBearerToken(req.headers.authorization);

  if (!token) {
    return res.status(401).json({
      message: "Driver sign-in is required.",
    });
  }

  try {
    const session = verifyDriverSessionToken(token);
    if (session) {
      const account = await getAccount(session.uid);

      if (!account?.roles.includes("driver") || account.disabled) {
        return res.status(403).json({
          message: "Driver access is required.",
        });
      }

      req.driverAuth = {
        uid: session.uid,
        email: account.email || session.email,
      };
      return next();
    }

    const decoded = await getBayblazeAuth().verifyIdToken(token);
    const account = await getAccount(decoded.uid);

    if (!account?.roles.includes("driver")) {
      return res.status(403).json({
        message: "Driver access is required.",
      });
    }

    req.driverAuth = {
      uid: decoded.uid,
      email: account.email || (typeof decoded.email === "string" ? decoded.email : ""),
    };

    return next();
  } catch {
    return res.status(401).json({
      message: "Driver session is not valid.",
    });
  }
}

function readBearerToken(value: unknown) {
  const header = Array.isArray(value) ? value[0] : value;

  if (typeof header !== "string" || !header.toLowerCase().startsWith("bearer ")) {
    return "";
  }

  return header.slice("bearer ".length).trim();
}
