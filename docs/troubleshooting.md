# Troubleshooting Guide

## Overview

This guide covers common issues and their solutions for the deep-in-system project.

## Network Issues

### No Internet Connection

**Symptoms**: Cannot ping external websites

**Solution**:
```bash
# Check IP address
ip addr show

# Check gateway
ip route

# Test gateway
ping -c 3 192.168.1.1

# Test DNS
ping -c 3 8.8.8.8
```

### Static IP Not Working

**Symptoms**: No network connectivity after IP change

**Solution**:
```bash
# Check netplan configuration
cat /etc/netplan/00-installer-config.yaml

# Apply configuration
sudo netplan apply

# Check for errors
sudo netplan --debug apply
```

## SSH Issues

### Cannot Connect via SSH

**Symptoms**: Connection refused or timeout

**Solution**:
```bash
# Check SSH service
sudo systemctl status ssh

# Check port
sudo netstat -tlnp | grep 2222

# Check firewall
sudo ufw status
```

### Permission Denied (Public Key)

**Symptoms**: "Permission denied (publickey)"

**Solution**:
```bash
# Check authorized_keys
cat ~/.ssh/authorized_keys

# Fix permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## Service Issues

### Nginx Not Starting

**Symptoms**: Nginx fails to start

**Solution**:
```bash
# Check error log
sudo tail -f /var/log/nginx/error.log

# Test configuration
sudo nginx -t

# Check port
sudo lsof -i :80
```

### MySQL Connection Error

**Symptoms**: Cannot connect to MySQL

**Solution**:
```bash
# Check MySQL status
sudo systemctl status mysql

# Check bind address
sudo netstat -tlnp | grep 3306

# Test connection
mysql -u wpuser -p -h localhost
```

### FTP Connection Issues

**Symptoms**: Cannot connect to FTP

**Solution**:
```bash
# Check vsftpd status
sudo systemctl status vsftpd

# Check port
sudo netstat -tlnp | grep 21

# Check firewall
sudo ufw status | grep 21
```

## WordPress Issues

### Database Connection Error

**Symptoms**: "Error establishing a database connection"

**Solution**:
```bash
# Check wp-config.php
cat /var/www/wordpress/wp-config.php

# Test MySQL
mysql -u wpuser -p wordpress

# Restart services
sudo systemctl restart mysql
sudo systemctl restart nginx
```

### 502 Bad Gateway

**Symptoms**: Nginx returns 502 error

**Solution**:
```bash
# Check PHP-FPM
sudo systemctl status php-fpm

# Restart PHP-FPM
sudo systemctl restart php-fpm

# Check socket
ls -la /run/php/
```

## Backup Issues

### Cron Not Running

**Symptoms**: Backup not created

**Solution**:
```bash
# Check cron service
sudo systemctl status cron

# List crontab
crontab -l

# Check logs
sudo tail -f /var/log/syslog | grep cron
```

### Backup File Not Created

**Symptoms**: No backup file in /backup

**Solution**:
```bash
# Run script manually
sudo /usr/local/bin/backup-db.sh

# Check permissions
ls -la /usr/local/bin/backup-db.sh

# Check log
cat /var/log/backup.log
```

## Docker Issues

### Container Not Starting

**Symptoms**: Docker container fails to start

**Solution**:
```bash
# Check logs
docker logs container-name

# Check status
docker ps -a

# Restart container
docker restart container-name
```

### Permission Issues

**Symptoms**: "Permission denied" in container

**Solution**:
```bash
# Fix ownership
sudo chown -R $(id -u):$(id -g) /path/to/volume

# Add user to docker group
sudo usermod -aG docker $USER
```

## Firewall Issues

### Accidentally Blocked SSH

**Symptoms**: Cannot connect to server

**Solution**:
```bash
# If still logged in
sudo ufw allow 2222/tcp

# If locked out, use console/VPN
# Then allow port
```

## System Issues

### Disk Full

**Symptoms**: "No space left on device"

**Solution**:
```bash
# Check disk usage
df -h

# Find large files
sudo du -sh /* | sort -rh | head -10

# Clean up
sudo apt clean
sudo docker system prune -a
```

### High CPU Usage

**Symptoms**: System is slow

**Solution**:
```bash
# Check processes
top

# Check specific service
systemctl status service-name
```

## Getting Help

### Check Logs

```bash
# All system logs
journalctl -xe

# Specific service
journalctl -u nginx -n 50

# SSH logs
tail -f /var/log/auth.log
```

### System Information

```bash
# OS version
cat /etc/os-release

# Kernel version
uname -a

# Running services
systemctl list-units --type=service
```
