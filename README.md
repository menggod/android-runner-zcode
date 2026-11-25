# Android Device Runner for ZCode

在 ZCode 里运行 Android 工程:侧栏面板看设备、编译、安装、启动、看日志。
移植自 VS Code 扩展 [menggod/android-runner](https://github.com/menggod/android-runner)。

> **macOS / Linux**. 启动器依赖 POSIX shell(`/bin/sh`);Windows 暂不支持。

## 安装

1. 打开 ZCode 的 **插件市场** → **添加 / Add** → **添加插件市场 / Add Plugin Marketplace**
2. 粘贴本仓库地址:`https://github.com/menggod/android-runner-zcode`
3. 在 **个人** 里找到「Android 设备运行器」→ **安装**
4. 新开一个任务,发送 `打开 Android 面板`(或输入 `/android-panel`)
5. 首次会询问是否信任插件的本地 MCP 服务器 → 允许

## 能做什么

**侧栏面板**(推荐)

- 设备卡片:型号、序列号、Android 版本、真机/模拟器;点击切换目标设备
- 模拟器:列出 AVD,一键启动并等待就绪(最多 180 秒)
- 应用:包名、模块/变体、APK 大小与构建时间
- 环境:SDK / adb / JDK / Gradle 实时探测结果
- 操作:运行(编译→安装→启动)、编译、安装、启动、停止、重启、日志、环境自检、卸载、清数据
- 控制台:编译/安装/启动的实时流式输出;日志标签页是实时 logcat

**命令行**(`scripts/ar.js`,零依赖)

```bash
node scripts/ar.js doctor          # 环境自检
node scripts/ar.js devices         # 设备与模拟器
node scripts/ar.js use <serial>    # 记住目标设备
node scripts/ar.js run             # 编译 → 安装 → 启动
node scripts/ar.js logcat          # 只看本应用进程的日志
```

完整命令:`ar.js --help`。

## 零配置探测

不需要先配置任何东西,按下面的顺序自动找:

| 项 | 探测顺序 |
|---|---|
| 工程根目录 | 当前窗口工作区内找 `gradlew`(向上 6 层 / 向下扫描) |
| adb | `local.properties` → `ANDROID_HOME` → 常见 SDK 目录 → `PATH` |
| JDK | 项目 `.idea/gradle.xml` 的 `gradleJvm` → `JAVA_HOME` → 系统默认 |
| 包名 | `output-metadata.json` → 模块 `build.gradle` 的 `applicationId` |
| APK | `build/outputs/apk/<variant>/` 下最新的产物 |

探测不到时才需要显式指定:`--module`、`--variant`、`--apk`、`--package`、`--adb`、`--java-home`。

## ⚠️ 破坏性行为

- **签名不一致或版本回退时会自动卸载重装**,并清空该应用在设备上的本地数据(登录态等)。这是默认行为;面板会弹提示,命令行会打印警告。想关掉:加 `--no-reinstall`,此时会以退出码 3 报错让你决定。
- `uninstall` / `clear-data` 会清数据,面板里点击时会二次确认;命令行需要显式 `--yes`。

## 要求

- ZCode Desktop(支持插件 `ui.surfaces` 面板的版本)
- Node.js 18+(桌面端 PATH 里没有时,启动器会自动尝试 Homebrew / nvm / `~/.local/bin` 等常见位置,最后回落到 ZCode 自带运行时)
- Android SDK(含 `platform-tools/adb`)
- 工程自带 Gradle Wrapper(`gradlew`)

## 目录结构

```
marketplace.json              # 市场清单
plugins/android-runner/
  .zcode-plugin/plugin.json   # 插件清单(声明面板 + MCP 服务器)
  assets/panel.html           # 侧栏面板 UI
  scripts/mcp-server.mjs      # MCP 服务器(工具/资源/作业)
  scripts/ar.js               # 命令行核心:探测 / 设备 / 编译 / 安装 / 启动 / 日志
  scripts/launch.sh           # 找 Node 并启动 MCP 服务器
  scripts/project-info.js     # 模块 / APK / 包名探测
  skills/android-runner/      # 技能说明
  commands/                   # /android-run, /android-doctor, /android-devices, /android-panel
```

## 开发

```bash
# 直接跑命令行部分
node plugins/android-runner/scripts/ar.js doctor

# 协议冒烟测试:模拟宿主走 MCP 握手 / 工具 / 资源
node plugins/android-runner/scripts/mcp-server.mjs   # 手动发 JSON-RPC 到 stdin
```

改完插件记得同步升版本:`.zcode-plugin/plugin.json`、`scripts/mcp-server.mjs` 的 `PLUGIN_VERSION`、
`assets/panel.html` 的 `VERSION`、以及 `marketplace.json` 里的 `version`,四处要一致。

## License

MIT。基于 [menggod/android-runner](https://github.com/menggod/android-runner) 的探测与执行逻辑移植,
原项目的 `LICENSE` 保留在 `plugins/android-runner/LICENSE`。
