# Plans

> Deep-lane execution specs and optional project design notes. **In-repo on purpose** so they travel with every clone, device, and cloud agent. Cursor's `.plan.md` and Claude Code's todo list are ephemeral scratch — when a plan matters, it gets written here and committed. **This folder is never a work queue.** What's next lives in the tracker named in `AGENTS.md`.

## What lives here

- **`plans/features/<issue-id>-<slug>.md`** — one file per **Deep-lane** issue currently in flight. `/plan-feature <issue-id>` writes it; `/close-unit` deletes it in the PR that ships the unit (the PR body carries the full plan). Standard- and Fast-lane issues have no plan file: the issue is the spec.
- **`plans/<project>/README.md`** *(optional)* — phase-level design that doesn't fit an issue: an architecture sketch, sequencing rationale. `/plan-phase` may write it. Not a unit list; the units are issues in the tracker project.
- **`plans/artifacts/`** — committed local-lane evidence (small PNGs), linked by SHA from PR bodies.

1. **The roadmap is in the tracker.** `AGENTS.md`'s landing pad points at the active project and the next Todo issue; nothing here is a roadmap.
2. **Deep-lane work gets a plan first.** A strong model expands the approved issue into a gated unit here, **writes the plan and stops**; a human reviews before any execution.
3. **Fully specify only the next unit or two.** Later issues stay thin in the tracker until they approach Todo.
4. **Each unit has an entry dependency + a verification gate.** Execute one at a time (WIP limit in `AGENTS.md`): build → verify gate → update `docs/status.md` + landing pad → PR → next.
5. **Expensive-to-reverse decisions** get logged in `DECISIONS.md`.

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

The tracker owns the roadmap, backlog, briefs, and delivery status. The repo owns what an agent needs *with the code open*: `AGENTS.md`, `VISION.md`, `DECISIONS.md`, `docs/architecture.md`, `docs/status.md` (code-side history), and the **open** Deep-lane units under `plans/features/`. A plan unit is the execution spec for one issue — file paths, approach, gate — and it lives here because cloud agents, the coordinator, and PR reviewers read the repo, not the tracker. It is deleted by `/close-unit` in the same PR that ships it; the PR body carries the full plan. Result: `plans/features/` never holds more than the units currently in flight, and the repo does not accumulate markdown.

## In flight

- `features/` — Deep-lane units currently being built (should match the tracker's In Progress, minus Standard/Fast-lane issues)
- <optional: `<project>/README.md` design notes for the active project>
