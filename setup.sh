#!/bin/bash

set -e

function egress() {
  rm -rf "$scratch"
}

# create scratch dir
scratch=$(mktemp -d -t tmp.XXXXXXXXXX)

# call egress on exit
trap egress EXIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


function setup_wsl() {
  kernel=$(uname -r | tr '[:upper:]' '[:lower:]')
  if [[ $kernel == *"microsoft"* ]]; then
    if [ -z "$WSL_ENV" ]; then
	  echo "Setting up wsl..."
      SETUP_WSL=1
      cp "$DIR"/wsl_env.sh ~/.wsl_env.sh
      {
        printf "\n%s" "source ~/.wsl_env.sh"
        printf "\n%s" "# enable passphrase prompt for GPG"
        printf "\n%s\n" "export GPG_TTY=\$(tty)"
      } >> ~/.bashrc
      echo "added wsl_env to bashrc"
	  printf "%s\n\n" "Done"
    fi
  fi
}

function install_tools() {
  echo "Installing tools..."
  source "$DIR/tools/tools_install.sh"
  printf "%s\n\n" "Done"
}

function configure_gpg() {
  echo "Configuring gpg..."
  local -r gpg_conf="$HOME/.gnupg/gpg-agent.conf"
  mkdir -p "$HOME/.gnupg"
  if [ ! -f "$gpg_conf" ]; then
    touch "$gpg_conf"
    {
      printf "%s" "default-cache-ttl 28800"
      printf "\n%s" "max-cache-ttl 28800"
    } >> "$gpg_conf"
    echo "created config for gpg agent: $gpg_conf"
  fi
  printf "%s\n\n" "Done"
}

function configure_git() {
  echo "Setting up git..."
  echo 'git config --global user.name "Jeroen Lammersma"'
  git config --global user.name "Jeroen Lammersma"
  echo 'git config --global user.email "jeroen@lammersma.dev"'
  git config --global user.email "jeroen@lammersma.dev"
  echo 'git config --global commit.gpgSign true'
  git config --global commit.gpgSign true
  echo 'git config --global tag.gpgSign true'
  git config --global tag.gpgSign true
  echo 'git config --global user.signingKey 9C4B57F5605ECAE2'
  git config --global user.signingKey 9C4B57F5605ECAE2
  printf "%s\n\n" "Done"
}

function create_aliases() {
  echo "Creating aliases..."
  printf "\n%s" "alias git-submodule-update='git submodule update --recursive'" >> ~/.bashrc
  printf "%s\n\n" "Done"
}

function add_bashrc_vars() {
  echo "Adding bashrc vars..."
  printf "\n%s" "export CXXFLAGS='-std=c++20 -Wall -Wextra -Werror -Wpedantic -Wconversion'" >> ~/.bashrc
  printf "%s\n\n" "Done"
}


sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y curl git

setup_wsl
install_tools
configure_gpg
configure_git
create_aliases
add_bashrc_vars

echo
echo "----   SETUP DONE   ----"
echo "Open a new shell or configure your active shell env by running:"
echo "source ~/.bashrc"
