#!/usr/bin/env bash
# Sync the ritual layer from the playbook into an existing venture repo.
# The ritual layer is the set of generic files meant to stay identical across
# ventures: skills, code-review subagent, model policy, automation prompts, and
# the guard hooks. (project-check.sh and docs/coordinator.md are customized per
# project: seeded if missing, never overwritten.)
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
         "$TARGET/.cursor/hooks" "$TARGET/.cursor/automations" "$TARGET/.githooks" \
         "$TARGET/scripts/hooks" "$TARGET/docs"

rm -rf "$TARGET/.agents/skills"
cp -R "$T/.agents/skills" "$TARGET/.agents/skills"
ln -sfn ../.agents/skills "$TARGET/.claude/skills"
cp "$T/.claude/agents/code-review.md" "$TARGET/.claude/agents/"
cp "$T/.cursor/rules/model-policy.mdc" "$TARGET/.cursor/rules/"
cp "$T/.cursor/hooks.json" "$TARGET/.cursor/"
cp "$T/.cursor/hooks/commit-guard.sh" "$TARGET/.cursor/hooks/"
cp "$T/.cursor/automations/"*.md "$TARGET/.cursor/automations/"
cp "$T/.githooks/pre-commit" "$TARGET/.githooks/"
cp "$T/scripts/hooks/secret-scan.sh" "$TARGET/scripts/hooks/"
chmod +x "$TARGET/.githooks/pre-commit" "$TARGET/.cursor/hooks/commit-guard.sh" \
         "$TARGET/scripts/hooks/secret-scan.sh"

# pre-commit requires project-check.sh; seed the template stub if the repo
# doesn't have one (never overwrite — it's customized per project).
if [ ! -f "$TARGET/scripts/hooks/project-check.sh" ]; then
  cp "$T/scripts/hooks/project-check.sh" "$TARGET/scripts/hooks/"
  chmod +x "$TARGET/scripts/hooks/project-check.sh"
  echo "NOTE: seeded scripts/hooks/project-check.sh from the template — customize it for this stack."
fi

# Coordinator brief: seed if missing (it carries per-project delegated-approval
# rules once in use, so never overwrite). Fill {{PROJECT_NAME}}/{{ONE_LINER}}
# from the repo's AGENTS.md by hand.
if [ ! -f "$TARGET/docs/coordinator.md" ]; then
  cp "$T/docs/coordinator.md" "$TARGET/docs/"
  echo "NOTE: seeded docs/coordinator.md — replace the {{PLACEHOLDERS}} and point your Cursor Project at it."
fi

# Drop legacy copies of the rituals from the pre-skills era (now in .agents/skills/).
for cmd in plan-phase start-unit close-unit context-sync; do
  rm -f "$TARGET/.claude/commands/$cmd.md"
done
rmdir "$TARGET/.claude/commands" 2>/dev/null || true

echo "Synced ritual layer into $TARGET:"
git -C "$TARGET" status --short -- .agents .claude .cursor .githooks scripts/hooks/secret-scan.sh docs/coordinator.md
echo
echo "Review the diff, then commit on a branch and open a PR (main is sacred)."
