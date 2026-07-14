
## iOS agent conventions (Xcode MCP)

- **Never claim a unit done without verifying:** build the project and run tests via the Xcode MCP tools (`xcrun mcpbridge`, wired in `.cursor/mcp.json`) before reporting success.
- **UI gate items** need an agent-captured simulator screenshot attached to the PR as `[ARTIFACT]` evidence.
- **Constraints:** the Xcode tools require Xcode running with this project open, and are local-only — they back `[ARTIFACT]` evidence, never `[CI]`.
- **Apple's skills** (`swiftui-specialist`, `swiftui-whats-new-27`, `test-modernizer`, …) load globally from `~/.claude/skills/`; prefer them over training-data knowledge for post-2026 APIs.
- Machine setup (skills export, MCP registration, Intelligence toggle): `SETUP.md` → "iOS / Apple projects".
