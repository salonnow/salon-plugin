#!/usr/bin/env bash
# Build the OpenAI plugin ZIP: this folder's manifest, MCP config and assets, plus the ONE
# skill set that lives at the repo root (skills/), so the skill is never maintained twice.
#
# Usage: openai/build-zip.sh            → dist/salon-openai-<version>.zip
#
# Refuses when the Claude manifest (.claude-plugin/plugin.json) and the OpenAI manifest
# (openai/plugin.json) disagree on the version: one public version, bumped together with the
# connector's CONNECTOR_VERSION. Reviewer credentials never go in the ZIP (OpenAI rejects
# test_credentials and reviewer_instructions there); they are typed in the dashboard.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
openai_dir="$repo/openai"
dist="$repo/dist"

read_version() {
  python3 -I -c 'import json, sys; print(json.load(open(sys.argv[1]))["version"])' "$1"
}

claude_version="$(read_version "$repo/.claude-plugin/plugin.json")"
openai_version="$(read_version "$openai_dir/plugin.json")"
if [ "$claude_version" != "$openai_version" ]; then
  echo "build-zip: version mismatch — .claude-plugin/plugin.json says $claude_version, openai/plugin.json says $openai_version" >&2
  echo "build-zip: bump both (and CONNECTOR_VERSION in salon-mcp) together, then retry" >&2
  exit 2
fi

# Every path the manifest references must exist in the archive.
for asset in "$openai_dir/assets/logo.png" "$openai_dir/assets/icon.png"; do
  [ -f "$asset" ] || { echo "build-zip: missing $asset" >&2; exit 2; }
done
[ -f "$repo/skills/salon-operations/SKILL.md" ] || { echo "build-zip: missing root skills/salon-operations/SKILL.md" >&2; exit 2; }
# The archive declares Apache-2.0 and carries the skill, so the licence text and the trademark
# notice travel with it (NOTICE: SALON and SALON NOW are not licensed with the plugin).
for legal in "$repo/LICENSE" "$repo/NOTICE"; do
  [ -f "$legal" ] || { echo "build-zip: missing $legal" >&2; exit 2; }
done

if ! python3 -I -c 'import json, sys; d = json.load(open(sys.argv[1])); sys.exit(0 if d["extensions"]["com.openai"]["review"].get("demo_recording_url") else 1)' "$openai_dir/plugin.json"; then
  echo "build-zip: note — review.demo_recording_url is not set; OpenAI requires it before submitting for review (the dashboard can also take it)" >&2
fi

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
cp "$openai_dir/plugin.json" "$openai_dir/mcp.json" "$repo/LICENSE" "$repo/NOTICE" "$stage/"
cp -R "$openai_dir/assets" "$stage/assets"
cp -R "$repo/skills" "$stage/skills"
find "$stage" -name '.DS_Store' -delete

mkdir -p "$dist"
out="$dist/salon-openai-$openai_version.zip"
rm -f "$out"
( cd "$stage" && zip -q -r -X "$out" plugin.json mcp.json LICENSE NOTICE assets skills )

# Read the listing once: under pipefail, `unzip | grep -q` fails on grep's early exit (SIGPIPE).
entries="$(unzip -Z1 "$out")"
for required in plugin.json mcp.json LICENSE NOTICE assets/logo.png assets/icon.png skills/salon-operations/SKILL.md; do
  grep -qx "$required" <<< "$entries" || { echo "build-zip: $required missing from the archive" >&2; exit 2; }
done

echo "build-zip: $out"
unzip -l "$out"
