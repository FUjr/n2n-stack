variable "image_prefix" {
  default = "registry.cn-hangzhou.aliyuncs.com/fjrcn"
}

group "default" {
  targets = ["supernode", "edge", "dhcpd", "lease-ui"]
}

target "supernode" {
  context = "."
  dockerfile = "supernode/Dockerfile"
  tags = ["${image_prefix}/n2n-supernode"]
  platforms = ["linux/amd64", "linux/arm64"]
  push = true
}

target "edge" {
  context = "."
  dockerfile = "edge/Dockerfile"
  tags = ["${image_prefix}/n2n-edge"]
  platforms = ["linux/amd64", "linux/arm64"]
  push = true
}

target "dhcpd" {
  context = "dhcpd"
  tags = ["${image_prefix}/isc-dhcpd"]
  platforms = ["linux/amd64", "linux/arm64"]
  push = true
}

target "lease-ui" {
  context = "lease-ui"
  tags = ["${image_prefix}/dhcp-lease-ui"]
  platforms = ["linux/amd64", "linux/arm64"]
  push = true
}
