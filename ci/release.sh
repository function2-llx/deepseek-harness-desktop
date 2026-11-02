#!/usr/bin/env bash
# Publish the package that ci/build.sh left in <output-dir> as a GitHub release tagged pkgver-pkgrel.
# Usage: release.sh <output-dir> <aur-commit>
set -euo pipefail

output=$1
commit=$2

field() {
  sed -n "s/^\t$1 = //p" "$output/.SRCINFO"
}
version="$(field pkgver)-$(field pkgrel)"
upstream=$(field source | sed -n 's/.*#tag=//p')

gh release create "$version" "$output"/*.pkg.tar.zst \
  --target "$GITHUB_SHA" \
  --title "deepseek-harness-desktop $version" \
  --notes "Built from AUR commit [${commit:0:12}](https://github.com/archlinux/aur/commit/$commit), upstream tag \`$upstream\`."
