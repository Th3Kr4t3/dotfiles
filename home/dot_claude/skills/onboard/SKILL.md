---
name: onboard
description: Build context on the project in the current folder (workspace rules, stack, history, tests) and propose next steps before changing anything.
argument-hint: "[goal for this session]"
disable-model-invocation: true
---

You're picking up development of the project in the current folder. Build context first, then propose a plan. Don't write code yet.

## 0. Check where you're running

Run `uname -sr; echo "$HOME"; test -f ~/projects/AGENTS.md && echo "workspace rules found"`.

- **WSL** (the kernel name contains "microsoft", `$HOME` is `/home/user`, and the rules are found): continue.
- **Windows** (`uname` fails, or `$HOME` looks like `C:\Users\...`): stop. Tell me to reopen the project from the Ubuntu terminal with `cd ~/projects/<folder>/<name> && claude`. Don't look for the files from Windows.
- **A container or Codespaces** (Linux without `~/projects/AGENTS.md`): continue, using only the project's own files for rules.

## 1. Read the rules

- `~/projects/AGENTS.md`: the shared workspace rules (isolation, no global installs, ports, the sandbox → prod checklist).
- Check which folder the project is in (`sandbox`, `courses`, `clients`, or `prod`) and follow that folder's rules.
- The project's own `AGENTS.md` / `CLAUDE.md` (its "Current status" section is where the last session left off), `README.md`, and anything under `docs/`.

## 2. Understand the current state

- Stack and versions: `.mise.toml`, `pyproject.toml` / `package.json`, lockfiles, `compose.yaml`.
- History: `git log --oneline -20` and `git status`. If it isn't a git repo, say so.
- Open work: `rg -n "TODO|FIXME"`, skipped or failing tests, and any checklist in the docs.
- Run the tests and the linter once, and note what passes and what fails.
- If the folder is empty, skip this step: ask me for the stack, then propose the initial setup from the "Every new project starts with" list in `~/projects/AGENTS.md`.

## 3. Report back, briefly

- What the project does, in 2–3 sentences.
- The stack, how to set it up and run it, and its ports.
- Where it stands: what's done, what's half-done, and what's broken.
- Gaps against the workspace rules (for example, no `.mise.toml`, `.env.example`, or `AGENTS.md`).
- The 3–5 most valuable next steps, in order, each with a one-line reason.

## 4. Then wait

Don't change anything until I pick a step. After that, work in small, reviewable steps, run the tests before calling anything done, and ask before anything that touches files outside this project.

## Goal for this session

$ARGUMENTS

If no goal is given above, ask me for one in your report.
