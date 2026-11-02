# deepseek-harness-desktop 自动构建

[English](README.md) | 简体中文

[DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 桌面应用的非官方 Arch Linux 软件包，由 GitHub Actions 根据 AUR 包 [deepseek-harness-desktop](https://aur.archlinux.org/packages/deepseek-harness-desktop) 构建。
上游只发布 macOS 和 Windows 版桌面应用；HarryLoong 维护的 AUR 包补上了 Linux 版构建，本仓库原样使用该包，不做任何修改。

## 安装

从[最新 release](https://github.com/function2-llx/deepseek-harness-desktop/releases/latest) 下载 `.pkg.tar.zst` 文件，然后安装：

```sh
sudo pacman -U deepseek-harness-desktop-*-x86_64.pkg.tar.zst
```

## 构建流程

- [aur-commit](aur-commit) 锁定 AUR 包的某个提交，该提交取自 [AUR 的 GitHub 镜像](https://github.com/archlinux/aur/tree/deepseek-harness-desktop)。
- [ci/build.sh](ci/build.sh) 在 `archlinux:base-devel` 容器中对该提交运行 `makepkg`。
- 推送到 `main` 的提交若修改了 `aur-commit`，就会构建软件包，并以 `pkgver-pkgrel` 为标签发布 release。
- 每日运行的工作流发现 AUR 包有新提交时，会开一个 pull request 并构建该分支；合并该 pull request 即发布新 release。
