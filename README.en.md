# deepseek-harness-desktop builds

[简体中文](README.md) | English

Unofficial Arch Linux packages of the [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) desktop app, built on GitHub Actions from the AUR package [deepseek-harness-desktop](https://aur.archlinux.org/packages/deepseek-harness-desktop).
Upstream publishes desktop builds for macOS and Windows only; the AUR package, maintained by HarryLoong, adds the Linux build, and this repository runs it unchanged.

## Installation

Install the latest version:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/function2-llx/deepseek-harness-desktop/main/install.sh)
```

To install a specific version, pass the tag from [release](https://github.com/function2-llx/deepseek-harness-desktop/releases) as an argument:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/function2-llx/deepseek-harness-desktop/main/install.sh) 0.2.2alpha.2-1
```

[install.sh](install.sh) downloads the package to a temporary directory, installs it with `sudo pacman -U`, and finally removes the temporary directory.
The package is not signed, and Arch's default `pacman.conf` requires packages installed via URL to be signed, so the script downloads it locally first before installing.
When running the script with `bash <(...)`, pacman's confirmation prompt reads answers from the terminal; `curl ... | bash` would make it read from a pipe.

### Coexistence with AUR helpers such as paru

Packages installed this way do not belong to any pacman repository. `paru -Syu` will compare it with the AUR package of the same name, and when the AUR version is updated, it will propose building from source.
If you only want to use the prebuilt packages provided here, add `deepseek-harness-desktop` to `IgnorePkg` in `/etc/pacman.conf`, then rerun the installation script to update.

## How builds happen

- [aur-commit](aur-commit) pins one revision of the AUR package, read from the [GitHub mirror of the AUR](https://github.com/archlinux/aur/tree/deepseek-harness-desktop).
- [ci/build.sh](ci/build.sh) runs `makepkg` on that revision inside an `archlinux:base-devel` container.
- A push to `main` that changes `aur-commit` builds the package and publishes it as a release tagged `pkgver-pkgrel`.
- A daily workflow opens a pull request when the AUR package has a newer revision and builds that branch; merging the pull request publishes the new release.
