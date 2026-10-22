# VTC app development with Cursor

Guide for external developers using this public rule pack.

## One-time setup

1. **Clone the rules** (pick SSH or HTTPS):

   ```bash
   git clone https://github.com/vtcdotcom/vtc-app-rules.git ~/vtc-app-rules
   ```

2. **Create or open your app repo** in its own folder (not a parent folder with many sibling apps).

3. **Copy rules into the app**:

   ```bash
   ~/vtc-app-rules/scripts/copy-cursor-rules.sh ~/projects/my-app
   ```

4. **Open the app folder in Cursor** — workspace root must be the app directory.

5. **Register on the private npm registry** (required before first `npm install` on any app using `@vtc/*`):

   ```bash
   npm adduser --registry https://npm.vtc.com
   ```

   Pick your own username and password. Credentials are stored in `~/.npmrc`. Do **not** use the shared `vtc-ci` account — that is for the build server only.

   If you already have an account:

   ```bash
   npm login --registry https://npm.vtc.com
   ```

   Then in the app: `npm install`. See `rules/vtc-packages.mdc` for `.npmrc` and package details.

## Start a new app

```bash
APPS_ROOT=~/projects ~/vtc-app-rules/scripts/new.sh
```

Expo / React Native (VTC Store only — not shown in the VTC shell catalog):

```bash
NATIVE_ROOT=~/projects ~/vtc-app-rules/scripts/new-native.sh
```

Then in Cursor chat, for example:

> Scaffold per `scaffold-checklist.mdc` — Shared app, primary screen is a task list for …

Read `rules/BUILD-CHECKLIST.md` for the human checklist.

## Choosing Shared vs Dedicated

| Need | Type |
|------|------|
| Each space has its own data (CRM, bookings, inventory) | **Shared** — see `app-types.mdc` |
| Same publisher data for all spaces (catalog, price list) | **Dedicated** |

## Refresh when rules update

```bash
git -C ~/vtc-app-rules pull
~/vtc-app-rules/scripts/check-rule-pack.sh ~/projects/my-app
~/vtc-app-rules/scripts/copy-cursor-rules.sh ~/projects/my-app
```

Compare version in `~/vtc-app-rules/rules/RULE-PACK-VERSION` with your app’s `.cursor/rules/RULE-PACK-VERSION`.

## Do not

- **Symlink** `.cursor/rules` — breaks Next.js dev on Linux (EMFILE). Always copy.
- **Commit** `.cursor/` into your app git repo — rules are local dev tooling.
- **Copy patterns** from random apps on the platform — implement from `.cursor/rules/` only (`core.mdc`).
- **Open Cursor** at a parent suite folder with dozens of sibling apps.

## Runtime names (unchanged on purpose)

These still use legacy `posif` identifiers in code and env — do not rename in your app unless the platform ships a migration:

| Item | Name |
|------|------|
| npm SDK | `@vtc/sdk` from `https://npm.vtc.com` — register with `npm adduser --registry https://npm.vtc.com` before install (`vtc-packages.mdc`) |
| Legacy API env | `POSIF_API_URL` (injected alongside `VTC_API_URL`) |
| App localStorage | `posif_token`, `posif_user`, `posif_group` |

## Production URLs

- **Publisher child apps** (typical apps you build and publish): `https://{appshortname}.apps.vtc.com`
- **Platform / network apps** on bare subdomains (internal examples: `maps.vtc.com`, `app.vtc.com`): `https://{name}.vtc.com` — not the publisher lane
- API: `https://api.vtc.com` via injected `VTC_API_URL` — do not commit in `.env.production`
- Deploy: push to your app git remote — publisher apps auto-deploy at `{appshortname}.apps.vtc.com` (`deployment.mdc`)

## Help

Platform hostname map: https://vtc.com/developers.  
AI routing index: `rules/README.md`.
