#!/bin/sh
set -e

mkdir -p /etc/n2n

EDGE_MODE="${N2N_MODE:-${COMPOSE_PROFILES:-gateway}}"

if [ "$EDGE_MODE" = "edge" ]; then
  EDGE_IP_ADDR="dhcp:0.0.0.0"
else
  EDGE_IP_ADDR="${N2N_EDGE_IP}"
fi

cat > /etc/n2n/edge.conf <<CFG
-d ${N2N_DEVICE}
-c ${N2N_COMMUNITY}
-k ${N2N_KEY}
-l ${SUPERNODE_HOST}:${SUPERNODE_PORT}
-r
-a ${EDGE_IP_ADDR}
-m ${N2N_EDGE_MAC}
-E
CFG
ADD_DEFAULT_GW="${EDGE_ADD_DEFAULT_GW:-false}"

/usr/sbin/edge /etc/n2n/edge.conf -f &
EDGE_PID=$!

if [ "$EDGE_MODE" = "edge" ]; then
	i=0
	while [ $i -lt 20 ]; do
		if ip link show "$N2N_DEVICE" >/dev/null 2>&1; then
			break
		fi
		i=$((i+1))
		sleep 0.5
	done

	mkdir -p /var/lib/dhcp
	dhclient -v -4 -pf /var/run/dhclient.pid -lf /var/lib/dhcp/dhclient.leases "$N2N_DEVICE" || true

	if [ "$ADD_DEFAULT_GW" != "true" ]; then
		ip route del default dev "$N2N_DEVICE" 2>/dev/null || true
	fi
fi

wait "$EDGE_PID"
