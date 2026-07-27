
## iOS agent conventions (Xcode MCP)

- **Never claim a unit done without verifying:** build the project and run tests via the Xcode MCP tools (`xcrun mcpbridge`, wired in `.cursor/mcp.json`) before reporting success.
- **UI gate items** that a `#Preview` block can show: attach an agent-captured `RenderPreview` snapshot as `[ARTIFACT]` evidence (it supports dark-mode / orientation / type-size variants).
- **What the MCP tools cannot do:** there is no live-simulator interaction and no LLDB/debugger tool. Tapping through a flow, or capturing arbitrary in-app state, stays `[MANUAL]` — write those gate items for a human, and never let an agent claim them.
- **Constraints:** the Xcode tools require Xcode running with this project open, and are local-only — they back `[ARTIFACT]` evidence, never `[CI]`.
- **Apple's skills** (`swiftui-specialist`, `swiftui-whats-new-27`, `test-modernizer`, …) load globally from `~/.claude/skills/`; prefer them over training-data knowledge for post-2026 APIs.
- Machine setup (skills export, MCP registration, Intelligence toggle): `SETUP.md` → "iOS / Apple projects".
