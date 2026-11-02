# deepseek-harness-desktop builds

Unofficial Arch Linux packages of the [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) desktop app, built on GitHub Actions from the AUR package [deepseek-harness-desktop](https://aur.archlinux.org/packages/deepseek-harness-desktop).
Upstream publishes desktop builds for macOS and Windows only; the AUR package, maintained by HarryLoong, adds the Linux build, and this repository runs it unchanged.

## Install

Download the `.pkg.tar.zst` file from the [latest release](https://github.com/function2-llx/deepseek-harness-desktop/releases/latest) and install it:

```sh
sudo pacman -U deepseek-harness-desktop-*-x86_64.pkg.tar.zst
```

## How builds happen

- [aur-commit](aur-commit) pins one revision of the AUR package, read from the [GitHub mirror of the AUR](https://github.com/archlinux/aur/tree/deepseek-harness-desktop).
- [ci/build.sh](ci/build.sh) runs `makepkg` on that revision inside an `archlinux:base-devel` container.
- A push to `main` that changes `aur-commit` builds the package and publishes it as a release tagged `pkgver-pkgrel`.
- A daily workflow opens a pull request when the AUR package has a newer revision and builds that branch; merging the pull request publishes the new release.
