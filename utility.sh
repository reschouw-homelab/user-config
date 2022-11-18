# utility.sh
# Functions for file management, etc used by setup.sh

# Idempotent function for creating a symlink
# $1 = link source
# $2 = link target
set_symlink() {
  if [ ! -L "$1" ]
  then
    ln -s "$2" "$1"
    echo Changed
  else
    echo OK
  fi
}

# Idempotent function for ensuring a directory exists
# $1 = directory target
set_directory(){
    if [ -d "$1" ]; then
      echo OK
    else
      mkdir -p "$1"
      echo Changed
    fi
}

# Idempotent function for cloning a directory
# $1 = repo source
# $2 = repo destination
# $3 = extra git clone arguments
clone_repo(){
  if [ ! -d "$2/.git" ]
  then
    git clone "$3" "$1" "$2" > /dev/null
    echo Changed
  else
    echo OK
  fi
}

# Idempotent function for installing a brew package
# $1 = command name
brew_install(){
if (( $(which "$1" | wc -l) > 0))
  then
    echo OK
  else
    brew install "$1" > /dev/null
    echo Changed
  fi
}
