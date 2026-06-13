import type { NextFunction, Request, Response } from "express";

import { getBayblazeAuth } from "../../clients/firebaseAdminClient";
import { getAccount } from "../../modules/accounts/accountService";
import { verifyAccountSessionToken } from "../../modules/accounts/accountSession";
import type { AccountRole, AccountSessionPayload } from "../../modules/accounts/accountTypes";

export type AccountAuthedRequest = Request & {
  accountAuth?: AccountSessionPayload;
};

export async function requireAccountAuth(
  req: AccountAuthedRequest,
  res: Response,
  next: NextFunction,
) {
  const token = readBearerToken(req.headers.authorization);

  if (!token) {
    return res.status(401).json({
      message: "BayBlaze account sign-in is required.",
    });
  }

  try {
    const session = verifyAccountSessionToken(token);
    if (session) {
      const account = await getAccount(session.uid);

      if (!account || account.disabled) {
        return res.status(403).json({
          message: "This BayBlaze account is not enabled.",
        });
      }

      req.accountAuth = {
        ...session,
        badges: account.badges,
        email: account.email || session.email,
        roles: account.roles,
        settings: account.settings,
      };
      return next();
    }

    const decoded = await getBayblazeAuth().verifyIdToken(token);
    const account = await getAccount(decoded.uid);

    if (!account || account.disabled) {
      return res.status(403).json({
        message: "This BayBlaze account is not enabled.",
      });
    }

    req.accountAuth = {
      badges: account.badges,
      email: account.email || (typeof decoded.email === "string" ? decoded.email : ""),
      exp: Math.floor(Date.now() / 1000) + 60,
      roles: account.roles,
      settings: account.settings,
      uid: decoded.uid,
    };

    return next();
  } catch {
    return res.status(401).json({
      message: "BayBlaze account session is not valid.",
    });
  }
}

export function requireAccountRole(role: AccountRole) {
  return (req: AccountAuthedRequest, res: Response, next: NextFunction) => {
    if (!req.accountAuth?.badges.includes("employee") || !req.accountAuth.roles.includes(role)) {
      return res.status(403).json({
        message: `${role} access is required.`,
      });
    }

    return next();
  };
}

export function readBearerToken(value: unknown) {
  const header = Array.isArray(value) ? value[0] : value;

  if (typeof header !== "string" || !header.toLowerCase().startsWith("bearer ")) {
    return "";
  }

  return header.slice("bearer ".length).trim();
}
