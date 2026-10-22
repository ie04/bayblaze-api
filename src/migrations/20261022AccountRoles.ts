import { mkdir, writeFile } from "node:fs/promises";
import { dirname } from "node:path";
import { FieldValue } from "firebase-admin/firestore";
import { getBayblazeAuth, getBayblazeFirestore } from "../clients/firebaseAdminClient";
import { env } from "../config/env";
import { planAccountRoles } from "./accountRolesPlan";

async function main() {
  const apply = process.argv.includes("--apply");
  const backupPath = process.argv[process.argv.indexOf("--backup") + 1];
  if (!process.argv.includes("--backup") || !backupPath || backupPath.startsWith("--")) {
    throw new Error("Supply --backup /private/path/accounts.json (dry-run by default).");
  }
  const db = getBayblazeFirestore();
  const snapshot = await db.collection("accounts").get();
  const users = [];
  let pageToken: string | undefined;
  do {
    const page = await getBayblazeAuth().listUsers(1000, pageToken);
    users.push(...page.users);
    pageToken = page.pageToken;
  } while (pageToken);
  const authByUid = new Map(users.map((user) => [user.uid, user]));
  const byUid = new Map(snapshot.docs.map((doc) => [doc.id, doc]));
  const uids = new Set([...byUid.keys(), ...authByUid.keys()]);
  // Validate every plan before the first write; never silently drop unknown roles.
  for (const uid of uids) planAccountRoles(byUid.get(uid)?.data() ?? {}, authByUid.get(uid));
  await mkdir(dirname(backupPath), { recursive: true, mode: 0o700 });
  await writeFile(backupPath, JSON.stringify({
    version: 1, projectId: env.FIREBASE_PROJECT_ID, exportedAt: new Date().toISOString(),
    accounts: snapshot.docs.map((doc) => ({
      uid: doc.id,
      // Raw Firestore Value protos preserve timestamps and types for recovery.
      fields: (doc as unknown as { _fieldsProto: unknown })._fieldsProto,
      updateTime: doc.updateTime?.toDate().toISOString(),
    })),
    authUsers: users.map((user) => ({
      uid: user.uid, email: user.email, displayName: user.displayName,
      disabled: user.disabled, customClaims: user.customClaims, metadata: user.metadata,
    })),
  }, null, 2), { flag: "wx", mode: 0o600 });
  let changed = 0;
  let created = 0;
  for (const uid of uids) {
    const authUser = authByUid.get(uid);
    const ref = db.collection("accounts").doc(uid);
    const update = async (data: Record<string, unknown>, exists: boolean) => {
      const patch = planAccountRoles(data, authUser);
      const needsChange = !exists || Object.hasOwn(data, "badges") ||
        Object.entries(patch).some(([key, value]) => JSON.stringify(data[key]) !== JSON.stringify(value));
      return { patch, needsChange };
    };
    if (!apply) {
      const doc = byUid.get(uid);
      if ((await update(doc?.data() ?? {}, Boolean(doc))).needsChange) changed++;
      if (!doc) created++;
      continue;
    }
    // Re-read inside each transaction, preserving concurrent role and profile edits.
    const outcome = await db.runTransaction(async (tx) => {
      const current = await tx.get(ref);
      const { patch, needsChange } = await update(current.data() ?? {}, current.exists);
      if (needsChange) tx.set(ref, {
        ...patch, badges: FieldValue.delete(), updatedAt: FieldValue.serverTimestamp(),
        ...(!current.exists ? { createdAt: FieldValue.serverTimestamp() } : {}),
      }, { merge: true });
      return { changed: needsChange, created: !current.exists };
    });
    if (outcome.changed) changed++;
    if (outcome.created) created++;
  }
  console.log(JSON.stringify({ mode: apply ? "apply" : "dry-run", accounts: snapshot.size,
    authUsers: users.length, changed, created, backupPath }));
  await db.terminate();
}
main().catch((error: unknown) => { console.error(error instanceof Error ? error.message : "Migration failed"); process.exitCode = 1; });
