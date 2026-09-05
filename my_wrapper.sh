#!/bin/sh
set -e

echo "🚀 Run docker-entrypoint.sh with DOCKER_ARCH:$DOCKER_ARCH ..."

# 1. 检查环境变量 和 cloudflared 是否存在
if [ -n "$TUNNEL_TOKEN" ] && [ -n "$(command -v "cloudflared")" ]; then
  echo "🚀 Detected TUNNEL, starting Cloudflare Tunnel..."
  # & 在后台启动 cloudflared
  # --no-autoupdate: 容器内不需要自动更新
  # --token: 使用环境变量中的 Token 连接
  # > /dev/null 2>&1: 稍微抑制一下日志，避免和 SubStore 日志混杂
  nohup cloudflared tunnel --edge-ip-version auto --no-autoupdate --protocol http2 run --token "$TUNNEL_TOKEN" >/dev/null 2>&1 &
  echo "✅ Cloudflare Tunnel started in background."
else
  echo "⚠️ TUNNEL_TOKEN or cloudflared not found, skipping Tunnel startup."
fi

echo "🚀 Run docker-entrypoint-origin.sh ..."
echo "🚀 Starting Sub-Store application ..."

# 3. 执行容器原本的启动命令 调用父镜像原本的脚本 "$@" 包含了父镜像原本的 CMD 参数(完整继承)
# "$@" 代表 Dockerfile CMD 传递进来的所有参数
# 使用 exec 确保主进程 PID 为 1，能够接收停止信号
exec /usr/local/bin/docker-entrypoint-origin.sh "$@"
