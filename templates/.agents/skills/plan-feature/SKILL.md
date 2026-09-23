---
name: plan-feature
description: Expand one Deep-lane tracker issue into a single gated plan unit (write the plan, do NOT build)
disable-model-invocation: true
---

# /plan-feature $ARGUMENTS

Expand the tracker issue `$ARGUMENTS` (e.g. `SS-42`, or `#42` on the GitHub tier) into one reviewable, session-sized plan unit at `plans/features/<issue-id>-<slug>.md`. **Your only deliverable is the plan. Do not implement anything.** A human (or the coordinator, if the human has delegated approval for this class of issue) reviews before execution.

**Deep lane only.** Standard-lane issues don't get a plan file — the issue is the spec and `/start-unit` reads it directly. Run this when the issue is ambiguous, risky, cross-cutting, `strong` tier, or touches prompts, safety, schema, or auth. If the issue turns out to be Standard-lane, say so and stop; don't write a plan nobody needs.

1. Read the issue — title, description, acceptance criteria, comments — from the tracker `AGENTS.md` declares: Linear MCP (`get_issue`) or `gh issue view <n> --comments`. Do not open the other tracker, and do not scavenge `plans/` or Notion for a substitute; if the tracker is unreachable, stop and say so. If the description still has a `## Needs human` section, or acceptance criteria are missing or ambiguous, **stop and say what's missing** — do not invent product intent, and do not read strategy docs or knowledge-layer pages to infer it; the issue and `VISION.md` are the whole spec. A comment that answers the questions is not enough until those answers have been folded into a `## Decided` section in the description.
2. Read `VISION.md` (scope fence), `AGENTS.md`, `docs/architecture.md` for the area, `DECISIONS.md`, and the code the issue touches. If the issue violates the scope fence ("what we're explicitly NOT building"), stop and flag it.
3. Decide size. If this issue is genuinely a subsystem (several PRs, several sessions), say so and recommend converting it to a tracker project + `/plan-phase` — do not cram it into one unit.
4. Write `plans/features/<issue-id>-<slug>.md`. Don't restate the issue; link it and add what the code tells you:
   - **Issue:** id + link. **Entry dependency:** what must already be true (merged PRs, migrations, config).
   - **Why this now:** one or two lines tying it to the acceptance criteria.
   - **The concrete work:** files/areas to touch, the approach, what NOT to touch.
   - **Verification gate:** every acceptance criterion becomes at least one gate item tagged `[CI]` / `[ARTIFACT]` / `[MANUAL]`, phone-checkable. Only tag `[CI]` if the check exists; only tag `[ARTIFACT]` if a tool can actually produce that evidence.
   - **Branch:** `<issue-id>-<slug>` so the tracker auto-links the PR and closes the issue on merge.
   - **Model:** `fast` / `mid` / `strong` per `.cursor/rules/model-policy.mdc`, with one clause of reasoning. Prompts, safety, schema, auth, or a `DECISIONS.md` call → `strong`. This line is what the dispatcher turns into `[model=…]` or a subagent model choice.
5. Log expensive-to-reverse decisions in `DECISIONS.md`.
6. Update the `AGENTS.md` landing pad's *Next unit* line to this issue if it is now the top of the queue.

Stop after writing the plan. Summarize the gate and flag anything the issue left undecided.
