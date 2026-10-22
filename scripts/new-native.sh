#!/usr/bin/env bash
# Create a new Expo (React Native) VTC app under ~/native.
#
# Usage:  ~/cursor_rules/scripts/new-native.sh
#         Opens the new project in Cursor and drops you into that folder.
# Override: NATIVE_ROOT=~/projects ~/cursor_rules/scripts/new-native.sh
#
# This is the native lane (Memory-class). Default new apps are still web:
#   ~/cursor_rules/scripts/new.sh  → Vite / Next.js under ~/apps.
#
# Factory contract (apk-factory build_type=native):
#   - git branch beta
#   - expo.android.package = com.vtc.{code}
#   - versionCode in app.json is a floor; factory increments on each Store APK build
#   - env_development copied to .env on the build server
#   - no committed android/ or signing config

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NATIVE_ROOT="${NATIVE_ROOT:-$HOME/native}"
CURSOR_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
STUB_SRC="$CURSOR_REPO/stubs/vtc-central.mdc"
CENTRAL_RULES="$CURSOR_REPO/rules"

mkdir -p "$NATIVE_ROOT"

echo "VTC Expo native app setup"
echo "  Native root:     $NATIVE_ROOT"
echo "  Rules stub:      $STUB_SRC"
echo "  Central rules:   $CENTRAL_RULES"
echo ""

if [ ! -f "$STUB_SRC" ]; then
  echo "Error: stub not found at $STUB_SRC" >&2
  exit 1
fi
if [ ! -d "$CENTRAL_RULES" ]; then
  echo "Error: central rules not found at $CENTRAL_RULES" >&2
  exit 1
fi

read -r -p "New folder / module code (under $NATIVE_ROOT): " NAME

if [ -z "${NAME// }" ]; then
  echo "Error: name cannot be empty." >&2
  exit 1
fi

if ! [[ "$NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
  echo "Error: use a letter first, then letters, numbers, hyphens, or underscores only." >&2
  exit 1
fi

APP_DIR="$NATIVE_ROOT/$NAME"

if [ -e "$APP_DIR" ]; then
  echo "Error: already exists: $APP_DIR" >&2
  exit 1
fi

CODE="$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]' | tr -d '_-' )"
if [ -z "$CODE" ]; then
  echo "Error: module code collapsed to empty after sanitizing." >&2
  exit 1
fi
PACKAGE_ID="com.vtc.${CODE}"

read -r -p "Display name [${NAME}]: " DISPLAY_IN
DISPLAY_NAME="${DISPLAY_IN:-$NAME}"

SCHEME="$(printf '%s' "$CODE" | tr -cd 'a-z0-9' | cut -c1-20)"
SCHEME="${SCHEME:-vtcapp}"

mkdir -p "$APP_DIR/app" "$APP_DIR/assets" "$APP_DIR/lib"

"$SCRIPT_DIR/push-stub.sh" "$APP_DIR"

cat > "$APP_DIR/.gitignore" <<'GITIGNORE'
node_modules/
.expo/
dist/
web-build/
.env
.env.local
.env.development
android/
ios/
.cursor/
npm-debug.log*
.DS_Store
*.jks
*.p8
*.p12
*.key
*.mobileprovision
*.orig.*
web-build/
GITIGNORE

cat > "$APP_DIR/.npmrc" <<'NPMRC'
registry=https://npm.vtc.com/
@vtc:registry=https://npm.vtc.com/
NPMRC

cat > "$APP_DIR/package.json" <<PKG
{
  "name": "${NAME}",
  "main": "expo-router/entry",
  "version": "0.1.0",
  "private": true,
  "engines": {
    "node": ">=22 <23"
  },
  "scripts": {
    "start": "expo start",
    "android": "expo run:android",
    "ios": "expo run:ios"
  },
  "dependencies": {
    "expo": "~57.0.22",
    "expo-constants": "~57.0.18",
    "expo-linking": "~57.0.10",
    "expo-router": "~57.0.21",
    "expo-status-bar": "~57.0.1",
    "expo-file-system": "~57.0.7",
    "expo-linking": "~57.0.10",
    "expo-secure-store": "~57.0.4",
    "@vtc/native": "^0.1.0",
    "react": "19.2.3",
    "react-native": "0.86.3",
    "react-native-safe-area-context": "~5.7.0",
    "react-native-screens": "~4.26.0"
  },
  "devDependencies": {
    "@types/react": "~19.2.2",
    "typescript": "~5.9.0"
  }
}
PKG

# react-native 19.1.0 is wrong - Memory uses 0.86.3. Fix that.
# I'll correct in a follow-up replace. Writing app.json etc.

cat > "$APP_DIR/app.json" <<JSON
{
  "expo": {
    "name": "${DISPLAY_NAME}",
    "slug": "${NAME}",
    "version": "0.1.0",
    "orientation": "portrait",
    "scheme": "vtc${SCHEME}",
    "userInterfaceStyle": "automatic",
    "android": {
      "package": "${PACKAGE_ID}",
      "versionCode": 1,
      "adaptiveIcon": {
        "backgroundColor": "#004A80"
      }
    },
    "ios": {
      "bundleIdentifier": "${PACKAGE_ID}",
      "supportsTablet": true
    },
    "plugins": [
      "expo-router",
      "@vtc/native"
    ]
  }
}
JSON

cat > "$APP_DIR/tsconfig.json" <<'TSCONFIG'
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true
  },
  "include": [
    "**/*.ts",
    "**/*.tsx",
    ".expo/types/**/*.ts",
    "expo-env.d.ts"
  ]
}
TSCONFIG

cat > "$APP_DIR/lib/vtc.ts" <<VTC
import { configure } from '@vtc/native';

configure({
  apiUrl: process.env.EXPO_PUBLIC_VTC_API_URL || 'https://api.vtc.com',
  appCode: '${CODE}',
  androidPackage: '${PACKAGE_ID}',
});
VTC

cat > "$APP_DIR/app/_layout.tsx" <<'LAYOUT'
import { useEffect, useState } from 'react';
import { Stack } from 'expo-router';
import { bootstrapSession, openStoreLogin } from '@vtc/native';
import '../lib/vtc';

export default function RootLayout() {
  const [ready, setReady] = useState(false);
  useEffect(() => {
    bootstrapSession().then((session) => {
      if (!session) void openStoreLogin();
      setReady(true);
    });
  }, []);
  if (!ready) return null;
  return <Stack screenOptions={{ headerShown: false }} />;
}
LAYOUT

cat > "$APP_DIR/app/index.tsx" <<INDEX
import { StyleSheet, Text, View } from 'react-native';

export default function HomeScreen() {
  return (
    <View style={styles.wrap}>
      <Text style={styles.title}>${DISPLAY_NAME}</Text>
      <Text style={styles.body}>
        Scaffold from ~/cursor_rules/scripts/new-native.sh. Follow
        scaffold-checklist-native.mdc. Auth comes from VTC App Store — do not
        add in-app OTP.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    flex: 1,
    justifyContent: 'center',
    padding: 24,
    backgroundColor: '#0b1220',
  },
  title: {
    color: '#e8eef8',
    fontSize: 28,
    fontWeight: '600',
    marginBottom: 12,
  },
  body: {
    color: '#9fb0c8',
    fontSize: 16,
    lineHeight: 22,
  },
});
INDEX

cat > "$APP_DIR/env_development" <<ENV
# Copied to .env by apk-factory before the JS bundle is built.
# Do not put signing secrets here.

EXPO_PUBLIC_VTC_API_URL=https://api.vtc.com
EXPO_PUBLIC_APP_NAME=${DISPLAY_NAME}
EXPO_PUBLIC_APP_CODE=${CODE}
EXPO_PUBLIC_ANDROID_PACKAGE=${PACKAGE_ID}
ENV

cat > "$APP_DIR/README.md" <<README
# ${DISPLAY_NAME}

VTC **Expo / React Native** app. Distributed via VTC App Store (\`store.vtc.com\`), not \`*.apps.vtc.com\`.

- Package: \`${PACKAGE_ID}\`
- Module code: \`${CODE}\`
- Rules: \`~/cursor_rules/rules/scaffold-checklist-native.mdc\`

## Local

\`\`\`bash
npm install
npx expo start
\`\`\`

Sign in with VTC App Store on the device/emulator. Do not add OTP on this landing screen.

## Release

1. Bump \`expo.android.versionCode\` in \`app.json\`.
2. Push branch \`beta\` to \`git.vtc.com/zeresoft/${NAME}\`.
3. Enqueue \`POST https://store.vtc.com/api/build/android\` with \`build_type: native\` and \`module_code: ${CODE}\`.

Identity is repo-owned. The factory signs with the platform keystore.
README

git -C "$APP_DIR" init -b beta >/dev/null
git -C "$APP_DIR" add .gitignore .npmrc package.json app.json tsconfig.json app lib README.md env_development
if git -C "$APP_DIR" commit -m "init: $NAME (expo native)" >/dev/null 2>&1; then
  GIT_NOTE="initial commit on beta"
else
  GIT_NOTE="init only (set git user.name / user.email to commit)"
fi

echo ""
echo "Created: $APP_DIR"
echo "Package: $PACKAGE_ID"
echo "Rules:   $APP_DIR/.cursor/rules/00-vtc-central.mdc"
echo "Git:     branch beta — $GIT_NOTE"
echo ""

if command -v cursor >/dev/null 2>&1; then
  echo "Opening in Cursor..."
  cursor "$APP_DIR"
fi

echo "Next steps:"
echo "  1. npm install && npx expo start"
echo "  2. Scaffold per ~/cursor_rules/rules/scaffold-checklist-native.mdc"
echo "  3. Create the Store catalog row in VTC (Android / VTC Store app type)"
echo "  4. git remote add origin https://git.vtc.com/zeresoft/${NAME}.git && git push -u origin beta"

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  cd "$APP_DIR" || exit 1
elif [[ -t 0 && -t 1 ]]; then
  echo ""
  echo "Ready in: $APP_DIR"
  cd "$APP_DIR" || exit 1
  exec "${SHELL:-/bin/bash}"
else
  echo ""
  echo "  cd $APP_DIR"
fi
