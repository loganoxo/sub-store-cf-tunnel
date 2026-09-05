# sub-store-cf-tunnel

> sub-store修改版docker镜像, 使用cloudflare tunnel隧道
>
> 解决clawcloud不能绑定域名的问题

## 一、创建cloudflare 隧道

- 登录cloudflare
- 左侧菜单栏选择 `Zero Trust`
- 左侧菜单栏选择 `网络`->`连接器`->`创建隧道`->`cloudflared`
- 为隧道命名 后 保存隧道 -> `下一步`
- 添加已发布应用程序路由: 类型:HTTP, URL填写为`localhost:8080`
- 完成设置
- 记录下 TUNNEL_TOKEN

## 二、构建镜像和部署

### 1.1 构建镜像 (任选一种)

- github action 构建镜像, 使用自己的github账户fork此仓库, 然后在Action中手动执行
- 在 `Dockerfile`所在目录执行: `docker build --no-cache -f Dockerfile -t sub-store-cf-tunnel:1.1 .`
- 在 `docker-compose.yaml` 中部署时构建

### 1.2 部署运行

- 命令 `docker compose -f docker-compose.yaml up -d`
- 文件 `docker-compose.yaml` 内容如下:

```yaml
services:
  sub-store-cf-tunnel:
    # 按需修改, 镜像
    image: ghcr.io/loganoxo/sub-store-cf-tunnel:1.1
    # 或者自己github账户构建的 ghcr.io/username/sub-store-cf-tunnel:1.1
    # 或者自己本地构建的 sub-store-cf-tunnel:1.1
    container_name: sub-store-cf-tunnel
    restart: unless-stopped
    tty: true
    network_mode: host
    environment:
      # 必须修改
      TUNNEL_TOKEN: <填写cloudflare中创建的隧道的TUNNEL_TOKEN>
      SUB_STORE_BACKEND_API_HOST: 127.0.0.1
      # 按需修改, 此端口必须与cloudflare网站中设置的端口相同,即 `URL填写为`localhost:8080``
      SUB_STORE_BACKEND_API_PORT: 8080
      SUB_STORE_BACKEND_MERGE: true
      # 建议修改, 保护网站后端的安全,防止被扫描
      SUB_STORE_FRONTEND_BACKEND_PATH: /XFnD7iDzz7m3b3FcuhPEpc7RRLeiKNYj
      SUB_STORE_BACKEND_PREFIX: 1
      # HTTP-META 的, 一般不用改
      PORT: 56938
      HOST: 127.0.0.1
      TZ: "Asia/Shanghai"
      SUB_STORE_BACKEND_SYNC_CRON: 55 23 * * *
      SUB_STORE_PRODUCE_CRON: 0 0 */3 * *,col,zuhe
      SUB_STORE_MMDB_COUNTRY_PATH: /opt/app/data/Country.mmdb
      SUB_STORE_MMDB_COUNTRY_URL: https://cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/Country.mmdb
      # SUB_STORE_MMDB_ASN_PATH: /opt/app/data/GeoLite2-ASN.mmdb
      # SUB_STORE_MMDB_ASN_URL: https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-ASN.mmdb
      SUB_STORE_MMDB_CRON: 0 0 */10 * *
    volumes:
      - ./data:/opt/app/data


```

### 1.3 访问

`https://<TUNNEL_DOMAIN>/?api=https://<TUNNEL_DOMAIN>/XFnD7iDzz7m3b3FcuhPEpc7RRLeiKNYj`

> <TUNNEL_DOMAIN> 是 你在 cloudflare tunnel 隧道页面中设置的域名
>
>   /XFnD7iDzz7m3b3FcuhPEpc7RRLeiKNYj 需要修改为 SUB_STORE_FRONTEND_BACKEND_PATH 的内容
