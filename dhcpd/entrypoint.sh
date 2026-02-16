#!/bin/sh
set -e

USE_ENV=0
if [ -n "$DHCP_SUBNET" ] || [ -n "$DHCP_NETMASK" ] || [ -n "$DHCP_RANGE_START" ] || \
   [ -n "$DHCP_RANGE_END" ] || [ -n "$DHCP_GATEWAY" ] || [ -n "$DHCP_DNS" ]; then
  USE_ENV=1
fi

if [ "$USE_ENV" = "1" ]; then
  SUBNET="${DHCP_SUBNET:-10.255.255.0}"
  NETMASK="${DHCP_NETMASK:-255.255.255.0}"
  RANGE_START="${DHCP_RANGE_START:-10.255.255.50}"
  RANGE_END="${DHCP_RANGE_END:-10.255.255.200}"
  GATEWAY="${DHCP_GATEWAY:-10.255.255.1}"
  DNS="${DHCP_DNS:-8.8.8.8}"

  cat > /tmp/dhcpd.conf <<CFG
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet ${SUBNET} netmask ${NETMASK} {
  range ${RANGE_START} ${RANGE_END};
  option routers ${GATEWAY};
  option domain-name-servers ${DNS};
}
CFG

  CONF_PATH="/tmp/dhcpd.conf"
else
  CONF_PATH="/etc/dhcp/dhcpd.conf"
fi
mkdir -p /var/lib/dhcp
if [ ! -f /var/lib/dhcp/dhcpd.leases ]; then
  touch /var/lib/dhcp/dhcpd.leases
fi
exec /usr/sbin/dhcpd -4 -f -cf "$CONF_PATH" ${DHCP_IFACE}
