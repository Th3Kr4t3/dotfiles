# dotfiles

My development environment as code: **Windows 11 + WSL2 (Ubuntu)**, managed with [chezmoi](https://www.chezmoi.io).

> **Status:** Phases 0–3 done, Phase 4 in progress.
> **WSL:** shell (zsh + bash fallback), git, SSH config, mise tools (including gh and gitleaks), and apt packages.
> **Windows:** `.wslconfig`, Windows Terminal, Cursor, dev apps (winget), the Start Menu shortcut, and the Quick Access pin.
> The Linux bootstrap is tested on a clean Ubuntu 26.04 container.

## Usage

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

**Containers or plain Linux:** step 2 alone.

**Day to day:**

| Task | Command |
|---|---|
| Preview what would change | `chezmoi diff` |
| Edit a managed file | `chezmoi edit ~/.zshrc`, then `chezmoi apply` |
| Start managing a new file | `chezmoi add ~/.config/foo` |
| Pull from GitHub and apply | `chezmoi update` |
| Go to this repo | `dots` (alias for `chezmoi cd`) |
| Add an apt package | Edit `home/.chezmoiscripts/linux/run_onchange_before_10-apt-packages.sh`; it re-runs on the next apply |
| Add a Windows app | Edit `home/.chezmoiscripts/windows/run_onchange_before_10-winget-apps.ps1` |
| Apply changes on Windows | `chezmoi apply` in PowerShell (it reads the repo in WSL) |
| Keep a setting you changed in Cursor's UI | `chezmoi re-add` in PowerShell, then commit in WSL |

**Test on a clean Ubuntu** (from the repo root):

```sh
docker run --rm -v "$PWD":/src:ro ubuntu:26.04 bash /src/tests/bootstrap-test.sh
```

## Goal

Any of my environments (this PC, a new PC, a dev container, or Codespaces) is ready to work with **one command**: reproducible, secure, and version-controlled.

### Success criteria

1. A fresh Windows install is ready in **under 30 minutes**, with one command per OS.
2. Running `chezmoi apply` twice in a row changes nothing the second time (idempotent).
3. **Zero secrets** in the repo, enforced by gitleaks in pre-commit and CI.
4. The same shell experience in WSL, dev containers, and Codespaces.
5. AI agent rules are versioned and shared between Claude Code and Cursor.
6. CI tests the bootstrap on a clean Ubuntu on every push.
7. This README explains the structure and how to update it.

**Out of scope:** per-project environments (they live in each project's repo), macOS, servers.

## Decisions

| # | Topic | Choice | Why |
|---|---|---|---|
| 1 | Dotfiles manager | chezmoi | The only tool that covers Windows + WSL + containers with templates, secrets, and `run_onchange_` scripts in a single binary. |
| 2 | Repo visibility | Public | Portfolio value. Safe because personal data comes from templates and secrets from Bitwarden. |
| 3 | Secrets | Bitwarden (`bw` CLI), plus age for static files | Already in use, and free. Nothing secret is ever committed in plain text. |
| 4 | Shell (WSL) | zsh, with no framework (no oh-my-zsh) | Better completion. Plugins come from apt. Aliases live in one shared file that bash can also source, so containers without zsh still work. |
| 5 | Windows apps | Dev tools only, installed by a `winget install` script | Games and hardware utilities are personal, not part of the environment. `winget configure` was dropped because it needs an admin-only enable step and PowerShell DSC modules on every new PC. |
| 6 | Repo layout | `.chezmoiroot` → `home/` | Keeps the README, docs, and CI out of `$HOME`. |
| 7 | Source location | One clone, in WSL at the chezmoi default (`~/.local/share/chezmoi`). chezmoi on Windows reads it through `\\wsl.localhost` | One repo to edit and commit, and no second clone to keep in sync. `chezmoi re-add` on Windows writes straight into it. |
| 8 | Decision log | This table + commit messages | No ADRs for a personal repo. Any change can be undone with `git revert`. |

To change a decision, edit its row in the same commit as the change, and explain why in the commit message.

## Layout

```
.
├── README.md
├── docs/inventory.md          # what is managed, where, and how
├── tests/bootstrap-test.sh    # clean-Ubuntu bootstrap check
├── .chezmoiroot               # contains "home"
└── home/                      # everything chezmoi applies
    ├── .chezmoi.toml.tmpl     # per-machine data: name, email, isWSL, isContainer
    ├── .chezmoiignore         # which files go to Windows vs Linux
    ├── dot_zshrc              # default shell
    ├── dot_bashrc             # fallback shell
    ├── dot_gitconfig.tmpl
    ├── dot_config/shell/      # aliases + tool init shared by zsh and bash
    ├── dot_config/mise/       # global tool versions
    ├── projects/CLAUDE.md     # layout + isolation rules for every project in ~/projects
    ├── dot_wslconfig          # Windows: WSL resource limits
    ├── AppData/               # Windows: Terminal (modify template) + Cursor settings
    └── .chezmoiscripts/
        ├── linux/             # apt packages, mise, ~/projects folders, default shell
        └── windows/           # winget apps, Cursor extensions, Start Menu shortcut, Quick Access pin
```

## Roadmap

- [x] **Phase 0:** decisions
- [x] **Phase 1:** inventory ([docs/inventory.md](docs/inventory.md))
- [x] **Phase 2:** MVP on WSL (zsh, git, mise, apt), tested on a clean container
- [x] **Phase 3:** Windows side (`.wslconfig`, Terminal, Cursor, winget apps, shortcut, Quick Access)
- [ ] **Phase 4:** secrets + SSH. Done: SSH config, gh, gitleaks history scan. Pending: Bitwarden, age, gitleaks pre-commit
- [ ] **Phase 5:** AI agents (`AGENTS.md`, Claude Code, Cursor)
- [ ] **Phase 6:** dev containers + Codespaces (`install.sh`)
- [ ] **Phase 7:** CI + final docs
