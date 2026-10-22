#!/usr/bin/env bash
# Bootstraps the dotfiles on a clean Ubuntu and checks the result.
# Run from the repo root:
#   docker run --rm -v "$PWD":/src:ro ubuntu:26.04 bash /src/tests/bootstrap-test.sh
set -euo pipefail

step() { printf '\n\033[1;36m== %s\033[0m\n' "$1"; }

step "Install prerequisites (curl, git) and chezmoi"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl ca-certificates git >/dev/null
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin

step "First apply"
chezmoi init --apply --promptDefaults --source /src

step "Second apply must change nothing"
chezmoi verify --source /src
echo "idempotent: ok"

step "Machine data"
chezmoi data --source /src --format yaml | grep -E 'is(Container|WSL)'

check_shell() {
  "$1" -i -c '
    for t in mise starship node uv zoxide fzf; do
      command -v "$t" >/dev/null || { echo "missing: $t"; exit 1; }
    done
    alias gs >/dev/null || { echo "missing alias: gs"; exit 1; }
    echo "'"$1"': ok"
  '
}

step "Projects workspace has its rules and folders"
test -f ~/projects/CLAUDE.md
for d in sandbox courses clients prod; do test -d ~/projects/"$d"; done
echo "projects: ok"

step "Interactive shells load tools and aliases"
check_shell zsh
check_shell bash

step "All checks passed"
