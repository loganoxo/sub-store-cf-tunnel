FROM xream/sub-store:2.20.40-http-meta

# 声明架构参数,Docker会自动传入 amd64 或 arm64
ARG TARGETARCH
# 把临时的 ARG 赋值给持久的 ENV
ENV DOCKER_ARCH=${TARGETARCH}
# cloudflared 环境变量默认值(初始化),如果不传 则不启动 cloudflared
ENV TUNNEL_TOKEN=""

# 把我们自己的"中间件"脚本复制进去
COPY my_wrapper.sh /usr/local/bin/my_wrapper.sh

# 安装cloudflared 和 entrypoint脚本处理
# https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${TARGETARCH} && \
# 把父镜像原本的启动脚本重命名(备份)
# 把我们自己的"中间件"脚本伪装成原来的脚本
# 赋予执行权限
RUN echo "Building for architecture: ${TARGETARCH}" && \
  curl -s -L --connect-timeout 5 --max-time 10 --retry 2 --retry-delay 0 --retry-max-time 20 --output /usr/local/bin/cloudflared \
  "https://github.com/cloudflare/cloudflared/releases/download/2025.11.1/cloudflared-linux-${TARGETARCH}" && \
  chmod +x /usr/local/bin/cloudflared && \
  cloudflared --version && \
  mv /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-origin.sh && \
  mv /usr/local/bin/my_wrapper.sh /usr/local/bin/docker-entrypoint.sh && \
  chmod +x /usr/local/bin/docker-entrypoint.sh

# 关键: 这里绝对不要写 ENTRYPOINT 和 CMD 指令,目的是完整保留父镜像的 CMD 参数

# 构建命令
# docker build --no-cache -f Dockerfile -t sub-store-cf-tunnel:1.1 .
