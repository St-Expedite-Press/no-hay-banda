# Local Patches — Barresider/x-mcp

This fork is maintained locally at `~/.hermes/mcp/x-mcp/` to preserve patches that fix login failures on EC2. All patches are applied to `src/behaviors/login.ts` — edit source, then rebuild with `npm run build`.

**Upstream:** https://github.com/Barresider/x-mcp
**Patch date:** 2026-06-05

---

## Patch 1 — Login URL

**File:** `src/behaviors/login.ts`
**Problem:** `twitter.com/i/flow/login` redirects to `x.com` but the redirect chain races React hydration, causing selectors to fail.
**Fix:** Use `x.com/i/flow/login` directly with `waitUntil: "domcontentloaded"` + 4000ms explicit wait.

## Patch 2 — Username selector

**File:** `src/behaviors/login.ts`
**Problem:** `//input[@autocomplete="username"]` no longer matches — X changed the field to `name="username_or_email"` with `autocomplete="username webauthn"`.
**Fix:** `page.fill('input[name="username_or_email"]', user, { timeout: 15000 })`

## Patch 3 — Next/Continue button

**File:** `src/behaviors/login.ts`
**Problem:** X renamed "Next" to "Continue" in some login-flow states. Text-match on "Next" alone fails intermittently.
**Fix:** `page.locator('span:text("Next"), span:text("Continue")').first().click(...)` — tries both.

## Patch 4 — console.log stdio pollution

**File:** `src/behaviors/login.ts`
**Problem:** MCP protocol uses JSON-RPC over stdio. Any `console.log` output on stdout corrupts the message stream, causing the Hermes MCP client to fail parsing server responses.
**Fix:** All `console.log(...)` calls in the login flow changed to `console.error(...)`, which writes to stderr (captured in Hermes logs, not the protocol channel).

## Patch 5 — Auth directory auto-creation

**File:** `src/behaviors/login.ts`
**Problem:** `storageState({ path: authFile })` fails if the parent directory does not exist. No mkdir was present.
**Fix:** Added `fs.mkdirSync(authDir, { recursive: true })` immediately after the `authDir` constant is defined.

---

## Rebuild after editing

```bash
cd ~/.hermes/mcp/x-mcp
npm run build
```

The entry point for the MCP server is `dist/mcp.js`.
