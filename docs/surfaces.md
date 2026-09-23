# Surface map — which product fills which role

> **As of September 2026. This file is expected to rot.** `PLAYBOOK.md` → *Orchestration model* is written in roles and should not change when a vendor ships a feature; this file is where the product facts live, dated, so they can be wrong in one place. When a fact here turns out to be wrong, log the exact correction in `FRICTION.md`; the steward verifies against the vendor's docs and edits here. Every claim below was verified against vendor docs or observed on Nathan's machines in Sept 2026; "observed" facts are marked.

## Role → surface

| Role (doctrine) | Filled by, today | Notes |
|---|---|---|
| **Tracker** | **Linear** (ventures) · **GitHub Issues** (solo tier) | Declared per repo in `AGENTS.md`. |
| **Human review surface** | GitHub mobile · Linear iOS · Cursor iOS · Slack | Merge from GitHub mobile or Linear Reviews (same merge). |
| **Executor — local lane** | Cursor editor chat ("This Mac") · Cursor Remote Control ("This Mac (Remote Control)") · Claude Code CLI/desktop · Xcode's agent (specialist) | Has local tools: simulators, Xcode MCP, project MCPs, secrets. |
| **Executor — cloud lane** | Cursor cloud agents (from Linear `@Cursor`, Slack, GitHub `@cursoragent`, the iOS app, or chat) · Claude Code cloud sessions | Never has local-only tools. |
| **Coordinator** *(earned)* | Cursor Project | One per repo. Off by default. |
| **Reviewer** | `code-review` subagent (always) · Cursor Bugbot / CodeRabbit *(earned)* · `pr-review` Automation *(earned)* | |
| **Supervisor** *(optional)* | Grok Bot · you | Account-bound memory; durable facts go to the repo. |
| **Thinking layer / thinking agent** | Notion · Claude projects · Linear Agent · Grok Bot | Off the code loop. |
| **Model routing** | `fast`/`mid` → Cursor · `strong` → Claude Code (Opus 5.5, medium effort) · overflow → Codex | `templates/.cursor/rules/model-policy.mdc` has the table. |

## Cursor

**Three ways an agent runs, and what each can see.**

| Mode | Where the loop runs | Where tools run | MCP comes from | Gets Xcode MCP? |
|---|---|---|---|---|
| **This Mac** (editor chat) | Your Mac | Your Mac | Project `.cursor/mcp.json` + user `~/.cursor/mcp.json` of the *open workspace* | Yes, if the workspace's `mcp.json` declares it and the server is up |
| **This Mac (Remote Control)** — steer a local agent from phone/web | Cursor's cloud | Your Mac (a worker process; outbound connection only) | The **Cloud Agents MCP configuration**, routed by transport: stdio servers start on your Mac, HTTP servers run on Cursor's backend. **Not** the chat's project `.cursor/mcp.json`. Adding a server needs a new run. | Only if `xcrun mcpbridge` is in the Cloud Agents MCP config as a stdio server *and* the Mac's WindowServer is up |
| **Cloud agent** (`@Cursor` in Linear/Slack, `@cursoragent` on GitHub, iOS app, chat "Cloud") | Cursor's cloud | A hosted VM built from `.cursor/environment.json` | Cloud Agents MCP configuration (HTTP servers; stdio servers run on the VM, so no Xcode) | **Never** |

- **Hooks:** `.cursor/hooks.json` fires in all three modes (Remote Control uses the workspace the worker started from). The commit guard travels.
- **`worker=<name>` / `machine=<name>` in a Linear issue body, Slack message, or GitHub comment** routes that request to *your* named self-hosted worker (`agent worker start --name <name>`) if it's registered for the target repo. This is how a tracker-launched run gets the **local lane** — Mac tools, Xcode — without a laptop chat. Requires the worker to be started in a checkout of that repo; Cursor refuses to run repo A's request on repo B's checkout.
- **Remote Control machine requirements:** awake, logged in, Git-backed, **WindowServer up**. Lid closed with an external display and power (true clamshell) is fine; lid closed with no display sleeps the GUI and Device Interaction will hang or never attach even though the worker is still running. *(observed)*
- **Workspace hopping:** a chat's workspace root decides which `.cursor/mcp.json`, rules, and skills it loads. The `move_agent_to_root` tool checks out the chat's *recorded* branch in the destination repo and fails if that branch doesn't exist there. A playbook or ops chat does not acquire Xcode tools by opening Xcode; the tools belong to the iOS repo's workspace. Doctrine: stay in your repo.
- **Linear integration:** one Linear workspace per Cursor account (a second connection disconnects the first). Route repos with `repo=owner/name` labels. Delegation needs GitHub connected and usage-based pricing on. Linear-triggered agents have been observed ignoring the dashboard default model — carry `[model=…]` in the comment.
- **Artifacts:** on by default; uploaded from wherever the worker runs to Cursor storage; embed in PR bodies only for PRs the cloud agent itself opened, via long public URLs (*Allow posting artifacts to GitHub*). Decide per venture.
- **Projects** (coordinator): persistent, delegates to subagents on isolated VMs, subscribes to its own PRs, can watch Slack or run on a schedule. Beta pricing on cloud-agent allowance.
- **Automations:** dashboard → Automations or `/automate`; prompts versioned in `.cursor/automations/`.
- **Computer Use** is a separate capability (`agent worker --computer-use`), not Remote Control; needs Accessibility + Screen Recording permissions on macOS.
- **Cursor iOS app:** launch/steer cloud agents, review diffs and artifacts, merge. Remote Control hands a laptop agent to the phone.

## Claude Code (CLI + desktop)

- Same git flow and rituals. `CLAUDE.md` = `@AGENTS.md` first line; skills via the `.claude/skills → ../.agents/skills` symlink; subagents in `.claude/agents/`.
- **Scoped `.cursor/rules/*.mdc` are not auto-loaded.** Read the `.mdc` whose `globs` match before editing a file. (`AGENTS.md` says this; it binds.)
- **MCP:** project scope `.mcp.json` (iOS overlay ships Xcode), user scope `~/.claude.json` via `claude mcp add`. Linear: `claude mcp add --transport http linear-server https://mcp.linear.app/mcp`, then `/mcp` to authenticate. Day-one floor for any Linear-tracked repo.
- **Desktop app extras:** an embedded **iOS Simulator pane** (public beta) — a live simulator you can watch and touch, plus headless screenshot/tap/inspect for the agent — a second `[ARTIFACT]` path beside Xcode MCP `DeviceInteraction*`. **Local sessions only. Requires Xcode 26.x selected via `xcode-select`; it does not work with Xcode 27's Device Hub.** *(observed on a Mac with Xcode 27.0.)* Until that changes, the pane is not the UI lane for Xcode 27 repos. Also: a built-in browser pane, and its own Remote Control / cloud sessions for steering a local session from the phone.
- **Model:** the `strong` surface. Opus 5.5 at medium effort by default; 5.5 thinks longer per turn than 5 at the same label, so raise effort only when medium visibly falls short. Session limits reset every ~5 hours — this is where planning tokens go.
- **Steward:** the playbook steward is a Claude Code agent launched inside `agent-playbook`.

## Codex / ChatGPT

- **Overflow execution and second-opinion PR review only.** Not structural — don't build workflow that depends on it.
- Reads `AGENTS.md` natively. Does not auto-load `.cursor/rules/*.mdc` (same rule as Claude Code: read the matching `.mdc` first).
- **The repo is the source of truth**, not the ChatGPT project or its chat memory. Anything durable it learns goes to `AGENTS.md` / `DECISIONS.md` / `docs/`.
- **Confirm the commit hooks fire before trusting a commit from it.** Its environment must run `git config core.hooksPath .githooks`; test once with a fake `sk-ant-…` string in a staged file. Until confirmed, treat its commits as unhooked and rely on CI.

## Xcode (iOS projects)

- **Xcode 27 MCP** (`xcrun mcpbridge`): 53 tools — build/test, `RenderPreview`, `RunProject`/`StopProject`/`GetConsoleOutput`, `InvokeDebuggerCommand` (LLDB), `DeviceInteraction*` (boot simulator, install, taps/typing, screenshots), `GetTopCrashIssues`/`GetCrashIssueLogs`, scheme/destination/build-settings/String Catalog tools. Xcode 26.x: 21 tools, no run/debug/device interaction. **Verify with `tools/list`; the surface changes between versions.**
- **Local-only.** Backs `[ARTIFACT]`, never `[CI]`. Cloud agents never get it.
- **Counts only if it is in the executor's live catalog** (`DeviceInteraction*` visible). Descriptors cached on disk from a previous Xcode session do not attach to a cloud worker or to a Remote Control run whose Cloud Agents MCP config lacks the server.
- **Requirements:** Xcode → Settings → Intelligence → "Allow external agents to use Xcode tools"; Xcode open on the project, or **headless** (`sudo xcrun mcp-server enable`, `sudo xcrun mcp-server allow-folder <repo> --always`). Never `--unsafe-always-allow-all-agents`. WindowServer must be up for simulator work (see Remote Control above).
- **Wiring:** project-scoped `.cursor/mcp.json` (Cursor editor chats in that repo), `.mcp.json` (Claude Code project scope), and — for Remote Control — the Cloud Agents MCP config as a stdio server. Keep it out of `~/.cursor/mcp.json`; you don't want Xcode attached to the playbook or NOVA chats.
- **Apple's skills** (`xcrun agent skills export`, 10 on Xcode 27): knowledge skills work in any tool; `device-interaction` and `audit-xcode-security-settings` call Xcode MCP tools and work only when the MCP is connected. Re-export after each Xcode update.
- **Xcode's own agent** (plan mode, ACP so Claude Code can run inside it) is a specialist surface for pure-Swift UI units, not the daily driver.

## Linear

- One workspace for the portfolio; one team per venture, **subject to plan limits** (free: 2 teams, 250 non-archived issues; Basic: 5 teams, no cap). SmartSport and NOVA use both free-tier teams; a third venture means upgrading or the GitHub tier.
- Three states used: Triage (inbox, one-key accept/decline/duplicate/snooze), Backlog, Todo. In Progress / Done come from the GitHub integration on PR open / merge.
- **Docs-only PRs must not put live issue ids in the title** — Linear attaches them and moves them In Progress.
- **Linear Reviews** = the same GitHub PRs; squash-and-merge there is a GitHub merge.
- **Linear Agent** shapes the product side of issues (no code access). **Linear MCP** (`https://mcp.linear.app/mcp`) in Cursor, Claude Code, and the Cloud Agents MCP config.
- **Attachments:** `prepare_attachment_upload` → PUT bytes → `create_attachment_from_upload` renders inline on the phone. Never paste `uploads.linear.app` signed URLs into GitHub; they expire.
- **Status is never moved by an agent** except to undo its own mistake or in the Fast lane (issue filed straight into In Progress after in-chat approval).

## GitHub

- **Issues** are the solo-tier tracker: labels `accepted` (Backlog) / `ready` (Todo); `Closes #n` in the PR body; branches `<n>-<slug>`; `gh issue view <n> --comments` for agents.
- **GitHub mobile** is the review surface: diff, CI check, gate checklist, merge.
- **Settings → Pull Requests → Automatically delete head branches** — the one click that keeps the remote clean (Linear and GitHub mobile have no delete-branch control).
- **Free + private repos:** rulesets are not enforced; CI still runs and shows. Public repo or GitHub Pro for hard enforcement.
- **Images in PR bodies on private repos don't render** (Camo can't fetch). Commit PNG under `plans/artifacts/`, **link** the SHA-pinned blob URL, and attach to the tracker issue. Never `![]`-embed. No API uploads to the drag-and-drop attachment host.
- `@cursoragent worker=<name>` in a comment runs a Cursor agent on your named machine (trusted commenters only).

## Slack · Grok Bot · Notion · Railway

- **Slack:** `#<venture>-dev` per venture; GitHub app subscribed to `pulls checks`; launch Cursor cloud agents by message; `@Cursor worker=<name>` targets your machine.
- **Grok Bot:** supervisor and ops agent, not a coder. Acts in tools with no API; can read cloud-agent transcripts and artifacts and push back. Memory is account-bound — durable facts go to the repo or the knowledge hub. Files tracker issues; never dispatches coding agents at a repo that has a coordinator.
- **Notion:** the thinking layer. A venture hub links the active tracker project and never restates delivery status. Execution agents don't read it.
- **Railway** (SmartSport backend, Hobby plan): the CLI's built-in MCP proxy (`railway mcp`, stdio, in `~/.cursor/mcp.json`) works after `railway login`. The Cursor Railway *plugin*'s HTTP OAuth to `mcp.railway.com` hangs on the localhost callback on this machine *(observed)* — use the CLI proxy. `railway login --browserless` is the fallback when the browser flow stalls. Never print secret values; list key names only.
