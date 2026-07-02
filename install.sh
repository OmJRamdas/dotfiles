#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"

link() {
  local src="$DOTFILES/$1"
  local dst="$CONFIG/$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "backing up $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  ln -sfn "$src" "$dst"
  echo "linked $dst -> $src"
}

setup_ssh_agent() {
  local marker="# >>> dotfiles ssh-agent autostart >>>"
  local bashrc="$HOME/.bashrc"
  if grep -qF "$marker" "$bashrc" 2>/dev/null; then
    echo "ssh-agent autostart already in $bashrc"
    return
  fi
  echo "adding ssh-agent autostart to $bashrc"
  cat >> "$bashrc" << 'EOF'

# >>> dotfiles ssh-agent autostart >>>
SSH_ENV="$HOME/.ssh/agent-env"

start_ssh_agent() {
    ssh-agent -s > "$SSH_ENV"
    chmod 600 "$SSH_ENV"
    source "$SSH_ENV" > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
}

if [ -f "$SSH_ENV" ]; then
    source "$SSH_ENV" > /dev/null
    ssh-add -l > /dev/null 2>&1
    if [ $? -eq 2 ]; then
        start_ssh_agent
    fi
else
    start_ssh_agent
fi
# <<< dotfiles ssh-agent autostart <<<
EOF
}

NVIM_VERSION="v0.11.2"

install_neovim() {
  local current
  current=$(nvim --version 2>/dev/null | head -1 | grep -oP 'v[\d.]+' || echo "none")
  if [ "$current" = "$NVIM_VERSION" ]; then
    echo "nvim $NVIM_VERSION already installed"
    return
  fi
  echo "installing neovim $NVIM_VERSION (current: $current)..."
  if command -v brew &>/dev/null; then
    brew install neovim
    return
  fi
  curl -fLo /tmp/nvim.tar.gz \
    "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
  sudo tar -C /usr/local --strip-components=1 -xzf /tmp/nvim.tar.gz
  rm /tmp/nvim.tar.gz
  echo "nvim $(nvim --version | head -1) installed"
}

install_neovim
setup_ssh_agent

mkdir -p "$CONFIG"

link wezterm wezterm
link nvim    nvim
link tmux    tmux

echo "syncing neovim plugins..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
