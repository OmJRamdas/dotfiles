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

mkdir -p "$CONFIG"

link wezterm wezterm
link nvim    nvim
link tmux    tmux

echo "syncing neovim plugins..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
