#!/usr/bin/env bash
# Build one AUR revision of deepseek-harness-desktop with makepkg.
# Runs as root inside an archlinux:base-devel container and runs makepkg as an unprivileged user with passwordless sudo, because makepkg refuses to run as root.
# Usage: build.sh <aur-commit> <output-dir>
set -euo pipefail

commit=$1
output=$2

pacman -Syu --noconfirm --needed git sudo
useradd --create-home builder
echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder

workdir=/home/builder/aur
sudo -u builder -H git clone --branch deepseek-harness-desktop --single-branch https://github.com/archlinux/aur.git "$workdir"
sudo -u builder -H git -C "$workdir" checkout --detach "$commit"

cd "$workdir"
sudo -u builder -H makepkg --syncdeps --noconfirm

mkdir -p "$output"
cp -- *.pkg.tar.zst .SRCINFO "$output"/
