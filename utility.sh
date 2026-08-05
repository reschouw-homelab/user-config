# utility.sh
# Functions for file management, etc used by setup.sh
# shellcheck shell=bash

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
    # $3 is intentionally unquoted so multi-word args (e.g. "--depth 1") split
    # shellcheck disable=SC2086
    git clone $3 "$1" "$2" > /dev/null
    echo Changed
  else
    echo OK
  fi
}

# Idempotent function for seeding a file from a template only if it does not
# already exist (used for local, untracked config).
# $1 = source template
# $2 = destination
copy_if_missing(){
  if [ -f "$2" ]; then
    echo OK
  else
    cp "$1" "$2"
    echo Changed
  fi
}

# Idempotent function for installing a brew package
# $1 = command name
brew_install(){
if [ "$(which "$1")" ]
  then
    echo OK
  else
    brew install "$1" > /dev/null
    echo Changed
  fi
}

# Idempotent, per-user (no root) install of the GitHub CLI on Linux.
# Downloads the official release tarball and drops the binary in ~/.local/bin,
# which path.conf already puts on PATH. Verifies the checksum when possible.
# Always returns success so a failed download can't abort setup.sh (set -e).
install_gh(){
  if [ "$(which gh)" ] || [ -x "$HOME/.local/bin/gh" ]; then
    echo OK
    return 0
  fi

  local arch ver asset url tmp
  case "$(uname -m)" in
    x86_64|amd64)  arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    armv6l)        arch=armv6 ;;
    *) echo "Skipped (unsupported arch $(uname -m))"; return 0 ;;
  esac

  # Resolve the latest release tag (e.g. v2.97.0) and strip the leading v
  ver=$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
        | grep -oE '"tag_name":[[:space:]]*"[^"]+"' | head -1 \
        | grep -oE 'v[0-9][^"]*')
  ver=${ver#v}
  if [ -z "$ver" ]; then
    echo "Skipped (version lookup failed)"
    return 0
  fi

  asset="gh_${ver}_linux_${arch}.tar.gz"
  url="https://github.com/cli/cli/releases/download/v${ver}"
  tmp=$(mktemp -d)

  if ! curl -fsSL "$url/$asset" -o "$tmp/$asset"; then
    echo Failed
    rm -rf "$tmp"
    return 0
  fi

  # Verify against the published checksums when sha256sum is available
  if command -v sha256sum >/dev/null 2>&1 \
     && curl -fsSL "$url/gh_${ver}_checksums.txt" -o "$tmp/checksums.txt"; then
    if ! (cd "$tmp" && grep " $asset\$" checksums.txt | sha256sum -c - >/dev/null 2>&1); then
      echo "Failed (checksum mismatch)"
      rm -rf "$tmp"
      return 0
    fi
  fi

  if tar -xzf "$tmp/$asset" -C "$tmp"; then
    mkdir -p "$HOME/.local/bin"
    cp "$tmp/gh_${ver}_linux_${arch}/bin/gh" "$HOME/.local/bin/gh"
    chmod +x "$HOME/.local/bin/gh"
    rm -rf "$tmp"
    echo Changed
  else
    echo Failed
    rm -rf "$tmp"
  fi
  return 0
}
