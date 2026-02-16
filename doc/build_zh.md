# 从源码构建

本文档介绍如何构建多架构容器镜像并推送到镜像仓库。

## 系统要求

### Docker Buildx

检查 buildx 是否可用：

```bash
docker buildx version
```

如果未安装，请安装 Docker Buildx：

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y docker-buildx
```

**macOS (Docker Desktop):**
Docker Desktop 已默认包含 Buildx。

### 多架构支持

在非 x86_64 系统上，启用 QEMU 模拟：

```bash
docker run --privileged --rm tonistiigi/binfmt --install all
```

验证 QEMU 支持：
```bash
ls /proc/sys/fs/binfmt_misc/
```

## 配置 Buildx Builder

### 创建多架构 Builder

```bash
docker buildx create --name multiarch --use
```

可选：为了推送到镜像仓库，配置凭证：
```bash
docker login your-registry.com
```

### 检查 Builder 状态

```bash
docker buildx inspect --bootstrap
```

输出应显示对 `linux/amd64` 和 `linux/arm64` 的支持。

## 构建

### 构建配置

项目通过 `docker-bake.hcl` 定义多架构构建目标。每个服务都会针对 `amd64` 和 `arm64` 两种架构进行构建。

### 构建并推送

推送到默认镜像仓库（需要身份验证）：
```bash
docker buildx bake
```

使用自定义仓库前缀：
```bash
IMAGE_PREFIX=your-registry.com/your-org docker buildx bake
```

仅本地构建（不推送，用于测试）：
```bash
docker buildx bake --load
```

### 构建特定服务

仅构建 edge 服务：
```bash
docker buildx bake edge
```

构建多个服务：
```bash
docker buildx bake edge supernode
```

## 故障排除

### "unknown flag: --set" 错误

Buildx 版本过旧。升级 Docker：
```bash
sudo apt-get upgrade docker-ce docker-ce-cli
```

### ARM 构建失败

如果跨架构编译失败，确保 QEMU 已正确安装：
```bash
docker run --privileged --rm tonistiigi/binfmt --install arm64
```

### 镜像仓库身份验证

对于私有镜像仓库，构建前配置凭证：
```bash
docker logout
docker login your-registry.com
```

### 磁盘空间

多架构构建可能占用大量磁盘空间。如需释放空间：
```bash
docker buildx du
docker builder prune
```
