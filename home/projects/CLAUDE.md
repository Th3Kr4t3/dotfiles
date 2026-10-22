# Projects workspace

<!-- Managed by chezmoi. Edit with `chezmoi edit ~/projects/CLAUDE.md`; direct edits get overwritten. -->

Every project I develop lives under `~/projects` in WSL2 (Ubuntu 26.04) on a Windows 11 host.
These rules apply to every project below this folder. Each project's own `CLAUDE.md` adds the specifics: stack, commands, and ports.

## The golden rule: isolation

**IMPORTANT: every change stays inside the project you are working in.**
Your work must never affect, directly or indirectly, the Windows host, the WSL system, or any other project in this folder.
If a task seems to need a change outside the project, stop and ask. Don't look for a workaround.

## Layout

| Folder | What lives here | How to work |
|---|---|---|
| `sandbox/` | Experiments and prototypes | Move fast and break things. Tests are optional. The isolation rules still apply. |
| `courses/` | Projects from courses | Keep the course's stack and versions, even if they're outdated. Don't upgrade unless asked. |
| `clients/` | Client work | Confidential. Follow the client repo's conventions. Ask before adding a dependency. |
| `prod/` | Critical local projects | Be careful. Run the tests before calling anything done. Ask before any destructive action. |

Projects usually start in `sandbox/` and get promoted to `prod/` (see the checklist below).

## Never

- **Install anything globally:** `sudo apt install`, `npm i -g`, `pnpm add -g`, `pip install` outside a venv, `uv tool install`, `pipx`, `cargo install`, `go install`, `mise use -g`.
- **Edit files outside the project:** `~/.zshrc`, `~/.bashrc`, `~/.gitconfig`, `~/.config/`, `/etc/`, anything under `/mnt/c/`, or other projects.
- **Change the Windows host:** don't run `powershell.exe`, `cmd.exe`, `winget`, or `reg` to modify anything.
- **Change global git config.** If a repo needs a setting, use `git config --local`.
- **Touch Docker resources this project didn't create:** no `docker system prune`, no removing other volumes, networks, containers, or images.
- **Copy code, data, or secrets between client projects,** or from `clients/` into any other folder.
- **Leave background processes running** (dev servers, watchers, containers) when the task ends.

## Instead, keep everything in the project

| Need | Do this |
|---|---|
| Tool versions (node, python, go…) | Pin them in `.mise.toml` at the project root (`mise use node@22`, without `-g`) |
| Python dependencies | `uv` with the project's own `.venv` (`uv add`, `uv run`) |
| Node dependencies | Local `node_modules` with a committed lockfile. Pin the package manager in `package.json` (`"packageManager"`). Run binaries with `pnpm exec` / `npx`. |
| A CLI tool only this project needs | Add it to `.mise.toml` under `[tools]` |
| Databases, Redis, queues | `compose.yaml` with a top-level `name:` equal to the project name, so containers, volumes, and networks are namespaced |
| Config and secrets | `.env` (gitignored) + a committed `.env.example`. Never export them from shell rc files. |
| Caches, build output, temp files | Inside the project, and gitignored |
| A genuinely global change (new apt package, shell alias) | Don't apply it. Propose it as a change to the dotfiles repo (see Environment). |

## Ports

- Before using a port, check that it's free (`ss -ltn`) and that no other project declares it in its `.env` or `compose.yaml`.
- Bind services to `127.0.0.1`, not `0.0.0.0`.
- Keep host ports in `.env` and list them in the project's README.

## Promoting a project from `sandbox/` to `prod/`

A project is ready to move when:

1. It's a git repo with a remote, and private by default.
2. Versions are pinned (`.mise.toml`) and lockfiles are committed.
3. There's an `.env.example`, and gitleaks finds no secrets in the history.
4. Tests and lint pass.
5. Setup and run are one command each (mise tasks, `make`, or `just`), documented in the README with the ports.
6. It has its own `CLAUDE.md`.

After `mv sandbox/<name> prod/<name>`, recreate environments that store absolute paths: delete and rebuild `.venv` (`uv sync`). Also search for leftover absolute paths (`rg "/projects/sandbox"`).

## Every new project starts with

`git init`, `.gitignore`, `.gitattributes` (`* text=auto eol=lf`), `.mise.toml`, `.env.example`, a README, and its own `CLAUDE.md`.

## Environment

- Work runs inside WSL (zsh). Don't run dev tools from Windows against these files: it's slow, and it breaks permissions and line endings.
- The machine setup (shell, git, mise globals, apt packages) is managed by chezmoi in `~/.local/share/chezmoi`, also called "dotfiles" or "Project F". Changes to the machine go there as a proposal for me to review, never as direct edits to `$HOME`.
- Git commits use my GitHub noreply email, set globally by the dotfiles. Don't override it.
- `docker` comes from Docker Desktop.

## Ask before

- Running anything with `sudo`, or touching a path outside the current project
- Deleting files or data, dropping databases, `git push --force`, or rewriting history
- Adding a dependency in `clients/` or `prod/`
- Exposing a service beyond localhost
