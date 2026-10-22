#!/usr/bin/env bash
# Re-runs only when this file changes, so editing the list is how you add a package.
set -euo pipefail

packages=(
  bat build-essential ca-certificates curl fd-find fzf git htop jq
  ripgrep tree unzip wget zip zoxide
  zsh zsh-autosuggestions zsh-syntax-highlighting
  bubblewrap socat  # Claude Code's Bash sandbox
)

SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"
$SUDO apt-get update -y
$SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
