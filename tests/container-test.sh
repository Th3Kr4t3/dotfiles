#!/usr/bin/env bash
# Simulates GitHub Codespaces and dev containers: a non-root user with passwordless sudo
# runs install.sh from a clone of this repo, then the light container profile is checked.
# Run from the repo root:
#   docker run --rm -v "$PWD":/src:ro ubuntu:26.04 bash /src/tests/container-test.sh
set -euo pipefail

step() { printf '\n\033[1;36m== %s\033[0m\n' "$1"; }

step "Prepare a Codespaces-like user and clone"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl ca-certificates git sudo >/dev/null
useradd -m -s /bin/bash dev
echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev
cp -r /src /home/dev/dotfiles
chown -R dev:dev /home/dev/dotfiles

step "Run install.sh as that user, like Codespaces does"
start=$(date +%s)
su - dev -c 'sh ~/dotfiles/install.sh'
echo "install time: $(( $(date +%s) - start ))s"

cat > /tmp/checks.sh <<'EOF'
set -euo pipefail
export PATH="$HOME/.local/bin:$PATH"

chezmoi verify   # no --source: the clone's path must have been remembered
echo "idempotent: ok"
chezmoi data --format yaml | grep -q 'isContainer: true'
echo "profile: container"

for p in ~/.ssh ~/.config/mise ~/projects ~/.local/bin/mise; do
  [ ! -e "$p" ] || { echo "should not exist in a container: $p"; exit 1; }
done
echo "machine-only parts skipped: ok"

# bubblewrap can't start inside Docker; with failIfUnavailable, Claude Code wouldn't launch.
if grep -q '"sandbox"' ~/.claude/settings.json; then
  echo "the Claude Code sandbox must stay off in containers"; exit 1
fi
echo "sandbox off in containers: ok"

check_shell() {
  "$1" -i -c '
    for t in starship zoxide fzf rg; do
      command -v "$t" >/dev/null || { echo "missing: $t"; exit 1; }
    done
    alias gs >/dev/null || { echo "missing alias: gs"; exit 1; }
    echo "'"$1"': ok"
  ' 2>/dev/null
}
check_shell zsh
check_shell bash
EOF

step "Checks"
su - dev -c 'bash /tmp/checks.sh'

step "All checks passed"
