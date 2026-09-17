# Plans

> The durable home for active work plans. **In-repo on purpose** so plans travel with every clone, device, and cloud agent. Cursor's `.plan.md` and Claude Code's todo list are ephemeral scratch — when a plan matters, it gets written here and committed.

## How plans work

Two layouts, one doctrine (`PLAYBOOK.md` → *Phase mode and continuous mode*):

- **Phase mode (pre-v1):** `plans/<phase>/README.md` + one file per unit. `/plan-phase <phase>` writes it.
- **Continuous mode (live product):** `plans/features/<issue-id>-<slug>.md`, one file per tracker issue. `/plan-feature <issue-id>` writes it. The tracker (Linear) owns *what's next*; this folder owns *how each unit is done and proven*.

1. **Roadmap lives in `AGENTS.md`** as a terse phase table (phase mode) or as a pointer to the tracker (continuous mode); the landing pad points at the next unit here.
2. **When work becomes active**, a strong model expands it into a gated unit. The planning agent **writes the plan and stops**; a human reviews/approves before any execution.
3. **Match ceremony to maturity:** fully expand only the *next* unit; keep later units as roadmap bullets (or as un-expanded tracker issues).
4. **Each unit has an entry dependency + a verification gate.** Execute one at a time: build → verify gate → update `docs/status.md` + landing pad → PR → next.
5. **Expensive-to-reverse decisions** get logged in `DECISIONS.md`.
6. **Merged feature units** may be deleted from `plans/features/` once `docs/status.md` records them — the PR is the permanent record. Phase folders stay until the phase closes.

## Verification gates (phone-checkable)

Tag each gate item by evidence tier:

- **[CI]** — a green check proves it. Best tier. Only tag `[CI]` if the check actually exists.
- **[ARTIFACT]** — screenshot / recording / log / curl output the reviewer can actually open from the PR or the tracker issue. Includes agent-captured evidence: build/test output, preview renders, simulator screenshots from a driven flow, console/debugger output via local tools (e.g. Xcode 27 MCP), browser screenshots/recordings from a cloud agent's VM. Only if the agent actually has the tool — and only if the evidence is placed where it renders (see below).
- **[MANUAL]** — hands-on verification an agent genuinely can't do (physical-device-only behavior, real payments/push, subjective feel). Spell out exact steps + expected result.

Before tagging `[ARTIFACT]`, confirm a tool can actually produce that evidence — a gate item is worthless if it silently invites the agent to overclaim.

A unit is done only when every gate item is checked with evidence on the PR.

### Where evidence lives (and why images break)

PR bodies and tracker issues are comments, not repo files, so relative image paths 404. On a **private** repo GitHub's image proxy can't fetch repo images either, so `raw`/`blob?raw=true` embeds break too, and there is no API to upload to GitHub's drag-and-drop attachment host. Hence two lanes, chosen by where the agent ran:

| Lane | Who produces it | Where it goes | Where you look |
|---|---|---|---|
| **Local** (laptop, Remote Control; Xcode MCP, local browser) | agent on your Mac | PNG committed under `plans/artifacts/<issue-id>-<what>.png`; **linked** (not embedded) in the PR body by SHA-pinned blob URL; same file attached natively to the tracker issue | GitHub web/mobile while signed in; inline on the Linear issue (phone) |
| **Cloud** (Cursor cloud agent VM; web apps, browser flows) | agent on a Cursor VM | `/opt/cursor/artifacts/` → attached to the agent run; embedded in the PR description if *Allow posting artifacts to GitHub* is on (public unguessable URLs) | Cursor agent view (desktop/iOS), and the PR body |

Recordings (video) never go in git — cloud lane attaches them to the run/PR; local lane attaches them to the tracker issue. Keep committed PNGs small; if `plans/artifacts/` grows past a few tens of MB, sweep artifacts of long-shipped units (SHA-pinned links in old PRs keep working).

## What stays in the repo, and what doesn't

The tracker owns the roadmap, backlog, briefs, and status. The repo owns what an agent needs *with the code open*: `AGENTS.md`, `VISION.md`, `DECISIONS.md`, `docs/architecture.md`, `docs/status.md` (the changelog), and the **open** plan units under `plans/features/`. A plan unit is the execution spec for one issue — file paths, approach, gate — and it lives here because cloud agents, the coordinator, and PR reviewers read the repo, not the tracker. It is deleted by `/close-unit` in the same PR that ships it; the PR body carries the full plan. Result: `plans/features/` never holds more than the units currently in flight, and the repo does not accumulate markdown.

## Active plans

- <link to active phase folder, or the tracker view for continuous mode>
- `features/` — issue-sized units (continuous mode)
