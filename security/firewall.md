# Firewall Configuration Guide

## Overview

This guide covers firewall configuration for the Ubuntu Server, focusing on securing the system while allowing necessary services to function.

## What is a Firewall?

A firewall is a network security system that monitors and controls incoming and outgoing network traffic based on predetermined security rules. It establishes a barrier between trusted internal networks and untrusted external networks.

## Why Firewall is Important

- **Security**: Blocks unauthorized access to your server
- **Control**: Only allowed services are accessible
- **Auditing**: Tracks connection attempts
- **Compliance**: Meets security best practices

## Firewall Types on Ubuntu

### UFW (Uncomplicated Firewall)

UFW is the default firewall on Ubuntu, providing a user-friendly interface for managing iptables rules.

### iptables

The underlying firewall system that UFW manages. More complex but powerful.

### firewalld

Alternative firewall management tool (not default on Ubuntu).

## UFW Quick Start

```bash
# Check UFW status
sudo ufw status

# Enable UFW
sudo ufw enable

# Disable UFW
sudo ufw disable

# Reset UFW (removes all rules)
sudo ufw reset
```

## Default Policies

```bash
# Set default incoming policy to deny
sudo ufw default deny incoming

# Set default outgoing policy to allow
sudo ufw default allow outgoing

# This ensures:
# - All incoming connections are blocked by default
# - All outgoing connections are allowed
```

## Opening Ports

Based on the project requirements, we need to open these ports:

### SSH (Port 2222 - Changed from default 22)

```bash
# Allow SSH on port 2222
sudo ufw allow 2222/tcp

# Or use service name (if ssh is configured for port 2222)
sudo ufw allow ssh
```

### Web Server (HTTP/HTTPS)

```bash
# Allow HTTP (port 80)
sudo ufw allow 80/tcp

# Allow HTTPS (port 443)
sudo ufw allow 443/tcp

# Or both
sudo ufw allow http
sudo ufw allow https
```

### FTP (Port 21)

```bash
# Allow FTP
sudo ufw allow 21/tcp
```

### Jenkins (Port 8080)

```bash
# Allow Jenkins
sudo ufw allow 8080/tcp
```

### SonarQube (Port 9000)

```bash
# Allow SonarQube
sudo ufw allow 9000/tcp
```

## Closing Ports

```bash
# Deny specific port
sudo ufw deny 3306/tcp

# Delete a rule
sudo ufw delete allow 80/tcp
```

## Viewing Rules

```bash
# List rules with numbers
sudo ufw status numbered

# Verbose status
sudo ufw verbose
```

## Port Justification

| Port | Service | Justification |
|------|---------|----------------|
| 2222 | SSH | Remote server administration (changed from default 22) |
| 80 | HTTP | WordPress web server |
| 21 | FTP | FTP server for backup access |
| 8080 | Jenkins | CI/CD server (Docker container) |
| 9000 | SonarQube | Code quality platform (Docker container) |

## Advanced Rules

### Allow from Specific IP

```bash
# Allow SSH only from specific IP
sudo ufw allow from 192.168.1.50 to any port 2222
```

### Allow IP Range

```bash
# Allow from IP range
sudo ufw allow from 192.168.1.0/24 to any port 80
```

### Allow with Interface

```bash
# Allow on specific interface
sudo ufw allow in on ens33 to any port 80
```

## Rate Limiting (Brute Force Protection)

```bash
# Limit SSH connections (6 connections per 30 seconds)
sudo ufw limit 2222/tcp
```

## Logging

```bash
# Enable logging
sudo ufw logging on

# Set logging level
sudo ufw logging low      # Low: blocked packets not matching default policy
sudo ufw logging medium  # Medium: includes invalid packets
sudo ufw logging high    # High: includes all packets

# View logs
sudo less /var/log/ufw.log
```

## Testing Firewall Rules

```bash
# Check which ports are open
sudo ufw status verbose

# Scan from another machine
nmap -sT -p- server-ip

# Check specific port
nc -zv server-ip 2222
```

## Troubleshooting

### Locked Out

If you accidentally lock yourself out:

```bash
# Allow SSH temporarily
sudo ufw allow 22/tcp

# Or disable firewall (recovery)
sudo ufw disable
```

### Services Not Accessible

```bash
# Check if port is open
sudo ufw status

# Check if service is running
sudo systemctl status <service-name>

# Check listening ports
sudo ss -tuln
```

## Complete Firewall Setup Script

```bash
#!/bin/bash

# Firewall Setup Script for deep-in-system

# Set defaults
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Open required ports
sudo ufw allow 2222/tcp  # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 21/tcp    # FTP

# Open DevOps ports (if needed)
# sudo ufw allow 8080/tcp  # Jenkins
# sudo ufw allow 9000/tcp # SonarQube

# Enable firewall
sudo ufw enable

# Show status
sudo ufw status verbose
```

## Security Best Practices

1. **Deny by Default**: Block everything, then explicitly allow needed services
2. **Change Default Ports**: SSH on 2222 instead of 22
3. **Enable Logging**: Monitor blocked attempts
4. **Use Rate Limiting**: Prevent brute force attacks
5. **Regular Review**: Check firewall rules periodically
6. **Close Unused Ports**: Every open port is a potential vulnerability
