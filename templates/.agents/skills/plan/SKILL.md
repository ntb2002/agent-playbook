---
name: plan
description: Plan work at either size — decompose a tracker project into session-sized issues, or expand one Deep-lane issue into a gated plan unit. Writes the plan, never builds, never moves status.
disable-model-invocation: true
---

# /plan $ARGUMENTS

One planning ritual, two sizes. The argument decides which:

- **An issue id** (`SS-42`, `NV-7`, `#42`, or a bare `42` on the GitHub tier) → **issue mode**: expand one Deep-lane issue into `plans/features/<issue-id>-<slug>.md`.
- **Anything else** (a project name, a Linear project URL, a GitHub milestone) → **project mode**: decompose the project into session-sized issues filed into the tracker.

Both modes share the rules: **your only deliverable is the plan** (issues or a plan file). Do not implement anything. Do not change any issue's status — a human accepts, promotes, and approves. Read the tracker `AGENTS.md` declares (Linear MCP, or `gh`) and no other; if it is unreachable, stop and say so. Never read the knowledge layer (Notion, strategy docs, chat exports) to infer product intent — the tracker and `VISION.md` are the whole spec.

## Project mode — decompose into issues

The strong-model step whose cost is amortized across many cheap execution units. Design coherence matters because nothing exists yet — think through the whole decomposition, but write down only what will still be true when each issue is picked up.

1. Read `VISION.md`, `AGENTS.md`, `docs/architecture.md`, `DECISIONS.md`, and the project's description in the tracker. If the outcome is unclear or violates the scope fence in `VISION.md`, stop and say so.
2. Decompose into **session-sized issues**: each buildable in one agent session and shippable as one PR. Sub-issues only when each child is itself session-sized. Identify **milestones** (user-visible capability checkpoints, not technical layers) and which issues are parallel-safe vs strictly serial.
3. **Fully specify only the first one or two issues** — the ones a human could promote to Todo today: acceptance criteria, entry dependency, a **verification gate** where every item is tagged `[CI]` / `[ARTIFACT]` / `[MANUAL]` and is phone-checkable (only tag `[CI]` if the check exists; only tag `[ARTIFACT]` if a tool the agent has can produce it), and a **Model:** tier line per `.cursor/rules/model-policy.mdc`.
4. **Leave the rest thin**: a title that names the work, one line of intent, milestone, `blocked by` links. No acceptance criteria yet — an agent writes them against the code as it exists when the issue approaches Todo. A greenfield decomposition is wrong by the fourth unit; don't pretend otherwise.
5. Open product calls go under `## Needs human` on the issue (numbered, with a recommendation each). Don't resolve them yourself.
6. File the issues into the project (Linear MCP, or `gh issue create` with the milestone). **Titles name the work** — no ids, codes, or team prefixes in the title.
7. Phase-level design that fits no issue (architecture sketch, sequencing rationale) → `plans/<project>/README.md`. Short. Design notes, not a unit list.
8. Log expensive-to-reverse decisions in `DECISIONS.md`. Update the `AGENTS.md` landing pad's *Active project* line.

Stop. Summarize milestones and sequence, list the issues you filed (ids + titles), and name the one you'd promote to Todo first. The human presses the keys.

## Issue mode — expand one Deep-lane issue

**Deep lane only.** Standard-lane issues don't get a plan file — the issue is the spec and `/start-unit` reads it directly. Use this when the issue is ambiguous, risky, cross-cutting, `strong` tier, or touches prompts, safety, schema, or auth. If the issue turns out to be Standard-lane, say so and stop; don't write a plan nobody needs.

1. Read the issue — title, description, acceptance criteria, comments (Linear MCP `get_issue`, or `gh issue view <n> --comments`). If it still has a `## Needs human` section, or acceptance criteria are missing or ambiguous, **stop and say what's missing**. A comment that answers the questions is not enough until those answers are folded into `## Decided` in the description.
2. Read `VISION.md` (scope fence), `AGENTS.md`, `docs/architecture.md` for the area, `DECISIONS.md`, and the code the issue touches. If the issue violates the scope fence, stop and flag it.
3. Decide size. If this is genuinely a subsystem (several PRs, several sessions), say so and recommend converting it to a tracker project and running `/plan <project>` — do not cram it into one unit.
4. Write `plans/features/<issue-id>-<slug>.md`. Don't restate the issue; link it and add what the code tells you:
   - **Issue:** id + link. **Entry dependency:** what must already be true (merged PRs, migrations, config).
   - **Why this now:** one or two lines tying it to the acceptance criteria.
   - **The concrete work:** files/areas to touch, the approach, what NOT to touch.
   - **Verification gate:** every acceptance criterion becomes at least one gate item tagged `[CI]` / `[ARTIFACT]` / `[MANUAL]`, phone-checkable.
   - **Branch:** `<issue-id>-<slug>` so the tracker auto-links the PR and closes the issue on merge.
   - **Model:** `fast` / `mid` / `strong` per `.cursor/rules/model-policy.mdc`, one clause of reasoning. Prompts, safety, schema, auth, or a `DECISIONS.md` call → `strong`.
5. Log expensive-to-reverse decisions in `DECISIONS.md`.
6. Update the `AGENTS.md` landing pad's *Next unit* line to this issue if it is now the top of the queue.

Stop. Summarize the gate and flag anything the issue left undecided.
