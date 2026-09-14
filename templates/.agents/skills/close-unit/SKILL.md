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
2. Update **`docs/status.md`** (check off the unit) and the **`AGENTS.md` landing pad** (advance next-actionable).
3. If the next unit was a roadmap bullet, expand it into its own gated spec.
4. Log expensive-to-reverse decisions in `DECISIONS.md`.
5. Open the PR (never commit to `main`): ensure work is on its branch (`<phase>/<unit>`, or `<issue-id>-<slug>` for a feature unit); `git add`, commit (concise why-focused message), `git push -u origin HEAD`; `gh pr create` with the body filled from `.github/pull_request_template.md` (paste the gate checklist + evidence). For a feature unit, put the issue id in the PR title (e.g. `SS-42: …`) so the tracker links it and closes the issue on merge. **Stop at the open PR — do not merge.** Return the PR URL.

Report the gate results and the PR URL.
