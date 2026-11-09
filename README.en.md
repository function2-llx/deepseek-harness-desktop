# deepseek-harness-desktop builds

[简体中文](README.md) | English

Unofficial Arch Linux packages of the [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) desktop app, built on GitHub Actions from the AUR package [deepseek-harness-desktop](https://aur.archlinux.org/packages/deepseek-harness-desktop).
Upstream publishes desktop builds for macOS and Windows only; the AUR package, maintained by HarryLoong, adds the Linux build, and this repository runs it unchanged.

## Installation

### Installation script (recommended)

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/function2-llx/deepseek-harness-desktop/main/install.sh)
```

[install.sh](install.sh) downloads the latest version of the package, installs it with `sudo pacman -U`, and finally deletes the downloaded file.
If this project's pacman repository is not already in `/etc/pacman.conf`, the script first shows the configuration to be added and asks whether to add it (default is to add it); once added, both `pacman -Syu` and `paru -Syu` will fetch updates from this repository.
The script installs with `pacman -U`, so it does not upgrade other packages on the system along the way.

To install a specific version, pass the tag from [release](https://github.com/function2-llx/deepseek-harness-desktop/releases) as an argument:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/function2-llx/deepseek-harness-desktop/main/install.sh) 0.2.2alpha.2-1
```

The pacman repository only provides the latest version, so when a specific version is specified, the script does not ask whether to add the repository.
If the repository has already been added, the next `pacman -Syu` will upgrade the specified version to the latest one, unless `deepseek-harness-desktop` is added to `IgnorePkg` in `/etc/pacman.conf`.

The package is not signed, and Arch's default `pacman.conf` requires packages installed via URL to be signed, so the script downloads to a local file first and then installs.
Please run the script with `bash <(...)`: using `curl ... | bash` would cause pacman's confirmation prompts to read answers from the pipe instead of the terminal.

### Manually adding the pacman repository

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

The packages in the repository are not signed; `SigLevel = Optional TrustAll` accepts unsigned packages only for this repository.
The repository is the release tagged `x86_64`, which only keeps the latest version; packages for older versions are in the releases for their respective versions.

### Coexisting with paru and other AUR helpers

paru only compares installed packages that do not belong to any pacman repository against the AUR.
After adding the pacman repository, `paru -Syu` updates this package from the repository and will not suggest building from the AUR.
Without the repository added, `paru -Syu` will compare it against the AUR package of the same name and, when the AUR version is newer, suggest building from source; rerun the installation script and agree to add the repository, or add it manually as described in the previous section, to avoid this.

## Build process

- [aur-commit](aur-commit) pins a specific commit of the AUR package, taken from the [AUR's GitHub mirror](https://github.com/archlinux/aur/tree/deepseek-harness-desktop).
- [ci/build.sh](ci/build.sh) runs `makepkg` on that commit in an `archlinux:base-devel` container.
- When a commit pushed to `main` modifies `aur-commit`, the package is built, a release is published with the tag `pkgver-pkgrel`, and [ci/publish-repo.sh](ci/publish-repo.sh) updates the pacman repository to this version.
- A daily workflow, upon discovering a new commit in the AUR package, opens a pull request and builds that branch; merging the pull request publishes a new release.
- Manually running the [publish-repo](.github/workflows/publish-repo.yml) workflow can point the pacman repository to any previously published version.
