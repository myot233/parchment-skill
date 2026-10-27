# Parchment skill · 羊皮纸

由 [Parchment](https://github.com/myot233/Parchment) 的 GitHub Actions 自动生成，包含 skill 说明和五个平台的 CLI，无需安装 Rust。

## 安装

```sh
git clone https://github.com/myot233/parchment-skill.git ~/.codex/skills/parchment
```

也可以下载整个仓库或 multiplatform ZIP，将内容放入 skills 目录中的 `parchment` 文件夹。

## 支持平台

| 系统 | 架构 |
| --- | --- |
| macOS | Apple Silicon / Intel |
| Linux（glibc 2.35+） | ARM64 / x64 |
| Windows | x64 |

macOS/Linux 使用 `bin/parchment`，Windows 使用 `bin/parchment.cmd`。启动器会调用包内 CLI。

默认服务：https://parchment.ink。普通发布无需登录，安装后可调用 `$parchment`。详细用法见 [SKILL.md](SKILL.md)。

版本：0.1.0。本仓库由源仓库的发布流程维护，请在源仓库修改模板或 CLI。
