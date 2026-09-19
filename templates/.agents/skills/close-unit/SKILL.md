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
   - `[ARTIFACT]` → confirm the screenshot/recording/log/curl exists and will be **viewable by the reviewer** (see *Evidence placement* below — a broken image is a failed gate item).
   - `[MANUAL]` → confirm the exact steps were performed with the expected result.
   If any item fails, stop and report what's missing — do not mark the unit done.

   **Evidence placement.** PR bodies and tracker issues are *comments*, not repo files: `![](plans/artifacts/x.png)` 404s. On a **private** repo, GitHub's image proxy (Camo) fetches without your login, so `raw.githubusercontent.com` and `blob/…?raw=true` embeds also break; and no token can upload to GitHub's drag-and-drop attachment host — don't spend a turn trying. Two lanes:
   - **Local lane** (you are running on a laptop / Remote Control, e.g. Xcode MCP screenshots): commit the image under `plans/artifacts/<issue-id>-<what>.png` (PNG, keep it small; never video in git). In the PR body **link** — don't `![]`-embed — the SHA-pinned blob URL `https://github.com/<owner>/<repo>/blob/<commit-sha>/plans/artifacts/<file>.png`; it renders for a signed-in reviewer on web and GitHub mobile. Also attach the same file natively to the tracker issue (Linear MCP: `prepare_attachment_upload` → PUT bytes → `create_attachment_from_upload`) — that is what renders inline on the phone. Never paste `uploads.linear.app` signed URLs into GitHub; they expire. Recordings go to the tracker attachment only.
   - **Cloud lane** (Cursor cloud agent): write artifacts to `/opt/cursor/artifacts/` and let Cursor's PR pipeline reference them; they attach to the agent run and, if the repo has *Allow posting artifacts to GitHub* enabled, embed in the PR description via unguessable public URLs. This only works in the body of a PR the cloud agent itself opened — not via `gh pr edit`, not in comments, not on a human-opened PR.
   - **Public repo:** plain `![](https://github.com/<owner>/<repo>/blob/<sha>/plans/artifacts/x.png?raw=true)` embeds work everywhere. Still commit under `plans/artifacts/` and pin the SHA.
2. Update **`docs/status.md`** (one dated line for the unit) and the **`AGENTS.md` landing pad** (advance next-actionable; in continuous mode it points at the tracker view, so usually no change).
3. Phase mode only: if the next unit was a roadmap bullet, expand it into its own gated spec.
4. Log expensive-to-reverse decisions in `DECISIONS.md`.
5. **Continuous mode — keep the repo clean:** the PR body is the durable record, not the plan file. If the unit had a plan file (deep lane), paste the *entire* plan unit (not just the gate) into the PR body, then `git rm plans/features/<issue-id>-<slug>.md` in the same commit. Fast/standard lanes have no plan file — the PR body carries the cause, fix, and gate. `plans/features/` holds only *open* units; the tracker issue + merged PR hold the history. Phase-mode plans under `plans/<phase>/` stay as the historical record.
6. Open the PR (never commit to `main`): ensure work is on its branch (`<phase>/<unit>`, or `<issue-id>-<slug>` for a feature unit); `git add`, commit (concise why-focused message), `git push -u origin HEAD`; `gh pr create` with the body filled from `.github/pull_request_template.md` (plan + gate checklist + evidence). For a feature unit, put **every** bundled issue id in the PR title (e.g. `SP-7 SP-9: …`) so the tracker links and closes all of them on merge. **Stop at the open PR — do not merge.** Return the PR URL.

Report the gate results and the PR URL.
