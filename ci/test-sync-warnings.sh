#!/usr/bin/env bash
# Proves sync.sh warns on missing AGENTS.md sections and stale venture-owned refs.
set -euo pipefail

playbook_root="$(cd "$(dirname "$0")/.." && pwd)"
sync="$playbook_root/sync.sh"

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

init_venture() {
  local dir="$1"
  mkdir -p "$dir"
  cd "$dir"
  git init -q
  git config user.email "ci@test"
  git config user.name "CI"
}

# --- Dirty fixture: missing section + stale ritual name ---
dirty="$scratch/dirty"
init_venture "$dirty"
cp "$playbook_root/templates/AGENTS.md" "$dirty/AGENTS.md"
# Drop a section skills point at (keep the next ## heading).
sed -i '/^## Autonomy inside the box$/,/^## Quick reference$/{
  /^## Quick reference$/!d
}' "$dirty/AGENTS.md"
mkdir -p "$dirty/plans"
printf '%s\n' '# Plans' 'Use /plan-phase when decomposing.' >"$dirty/plans/README.md"
git -C "$dirty" add AGENTS.md plans/README.md
git -C "$dirty" commit -q -m "stale venture fixtures"

dirty_out="$(bash "$sync" "$dirty" 2>&1)" || true
echo "$dirty_out" | grep -q 'WARNING: template AGENTS.md sections missing' || {
  echo "expected missing-section WARNING"; echo "$dirty_out"; exit 1
}
echo "$dirty_out" | grep -q 'Autonomy inside the box' || {
  echo "expected Autonomy inside the box in missing list"; echo "$dirty_out"; exit 1
}
echo "$dirty_out" | grep -q 'WARNING: stale template references' || {
  echo "expected stale-ref WARNING"; echo "$dirty_out"; exit 1
}
echo "$dirty_out" | grep -q 'plans/README.md:.*plan-phase' || {
  echo "expected plans/README.md:line for /plan-phase"; echo "$dirty_out"; exit 1
}

# --- Clean fixture: template AGENTS + no stale strings ---
clean="$scratch/clean"
"$playbook_root/bootstrap.sh" "$clean" "Sync Warn CI" "fixture" --tracker github >/dev/null
git -C "$clean" add -A
git -C "$clean" commit -q -m "bootstrap" || true

clean_out="$(bash "$sync" "$clean" 2>&1)"
if echo "$clean_out" | grep -q 'WARNING: template AGENTS.md sections missing'; then
  echo "clean fixture should not warn on missing sections"; echo "$clean_out"; exit 1
fi
if echo "$clean_out" | grep -q 'WARNING: stale template references'; then
  echo "clean fixture should not warn on stale refs"; echo "$clean_out"; exit 1
fi

echo "sync-warnings: ok (dirty warns, clean quiet)"
