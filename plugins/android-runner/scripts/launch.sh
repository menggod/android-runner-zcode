#!/bin/sh
# Android Runner 的 MCP 服务器启动器。
#
# 桌面 App 启动的子进程 PATH 通常不含 Homebrew / nvm 路径,所以这里按
#   1) 用户显式指定  2) PATH  3) 常见安装位置  4) ZCode 自带运行时
# 依次查找可用的 Node,找到即以 stdio 方式启动 mcp-server.mjs。

set -u

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SERVER="$DIR/mcp-server.mjs"

if [ ! -f "$SERVER" ]; then
  echo "Android Runner: 找不到 $SERVER" >&2
  exit 1
fi

run_node() {
  exec "$1" "$SERVER"
}

# 1) 显式指定
if [ -n "${ANDROID_RUNNER_NODE:-}" ] && [ -x "${ANDROID_RUNNER_NODE}" ]; then
  run_node "$ANDROID_RUNNER_NODE"
fi

# 2) PATH
if command -v node >/dev/null 2>&1; then
  run_node "$(command -v node)"
fi

# 3) 常见安装位置
for candidate in \
  /opt/homebrew/bin/node \
  /usr/local/bin/node \
  "$HOME/.local/bin/node" \
  "$HOME/.nvm/versions/node"/*/bin/node \
  /usr/bin/node \
  /snap/bin/node
do
  if [ -x "$candidate" ]; then
    run_node "$candidate"
  fi
done

# 4) 用 ZCode 自带的 Electron 作为 Node(ZCode 官方插件就是这么跑的)
HELPER="/Applications/ZCode.app/Contents/Frameworks/ZCode Helper.app/Contents/MacOS/ZCode Helper"
ZC="/Applications/ZCode.app/Contents/Resources/glm/zcode.cjs"
if [ -x "$HELPER" ] && [ -f "$ZC" ]; then
  ANDROID_RUNNER_MCP_NO_AUTOSTART=1 ELECTRON_RUN_AS_NODE=1 exec "$HELPER" "$ZC" __zcode-plugin-host "$SERVER"
fi

echo "Android Runner: 没有找到 Node.js。请安装 Node 18+,或设置环境变量 ANDROID_RUNNER_NODE 指向 node 可执行文件。" >&2
exit 1
