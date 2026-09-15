---
name: close-unit
description: Verify a plan unit's gate, sync docs, and open the PR
disable-model-invocation: true
allowed-tools: Read, Edit, Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git checkout:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*)
---

# /close-unit $ARGUMENTS

Close out the plan unit `$ARGUMENTS` only after its gate is fully met.

1. Walk the unit's **verification gate**. For each item confirm evidence exists:
   - `[CI]` → run lint/tests now and capture output.
   - `[ARTIFACT]` → confirm the screenshot/recording/log/curl is ready to attach.
   - `[MANUAL]` → confirm the exact steps were performed with the expected result.
   If any item fails, stop and report what's missing — do not mark the unit done.
2. Update **`docs/status.md`** (one dated line for the unit) and the **`AGENTS.md` landing pad** (advance next-actionable; in continuous mode it points at the tracker view, so usually no change).
3. Phase mode only: if the next unit was a roadmap bullet, expand it into its own gated spec.
4. Log expensive-to-reverse decisions in `DECISIONS.md`.
5. **Continuous mode — keep the repo clean:** the PR body is the durable record, not the plan file. Paste the *entire* plan unit (not just the gate) into the PR body, then `git rm plans/features/<issue-id>-<slug>.md` in the same commit. `plans/features/` holds only *open* units; the tracker issue + merged PR hold the history. Phase-mode plans under `plans/<phase>/` stay as the historical record.
6. Open the PR (never commit to `main`): ensure work is on its branch (`<phase>/<unit>`, or `<issue-id>-<slug>` for a feature unit); `git add`, commit (concise why-focused message), `git push -u origin HEAD`; `gh pr create` with the body filled from `.github/pull_request_template.md` (plan + gate checklist + evidence). For a feature unit, put **every** bundled issue id in the PR title (e.g. `SP-7 SP-9: …`) so the tracker links and closes all of them on merge. **Stop at the open PR — do not merge.** Return the PR URL.

Report the gate results and the PR URL.
