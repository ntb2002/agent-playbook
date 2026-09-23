---
name: plan-phase
description: Decompose a tracker project into session-sized issues (file the issues, do NOT build, never move status)
disable-model-invocation: true
---

# /plan-phase $ARGUMENTS

Decompose the tracker project `$ARGUMENTS` (a Linear project, or a GitHub milestone on the GitHub tier — whichever tracker `AGENTS.md` declares) into session-sized issues filed into that project. **Your only deliverable is the set of issues. Do not implement anything. Do not change any issue's status.** Issues land in Triage; a human accepts and promotes them.

This is the strong-model step whose cost is amortized across many cheap execution units. Design coherence matters here because nothing exists yet — think through the whole decomposition, but write down only what will still be true when each issue is picked up.

1. Read `VISION.md`, `AGENTS.md`, `docs/architecture.md`, `DECISIONS.md`, and the project's description in the tracker. If the project's outcome is unclear or violates the scope fence in `VISION.md`, stop and say so.
2. Decompose into **session-sized issues**: each one buildable in a single agent session and shippable as one PR. Sub-issues only when each child is itself session-sized. Identify **milestones** (user-visible capability checkpoints, not technical layers) and which issues are parallel-safe vs strictly serial.
3. **Fully specify only the first one or two issues** — the ones a human could promote to Todo today: acceptance criteria, an entry dependency, and a **verification gate** where every item is tagged `[CI]` / `[ARTIFACT]` / `[MANUAL]` and is phone-checkable (only tag `[CI]` if the check exists; only tag `[ARTIFACT]` if a tool the agent has can produce it). Add a **Model:** tier line per `.cursor/rules/model-policy.mdc`.
4. **Leave the rest thin**: title that names the work, one line of intent, milestone, `blocked by` links. No acceptance criteria yet — they get written by an agent reading the code as it exists when the issue approaches Todo. A greenfield decomposition is wrong by the fourth unit; don't pretend otherwise.
5. Open product calls go under a `## Needs human` heading on the issue (numbered, with a recommendation each). Do not resolve them yourself.
6. File the issues into the project via the tracker's tools (Linear MCP, or `gh issue create` with the milestone). **Titles name the work** — no ids, codes, or team prefixes in the title.
7. If there is phase-level design that doesn't fit any issue (an architecture sketch, sequencing rationale), write it to `plans/$ARGUMENTS/README.md`. Keep it short; it is design notes, not a unit list.
8. Log expensive-to-reverse decisions in `DECISIONS.md`. Update the `AGENTS.md` landing pad's *Active project* line.

Stop after filing. Summarize the milestones and sequence, list the issues you filed (ids + titles), and name the single issue you'd promote to Todo first. The human presses the keys.
