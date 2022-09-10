#!/bin/bash

VIM_CONFIG_REPO_OWNER="jeroenlammersma"
VIM_CONFIG_REPO_NAME="vim-config"

function setup_vim() {
  echo "Installing Vim"
  if command -v "vim" > /dev/null 2>&1; then
    echo "Vim already installed"
  else
    sudo apt-get install -y vim
  fi

  local -r vim_config_path="$scratch/$VIM_CONFIG_REPO_NAME"
  # cloning repo
  git clone "https://github.com/$VIM_CONFIG_REPO_OWNER/$VIM_CONFIG_REPO_NAME.git" \
            "$vim_config_path" --recurse-submodules -j"$(nproc)" --quiet > /dev/null

  # copy config
  if [ ! -f "$HOME/.vimrc" ]; then
    cp "$vim_config_path/.vimrc" "$HOME/.vimrc"
    echo "Configured .vimrc"
  fi
  if [ ! -d "$HOME/.vim" ]; then
    cp "$vim_config_path/.vim" "$HOME/.vim" -r
    echo "Configured .vim"
  fi
}
