#!/usr/bin/env bash
# Scaffold a new project from the agent-playbook templates.
# Usage: ./bootstrap.sh <target-dir> "<Project Name>" "<one-liner>" [--ios]
#   --ios  also layer the iOS overlay (.cursor/mcp.json for Xcode MCP,
#          iOS agent conventions appended to AGENTS.md)
set -euo pipefail

PLAYBOOK_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() { echo "Usage: $0 <target-dir> \"<Project Name>\" \"<one-liner>\" [--ios]"; exit 1; }
[ $# -lt 3 ] && usage

TARGET="$1"; NAME="$2"; ONELINER="$3"
IOS=0; [ "${4:-}" = "--ios" ] && IOS=1

if [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
  echo "Refusing: $TARGET exists and is not empty."; exit 1
fi

mkdir -p "$TARGET"
cp -R "$PLAYBOOK_DIR/templates/." "$TARGET/"
mv "$TARGET/gitignore" "$TARGET/.gitignore"

if [ "$IOS" -eq 1 ]; then
  cp "$PLAYBOOK_DIR/overlays/ios/.cursor/mcp.json" "$TARGET/.cursor/mcp.json"
  cat "$PLAYBOOK_DIR/overlays/ios/AGENTS-ios.md" >> "$TARGET/AGENTS.md"
fi

# Portable in-place sed (GNU vs BSD/macOS).
sed_inplace() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }
esc() { printf '%s' "$1" | sed -e 's/[&/\]/\\&/g'; }
NAME_E="$(esc "$NAME")"; ONELINER_E="$(esc "$ONELINER")"

while IFS= read -r -d '' f; do
  sed_inplace "s/{{PROJECT_NAME}}/$NAME_E/g; s/{{ONE_LINER}}/$ONELINER_E/g" "$f"
done < <(find "$TARGET" -type f \( -name '*.md' -o -name '*.mdc' \) -print0)

chmod +x "$TARGET/.githooks/pre-commit" "$TARGET/scripts/hooks/"*.sh "$TARGET/.cursor/hooks/"*.sh 2>/dev/null || true

cd "$TARGET"
git init -q -b main
git config core.hooksPath .githooks

cat <<EOF

Scaffolded "$NAME" at $TARGET

Next steps:
  1. Fill VISION.md, then AGENTS.md (stack + conventions + landing pad).
  2. Customize the CI job in .github/workflows/ci.yml and scripts/hooks/project-check.sh for your stack.
  3. Work the maturity ladder — see SETUP.md (branch protection, Slack/GitHub-mobile, cloud-agent bootstrap).
  4. The pre-commit hook is already enabled (core.hooksPath = .githooks).
$( [ "$IOS" -eq 1 ] && echo "  5. iOS overlay applied: .cursor/mcp.json + AGENTS.md conventions. Do the per-machine Xcode setup in SETUP.md → 'iOS / Apple projects'." )

Match ceremony to maturity: an idea-stage project may only need VISION.md + a rough phase sketch.
EOF
