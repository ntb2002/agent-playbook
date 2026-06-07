---
description: Expand a phase into gated, session-sized plan units (write the plan, do NOT build)
argument-hint: <phase, e.g. "phase-2">
---

# /plan-phase $ARGUMENTS

Expand the named phase into a reviewable plan under `plans/$ARGUMENTS/`. **Your only deliverable is the plan. Do not implement anything.** A human reviews and approves before execution.

1. Read `VISION.md`, `AGENTS.md`, `docs/architecture.md`, `DECISIONS.md`.
2. Create `plans/$ARGUMENTS/README.md`: overview, scope decisions, and a **session sequence table** (unit · entry dependency · status · spec link). Note which units are parallel-safe vs strictly serial.
3. **Match ceremony to maturity:** fully expand only the *next actionable* unit into `plans/$ARGUMENTS/<unit>.md` with: entry dependency, why-this-now, the concrete work, and a **verification gate** where every item is tagged `[CI]` / `[ARTIFACT]` / `[MANUAL]` and is phone-checkable. Leave later units as roadmap bullets.
4. Log expensive-to-reverse decisions in `DECISIONS.md`.
5. Update the `AGENTS.md` landing pad + phase table to point at the new plan.

Stop after writing the plan. Summarize the sequence and flag the single next-actionable unit.
