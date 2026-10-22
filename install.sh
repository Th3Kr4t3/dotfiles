#!/bin/sh
# Entry point for GitHub Codespaces and dev containers: they clone this repo and run this file.
# It installs chezmoi if needed and applies the light "container" profile:
# shell, git, and Claude settings, but no global toolchain (the project's image provides that).
set -eu

export DOTFILES_PROFILE="${DOTFILES_PROFILE:-container}"

if command -v chezmoi >/dev/null 2>&1; then
  chezmoi=chezmoi
else
  bin_dir="$HOME/.local/bin"
  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$bin_dir"
  elif command -v wget >/dev/null 2>&1; then
    sh -c "$(wget -qO- get.chezmoi.io)" -- -b "$bin_dir"
  else
    echo "install.sh: curl or wget is required to install chezmoi" >&2
    exit 1
  fi
  chezmoi="$bin_dir/chezmoi"
fi

script_dir="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"
exec "$chezmoi" init --apply --promptDefaults --source="$script_dir"
