# Static IP Configuration Guide

## Overview

This guide explains how to configure a static IP address on Ubuntu Server for the deep-in-system project.

## Requirements

- Static private IP address (your choice of netmask)
- Internet connectivity must work
- No dynamic IP (DHCP) on any internet-facing interface

## Why Static IP?

- **Server Reliability**: Servers need predictable IP addresses
- **DNS**: Easier to set up DNS records
- **Firewall**: Configure firewall rules consistently
- **Access**: Always know how to reach the server

## Network Interface Identification

```bash
# List all network interfaces
ip a

# Show only ethernet interfaces
ip link show

# Show interface details
ip addr show
```

Common interface names:
- `ens33`, `enp0s3` (VMware/VirtualBox)
- `eth0` (older systems)

## Configuration Methods

### Method 1: Netplan (Ubuntu Server 18.04+)

Netplan is the default network configuration tool for Ubuntu Server.

```bash
# Check current configuration
ls -la /etc/netplan/
```

Example netplan configuration file:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

Apply changes:

```bash
# Apply new configuration
sudo netplan apply

# Test connectivity
ping -c 5 google.com

# Check IP address
ip addr show ens33
```

### Method 2: Cloud-Init Configuration

On cloud images, network is managed by cloud-init:

```bash
# Edit cloud-init config
sudo vim /etc/cloud/cloud.cfg.d/99.cfg

# Or disable cloud-init network
sudo touch /etc/cloud/cloud-init.disabled
```

## Understanding IP Configuration

### IP Address Structure

```
192.168.1.100/24
|          |
|          └── Subnet mask (24 bits = 255.255.255.0)
|
└─────────── Network address (first 3 octets)
```

### Common Subnet Masks

| CIDR | Netmask | Usable Hosts |
|------|---------|--------------|
| /24  | 255.255.255.0 | 254 |
| /25  | 255.255.255.128 | 126 |
| /26  | 255.255.255.192 | 62 |
| /27  | 255.255.255.224 | 30 |
| /28  | 255.255.255.240 | 14 |

### Private IP Ranges

- **10.0.0.0/8**: 10.0.0.0 - 10.255.255.255
- **172.16.0.0/12**: 172.16.0.0 - 172.31.255.255
- **192.168.0.0/16**: 192.168.0.0 - 192.168.255.255

## Example Configurations

### Static IP with /24 Network

```yaml
# /etc/netplan/00-installer-config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

### Multiple DNS Servers

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
          - 1.1.1.1
        search:
          - local.domain
```

## Verify Internet Connectivity

```bash
# Test internet connection
ping -c 5 google.com

# Test DNS resolution
nslookup google.com

# Show routing table
ip route

# Check DNS
cat /etc/resolv.conf
```

## Troubleshooting

### No Internet After Configuration

```bash
# Check if interface is up
ip link set ens33 up

# Check IP address
ip addr show ens33

# Check gateway
ip route

# Test gateway
ping -c 5 192.168.1.1

# Test DNS
ping -c 5 8.8.8.8
```

### Netplan Apply Errors

```bash
# Validate configuration
sudo netplan generate

# Check for syntax errors
sudo netplan --debug apply
```

### DNS Not Working

```bash
# Check resolv.conf
cat /etc/resolv.conf

# Test specific DNS server
dig @8.8.8.8 google.com

# Use systemd-resolved
sudo systemctl restart systemd-resolved
```

## Network Commands Reference

| Command | Description |
|---------|-------------|
| `ip a` | Show all addresses |
| `ip link set <iface> up/down` | Enable/disable interface |
| `ip route show` | Display routing table |
| `ip neigh show` | Show ARP table |
| `ss -tuln` | Show listening ports |
