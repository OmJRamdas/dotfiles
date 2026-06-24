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

mkdir -p "$CONFIG"

link wezterm wezterm
link nvim    nvim
