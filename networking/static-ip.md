# Static IP Configuration

## Overview

This section documents how the static IP was configured on the Ubuntu Server.

The goal was to:

- disable DHCP
- assign a fixed IP
- ensure internet connectivity

---

## Network Context

Host machine:

```

10.1.18.24/16

```

Chosen static IP for the server:

```

10.1.18.50/16

```

---

## Step 1 — Switch to Bridged Network

In VirtualBox:

```

Settings → Network → Adapter 1

```

Set:

```

Attached to: Bridged Adapter
Interface: eno2
Promiscuous Mode: Allow All

```

This connects the VM to the same network as the host.

---

## Step 2 — Identify Interface

Inside the VM:

```bash
ip a
```

Interface used:

```
enp0s3
```

---

## Step 3 — Configure Netplan

Edit:

```
/etc/netplan/00-installer-config.yaml
```

Final configuration:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 10.1.18.50/16
      routes:
        - to: default
          via: 10.1.0.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

---

## Step 4 — Apply Configuration

```bash
sudo netplan try
sudo netplan apply
```

---

## Step 5 — Verification

```bash
ip a
ip route
ping 10.1.0.1
ping 8.8.8.8
ping google.com
```

Expected results:

- IP is correctly assigned → `10.1.18.50`
- Default route exists → `via 10.1.0.1`
- Internet access works

---

## Key Points

- `renderer: networkd` is used for server environments
- `routes` replaces deprecated `gateway4`
- IP, netmask, and gateway must belong to the same network
- Bridged mode is required to use the host network

---

## Troubleshooting (What Was Fixed)

- Wrong gateway (`192.168.x.x`) → fixed to `10.1.0.1`
- VM was using NAT → switched to Bridged
- Renderer typo (`network`) → corrected to `networkd`

---

## Result

The server now has:

- Static IP configured
- Internet access working
- Ready for further setup (SSH, firewall, services)
