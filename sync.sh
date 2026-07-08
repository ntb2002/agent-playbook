#!/usr/bin/env bash
# Sync the ritual layer from the playbook into an existing venture repo.
# The ritual layer is the set of generic files meant to stay identical across
# ventures: skills, code-review subagent, model policy, and the guard hooks.
# (project-check.sh is customized per project and deliberately NOT synced.)
#
# Usage: ./sync.sh <venture-repo-path>
# Changes land as an ordinary git diff in the venture repo — review, branch, PR.
set -euo pipefail

PLAYBOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
T="$PLAYBOOK_DIR/templates"

[ $# -eq 1 ] || { echo "Usage: $0 <venture-repo-path>"; exit 1; }
TARGET="$1"
[ -d "$TARGET/.git" ] || { echo "Refusing: $TARGET is not a git repo."; exit 1; }

mkdir -p "$TARGET/.agents" "$TARGET/.claude/agents" "$TARGET/.cursor/rules" \
         "$TARGET/.cursor/hooks" "$TARGET/.githooks" "$TARGET/scripts/hooks"

rm -rf "$TARGET/.agents/skills"
cp -R "$T/.agents/skills" "$TARGET/.agents/skills"
ln -sfn ../.agents/skills "$TARGET/.claude/skills"
cp "$T/.claude/agents/code-review.md" "$TARGET/.claude/agents/"
cp "$T/.cursor/rules/model-policy.mdc" "$TARGET/.cursor/rules/"
cp "$T/.cursor/hooks.json" "$TARGET/.cursor/"
cp "$T/.cursor/hooks/commit-guard.sh" "$TARGET/.cursor/hooks/"
cp "$T/.githooks/pre-commit" "$TARGET/.githooks/"
cp "$T/scripts/hooks/secret-scan.sh" "$TARGET/scripts/hooks/"
chmod +x "$TARGET/.githooks/pre-commit" "$TARGET/.cursor/hooks/commit-guard.sh" \
         "$TARGET/scripts/hooks/secret-scan.sh"

echo "Synced ritual layer into $TARGET:"
git -C "$TARGET" status --short -- .agents .claude .cursor .githooks scripts/hooks/secret-scan.sh
echo
echo "Review the diff, then commit on a branch and open a PR (main is sacred)."
