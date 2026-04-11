# UFW Firewall Rules Reference

## Quick Reference for UFW Commands

This file contains commonly used UFW firewall rules for the deep-in-system project.

## Basic Commands

```bash
# Enable UFW
sudo ufw enable

# Disable UFW
sudo ufw disable

# Check status
sudo ufw status verbose

# Show numbered rules
sudo ufw status numbered
```

## Default Policies

```bash
# Deny all incoming by default
sudo ufw default deny incoming

# Allow all outgoing by default
sudo ufw default allow outgoing
```

## SSH Configuration

```bash
# Allow SSH (port 2222 - as per project requirements)
sudo ufw allow 2222/tcp

# Allow SSH with rate limiting (prevents brute force)
sudo ufw limit 2222/tcp
```

## Web Server Ports

```bash
# Allow HTTP
sudo ufw allow 80/tcp

# Allow HTTPS
sudo ufw allow 443/tcp
```

## FTP Server Port

```bash
# Allow FTP
sudo ufw allow 21/tcp
```

## DevOps Ports (Optional)

```bash
# Allow Jenkins (8080)
sudo ufw allow 8080/tcp

# Allow SonarQube (9000)
sudo ufw allow 9000/tcp

# Allow Docker (2375 - not recommended for production)
# sudo ufw allow 2375/tcp
```

## Database Ports (Internal Only)

```bash
# MySQL - DO NOT open these to the internet
# These are for local access only (managed by MySQL bind-address)
# sudo ufw allow from 127.0.0.1 to any port 3306
```

## Managing Rules

```bash
# Delete a rule
sudo ufw delete allow 2222/tcp

# Delete by number
sudo ufw delete 2

# Insert a rule at position 1
sudo ufw insert 1 allow 2222/tcp

# Reload firewall
sudo ufw reload
```

## Advanced Rules

```bash
# Allow from specific IP
sudo ufw allow from 192.168.1.100 to any port 2222

# Allow specific port from subnet
sudo ufw allow from 192.168.1.0/24 to any port 80

# Allow on specific interface
sudo ufw allow in on ens33 to any port 80

# Deny from specific IP
sudo ufw deny from 192.168.1.50
```

## Common Port Reference

| Port | Service | Protocol |
|------|---------|----------|
| 21 | FTP | TCP |
| 22 | SSH (default) | TCP |
| 2222 | SSH (custom) | TCP |
| 80 | HTTP | TCP |
| 443 | HTTPS | TCP |
| 3306 | MySQL | TCP |
| 8080 | Jenkins | TCP |
| 9000 | SonarQube | TCP |

## Project-Specific Rules

Based on the deep-in-system project requirements:

```
# SSH (mandatory)
sudo ufw allow 2222/tcp

# Web (WordPress)
sudo ufw allow 80/tcp

# FTP (backup access)
sudo ufw allow 21/tcp
```

## UFW Logging

```bash
# Enable logging
sudo ufw logging on

# Disable logging
sudo ufw logging off

# View logs
sudo less /var/log/ufw.log
```

## Reset and Start Over

```bash
# Reset all rules
sudo ufw reset

# Disable and reset
sudo ufw disable
sudo ufw reset
```
