# deepseek-harness-desktop 自动构建

简体中文 | [English](README.en.md)

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 桌面应用的非官方 Arch Linux 软件包，由 GitHub Actions 根据 AUR 包 [deepseek-harness-desktop](https://aur.archlinux.org/packages/deepseek-harness-desktop) 构建。
上游只发布 macOS 和 Windows 版桌面应用；HarryLoong 维护的 AUR 包补上了 Linux 版构建，本仓库原样使用该包，不做任何修改。

## 安装

安装最新版本：

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/function2-llx/deepseek-harness-desktop/main/install.sh)
```

安装指定版本时，把 [release](https://github.com/function2-llx/deepseek-harness-desktop/releases) 的标签作为参数传入：

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/function2-llx/deepseek-harness-desktop/main/install.sh) 0.2.2alpha.2-1
```

[install.sh](install.sh) 把软件包下载到临时目录，用 `sudo pacman -U` 安装，最后删除临时目录。
软件包没有签名，而 Arch 默认的 `pacman.conf` 要求通过 URL 安装的软件包带签名，所以脚本先下载到本地再安装。
用 `bash <(...)` 运行脚本时，pacman 的确认提示从终端读取回答；`curl ... | bash` 会让它从管道读取。

### 与 paru 等 AUR helper 共存

这样安装的软件包不属于任何 pacman 仓库，`paru -Syu` 会把它与同名 AUR 包比较，在 AUR 版本更新后提议从源码构建。
只想使用这里的预编译包时，在 `/etc/pacman.conf` 的 `IgnorePkg` 中加入 `deepseek-harness-desktop`，之后重新运行安装脚本来更新。

## 构建流程

- [aur-commit](aur-commit) 锁定 AUR 包的某个提交，该提交取自 [AUR 的 GitHub 镜像](https://github.com/archlinux/aur/tree/deepseek-harness-desktop)。
- [ci/build.sh](ci/build.sh) 在 `archlinux:base-devel` 容器中对该提交运行 `makepkg`。
- 推送到 `main` 的提交若修改了 `aur-commit`，就会构建软件包，并以 `pkgver-pkgrel` 为标签发布 release。
- 每日运行的工作流发现 AUR 包有新提交时，会开一个 pull request 并构建该分支；合并该 pull request 即发布新 release。
