#!/usr/bin/env bash
# Sync the ritual layer from the playbook into an existing venture repo.
# The ritual layer is the set of generic files meant to stay identical across
# ventures: skills, code-review subagent, model policy, automation prompts, and
# the guard hooks. (project-check.sh and docs/coordinator.md are customized per
# project: seeded if missing, never overwritten.)
#
# Usage: ./sync.sh <venture-repo-path>
# Changes land as an ordinary git diff in the venture repo — review, branch, PR.
# After copying, warns (does not fail) when venture AGENTS.md lacks template sections
# or venture-owned docs hit templates/sync-stale-patterns.txt — see CHANGELOG 2026-11-04.
set -euo pipefail

PLAYBOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
T="$PLAYBOOK_DIR/templates"

[ $# -eq 1 ] || { echo "Usage: $0 <venture-repo-path>"; exit 1; }
TARGET="$1"
git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Refusing: $TARGET is not a git repo."; exit 1; }

mkdir -p "$TARGET/.agents" "$TARGET/.claude/agents" "$TARGET/.cursor/rules" \
         "$TARGET/.cursor/hooks" "$TARGET/.cursor/automations" "$TARGET/.githooks" \
         "$TARGET/scripts/hooks" "$TARGET/docs"

rm -rf "$TARGET/.agents/skills"
cp -R "$T/.agents/skills" "$TARGET/.agents/skills"
ln -sfn ../.agents/skills "$TARGET/.claude/skills"
cp "$T/.claude/agents/"*.md "$TARGET/.claude/agents/"
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

# Claude Code permissions: seed if missing, never overwrite. The deny list
# grows per repo (verifier paths) and allow carries the repo's own commands.
if [ ! -f "$TARGET/.claude/settings.json" ]; then
  cp "$T/.claude/settings.json" "$TARGET/.claude/"
  echo "NOTE: seeded .claude/settings.json — add this repo's test/build commands to allow and verifier paths to deny."
fi

# Drop legacy copies of the rituals from the pre-skills era (now in .agents/skills/).
# (.agents/skills is replaced wholesale above, so the retired /plan-phase and
# /plan-feature stubs disappear from a venture on its next sync.)
for cmd in plan-phase plan-feature start-unit close-unit context-sync; do
  rm -f "$TARGET/.claude/commands/$cmd.md"
done
rmdir "$TARGET/.claude/commands" 2>/dev/null || true

# A synced file the venture's .gitignore swallows would silently never be
# committed (e.g. a generic `build/` rule hiding .agents/skills/build/).
ignored="$(cd "$TARGET" && find .agents .claude/agents .claude/settings.json .cursor .githooks scripts/hooks -type f 2>/dev/null | git check-ignore --stdin || true)"
if [ -n "$ignored" ]; then
  echo "WARNING: these synced files are gitignored in $TARGET and would never be committed:"
  printf '  %s\n' $ignored
  echo "Add a negation to its .gitignore (template: !/.agents/skills/build/)."
fi

# --- Venture-owned docs: warn only (sync still succeeds) ---
# Missing sections: compare template AGENTS.md ## headings to the venture copy.
# Headings match after stripping a leading non-alphanumeric prefix (emoji etc.).
# Stale refs: fixed strings in templates/sync-stale-patterns.txt; see that file.
normalize_agents_heading() {
  sed -E 's/^##[[:space:]]+//' | sed -E 's/^[^[:alnum:]]+[[:space:]]*//'
}

template_agents="$T/AGENTS.md"
venture_agents="$TARGET/AGENTS.md"
missing_sections=()
while IFS= read -r heading; do
  [ -n "$heading" ] || continue
  key="$(printf '%s' "$heading" | normalize_agents_heading)"
  [ -n "$key" ] || continue
  missing_sections+=("$key")
done < <(grep '^## ' "$template_agents" || true)

if [ -f "$venture_agents" ]; then
  venture_keys="$(mktemp)"
  grep '^## ' "$venture_agents" 2>/dev/null | normalize_agents_heading | sort -u >"$venture_keys" || true
  still_missing=()
  for key in "${missing_sections[@]}"; do
    if ! grep -qxF "$key" "$venture_keys" 2>/dev/null; then
      still_missing+=("$key")
    fi
  done
  rm -f "$venture_keys"
  if [ "${#still_missing[@]}" -gt 0 ]; then
    echo "WARNING: template AGENTS.md sections missing from $TARGET/AGENTS.md:"
    printf '  %s\n' "${still_missing[@]}"
    echo "Add or merge these by hand — skills may point at them."
  fi
else
  echo "WARNING: no AGENTS.md in $TARGET — template defines these sections to mirror:"
  printf '  %s\n' "${missing_sections[@]}"
fi

stale_patterns_file="$T/sync-stale-patterns.txt"
owned_rels=()
for rel in AGENTS.md CLAUDE.md VISION.md DECISIONS.md SETUP.md \
           docs/coordinator.md docs/git-workflow.md docs/status.md plans/README.md; do
  [ -f "$TARGET/$rel" ] && owned_rels+=("$rel")
done

stale_hits=()
if [ -f "$stale_patterns_file" ] && [ "${#owned_rels[@]}" -gt 0 ]; then
  while IFS= read -r pattern || [ -n "${pattern:-}" ]; do
    pattern="${pattern%%$'\r'}"
    case "$pattern" in
      ''|'#'*) continue ;;
    esac
    while IFS= read -r hit; do
      [ -n "$hit" ] || continue
      stale_hits+=("$hit")
    done < <(cd "$TARGET" && grep -rnF "$pattern" "${owned_rels[@]}" 2>/dev/null || true)
  done <"$stale_patterns_file"
fi

if [ "${#stale_hits[@]}" -gt 0 ]; then
  echo "WARNING: stale template references in venture-owned docs (hand-edit after sync):"
  # file:line:matched line (dedupe while keeping order)
  seen=()
  for rel in "${stale_hits[@]}"; do
    skip=0
    for s in "${seen[@]:-}"; do
      [ "$s" = "$rel" ] && skip=1 && break
    done
    [ "$skip" -eq 1 ] && continue
    seen+=("$rel")
    printf '  %s\n' "$rel"
  done
  echo "Patterns live in templates/sync-stale-patterns.txt — update after template drift."
fi

echo "Synced ritual layer into $TARGET:"
git -C "$TARGET" status --short -- .agents .claude .cursor .githooks scripts/hooks/secret-scan.sh docs/coordinator.md
echo
echo "Review the diff, then commit on a branch and open a PR (main is sacred)."
