# Inventory

Snapshot of the machine taken on 2026-10-22, before chezmoi manages anything.
It answers three questions for every piece of config: **where it lives**, **who owns it**, and **in which phase it moves into the repo**.

**Legend:** ✅ manage · 🧩 template (differs per machine) · 📜 script (installed or created, not copied) · 🔒 secret (Bitwarden/age, never plain text) · ⛔ exclude (state, cache, or personal)

A scan for secret-looking values in the current shell and git config found nothing.

## WSL (Ubuntu 26.04, user `user`)

| Item | Today | Plan | Phase |
|---|---|---|---|
| `~/.bashrc` | Ubuntu default + a `machine-setup` block, with `~/.local/bin` added to PATH twice | ✅ Move the custom block into a shared `~/.config/shell/` that zsh and bash both source, and remove the duplicate PATH line | 2 |
| `~/.zshrc` | Doesn't exist (zsh isn't installed) | ✅ New, with completion, history, and plugins from apt | 2 |
| `~/.profile`, `~/.bash_logout` | Ubuntu defaults | ⛔ Leave as is | – |
| `~/.gitconfig` | defaultBranch, autocrlf, pull.rebase, fetch.prune, name, email | 🧩 Name and email are asked once by `chezmoi init` | 2 |
| `~/.config/mise/config.toml` | node lts, starship, uv | ✅ Manage | 2 |
| apt packages | 35 marked manual; ours: bat, build-essential, ca-certificates, curl, fd-find, fzf, git, htop, jq, ripgrep, tree, unzip, wget, zip, zoxide | 📜 `run_onchange_` script with the package list, adding zsh, zsh-autosuggestions, and zsh-syntax-highlighting | 2 |
| `~/.local/bin/mise` | Installed by mise.run | 📜 `run_once_` install script | 2 |
| `~/.local/bin/claude` | Installed by the Claude Code installer | 📜 `run_once_` install script | 5 |
| `~/projects/{sandbox,courses,clients,prod}` | Layout changed on 2026-10-22 (it was personal/web/mobile/sandbox); crawlr is at `~/projects/crawlr` | 📜 Script creates the folders. ✅ `~/projects/CLAUDE.md` holds the layout and isolation rules. Where crawlr goes is an open question (see below) | 2 |
| `/etc/wsl.conf` | `systemd=true`, `default=user` (distro defaults) | 📜 Check only; it's outside `$HOME` and needs sudo | 2 |
| `~/.ssh/` | **Doesn't exist**: no SSH keys yet | 🔒 Generate one key per machine, template `~/.ssh/config`, upload the public key to GitHub. The private key never goes in the repo | 4 |
| `~/.claude/settings.json` | `{"theme": "dark"}` | ✅ Manage | 5 |
| `~/.claude/CLAUDE.md` | Doesn't exist | ✅ New: a one-line `@AGENTS.md` bridge | 5 |
| `~/.claude/.credentials.json`, `history.jsonl`, `projects/`, `sessions/`, `session-env/`, `shell-snapshots/`, `cache/`, `backups/`, `downloads/`, `plugins/` | Claude Code state | ⛔ Never manage (credentials and history) | – |
| `~/.claude.json` | Claude Code app state | ⛔ Exclude | – |
| `~/.bash_history`, `~/.lesshst`, `~/.cache/`, `~/.landscape/`, `~/.motd_shown`, `~/.config/ubuntu-insights/` | Runtime state | ⛔ Exclude | – |
| docker CLI | Provided by Docker Desktop's WSL integration | ⛔ Nothing to manage in WSL | – |
| Missing tools | chezmoi, gh, bw, age, gitleaks | 📜 Install via mise or apt | 2 / 4 |

## Windows (`C:\Users\Usuario`)

| Item | Today | Plan | Phase |
|---|---|---|---|
| `~\.wslconfig` | 20 GB RAM, 12 CPUs, 8 GB swap, autoMemoryReclaim, sparseVhd | ✅ Manage (Windows-only target) | 3 |
| Windows Terminal `settings.json` | Ubuntu as default profile, starts in `~`, `useExisting` windowing | ✅ Manage. Terminal rewrites this file itself, so use a `modify_` script rather than a full copy | 3 |
| Start Menu shortcut "Ubuntu Dev" (Ctrl+Alt+T) | Created by `setup.ps1` | 📜 `run_once_` PowerShell script | 3 |
| Quick Access pin for `\\wsl.localhost\Ubuntu-26.04\home\user\projects` | Pinned by hand on 2026-10-22 | 📜 `run_once_` PowerShell script | 3 |
| Cursor `%APPDATA%\Cursor\User\settings.json` | Exists | ✅ Manage | 3 |
| Cursor extensions | anysphere.remote-ssh, anysphere.remote-wsl | 📜 `run_onchange_` with the extension list | 3 |
| `~\.cursor\agents`, `~\.cursor\skills-cursor` | Cursor agent config | ✅ Review in Phase 5 (shared AI rules) | 5 |
| `~\.cursor\extensions`, `projects`, `ai-tracking`, `plugins`, `argv.json` | Cursor state | ⛔ Exclude | – |
| `~\.claude\` | State only; no `settings.json` or `CLAUDE.md` | ✅ Same `CLAUDE.md` / settings as WSL | 5 |
| `~\.claude.json`, `~\.claude.json.backup` | Claude Code app state | ⛔ Exclude | – |
| `~\.config\opencode` | OpenCode config | ❓ Open question (see below) | 5 |
| `~\.docker\` | Managed by Docker Desktop; may reference a credential store | ⛔ Exclude | – |
| PowerShell profile | Doesn't exist | ⛔ Not needed; daily work happens in WSL | – |
| git on Windows | Not installed | ⛔ Not needed; chezmoi on Windows uses its built-in git | – |
| `machine-setup/setup.ps1` + `ubuntu-setup.sh` (in project A) | Already applied once | 📜 Absorbed into chezmoi scripts, then deleted | 2 / 3 |

### Windows apps (winget)

| Plan | Packages |
|---|---|
| ✅ Dev set → `winget configure` file | Microsoft.WindowsTerminal, Microsoft.WSL, Anysphere.Cursor, Docker.DockerDesktop, Bitwarden.Bitwarden, Anthropic.Claude, **twpayne.chezmoi** (new) |
| ❓ Review | SST.OpenCodeDesktop, Python.Python.3.12 + Python.Launcher (Python on Windows is likely unnecessary, since dev work happens in WSL) |
| ⛔ Personal | EpicGames.*, RockstarGames.Launcher, ElectronicArts.EADesktop, CPUID.*, Guru3D.RTSS, Nvidia.PhysX, Logitech.OptionsPlus, WhirlwindFX.SignalRgb, RARLab.WinRAR, Malwarebytes.Malwarebytes, Microsoft.OneDrive, Microsoft.Edge, Microsoft.365Copilot |
| ⛔ Runtimes (installed automatically as dependencies) | Microsoft.VCRedist.*, Microsoft.VCLibs.*, Microsoft.UI.Xaml.*, Microsoft.WindowsAppRuntime.*, Microsoft.DotNet.Native.Runtime, Microsoft.GameInput, Microsoft.AppInstaller |

## Open questions

1. **crawlr location:** which folder does it belong in: `prod/`, `sandbox/`, or somewhere else?
2. **OpenCode:** do you still use it? If yes, its config joins the shared AI rules in Phase 5. If not, it gets removed from the app list.
3. **Python on Windows:** keep it or uninstall it?
