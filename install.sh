#!/usr/bin/env bash
# Download a deepseek-harness-desktop release package and install it with pacman.
# Usage: install.sh [version]
# The version is a release tag such as 0.2.2alpha.2-1; without one, the latest release is installed.
# The package is unsigned, and Arch's default pacman.conf requires signatures for `pacman -U <url>`, so the package is installed from a local copy.
set -euo pipefail

repo=function2-llx/deepseek-harness-desktop

main() {
  local version=${1:-}
  if [ -z "$version" ]; then
    local latest
    latest=$(curl -fsSIL -o /dev/null -w '%{url_effective}' "https://github.com/$repo/releases/latest")
    version=${latest##*/}
  fi
  local file="deepseek-harness-desktop-$version-x86_64.pkg.tar.zst"
  # Global, because the EXIT trap runs after main has returned.
  dir=$(mktemp -d)
  trap 'rm -rf "$dir"' EXIT
  curl -fL --output "$dir/$file" "https://github.com/$repo/releases/download/$version/$file"
  sudo pacman -U "$dir/$file"
}

# The whole script is parsed before main runs, so a truncated download cannot run a partial script.
main "$@"
