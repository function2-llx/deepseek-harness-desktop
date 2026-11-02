#!/usr/bin/env bash
# Open a pull request that moves aur-commit to the newest AUR revision of deepseek-harness-desktop.
# The branch is also built, so the pull request shows whether that revision builds before it is merged.
set -euo pipefail

mirror=https://github.com/archlinux/aur.git
newest=$(git ls-remote --exit-code "$mirror" refs/heads/deepseek-harness-desktop | cut -f1)
pinned=$(cat aur-commit)
if [ "$newest" = "$pinned" ]; then
  echo "aur-commit already pins $newest"
  exit 0
fi

branch="aur-${newest:0:12}"
if git ls-remote --exit-code origin "refs/heads/$branch" > /dev/null; then
  echo "branch $branch already proposes $newest"
  exit 0
fi

git switch --create "$branch"
echo "$newest" > aur-commit
title="Track AUR commit ${newest:0:12}"
git -c user.name='github-actions[bot]' -c user.email='41898282+github-actions[bot]@users.noreply.github.com' \
  commit --all --message "$title"
git push origin "$branch"
gh pr create --head "$branch" --title "$title" \
  --body "AUR changes: https://github.com/archlinux/aur/compare/${pinned}...${newest}"
# Pushes and pull requests made with the workflow token start no workflows, so the branch build is dispatched explicitly.
gh workflow run build.yml --ref "$branch"
