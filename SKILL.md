---
name: parchment
description: 使用随附的 Parchment CLI，把 HTML、CSS、图片和 SVG 发布为可分享的羊皮纸链接。当用户希望分享 AI 整理的报告、研究结果、上下文或已有 HTML 目录时使用。
---

# Parchment · 羊皮纸

将内容整理为独立 HTML，连同资源一起上传，并把返回的分享链接交给用户。官方服务是 https://parchment.ink。已登录时默认归属当前账号，未登录也可匿名发布。

用户要求发布或分享时可以直接执行；仅要求生成文件时，先保存文件即可。

## 随附 CLI

使用本 skill 目录中的 `bin/parchment`，无需安装 Rust，也无需将 CLI 加入 PATH。命令中的 `<skill-dir>` 应替换为本 skill 的实际绝对路径。

```sh
PARCHMENT_CLI="<skill-dir>/bin/parchment"
"$PARCHMENT_CLI" --version
"$PARCHMENT_CLI" --help
```

CLI 已包含构建时的默认服务地址，运行时不需要 `.env`。`--help` 可查看默认值。覆盖优先级为 `--server` > 环境变量 `PARCHMENT_SERVER` > 内置地址。用户指定其他服务时使用 `--server https://example.com`。

附带的二进制适用于安装包文件名标明的系统和架构；遇到执行格式不匹配时，使用对应平台构建的包。

完整仓库和 `multiplatform` 安装包包含 macOS、Linux 的 ARM64/x64，以及 Windows x64。macOS/Linux 的 `bin/parchment` 会自动选择对应二进制。Windows 使用 `bin/parchment.cmd`；例如在 PowerShell 中：

```powershell
$ParchmentCli = "<skill-dir>\bin\parchment.cmd"
& $ParchmentCli publish C:\path\to\report --json
```

下文命令采用 POSIX shell 写法；在 PowerShell 中通过 `& $ParchmentCli` 传入相同参数。

## 准备发布目录

创建专用目录，只放用户希望公开分享的内容。目录中的可见文件都会上传；不要直接发布整个工作区。

```text
report/
├── index.html
└── assets/
    ├── style.css
    ├── chart.svg
    └── photo.png
```

- 入口必须是 UTF-8 的 `index.html`，写好 `<title>` 和 description 元信息。CLI 会返回解析后的标题和描述。
- 用相对路径引用目录内的 CSS、图片、SVG 和字体；CSS 内的相对路径以 CSS 文件位置为基准。
- 仅使用 HTML 和 CSS。JavaScript、内联事件、iframe、外部资源和表单提交会被阻止。需要折叠内容时可使用原生 `<details>`。
- 支持 HTML、CSS、SVG、常见图片格式、字体和 TXT。不要打包 JS、构建工具或依赖目录。
- 最多 512 个文件，单文件最多 10 MiB，文件总内容最多 20 MiB。
- 不使用符号链接或隐藏路径。资源路径中不能有 `..`、反斜线、控制字符或 `% ? # :`。

## 发布与验证

普通分享使用 CLI 已有身份；没有当前服务的登录凭据或 token 时，CLI 自动匿名发布：

```sh
"$PARCHMENT_CLI" publish /absolute/path/to/report --json
```

仅在用户明确要求匿名时追加 `--anonymous`，它会覆盖登录身份和配置的 token。不要为了绕过过期或已撤销的凭据自动切换匿名；提示用户重新登录。

匿名发布时 CLI 自动生成并持久化设备码，后续复用。使用默认设备文件即可；仅在用户需要独立配置位置时指定 `--device-code-file`。

成功返回 JSON，包含 `id`、`title`、`description`、`file_count`、`total_bytes` 和 `url`。检查命令退出状态并解析 JSON；使用返回的 `url`，不要自行拼接或猜测 ID。

发布后用 GET 或 HEAD 检查分享页和引用资源可访问，再向用户返回可点击的分享链接。页面对持有链接的人开放，`noindex` 不构成访问控制。

每次 `publish` 创建新快照和新链接，不能覆盖已有页面。内容修改后需重新发布，并返回新链接。

## 错误与限流

`--json` 下运行失败会以非零状态退出，并返回 `{"error":"..."}`。先修正 CLI 指出的路径、类型或大小问题，再决定是否重新发布。

匿名发布默认每设备每小时最多尝试 5 次、每来源 IP 每小时 20 次；无效上传也消耗额度。遇到 `429` 或 `503`，遵守错误中的重试时间并报告当前未完成，不循环重试、不更换设备码绕过限制。网络超时后也不要盲目重复发布。

## 管理内容

只有用户要求管理操作时才执行。普通登录用户可以管理自己的内容；匿名设备码不提供管理权限。先用 `whoami` 查看当前身份，登录凭据按服务地址保存：

```sh
"$PARCHMENT_CLI" whoami --json
"$PARCHMENT_CLI" login --no-browser --name "AI workspace"
```

`login` 会显示验证链接和用户确认码，并等待用户在浏览器完成 GitHub 登录与设备批准。将链接与确认码交给用户，不打印设备授权密钥或访问 token；不要把已有匿名设备码当作登录码。账号页位于 API 服务的 `/account`，可撤销指定凭据，也可创建仅发布或可管理内容的自动化 token。

自动化可以通过运行时环境变量 `PARCHMENT_TOKEN` 提供用户 token；它会覆盖保存的登录身份。不要把凭据写入发布目录、分享内容、命令参数或普通输出。登录不会撤回旧分享链接，`logout` 仅撤销当前 CLI 凭据。

```sh
"$PARCHMENT_CLI" list --json
"$PARCHMENT_CLI" info p_<id> --json
"$PARCHMENT_CLI" delete p_<id> --json
```

管理员 token 可以操作全部内容，只有用户明确要求管理员操作时才使用。普通登录不会自动获得管理员权限。
