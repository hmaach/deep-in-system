# Security Guide

## Overview

This guide covers security best practices and implementations for the Ubuntu Server in the deep-in-system project.

## Security Principles

### Defense in Depth

Multiple layers of security protect the system:

1. **Network Level**: Firewall, network segmentation
2. **System Level**: User permissions, file access
3. **Application Level**: Secure configurations
4. **Data Level**: Encryption, backups

### Principle of Least Privilege

Users and processes should have only the minimum permissions needed to function.

## System Security

### User Security

#### Create Users with Proper Permissions

```bash
# Create admin user with sudo
sudo adduser admin
sudo usermod -aG sudo admin

# Create regular user without sudo
sudo adduser user
```

#### SSH Key Authentication

```bash
# Generate SSH key (on local machine)
ssh-keygen -t ed25519

# Copy public key to server
ssh-copy-id user@server
```

### Sudo Configuration

```bash
# View sudoers
sudo visudo

# Grant specific sudo access
username ALL=(ALL) /path/to/command
```

## SSH Security

### Secure SSH Configuration

Edit `/etc/ssh/sshd_config`:

```bash
# Disable root login
PermitRootLogin no

# Change default port
Port 2222

# Disable password authentication (use keys)
PasswordAuthentication no

# Enable public key authentication
PubkeyAuthentication yes

# Limit authentication attempts
MaxAuthTries 3
```

### SSH Key Best Practices

1. Use Ed25519 or RSA 4096 keys
2. Protect keys with passphrases
3. Never share private keys
4. Rotate keys periodically

## Firewall Security

### UFW Configuration

```bash
# Default deny incoming
sudo ufw default deny incoming

# Default allow outgoing
sudo ufw default allow outgoing

# Allow specific ports
sudo ufw allow 2222/tcp   # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 21/tcp    # FTP

# Enable firewall
sudo ufw enable
```

### Port Security

| Port | Service | Security Note |
|------|---------|---------------|
| 22 | SSH | Changed to 2222 |
| 21 | FTP | Limited access |
| 80 | HTTP | Use HTTPS |
| 3306 | MySQL | Block external |

## Database Security

### MySQL Security

```bash
# Secure installation
sudo mysql_secure_installation

# Disable remote root
CREATE USER 'root'@'localhost' IDENTIFIED BY 'password';

# Use dedicated user for applications
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'strongpassword';
GRANT ALL PRIVILEGES ON appdb.* TO 'appuser'@'localhost';
```

### Database Best Practices

1. Use strong passwords
2. Limit user privileges
3. Disable remote access for root
4. Regular backups

## Web Server Security

### Nginx Security

```bash
# Hide version number
server_tokens off;

# Prevent clickjacking
add_header X-Frame-Options "SAMEORIGIN";

# Enable XSS protection
add_header X-XSS-Protection "1; mode=block";

# Enable HTTPS
```

### WordPress Security

1. Keep WordPress updated
2. Use strong admin password
3. Disable file editing
4. Protect wp-config.php

## Monitoring and Logging

### Enable Logging

```bash
# Enable UFW logging
sudo ufw logging on

# Check auth log
sudo less /var/log/auth.log
```

### Log Monitoring

```bash
# Monitor failed SSH attempts
sudo grep "Failed password" /var/log/auth.log

# Monitor firewall blocks
sudo tail -f /var/log/ufw.log
```

## Security Checklist

- [ ] SSH port changed from 22
- [ ] Root login disabled
- [ ] SSH key authentication enabled
- [ ] Firewall configured
- [ ] Users created with proper permissions
- [ ] Database secured
- [ ] Web server hardened
- [ ] Logging enabled
- [ ] Regular backups scheduled
- [ ] System updated
