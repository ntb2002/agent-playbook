#!/usr/bin/env bash
# Scaffold a new project from the agent-playbook templates.
# Usage: ./bootstrap.sh <target-dir> "<Project Name>" "<one-liner>" [--tracker linear|github] [--ios]
#   --tracker  which tracker the repo declares in AGENTS.md (default: linear).
#              linear = ventures (stakeholders beyond you); github = solo tools, MCP servers, open source.
#   --ios      also layer the iOS overlay (.cursor/mcp.json + .mcp.json for Xcode MCP,
#              iOS agent conventions appended to AGENTS.md)
set -euo pipefail

PLAYBOOK_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() { echo "Usage: $0 <target-dir> \"<Project Name>\" \"<one-liner>\" [--tracker linear|github] [--ios]"; exit 1; }
[ $# -lt 3 ] && usage

TARGET="$1"; NAME="$2"; ONELINER="$3"; shift 3
IOS=0; TRACKER="linear"
while [ $# -gt 0 ]; do
  case "$1" in
    --ios) IOS=1 ;;
    --tracker) [ $# -ge 2 ] || usage; TRACKER="$2"; shift ;;
    --tracker=*) TRACKER="${1#--tracker=}" ;;
    *) usage ;;
  esac
  shift
done
case "$TRACKER" in linear|github) ;; *) echo "Unknown tracker: $TRACKER (linear|github)"; usage ;; esac

if [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
  echo "Refusing: $TARGET exists and is not empty."; exit 1
fi

mkdir -p "$TARGET"
cp -R "$PLAYBOOK_DIR/templates/." "$TARGET/"
mv "$TARGET/gitignore" "$TARGET/.gitignore"

if [ "$IOS" -eq 1 ]; then
  cp "$PLAYBOOK_DIR/overlays/ios/.cursor/mcp.json" "$TARGET/.cursor/mcp.json"
  cp "$PLAYBOOK_DIR/overlays/ios/.mcp.json" "$TARGET/.mcp.json"   # Claude Code project scope
  cat "$PLAYBOOK_DIR/overlays/ios/AGENTS-ios.md" >> "$TARGET/AGENTS.md"
fi

# Portable in-place sed (GNU vs BSD/macOS).
sed_inplace() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }
esc() { printf '%s' "$1" | sed -e 's/[&/\]/\\&/g'; }
NAME_E="$(esc "$NAME")"; ONELINER_E="$(esc "$ONELINER")"
case "$TRACKER" in
  linear) TRACKER_LABEL="Linear" ;;
  github) TRACKER_LABEL="GitHub Issues" ;;
esac

while IFS= read -r -d '' f; do
  sed_inplace "s/{{PROJECT_NAME}}/$NAME_E/g; s/{{ONE_LINER}}/$ONELINER_E/g; s/{{TRACKER}}/$TRACKER_LABEL/g" "$f"
done < <(find "$TARGET" -type f \( -name '*.md' -o -name '*.mdc' \) -print0)

chmod +x "$TARGET/.githooks/pre-commit" "$TARGET/scripts/hooks/"*.sh "$TARGET/.cursor/hooks/"*.sh 2>/dev/null || true

cd "$TARGET"
git init -q -b main
git config core.hooksPath .githooks

cat <<EOF

Scaffolded "$NAME" at $TARGET  (tracker: $TRACKER_LABEL)

Next steps:
  1. Fill VISION.md, then AGENTS.md (stack + conventions + landing pad). The landing pad already declares the tracker.
  2. Set up the tracker now — it is the day-one floor, not a launch step (SETUP.md → "Tracker"):
EOF
if [ "$TRACKER" = "linear" ]; then
cat <<EOF
       - Linear team for this venture (one team per venture, subject to plan limits), project for the first body of work,
         GitHub integration on, labels: feature/bug/improvement + model: fast/mid/strong.
       - Linear MCP on every agent surface (Cursor, Claude Code, Cloud Agents MCP set). The issue is the spec; /start-unit stops without it.
       - Paste the team link into the AGENTS.md landing pad.
EOF
else
cat <<EOF
       - Enable Issues on the GitHub repo; labels: accepted (=Backlog), ready (=Todo), feature/bug/improvement, model: fast/mid/strong.
       - Agents read with 'gh issue view <n> --comments'; PRs say 'Closes #n'; branches are <n>-<slug>.
EOF
fi
cat <<EOF
  3. Customize the CI job in .github/workflows/ci.yml and scripts/hooks/project-check.sh for your stack.
  4. The pre-commit hook is already enabled (core.hooksPath = .githooks). Push to GitHub; when the codebase can break,
     add CI + branch protection + push protection (SETUP.md → "GitHub").
  5. Coordinator, automations, and bot reviewer stay OFF. Turn each on only when its trigger fires (SETUP.md → "Earned machinery").
EOF
[ "$IOS" -eq 1 ] && echo "  6. iOS overlay applied: .cursor/mcp.json + .mcp.json + AGENTS.md conventions. Do the per-machine Xcode setup in SETUP.md → 'iOS / Apple projects'."
cat <<EOF

First body of work: create a tracker project, then run /plan <project> — it files session-sized issues (first one or two fully
specified, the rest thin) into Triage. You accept and promote. Then /start-unit <issue-id>.
EOF
