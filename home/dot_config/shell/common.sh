# Shared by zsh and bash, so containers without zsh get the same experience.

# mise shims let non-interactive commands (Claude Code, IDE tasks) resolve per-project tool
# versions; in an interactive shell, `mise activate` below takes precedence over them.
for dir in "$HOME/.local/share/mise/shims" "$HOME/.local/bin"; do
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) PATH="$dir:$PATH" ;;
  esac
done
export PATH
unset dir

# One ssh-agent shared by every shell. The key is added on first use (AddKeysToAgent),
# so the passphrase is asked once per WSL boot. Forwarded agents (Codespaces) are left alone.
if [ -z "$SSH_AUTH_SOCK" ] && [ -d "$HOME/.ssh" ] && command -v ssh-agent >/dev/null 2>&1; then
  export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
  ssh-add -l >/dev/null 2>&1
  if [ $? -eq 2 ]; then   # 2 = no agent listening on the socket
    rm -f "$SSH_AUTH_SOCK"
    ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null
  fi
fi

if [ -n "$ZSH_VERSION" ]; then _sh=zsh; else _sh=bash; fi
command -v mise     >/dev/null 2>&1 && eval "$(mise activate $_sh)"   # per-folder tool versions
command -v starship >/dev/null 2>&1 && eval "$(starship init $_sh)"   # prompt with git branch
command -v zoxide   >/dev/null 2>&1 && eval "$(zoxide init $_sh --cmd cd)"  # `cd crawlr` jumps there
command -v fzf      >/dev/null 2>&1 && eval "$(fzf --$_sh)"           # Ctrl+R history, Ctrl+T files
unset _sh

alias ll='ls -lah --color=auto'
command -v batcat >/dev/null 2>&1 && alias bat='batcat'
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'
alias p='cd ~/projects'
alias gs='git status -sb'
alias gl='git log --oneline --graph -20'
alias c='cursor .'
if command -v explorer.exe >/dev/null 2>&1; then   # WSL only
  alias e='explorer.exe .'                          # open the current folder in Explorer
  export BROWSER="$HOME/.local/bin/open-in-windows" # CLIs open links in the Windows browser
fi
alias dots='chezmoi cd'
