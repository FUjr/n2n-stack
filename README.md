# n2n-stack

> A multi-mode Docker stack for n2n peer-to-peer virtual networking with integrated DHCP management.

[中文文档](README_zh.md)

## Features

- **Dual-mode operation**: Gateway mode with full infrastructure (supernode, DHCP, lease UI) or lightweight edge mode
- **Multi-architecture builds**: Seamless cross-architecture support (amd64, arm64) via Docker Buildx
- **Dynamic DHCP configuration**: Override subnet, IP ranges, and DNS via environment variables
- **Web-based lease viewer**: Real-time DHCP lease monitoring with countdown timers and comment filtering
- **Flexible networking**: Support for both static and DHCP-based IP assignment in edge mode
- **Production-ready**: Timezone support, health checks, and comprehensive logging

## Architecture

### Gateway Mode
Full-featured n2n gateway with DHCP server and web UI:
```
supernode + edge (static IP) + dhcpd + lease-ui
```
Ideal for centralized network hubs.

### Edge Mode  
Lightweight edge client with optional DHCP client integration:
```
edge (DHCP IP) + dhclient
```
Perfect for remote nodes that need automatic IP assignment.

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Docker Buildx with multi-architecture support

### Building

For detailed build instructions, see [Building from Source](doc/build.md).

Quick build and push:
```bash
docker buildx bake
```

Override registry:
```bash
IMAGE_PREFIX=your-registry/your-org docker buildx bake
```

### Deployment

#### Gateway Mode (Default)
```bash
echo "COMPOSE_PROFILES=gateway" >> .env
docker compose up -d
```
Services: supernode (UDP 13103), lease UI (port 51080)

#### Edge Mode
```bash
echo "COMPOSE_PROFILES=edge" >> .env
docker compose up -d
```
The edge node will automatically obtain an IP via DHCP.

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `COMPOSE_PROFILES` | `gateway` | Deployment mode: `gateway` or `edge` |
| `TIMEZONE` | `UTC` | Container timezone (e.g., `Asia/Shanghai`) |
| `IMAGE_PREFIX` | `registry.cn-hangzhou.aliyuncs.com/fjrcn` | Container registry prefix |
| `N2N_COMMUNITY` | `mynet` | n2n community name |
| `N2N_KEY` | `mysecret` | n2n encryption key |
| `N2N_DEVICE` | `n2n1` | Virtual network interface name |
| `N2N_EDGE_IP` | `10.255.255.1` | Static IP (gateway mode) |
| `SUPERNODE_HOST` | `127.0.0.1` | Supernode address |
| `SUPERNODE_PORT` | `13103` | Supernode port |
| `EDGE_ADD_DEFAULT_GW` | `false` | Keep DHCP default route (edge mode) |

### DHCP Configuration (Gateway Mode)

When any of these variables is set, `dhcpd.conf` is generated dynamically. Leave them empty to use the default config.

| Variable | Default |
|----------|---------|
| `DHCP_SUBNET` | `10.255.255.0` |
| `DHCP_NETMASK` | `255.255.255.0` |
| `DHCP_RANGE_START` | `10.255.255.50` |
| `DHCP_RANGE_END` | `10.255.255.200` |
| `DHCP_GATEWAY` | `10.255.255.1` |
| `DHCP_DNS` | `8.8.8.8` |

### Example: Custom DHCP Network

Edit `.env`:
```env
COMPOSE_PROFILES=gateway
DHCP_SUBNET=192.168.100.0
DHCP_NETMASK=255.255.255.0
DHCP_RANGE_START=192.168.100.100
DHCP_RANGE_END=192.168.100.200
DHCP_GATEWAY=192.168.100.1
DHCP_DNS=1.1.1.1,8.8.8.8
```

## Components

- **supernode**: n2n supernode (gateway mode)
- **edge**: n2n edge client (both modes)
- **dhcpd**: ISC DHCP server (gateway mode)
- **lease-ui**: Web-based lease viewer with real-time countdown (gateway mode)

## Notes

- In edge mode, `dhclient` runs automatically after the n2n device appears
- Set `EDGE_ADD_DEFAULT_GW=true` to preserve the default route from DHCP
- Comment lines in `dhcpd.leases` are automatically filtered by the lease UI
- All containers respect the `TIMEZONE` variable for proper time handling
