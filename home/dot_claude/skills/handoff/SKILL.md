---
name: handoff
description: Save where this session left off in the project's AGENTS.md, so the next session (and /onboard) can pick up from there.
argument-hint: "[extra notes to include]"
disable-model-invocation: true
---

We're stopping for now. Leave the project ready for the next session.

1. Update the `## Current status` section of the project's `AGENTS.md`, replacing the previous one, in this shape (15 lines at most):

   ```markdown
   ## Current status

   _Updated YYYY-MM-DD_

   - **Done:** what we finished in this session
   - **Next:** the next 1–3 steps, in order
   - **Open questions:** decisions that are waiting on me
   - **Known issues:** anything broken, flaky, or skipped
   ```

2. If the project has no `AGENTS.md`, create one with a short header (what the project is, its stack, how to set it up, run, and test it, and its ports), followed by the status section. If there's no `CLAUDE.md`, create one whose only line is `@AGENTS.md`.
3. If the project is a git repo, commit only those files with the message `docs: update current status`. Don't push. If it isn't a git repo, say so; don't run `git init` without asking.
4. Reply with the status section you wrote.

Extra notes from me to include:

$ARGUMENTS
