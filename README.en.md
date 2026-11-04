# deepseek-harness-desktop builds

[简体中文](README.md) | English

Unofficial Arch Linux packages of the [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) desktop app, built on GitHub Actions from the AUR package [deepseek-harness-desktop](https://aur.archlinux.org/packages/deepseek-harness-desktop).
Upstream publishes desktop builds for macOS and Windows only; the AUR package, maintained by HarryLoong, adds the Linux build, and this repository runs it unchanged.

## Installation

### Via the pacman repository (recommended)

Add the following to the end of `/etc/pacman.conf`:

```ini
[deepseek-harness-desktop]
SigLevel = Optional TrustAll
Server = https://github.com/function2-llx/deepseek-harness-desktop/releases/download/$arch
```

Then install:

```sh
sudo pacman -Syu deepseek-harness-desktop
```

After that, both `pacman -Syu` and `paru -Syu` will fetch updates from this repository.
The packages in the repository are not signed; `SigLevel = Optional TrustAll` accepts unsigned packages only for this repository.
The repository is simply the release tagged `x86_64`, which only keeps the latest version; older packages are in the releases for their respective versions.

### Via the install script

To install the latest version:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/function2-llx/deepseek-harness-desktop/main/install.sh)
```

To install a specific version, pass the tag from the [release](https://github.com/function2-llx/deepseek-harness-desktop/releases) as an argument:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/function2-llx/deepseek-harness-desktop/main/install.sh) 0.2.2alpha.2-1
```

[install.sh](install.sh) downloads the package to a temporary directory, installs it with `sudo pacman -U`, and finally removes the temporary directory.
The package is not signed, and Arch's default `pacman.conf` requires packages installed via URL to be signed, so the script downloads it locally first and then installs it.
When running the script with `bash <(...)`, pacman's confirmation prompt reads answers from the terminal; `curl ... | bash` would make it read from the pipe.

### Coexistence with paru and other AUR helpers

paru only compares installed packages that do not belong to any pacman repository against the AUR.
When installed via the pacman repository, `paru -Syu` updates this package from the repository and will not suggest building it from the AUR.
When installed via the install script, `paru -Syu` will compare it with the AUR package of the same name and, after the AUR version is updated, suggest building from source; adding the pacman repository above avoids this.

## Build process

- [aur-commit](aur-commit) pins a specific commit of the AUR package, taken from the [AUR's GitHub mirror](https://github.com/archlinux/aur/tree/deepseek-harness-desktop).
- [ci/build.sh](ci/build.sh) runs `makepkg` on that commit in an `archlinux:base-devel` container.
- When a commit pushed to `main` modifies `aur-commit`, the package is built, a release is published with the tag `pkgver-pkgrel`, and [ci/publish-repo.sh](ci/publish-repo.sh) updates the pacman repository to this version.
- A daily workflow, upon discovering a new commit in the AUR package, opens a pull request and builds that branch; merging the pull request publishes a new release.
- Manually running the [publish-repo](.github/workflows/publish-repo.yml) workflow can point the pacman repository to any previously published version.
