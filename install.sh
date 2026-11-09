#!/usr/bin/env bash
# Install deepseek-harness-desktop from a GitHub release.
# Usage: install.sh [version]
# Without a version, the latest release is installed, and if /etc/pacman.conf lacks the pacman repository that serves this package, the script offers to add it so that `pacman -Syu` installs later updates.
# With a version, a release tag such as 0.2.2alpha.2-1, only that version is installed, because the repository serves the latest version alone.
# The package is unsigned, and Arch's default pacman.conf requires signatures for `pacman -U <url>`, so the package is installed from a local copy.
# Installing with `pacman -U` instead of `pacman -Syu deepseek-harness-desktop` leaves the rest of the system at its current versions.
set -euo pipefail

repo=function2-llx/deepseek-harness-desktop
name=deepseek-harness-desktop
conf=/etc/pacman.conf
section="[$name]
SigLevel = Optional TrustAll
Server = https://github.com/$repo/releases/download/\$arch"

repo_configured() {
  grep -qxF "[$name]" "$conf"
}

# The prompt reads the terminal directly, because under `curl ... | bash` stdin carries the script itself.
offer_repo() {
  printf 'Add this pacman repository to %s so that pacman -Syu installs later updates?\n\n%s\n\n' "$conf" "$section"
  local answer
  read -r -p 'Add it? [Y/n] ' answer < /dev/tty
  case $answer in
    [nN]*) return ;;
  esac
  printf '\n%s\n' "$section" | sudo tee -a "$conf" > /dev/null
  echo "Added [$name] to $conf."
  echo "Until the next pacman -Syu downloads its database, pacman may warn that the database file for '$name' does not exist."
}

main() {
  local version=${1:-}
  if [ -z "$version" ]; then
    local latest
    latest=$(curl -fsSIL -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest")
    version=${latest##*/}
    if ! repo_configured; then
      offer_repo
    fi
  elif repo_configured; then
    echo "warning: $conf has the [$name] repository, so the next pacman -Syu upgrades $version to the latest version unless $name is listed in IgnorePkg." >&2
  fi
  local file="$name-$version-x86_64.pkg.tar.zst"
  # Global, because the EXIT trap runs after main has returned.
  dir=$(mktemp -d)
  trap 'rm -rf "$dir"' EXIT
  curl -fL --output "$dir/$file" "https://github.com/$repo/releases/download/$version/$file"
  sudo pacman -U "$dir/$file"
}

# The whole script is parsed before main runs, so a truncated download cannot run a partial script.
main "$@"
