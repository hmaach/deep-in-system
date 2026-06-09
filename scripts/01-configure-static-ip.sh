#!/usr/bin/env bash
set -eu

if [ "$#" -ne 3 ]; then
    echo "Usage: sudo bash $0 <interface> <address/cidr> <gateway>"
    echo "Example: sudo bash $0 enp0s3 10.1.18.50/16 10.1.0.1"
    exit 1
fi

INTERFACE="$1"
ADDRESS="$2"
GATEWAY="$3"
NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this script with sudo." >&2
    exit 1
fi

cp "$NETPLAN_FILE" "$NETPLAN_FILE.bak.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true

cat > "$NETPLAN_FILE" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      dhcp4: false
      addresses:
        - $ADDRESS
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
EOF

chmod 600 "$NETPLAN_FILE"
netplan apply

echo "Static IP configured on $INTERFACE:"
ip -4 addr show "$INTERFACE"
