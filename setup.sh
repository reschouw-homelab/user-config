#!/bin/bash
# Runs a number of operations to tie in all the config files in this repo into 
# their respective applications
# 
set -e

source ./utility.sh

OUTPUT=()

#
# Gather Environment Info: ---------------------------------------------------
#

OS="$(uname)"

#
# Vim Setup: -----------------------------------------------------------------
#

# Set up vimrc symlink
OUTPUT+=("vimrc_symlink: $(set_symlink ~/.vimrc ~/.config/vim/vimrc)")

# Set up vim directories
OUTPUT+=("vim_plugins_dir: $(set_directory ~/.vim/pack/git-plugins/start)")
OUTPUT+=("vim_backup_dir: $(set_directory ~/.config/vim/cache/backup)")
OUTPUT+=("vim_swap_dir: $(set_directory ~/.config/vim/cache/swap)")
OUTPUT+=("vim_undo_dir: $(set_directory ~/.config/vim/cache/undo)")

# Install ALE, vim linting plugin
OUTPUT+=("ALE_installed: $(clone_repo \
  https://github.com/dense-analysis/ale.git \
  ~/.vim/pack/git-plugins/start/ale \
  '--depth 1' \
)")

# Install shellcheck, to be used by ALE
if [ ! "$(which shellcheck)" ]; then
  if [ "$OS" = "Darwin" ]; then
    brew install shellcheck > /dev/null
  elif [ "$OS" = "Linux" ]; then
    sudo apt update -y && sudo apt install shellcheck > /dev/null
  fi    
  OUTPUT+=("shellcheck_installed: Changed")
else
  OUTPUT+=("shellcheck_installed: OK")
fi

#
# Terraform Setup: ------------------------------------------------------------
#

# Setup terraformrc symlink
OUTPUT+=("terraformrc_symlink: $(set_symlink ~/.terraformrc ~/.config/terraform/terraformrc)")

#
# Bashrc Setup: ---------------------------------------------------------------
#

# Ensure bashrc sources these config files
BASHRC_LOOP='for i in ~/.config/bashrc/*.conf; do source $i; done'
if (($(grep -Fc "$BASHRC_LOOP" ~/.bashrc) > 0 ))
  then
      OUTPUT+=("bashrc_link: OK")
  else
    echo "# Link to config in https://github.com/reschouw/user-config" >> ~/.bashrc
    echo "$BASHRC_LOOP" >> ~/.bashrc
      OUTPUT+=("bashrc_link: Changed")
  fi


#
# Brew setup: --------------------------------------------------------------
#

# Check if brew is installed
if [ "$(which brew)" ]
  then
    OUTPUT+=("brew_installed: OK")
  else
    sudo NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    OUTPUT+=("brew_installed: Changed")
  fi

#
# Brew packages: --------------------------------------------------------------
#

# Github CLI
OUTPUT+=("github_cli: $(HOMEBREW_NO_INSTALL_CLEANUP=1 brew_install gh)")

# aws-vault
OUTPUT+=("aws-vault: $(HOMEBREW_NO_INSTALL_CLEANUP=1 brew_install aws-vault)")


#
# Print Output: --------------------------------------------------------------
#

# https://stackoverflow.com/a/3016695
for LINE in "${OUTPUT[@]}"; do
  echo "$LINE"
done | column -t
