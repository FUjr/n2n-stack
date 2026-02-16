# n2n-stack

> 一个多模式 Docker 栈，用于 n2n 点到点虚拟网络，集成 DHCP 管理和 Web 租约查看器。

**English**: [README.md](README.md)

## 功能特点

- **双模式运行**：网关模式（完整基础设施）或轻量级边界模式
- **多架构构建**：通过 Docker Buildx 无缝支持跨架构（amd64、arm64）
- **动态 DHCP 配置**：通过环境变量覆盖子网、IP 范围和 DNS
- **Web 租约查看器**：实时 DHCP 租约监控，支持倒计时和注释过滤
- **灵活网络方案**：边界模式支持静态和动态 IP 分配
- **生产就绪**：时区支持、完整日志、容器化部署

## 架构

### 网关模式
完整的 n2n 网关，配备 DHCP 服务器和 Web UI：
```
supernode + edge (静态IP) + dhcpd + lease-ui
```
适合作为中心网络枢纽。

### 边界模式  
轻量级边界客户端，支持 DHCP 客户端集成：
```
edge (DHCP IP) + dhclient
```
适合需要自动 IP 分配的远程节点。

## 快速开始

### 系统要求
- Docker & Docker Compose
- Docker Buildx 多架构支持

### 构建

详见 [从源码构建](doc/build_zh.md)。

快速构建并推送：
```bash
docker buildx bake
```

使用自定义镜像仓库：
```bash
IMAGE_PREFIX=your-registry/your-org docker buildx bake
```

### 部署

#### 网关模式（默认）
```bash
echo "COMPOSE_PROFILES=gateway" >> .env
docker compose up -d
```
服务：supernode (UDP 13103)、租约 UI (51080)

#### 边界模式
```bash
echo "COMPOSE_PROFILES=edge" >> .env
docker compose up -d
```
边界节点会自动通过 DHCP 获取 IP。

## 配置

### 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `COMPOSE_PROFILES` | `gateway` | 部署模式：`gateway` 或 `edge` |
| `TIMEZONE` | `UTC` | 容器时区（如 `Asia/Shanghai`） |
| `IMAGE_PREFIX` | `registry.cn-hangzhou.aliyuncs.com/fjrcn` | 容器仓库前缀 |
| `N2N_COMMUNITY` | `mynet` | n2n 社区名称 |
| `N2N_KEY` | `mysecret` | n2n 加密密钥 |
| `N2N_DEVICE` | `n2n1` | 虚拟网络接口名称 |
| `N2N_EDGE_IP` | `10.255.255.1` | 静态 IP（网关模式） |
| `SUPERNODE_HOST` | `127.0.0.1` | Supernode 地址 |
| `SUPERNODE_PORT` | `13103` | Supernode 端口 |
| `EDGE_ADD_DEFAULT_GW` | `false` | 保留 DHCP 默认网关（边界模式） |

### DHCP 配置（网关模式）

当设置以下任意变量时，会动态生成 `dhcpd.conf`。留空则使用默认配置。

| 变量 | 默认值 |
|------|--------|
| `DHCP_SUBNET` | `10.255.255.0` |
| `DHCP_NETMASK` | `255.255.255.0` |
| `DHCP_RANGE_START` | `10.255.255.50` |
| `DHCP_RANGE_END` | `10.255.255.200` |
| `DHCP_GATEWAY` | `10.255.255.1` |
| `DHCP_DNS` | `8.8.8.8` |

### 示例：自定义 DHCP 网络

编辑 `.env`：
```env
COMPOSE_PROFILES=gateway
DHCP_SUBNET=192.168.100.0
DHCP_NETMASK=255.255.255.0
DHCP_RANGE_START=192.168.100.100
DHCP_RANGE_END=192.168.100.200
DHCP_GATEWAY=192.168.100.1
DHCP_DNS=1.1.1.1,8.8.8.8
```

## 组件

- **supernode**: n2n 超级节点（网关模式）
- **edge**: n2n 边界客户端（两种模式）
- **dhcpd**: ISC DHCP 服务器（网关模式）
- **lease-ui**: Web 租约查看器，支持实时倒计时（网关模式）

## 注意事项

- 边界模式下，n2n 设备出现后自动运行 `dhclient`
- 设置 `EDGE_ADD_DEFAULT_GW=true` 可保留 DHCP 的默认打由
- 租约 UI 会自动过滤 `dhcpd.leases` 中的注释行
- 所有容器都遵守 `TIMEZONE` 变量以确保时间准确
