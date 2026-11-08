#!/usr/bin/env bash
# Proves templates/.cursor/hooks/commit-guard.sh resolves the repo root and blocks staged secrets.
set -euo pipefail

playbook_root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

cp -R "$playbook_root/templates/." "$tmp/"
cd "$tmp"
git init -q
git config user.email "ci@test"
git config user.name "CI"
git config core.hooksPath .githooks

repo_root="$(cd "$tmp" && git rev-parse --show-toplevel)"
scanner="$repo_root/scripts/hooks/secret-scan.sh"
[ -x "$scanner" ] || { echo "missing scanner at $scanner"; exit 1; }

printf '%s\n' 'sk-ant-abcdefghijklmnopqrstuvwxyz1234567890' > leak.txt
git add leak.txt

# Guard must find the scanner (not under .cursor/scripts/...) and deny.
out="$(bash "$repo_root/.cursor/hooks/commit-guard.sh" 2>&1)"
echo "$out" | grep -q '"permission":"deny"' || {
  echo "commit-guard did not deny; output:"
  echo "$out"
  exit 1
}
echo "$out" | grep -q 'sk-ant-' || {
  echo "commit-guard deny output missing secret-scan detail"
  exit 1
}

# Pre-commit hook uses the same scanner path.
if .githooks/pre-commit 2>&1; then
  echo "pre-commit should have blocked staged secret"
  exit 1
fi

echo "commit-guard: ok (scanner found, staged secret blocked)"
