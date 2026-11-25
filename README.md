# ZCode Android Runner Marketplace

ZCode 插件市场源,收录 **Android Device Runner** —— 在 ZCode 侧栏里看设备、编译、安装、启动 Android 应用、看日志。

## 安装

1. 打开 ZCode 的 **插件市场** → 点击 **添加 / Add** → **添加插件市场 / Add Plugin Marketplace**
2. 粘贴本仓库地址:

   ```
   https://github.com/menggod/android-runner-zcode
   ```

3. 在 **个人** 里找到 **Android 设备运行器** → **安装**
4. **新开一个任务**(旧会话不会加载新插件),发送:

   ```
   打开 Android 面板
   ```

   也可以输入 `/android-panel`。
5. 首次会询问是否信任插件的本地 MCP 服务器 → 允许

## 要求

- **ZCode Desktop**,版本需支持插件 `ui.surfaces` 面板
- **Node.js 18+** 在 `PATH` 中(用于启动 MCP 服务器)
- **Android SDK**(含 `platform-tools/adb`)
- 工程自带 Gradle Wrapper(`gradlew`)

## 这是什么

- 侧栏面板:设备卡片切换目标、模拟器一键启动、编译/安装/启动/停止/重启/日志/自检/卸载/清数据,编译输出实时流式显示
- 命令行:`ar.js doctor|devices|use|run|build|install|launch|stop|restart|logcat`
- 零配置:自动探测 Gradle 工程根、adb、SDK、JDK、包名、APK 路径
- 工程跟随**当前窗口的工作区**,多窗口之间不串

## ⚠️ 破坏性行为

- 签名不一致或版本回退时,**安装会自动卸载重装**,清空该应用在设备上的本地数据。想关掉加 `--no-reinstall`。
- `uninstall` / `clear-data` 会清数据:面板里点击有二次确认,命令行需要显式 `--yes`。
- 插件的 MCP 服务器只走本地 stdio,不监听端口、不联网。

## 仓库结构

```
marketplace.json            # 市场清单
assets/icon.png             # 插件图标
plugins/android-runner/     # 插件本体
```

插件详细文档见 [`plugins/android-runner/README_CN.md`](./plugins/android-runner/README_CN.md) 与 [README.md](./plugins/android-runner/README.md)。

## License

MIT。探测与执行逻辑来自 [menggod/android-runner](https://github.com/menggod/android-runner)。
