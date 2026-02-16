#!/bin/sh
mkdir /etc/n2n
echo "-p ${SUPERNODE_PORT}" > /etc/n2n/supernode.conf
exec /usr/sbin/supernode /etc/n2n/supernode.conf -f ${SUPERNODE_EXTRAPARAM}
