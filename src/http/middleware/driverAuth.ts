import type { NextFunction, Request, Response } from "express";

import { getBayblazeAuth } from "../../clients/firebaseAdminClient";

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
    const decoded = await getBayblazeAuth().verifyIdToken(token);
    req.driverAuth = {
      uid: decoded.uid,
      email: typeof decoded.email === "string" ? decoded.email : "",
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
