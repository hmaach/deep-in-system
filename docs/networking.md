# Networking Guide

## Overview

This guide covers networking concepts and configuration for the Ubuntu Server in the deep-in-system project.

## Network Fundamentals

### IP Addresses

An IP address is a unique identifier for a device on a network.

#### IPv4

- Format: 4 octets (0-255) separated by dots
- Example: `192.168.1.100`

#### Private IP Ranges

| Range | Example | Used For |
|-------|---------|----------|
| 10.0.0.0/8 | 10.0.0.1 - 10.255.255.255 | Large networks |
| 172.16.0.0/12 | 172.16.0.1 - 172.31.255.255 | Medium networks |
| 192.168.0.0/16 | 192.168.0.1 - 192.168.255.255 | Small networks |

### Subnet Masks

A subnet mask determines which part of an IP address is the network portion.

| CIDR | Netmask | Hosts |
|------|---------|-------|
| /24 | 255.255.255.0 | 254 |
| /25 | 255.255.255.128 | 126 |
| /26 | 255.255.255.192 | 62 |
| /27 | 255.255.255.224 | 30 |
| /28 | 255.255.255.240 | 14 |

### Default Gateway

The default gateway is the router that connects the local network to the internet.

Example: `192.168.1.1`

### DNS (Domain Name System)

DNS translates domain names to IP addresses.

Common DNS servers:
- Google: 8.8.8.8, 8.8.4.4
- Cloudflare: 1.1.1.1

## Network Configuration

### Netplan Configuration

Netplan is the network configuration tool for Ubuntu.

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

### Network Commands

```bash
# Show IP addresses
ip addr

# Show routing table
ip route

# Test connectivity
ping google.com

# DNS lookup
nslookup google.com

# Check DNS resolution
dig google.com
```

## Network Services

### DNS Configuration

Edit `/etc/resolv.conf` for custom DNS servers:

```bash
nameserver 8.8.8.8
nameserver 8.8.4.4
```

### Static vs Dynamic IP

| Feature | Static IP | DHCP |
|---------|-----------|------|
| Address | Manual | Auto-assigned |
| Consistency | Same each time | May change |
| Use Case | Servers | Clients |
| Configuration | More setup | Easier |

## Network Ports

### Common Ports

| Port | Service |
|------|---------|
| 21 | FTP |
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |
| 3306 | MySQL |
| 5432 | PostgreSQL |
| 8080 | HTTP Alt |

### Port Ranges

- Well-known: 0-1023
- Registered: 1024-49151
- Dynamic: 49152-65535

## Firewall and Networking

### UFW Firewall

UFW (Uncomplicated Firewall) manages network access.

```bash
# Allow port
sudo ufw allow 80/tcp

# Deny port
sudo ufw deny 3306/tcp

# Check status
sudo ufw status
```

## Network Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| No internet | Check gateway and DNS |
| Can't connect to server | Check firewall rules |
| Slow connection | Check network congestion |
| IP conflict | Change IP address |

### Troubleshooting Commands

```bash
# Check connectivity
ping -c 4 google.com

# Trace route
traceroute google.com

# Check listening ports
netstat -tuln

# Check connections
ss -tun
```

## Security Considerations

1. **Use Static IPs for Servers**: Ensures consistent access
2. **Configure Firewall**: Block unused ports
3. **Disable Unnecessary Services**: Reduce attack surface
4. **Use SSH Keys**: More secure than passwords
5. **Enable Logging**: Monitor network activity
