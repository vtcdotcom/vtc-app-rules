#!/usr/bin/env bash
# Public vtc-app-rules pack only. External developers have no ~/cursor_rules.
# Local apps use the stub: ~/cursor_rules/scripts/add.sh <parent>
#
# Usage (public repo):
#   ~/vtc-app-rules/scripts/copy-cursor-rules.sh /path/to/your-app
#
# Re-run safe: refreshes all rule files and removes stale copies.
# Compares RULE-PACK-VERSION before/after so you can see if an app is current.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_REPO="${CURSOR_REPO:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CURSOR_RULES="${CURSOR_RULES:-$CURSOR_REPO/rules}"
RULE_PACK_VERSION_FILE="RULE-PACK-VERSION"

read_rule_pack_version() {
	local rules_dir="$1"
	local version_file="$rules_dir/$RULE_PACK_VERSION_FILE"

	if [[ ! -f "$version_file" ]]; then
		echo "(none)"
		return 0
	fi

	local line
	line="$(grep -m1 '^Rule pack version:' "$version_file" 2>/dev/null || true)"
	if [[ -z "$line" ]]; then
		echo "(unknown)"
		return 0
	fi

	echo "${line#Rule pack version:}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

copy_cursor_rules() {
	local target="$1"
	local old_ver new_ver

	if [[ ! -d "$target" ]]; then
		echo "ERROR: not a directory: $target" >&2
		return 1
	fi
	if [[ ! -d "$CURSOR_RULES" ]]; then
		echo "ERROR: rules directory not found: $CURSOR_RULES" >&2
		return 1
	fi
	if [[ ! -f "$CURSOR_RULES/$RULE_PACK_VERSION_FILE" ]]; then
		echo "ERROR: missing $CURSOR_RULES/$RULE_PACK_VERSION_FILE — add a rule pack version first." >&2
		return 1
	fi

	target="$(cd "$target" && pwd)"
	new_ver="$(read_rule_pack_version "$CURSOR_RULES")"
	old_ver="$(read_rule_pack_version "$target/.cursor/rules")"

	# Legacy: whole .cursor was a symlink to the cursor repo
	if [[ -L "$target/.cursor" ]]; then
		rm "$target/.cursor"
	fi

	mkdir -p "$target/.cursor"

	# Replace symlinked rules dir with a real copy
	if [[ -L "$target/.cursor/rules" ]]; then
		rm "$target/.cursor/rules"
	fi

	mkdir -p "$target/.cursor/rules"

	if command -v rsync >/dev/null 2>&1; then
		rsync -a --delete "$CURSOR_RULES/" "$target/.cursor/rules/"
	else
		find "$target/.cursor/rules" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
		cp -a "$CURSOR_RULES/." "$target/.cursor/rules/"
	fi

	if [[ "$old_ver" == "$new_ver" ]]; then
		echo "Rules up to date ($new_ver): $target"
	else
		echo "Rules updated ($old_ver → $new_ver): $target"
	fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	TARGET="${1:-}"
	if [[ -z "$TARGET" ]]; then
		echo "Usage: $(basename "$0") <project-dir>" >&2
		exit 1
	fi
	copy_cursor_rules "$(cd "$TARGET" && pwd)"
fi
