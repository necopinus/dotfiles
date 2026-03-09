<!-- nono-sandbox-start -->

## Nono Sandbox - CRITICAL

**You are running inside the nono security sandbox.** This is a capability-based sandbox that CANNOT be bypassed or modified from within the session.

### On ANY "operation not permitted" or "EPERM" error:

**IMMEDIATELY tell the user:**

> This path is not accessible in the current nono sandbox session. You need to exit and restart with:
> `nono run --allow /path/to/needed -- claude`

**NEVER attempt:**

- Alternative file paths or locations
- Copying files to accessible directories
- Using sudo or permission changes
- Manual workarounds for the user to try
- ANY other approach besides restarting nono

The sandbox is a hard security boundary. Once applied, it cannot be expanded. The ONLY solution is to restart the session with additional --allow flags.

<!-- nono-sandbox-end -->

## Code Intelligence

Prefer LSP over Grep/Glob/Read for code navigation:

- `goToDefinition` / `goToImplementation` to jump to source
- `findReferences` to see all usages across the codebase
- `workspaceSymbol` to find where something is defined
- `documentSymbol` to list all symbols in a file
- `hover` for type info without reading the file
- `incomingCalls` / `outgoingCalls` for call hierarchy

Before renaming or changing a function signature, use `findReferences` to find all call sites first.

Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't help.

After writing or editing code, check LSP diagnostics before moving on. Fix any type errors or missing imports immediately.
