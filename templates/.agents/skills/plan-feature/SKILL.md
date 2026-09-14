---
name: plan-feature
description: Expand one tracker issue into a single gated plan unit (write the plan, do NOT build)
disable-model-invocation: true
---

# /plan-feature $ARGUMENTS

Expand the tracker issue `$ARGUMENTS` (e.g. `SS-42`) into one reviewable, session-sized plan unit at `plans/features/<issue-id>-<slug>.md`. **Your only deliverable is the plan. Do not implement anything.** A human (or the coordinator, if the human has delegated approval for this class of issue) reviews before execution.

This is the continuous-mode sibling of `/plan-phase`: same doctrine, one issue instead of one phase.

1. Read the issue — title, description, acceptance criteria, comments. If a Linear MCP is available, fetch it; otherwise the issue text is pasted or linked in the prompt. If acceptance criteria are missing or ambiguous, **stop and say what's missing** — do not invent product intent, and do not go read strategy docs or knowledge-layer pages to infer it; the issue and `VISION.md` are the whole spec.
2. Read `VISION.md` (scope fence), `AGENTS.md`, `docs/architecture.md` for the area, `DECISIONS.md`. If the issue violates the scope fence ("what we're explicitly NOT building"), stop and flag it.
3. Decide size. If this issue is genuinely a subsystem (several PRs, several sessions), say so and recommend `/plan-phase` instead — do not cram it into one unit.
4. Write `plans/features/<issue-id>-<slug>.md` with:
   - **Issue:** id + link. **Entry dependency:** what must already be true (merged PRs, migrations, config).
   - **Why this now:** one or two lines tying it to the acceptance criteria.
   - **The concrete work:** files/areas to touch, the approach, what NOT to touch.
   - **Verification gate:** every acceptance criterion becomes at least one gate item tagged `[CI]` / `[ARTIFACT]` / `[MANUAL]`, phone-checkable. Only tag `[CI]` if the check exists; only tag `[ARTIFACT]` if a tool can actually produce that evidence.
   - **Branch:** `<issue-id>-<slug>` so the tracker auto-links the PR and closes the issue on merge.
5. Log expensive-to-reverse decisions in `DECISIONS.md`.
6. Update the `AGENTS.md` landing pad's *next actionable unit* to this file if it is now the top of the queue.

Stop after writing the plan. Summarize the gate and flag anything the issue left undecided.
