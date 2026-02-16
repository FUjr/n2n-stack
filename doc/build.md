# Building from Source

This guide covers building multi-architecture container images and pushing them to a registry.

## Prerequisites

### Docker Buildx

Check if buildx is available:

```bash
docker buildx version
```

If not found, install Docker Buildx:

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y docker-buildx
```

**macOS (Docker Desktop):**
Buildx is included by default in Docker Desktop.

### Multi-Architecture Support

For native builds on non-x86_64 systems, enable QEMU emulation:

```bash
docker run --privileged --rm tonistiigi/binfmt --install all
```

Verify QEMU support:
```bash
ls /proc/sys/fs/binfmt_misc/
```

## Setup Buildx Builder

### Create a Multi-Architecture Builder

```bash
docker buildx create --name multiarch --use
```

Optional: For pushing to registries, configure buildx with credentials:
```bash
docker login your-registry.com
```

### Inspect Builder Status

```bash
docker buildx inspect --bootstrap
```

Expected output shows support for `linux/amd64` and `linux/arm64`.

## Building

### Build Configuration

The project uses `docker-bake.hcl` to define multi-architecture targets. Each service is built for both `amd64` and `arm64` architectures.

### Build and Push

Push to default registry (requires authentication):
```bash
docker buildx bake
```

Override registry prefix:
```bash
IMAGE_PREFIX=your-registry.com/your-org docker buildx bake
```

Build locally without pushing (for testing):
```bash
docker buildx bake --load
```

### Build Specific Services

Build only the edge service:
```bash
docker buildx bake edge
```

Build multiple services:
```bash
docker buildx bake edge supernode
```

## Troubleshooting

### "unknown flag: --set" Error

Your buildx version is outdated. Upgrade Docker:
```bash
sudo apt-get upgrade docker-ce docker-ce-cli
```

### Build Failures on ARM

If cross-compilation fails, ensure QEMU is properly installed:
```bash
docker run --privileged --rm tonistiigi/binfmt --install arm64
```

### Registry Authentication

For private registries, configure credentials before building:
```bash
docker logout
docker login your-registry.com
```

### Disk Space

Multi-architecture builds can consume significant disk space. Free up space if needed:
```bash
docker buildx du
docker builder prune
```
