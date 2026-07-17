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

install_ripgrep() {
  if command -v rg &>/dev/null; then
    echo "ripgrep already installed"
    return
  fi
  echo "installing ripgrep..."
  if command -v brew &>/dev/null; then
    brew install ripgrep
  elif command -v apt &>/dev/null; then
    sudo apt install -y ripgrep
  else
    echo "no supported package manager found, install ripgrep manually" >&2
  fi
}

install_fzf() {
  if command -v fzf &>/dev/null; then
    echo "fzf already installed"
  else
    echo "installing fzf..."
    if command -v brew &>/dev/null; then
      brew install fzf
    elif command -v apt &>/dev/null; then
      sudo apt install -y fzf
    else
      echo "no supported package manager found, install fzf manually" >&2
      return
    fi
  fi

  local marker="# >>> dotfiles fzf keybindings >>>"
  local bashrc="$HOME/.bashrc"
  if grep -qF "$marker" "$bashrc" 2>/dev/null; then
    echo "fzf keybindings already in $bashrc, removing stale block to refresh it"
    sed -i "/^${marker}$/,/^# <<< dotfiles fzf keybindings <<<$/d" "$bashrc"
  fi
  echo "adding fzf keybindings to $bashrc"
  cat >> "$bashrc" << 'EOF'

# >>> dotfiles fzf keybindings >>>
# fuzzy Ctrl-R history search / Ctrl-T file search
# fzf >= 0.48 supports `fzf --bash`; older distro-packaged fzf (e.g. Ubuntu's/
# Debian's apt version) ships static key-bindings/completion scripts instead.
# NOTE: never probe by running `fzf --bash` directly on an unknown version -
# older fzf doesn't recognize the flag and falls through to its normal
# interactive mode, silently reading your real terminal stdin. Compare the
# version string instead.
if command -v fzf &>/dev/null; then
  __fzf_ver="$(fzf --version 2>/dev/null | awk '{print $1}')"
  if [ -n "$__fzf_ver" ] && [ "$(printf '%s\n%s\n' "$__fzf_ver" "0.48.0" | sort -V | tail -n1)" = "$__fzf_ver" ]; then
    eval "$(fzf --bash)"
  else
    for f in /usr/share/doc/fzf/examples/key-bindings.bash /opt/homebrew/opt/fzf/shell/key-bindings.bash; do
      [ -f "$f" ] && source "$f"
    done
    for f in /usr/share/bash-completion/completions/fzf /opt/homebrew/opt/fzf/shell/completion.bash; do
      [ -f "$f" ] && source "$f"
    done
  fi
  unset __fzf_ver
fi
# <<< dotfiles fzf keybindings <<<
EOF
}

install_neovim
install_ripgrep
install_fzf
setup_ssh_agent

mkdir -p "$CONFIG"

link wezterm wezterm
link nvim    nvim
link tmux    tmux

echo "syncing neovim plugins..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
