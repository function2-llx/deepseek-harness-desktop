#!/usr/bin/env bash
# Point the pacman repository at the package of one published release.
# The repository is the GitHub release tagged x86_64, which pacman reads through
#   Server = https://github.com/<owner>/<repo>/releases/download/$arch
# It holds the repository database and the one package that database lists.
# Usage: publish-repo.sh <version>
set -euo pipefail

version=$1
name=deepseek-harness-desktop
tag=x86_64

dir=$(mktemp -d)
gh release download "$version" --pattern '*.pkg.tar.zst' --dir "$dir"
package=$(basename "$dir"/*.pkg.tar.zst)

# repo-add ships with pacman, so it runs in an Arch container.
docker run --rm --user "$(id -u):$(id -g)" --volume "$dir:/repo" archlinux:base \
  repo-add "/repo/$name.db.tar.gz" "/repo/$package"

if ! gh release view "$tag" > /dev/null; then
  # Not marked latest: install.sh finds the newest version through the latest release.
  gh release create "$tag" --latest=false --target "$GITHUB_SHA" \
    --title "pacman repository ($tag)" \
    --notes 'Repository database and current package for pacman. See the README for the pacman.conf entry.'
fi

gh release upload "$tag" "$dir/$package" --clobber
# repo-add writes $name.db and $name.files as symlinks to the archives.
# Uploading a symlink stores the archive under the symlink's name, which is the name pacman requests.
gh release upload "$tag" "$dir/$name".{db,db.tar.gz,files,files.tar.gz} --clobber

# The database now lists only $package; older packages stay available in their own releases.
gh release view "$tag" --json assets \
  --jq ".assets[].name | select(endswith(\".pkg.tar.zst\") and . != \"$package\")" |
  while read -r stale; do
    gh release delete-asset "$tag" "$stale" --yes
  done
