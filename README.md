# dotfiles

My development environment as code: **Windows 11 + WSL2 (Ubuntu)**, managed with [chezmoi](https://www.chezmoi.io).

> **Status:** Phases 0–5 done.
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
| Check for secrets before pushing | `gitleaks git .` from the repo root |

**Test on a clean Ubuntu** (from the repo root):

```sh
docker run --rm -v "$PWD":/src:ro ubuntu:26.04 bash /src/tests/bootstrap-test.sh
```

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
| `~/.claude/settings.json` (WSL) | Claude Code | `deny` and `ask` rules that enforce the most critical rules. It's a modify template, so settings Claude Code writes itself are kept |

**Cursor** reads the `AGENTS.md` at the root of the project you open, not the one in `~/projects`. Its global User Rules live in its own settings, not in a file, so they can't be managed here. Do this once per machine: in Cursor, go to Settings → Rules → User Rules and add:

> Before changing anything, read and follow the shared workspace rules in `~/projects/AGENTS.md` (in WSL).

**Guardrails, not a security boundary.** Deny rules match the usual command forms; `sh -c "sudo ..."` or a full program path won't match. For hard enforcement, Claude Code's sandbox restricts writes to the project folder at the OS level.

## Goal

Any of my environments (this PC, a new PC, a dev container, or Codespaces) is ready to work with **one command**: reproducible, secure, and version-controlled.

### Success criteria

1. A fresh Windows install is ready in **under 30 minutes**, with one command per OS.
2. Running `chezmoi apply` twice in a row changes nothing the second time (idempotent).
3. **Zero secrets** in the repo. Secrets come from Bitwarden at apply time, and gitleaks scans the history before every push (and in CI, Phase 7).
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
| 3 | Secrets | Bitwarden (`bw` CLI). age only if a whole file ever needs encrypting | Already in use, and free. Nothing secret is ever committed in plain text. No gitleaks pre-commit hook: a manual scan before each push, plus CI, is enough for now. |
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
    ├── projects/AGENTS.md     # layout + isolation rules for every agent in ~/projects
    ├── projects/CLAUDE.md     # one line: @AGENTS.md
    ├── dot_claude/            # Claude Code: global instructions + deny/ask rules
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
- [x] **Phase 4:** secrets + SSH (SSH config, gh, gitleaks scans, Bitwarden CLI wired into chezmoi). Dropped: the gitleaks pre-commit hook. Deferred: age, until there's a file to encrypt
- [x] **Phase 5:** AI agents (shared `AGENTS.md`, global Claude instructions, deny/ask rules, Cursor User Rules bridge)
- [ ] **Phase 6:** dev containers + Codespaces (`install.sh`)
- [ ] **Phase 7:** CI + final docs
