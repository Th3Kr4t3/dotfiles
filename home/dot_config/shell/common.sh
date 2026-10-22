# Shared by zsh and bash, so containers without zsh get the same experience.

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

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
command -v explorer.exe >/dev/null 2>&1 && alias e='explorer.exe .'   # WSL only: open folder in Explorer
alias dots='chezmoi cd'
