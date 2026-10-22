# dotfiles

[![CI](https://github.com/Th3Kr4t3/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/Th3Kr4t3/dotfiles/actions/workflows/ci.yml)

My development environment as code: **Windows 11 + WSL2 (Ubuntu 26.04)**, plus Codespaces and dev containers, managed with [chezmoi](https://www.chezmoi.io).

One repo, three profiles:

| Profile | Where | What it sets up |
|---|---|---|
| **Machine** | WSL / Linux | zsh (bash as fallback) with shared aliases, git, SSH config, mise tools (node, uv, starship, gh, gitleaks, Bitwarden CLI), apt packages, `~/projects` with its agent rules, Claude Code guardrails and a strict Bash sandbox |
| **Windows** | The Windows host | `.wslconfig`, Windows Terminal, Cursor settings and extensions, dev apps via winget, a Start Menu shortcut (Ctrl+Alt+T), a Quick Access pin |
| **Container** | Codespaces, dev containers | The shell experience only: zsh/bash config, starship, fzf, zoxide, ripgrep, git, Claude settings. Applies in about 20 seconds |

## Quick start

**New Windows PC**, in three steps:

1. In PowerShell, install WSL and create the Linux user `user`:
   ```powershell
   wsl --install -d Ubuntu-26.04
   ```
2. In Ubuntu, one command sets up the whole Linux side:
   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply Th3Kr4t3
   ```
3. In PowerShell, point the Windows side at that same clone. Open a new PowerShell after the install, so `chezmoi` is on the PATH:
   ```powershell
   winget install --id twpayne.chezmoi -e
   chezmoi init --apply --source \\wsl.localhost\Ubuntu-26.04\home\user\.local\share\chezmoi
   ```

Then, once per machine, add the Cursor User Rule described in [AI agents](#ai-agents).

**Plain Linux (a VM or server):** step 2 alone.
**Codespaces and dev containers:** see [Containers](#containers).

## Day to day

Edit and commit in WSL. Windows reads the same clone, so it only needs `chezmoi apply`.

| Task | Command |
|---|---|
| Preview what would change | `chezmoi diff` |
| Edit a managed file | `chezmoi edit ~/.zshrc`, then `chezmoi apply` |
| Start managing a new file | `chezmoi add ~/.config/foo` |
| Pull from GitHub and apply | `chezmoi update` |
| Go to this repo | `dots` (alias for `chezmoi cd`) |
| Add an apt package | Edit `home/.chezmoiscripts/linux/run_onchange_before_10-apt-packages.sh` (containers: `…-apt-packages-container.sh.tmpl`). It re-runs on the next apply |
| Add a global tool | Edit `home/dot_config/mise/config.toml` |
| Add a Windows app | Edit `home/.chezmoiscripts/windows/run_onchange_before_10-winget-apps.ps1` |
| Apply changes on Windows | `chezmoi apply` in PowerShell |
| Keep a setting you changed in Cursor's UI | `chezmoi re-add` in PowerShell, then commit in WSL |
| Check for secrets before pushing | `gitleaks git .` from the repo root |

## Containers

Codespaces and dev containers clone this repo and run [`install.sh`](install.sh), which applies the light **container profile**:

| Gets | Skips, and why |
|---|---|
| zsh/bash config and aliases, starship, fzf, zoxide, ripgrep | mise and its global tools: the project's image defines node, python, and so on, and global versions would shadow them |
| `.gitconfig` (noreply email) | `~/.ssh`: Codespaces forwards its own SSH agent, and our `IdentitiesOnly` config would block it |
| Claude Code instructions and deny/ask rules | `~/projects`, `.wslconfig`, and the Windows files |

- **Codespaces**, once per account: GitHub → Settings → Codespaces → Dotfiles → *Automatically install dotfiles* → `Th3Kr4t3/dotfiles`. It applies to new codespaces only.
- **Cursor dev containers:** the managed Cursor settings set `dotfiles.repository`, and the `anysphere.remote-containers` extension clones the repo and runs `install.sh`. Cursor doesn't document this officially. If a container opens without your shell, run `git clone https://github.com/Th3Kr4t3/dotfiles ~/dotfiles && sh ~/dotfiles/install.sh` inside it.
- `DOTFILES_PROFILE=machine` or `container` overrides the detection. `install.sh` sets `container`.

## Secrets

- **Project secrets** (API keys for a single app) live in that project's `.env`, which is gitignored. They never go in the dotfiles.
- **Machine-wide secrets** live in Bitwarden. chezmoi reads them at apply time, so the repo only ever contains a reference to them.

To add one:

1. Log in once per machine with `bw login`. If your account is on the EU server, first run `bw config server https://vault.bitwarden.eu`.
2. Store the secret in Bitwarden, for example as a login item named `npm-token`.
3. Reference it from a template (a source file ending in `.tmpl`):
   ```
   //registry.npmjs.org/:_authToken={{ (bitwarden "item" "npm-token").login.password }}
   ```
4. Run `chezmoi apply`. It unlocks the vault when needed and asks for the master password.

Never `chezmoi add` a file that contains a secret as is. Add it with `--template` and replace the value with the Bitwarden call. Bitwarden's own state (`~/.config/Bitwarden CLI/`) is never managed.

## AI agents

| File | Read by | Purpose |
|---|---|---|
| `~/projects/AGENTS.md` | Claude Code (through `~/projects/CLAUDE.md`, whose only line is `@AGENTS.md`), Cursor (through its User Rules), and other agents | Shared workspace rules: isolation, layout, ports, promotion checklist |
| `~/.claude/CLAUDE.md` | Claude Code, in WSL and on Windows | Personal instructions: language, English coaching, machine changes |
| `~/.claude/settings.json` (WSL) | Claude Code | `deny` and `ask` rules, plus the strict sandbox below. It's a modify template, so settings Claude Code writes itself are kept |
| `~/.claude/skills/onboard`, `~/.claude/skills/handoff` | Claude Code, in WSL and on Windows | Session commands that only you can invoke (see below) |

**Session workflow.** Open a project from the Ubuntu terminal (`cd ~/projects/<folder>/<name> && claude`), then:

- `/onboard [goal]` checks that it's running in WSL (on Windows it stops and tells you to reopen from Ubuntu), reads the workspace and project rules, the history, and the tests, reports where the project stands, proposes next steps, and waits. On an empty folder, it asks for the stack and proposes the initial setup.
- `/handoff [notes]` writes a short "Current status" section in the project's `AGENTS.md` and commits it, so the next `/onboard` picks up from there.

**Cursor** reads the `AGENTS.md` at the root of the project you open, not the one in `~/projects`. Its global User Rules live in its own settings, not in a file, so they can't be managed here. Do this once per machine: in Cursor, go to Settings → Rules → User Rules and add:

> Before changing anything, read and follow the shared workspace rules in `~/projects/AGENTS.md` (in WSL).

### Sandbox (WSL)

Deny rules are guardrails: they match the usual command forms, and `sh -c "sudo ..."` or a full program path won't match. The real boundary is Claude Code's **Bash sandbox**, enforced by the OS through bubblewrap, in strict mode:

| Setting | Effect |
|---|---|
| Writes | Only the project folder, the temp directory, and package caches (`~/.cache`, `~/.npm`, pnpm, mise, cargo, go) |
| Reads | Everything except `~/.ssh`, Bitwarden's data, and Claude's credentials |
| Network | GitHub and the npm, PyPI, Node, crates, and Go registries; any other host asks first |
| `allowUnsandboxedCommands: false` | Claude can't retry a failed command outside the sandbox |
| `failIfUnavailable: true` | If the sandbox can't start, Claude Code refuses to run instead of running unprotected |
| `excludedCommands` | `docker compose/ps/logs` (docker can't run sandboxed) and `git push/pull/fetch` (SSH doesn't go through the proxy). They run outside the sandbox and ask first |

It applies only to Claude Code running **inside WSL**: native Windows has no sandbox, and containers already isolate (bubblewrap can't start inside Docker). Claude's own Read and Edit tools aren't sandboxed; the deny rules cover them. Run `/sandbox` in a session to inspect it.

## Testing and CI

Every push and pull request runs [CI](.github/workflows/ci.yml):

| Job | What it proves |
|---|---|
| gitleaks (full history) | No secret in any commit |
| machine profile on a clean Ubuntu | The WSL bootstrap installs everything, both shells load the tools, and a second apply changes nothing |
| container profile on a clean Ubuntu | A Codespaces-like user (non-root, with sudo) runs `install.sh` from a clone and gets the light profile, idempotently |

Run the same tests locally from the repo root:

```sh
docker run --rm -v "$PWD":/src:ro ubuntu:26.04 bash /src/tests/bootstrap-test.sh
docker run --rm -v "$PWD":/src:ro ubuntu:26.04 bash /src/tests/container-test.sh
```

The Windows profile isn't covered by CI. It was verified by hand on the real machine (preview, apply, and a second apply with no changes).

## Goal

Any of my environments (this PC, a new PC, a dev container, or Codespaces) is ready to work with **one command**: reproducible, secure, and version-controlled.

| # | Success criterion | Status |
|---|---|---|
| 1 | A fresh Windows install is ready in under 30 minutes, with one command per OS | ⚠️ The Linux side takes about 2 minutes from GitHub on a clean Ubuntu. The Windows side hasn't been timed on a fresh install yet |
| 2 | Running `chezmoi apply` twice in a row changes nothing the second time | ✅ Checked by both CI tests and on the real machine |
| 3 | Zero secrets in the repo | ✅ Secrets come from Bitwarden at apply time, and gitleaks scans the full history in CI |
| 4 | The same shell experience in WSL, dev containers, and Codespaces | ✅ One shared `common.sh`. The container profile is tested in CI; a real codespace is still to be tried |
| 5 | AI agent rules are versioned and shared between Claude Code and Cursor | ✅ `AGENTS.md` + `@AGENTS.md` bridge + a Cursor User Rule |
| 6 | CI tests the bootstrap on a clean Ubuntu on every push | ✅ |
| 7 | This README explains the structure and how to update it | ✅ |

**Out of scope:** per-project environments (they live in each project's repo), macOS, servers.

## Decisions

| # | Topic | Choice | Why |
|---|---|---|---|
| 1 | Dotfiles manager | chezmoi | The only tool that covers Windows + WSL + containers with templates, secrets, and `run_onchange_` scripts in a single binary. |
| 2 | Repo visibility | Public | Portfolio value. Safe because personal data comes from templates and secrets from Bitwarden. |
| 3 | Secrets | Bitwarden (`bw` CLI). age only if a whole file ever needs encrypting | Already in use, and free. Nothing secret is ever committed in plain text. No gitleaks pre-commit hook: a manual scan before each push, plus CI, is enough. |
| 4 | Shell (WSL) | zsh, with no framework (no oh-my-zsh) | Better completion. Plugins come from apt. Aliases live in one shared file that bash can also source, so containers without zsh still work. |
| 5 | Windows apps | Dev tools only, installed by a `winget install` script | Games and hardware utilities are personal, not part of the environment. `winget configure` was dropped because it needs an admin-only enable step and PowerShell DSC modules on every new PC. |
| 6 | Repo layout | `.chezmoiroot` → `home/` | Keeps the README, docs, tests, and CI out of `$HOME`. |
| 7 | Source location | One clone, in WSL at the chezmoi default (`~/.local/share/chezmoi`). chezmoi on Windows reads it through `\\wsl.localhost` | One repo to edit and commit, and no second clone to keep in sync. `chezmoi re-add` on Windows writes straight into it. |
| 8 | Decision log | This table + commit messages | No ADRs for a personal repo. Any change can be undone with `git revert`. |
| 9 | Containers | A light profile through `install.sh`: no mise, no `~/.ssh` | The project's image owns the toolchain, and Codespaces brings its own SSH agent. Containers only need the shell experience. |
| 10 | CI | GitHub Actions running the same Docker tests as local, with actions pinned by commit SHA | One test suite for laptop and CI. Pinning by SHA protects a public repo from a hijacked action tag. |
| 11 | Agent isolation | Claude Code's Bash sandbox in strict mode (no unsandboxed retries, fail if unavailable), machine profile only | Turns "every change stays in the project" from a request into an OS-enforced rule. Narrow `excludedCommands` for docker and git over SSH, because a broad exclusion would grant full access. |

To change a decision, edit its row in the same commit as the change, and explain why in the commit message.

## Layout

```
.
├── README.md
├── .github/workflows/ci.yml   # gitleaks + both profile tests on every push
├── docs/inventory.md          # what is managed, where, and how
├── install.sh                 # entry point for Codespaces and dev containers
├── tests/bootstrap-test.sh    # machine profile on a clean Ubuntu
├── tests/container-test.sh    # container profile, run like Codespaces does
├── .chezmoiroot               # contains "home"
└── home/                      # everything chezmoi applies
    ├── .chezmoi.toml.tmpl     # per-machine data: name, email, isWSL, isContainer
    ├── .chezmoiignore         # which files go to Windows, Linux, and containers
    ├── dot_zshrc              # default shell
    ├── dot_bashrc             # fallback shell
    ├── dot_gitconfig.tmpl
    ├── dot_config/shell/      # aliases + tool init shared by zsh and bash
    ├── dot_config/mise/       # global tool versions
    ├── dot_local/bin/         # open-in-windows ($BROWSER in WSL)
    ├── private_dot_ssh/       # SSH config for GitHub (keys are never stored)
    ├── projects/AGENTS.md     # layout + isolation rules for every agent in ~/projects
    ├── projects/CLAUDE.md     # one line: @AGENTS.md
    ├── dot_claude/            # Claude Code: global instructions, deny/ask rules, sandbox, /onboard + /handoff
    ├── dot_wslconfig          # Windows: WSL resource limits
    ├── AppData/               # Windows: Terminal (modify template) + Cursor settings
    └── .chezmoiscripts/
        ├── linux/             # apt packages, mise, ~/projects folders, default shell, container extras
        └── windows/           # winget apps, Cursor extensions, Start Menu shortcut, Quick Access pin
```

## Roadmap

- [x] **Phase 0:** decisions
- [x] **Phase 1:** inventory ([docs/inventory.md](docs/inventory.md))
- [x] **Phase 2:** MVP on WSL (zsh, git, mise, apt), tested on a clean container
- [x] **Phase 3:** Windows side (`.wslconfig`, Terminal, Cursor, winget apps, shortcut, Quick Access)
- [x] **Phase 4:** secrets + SSH (SSH config, gh, gitleaks scans, Bitwarden CLI wired into chezmoi). Dropped: the gitleaks pre-commit hook. Deferred: age, until there's a file to encrypt
- [x] **Phase 5:** AI agents (shared `AGENTS.md`, global Claude instructions, deny/ask rules, Cursor User Rules bridge)
- [x] **Phase 6:** dev containers + Codespaces (`install.sh`, light container profile, Cursor dev containers)
- [x] **Phase 7:** CI (gitleaks + both profile tests) and this final README

**Ideas for later:** render the Windows templates in CI on a Windows runner; time a full bootstrap on a fresh Windows install.
