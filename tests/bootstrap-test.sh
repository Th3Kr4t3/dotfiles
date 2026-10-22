#!/usr/bin/env bash
# Bootstraps the full machine profile (what WSL gets) on a clean Ubuntu and checks the result.
# Run from the repo root:
#   docker run --rm -v "$PWD":/src:ro ubuntu:26.04 bash /src/tests/bootstrap-test.sh
set -euo pipefail

# Docker would be detected as a container; this test is about the machine profile.
export DOTFILES_PROFILE=machine

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
    for t in mise starship node uv gh gitleaks bw zoxide fzf; do
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

step "Agent instructions and Claude Code guardrails"
grep -qx '@AGENTS.md' ~/projects/CLAUDE.md
test -f ~/projects/AGENTS.md
test -f ~/.claude/CLAUDE.md
grep -q '^name: onboard$' ~/.claude/skills/onboard/SKILL.md
grep -q '^name: handoff$' ~/.claude/skills/handoff/SKILL.md
jq -e '.permissions.deny | index("Bash(sudo *)")' ~/.claude/settings.json >/dev/null
jq -e '.permissions.ask | index("Bash(chezmoi apply *)")' ~/.claude/settings.json >/dev/null
echo "agents: ok"

step "Strict Claude Code sandbox and its dependencies"
jq -e '.sandbox | .enabled and .failIfUnavailable and (.allowUnsandboxedCommands == false)' \
  ~/.claude/settings.json >/dev/null
command -v bwrap >/dev/null && command -v socat >/dev/null
echo "sandbox: ok"

step "SSH config is private"
[ "$(stat -c %a ~/.ssh)" = 700 ] && [ "$(stat -c %a ~/.ssh/config)" = 600 ]
echo "ssh: ok"

step "Interactive shells load tools and aliases"
check_shell zsh
check_shell bash

step "All checks passed"
