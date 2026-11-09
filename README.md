# deepseek-harness-desktop 自动构建

简体中文 | [English](README.en.md)

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 桌面应用的非官方 Arch Linux 软件包，由 GitHub Actions 根据 AUR 包 [deepseek-harness-desktop](https://aur.archlinux.org/packages/deepseek-harness-desktop) 构建。
上游只发布 macOS 和 Windows 版桌面应用；HarryLoong 维护的 AUR 包补上了 Linux 版构建，本仓库原样使用该包，不做任何修改。

## 安装

### 安装脚本（推荐）

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/function2-llx/deepseek-harness-desktop/main/install.sh)
```

[install.sh](install.sh) 下载最新版本的软件包，用 `sudo pacman -U` 安装，最后删除下载的文件。
如果 `/etc/pacman.conf` 里还没有本项目的 pacman 仓库，脚本会先显示要加入的配置并询问是否加入（默认加入）；加入后，`pacman -Syu` 和 `paru -Syu` 都会从这个仓库获取更新。
脚本用 `pacman -U` 安装，不会顺带升级系统里的其他软件包。

安装指定版本时，把 [release](https://github.com/function2-llx/deepseek-harness-desktop/releases) 的标签作为参数传入：

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/function2-llx/deepseek-harness-desktop/main/install.sh) 0.2.2alpha.2-1
```

pacman 仓库只提供最新版本，所以指定版本时脚本不会询问是否加入仓库。
如果已经加入了仓库，下一次 `pacman -Syu` 会把指定的版本升级到最新版，除非在 `/etc/pacman.conf` 的 `IgnorePkg` 中加入 `deepseek-harness-desktop`。

软件包没有签名，而 Arch 默认的 `pacman.conf` 要求通过 URL 安装的软件包带签名，所以脚本先下载到本地再安装。
请用 `bash <(...)` 运行脚本：`curl ... | bash` 会让 pacman 的确认提示从管道而不是终端读取回答。

### 手动添加 pacman 仓库

在 `/etc/pacman.conf` 末尾加入：

```ini
[deepseek-harness-desktop]
SigLevel = Optional TrustAll
Server = https://github.com/function2-llx/deepseek-harness-desktop/releases/download/$arch
```

然后安装：

```sh
sudo pacman -Syu deepseek-harness-desktop
```

仓库里的软件包没有签名，`SigLevel = Optional TrustAll` 只对这个仓库接受未签名的软件包。
仓库就是标签为 `x86_64` 的 release，其中只保留最新版本；旧版本的软件包在各自版本的 release 里。

### 与 paru 等 AUR helper 共存

paru 只把不属于任何 pacman 仓库的已安装软件包与 AUR 比较。
加入 pacman 仓库后，`paru -Syu` 从仓库更新这个软件包，不会提议从 AUR 构建。
没有加入仓库时，`paru -Syu` 会把它与同名 AUR 包比较，在 AUR 版本更新后提议从源码构建；重新运行安装脚本并同意加入仓库，或按上一节手动加入，即可避免。

## 构建流程

- [aur-commit](aur-commit) 锁定 AUR 包的某个提交，该提交取自 [AUR 的 GitHub 镜像](https://github.com/archlinux/aur/tree/deepseek-harness-desktop)。
- [ci/build.sh](ci/build.sh) 在 `archlinux:base-devel` 容器中对该提交运行 `makepkg`。
- 推送到 `main` 的提交若修改了 `aur-commit`，就会构建软件包，以 `pkgver-pkgrel` 为标签发布 release，并用 [ci/publish-repo.sh](ci/publish-repo.sh) 把 pacman 仓库更新到这个版本。
- 每日运行的工作流发现 AUR 包有新提交时，会开一个 pull request 并构建该分支；合并该 pull request 即发布新 release。
- 手动运行 [publish-repo](.github/workflows/publish-repo.yml) 工作流，可以把 pacman 仓库指向任意一个已发布的版本。
