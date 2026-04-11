# FTP Server Setup Guide

## Overview

This guide covers installing and configuring an FTP server using vsftpd for the deep-in-system project. The FTP server will be used for backup file access.

## Requirements

- FTP server installed (vsftpd)
- User `nami` can only access `/backup` directory
- Read-only access for nami user
- Anonymous access disabled

## Install vsftpd

```bash
# Update package list
sudo apt update

# Install vsftpd
sudo apt install vsftpd

# Start vsftpd
sudo systemctl start vsftpd

# Enable on boot
sudo systemctl enable vsftpd

# Check status
sudo systemctl status vsftpd
```

## Configure vsftpd

### Backup Original Configuration

```bash
# Backup original config
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.backup
```

### Edit Configuration

```bash
# Open vsftpd configuration
sudo vim /etc/vsftpd.conf
```

Add or modify these settings:

```conf
# ============================================
# ANONYMOUS CONFIGURATION
# ============================================
# Disable anonymous login (security requirement)
anonymous_enable=NO

# ============================================
# LOCAL USER CONFIGURATION
# ============================================
# Enable local user login
local_enable=YES

# Write permission for local users
write_enable=YES

# ============================================
# CHROOT CONFIGURATION
# ==========================================
# Chroot local users (jail them to their home)
chroot_local_user=YES

# Allow writing to chroot
allow_writeable_chroot=YES

# ============================================
# PASV MODE CONFIGURATION
# ==========================================
# Enable passive mode
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100

# ============================================
# SECURITY SETTINGS
# ==========================================
# Deny with 530 response
deny_file_enable=YES
hide_file_enable=YES

# Limit connect attempts
max_clients=10
max_per_ip=5

# ============================================
# LOGGING
# ==========================================
# Enable logging
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log

# Use standard format
xferlog_std_format=YES
```

### Restart vsftpd

```bash
# Restart service
sudo systemctl restart vsftpd
```

## Create nami FTP User

### Create the User

```bash
# Create nami user
sudo adduser nami

# Enter password when prompted (for FTP login)
```

### Configure /backup Directory

```bash
# Create /backup directory
sudo mkdir -p /backup

# Set root ownership (nami can't write here)
sudo chown root:root /backup

# Set permissions (read-only for nami)
sudo chmod 755 /backup

# List /backup permissions
ls -la / | grep backup
```

### Configure User Home Directory

```bash
# Set nami's home to /backup
sudo usermod -d /backup nami

# Verify
grep nami /etc/passwd
```

## Test FTP Connection

### Connect as nami

```bash
# Connect to FTP server
ftp server-ip

# Response should be:
# Connected to server-ip.
# 220 (vsFTPd 3.0.3)
# Name (server-ip:username): nami
# 331 Please specify the password.
# Password: (enter nami's password)
# 230 Login successful.
# Remote system type is UNIX.
# Using binary mode to transfer files.
```

### Test Directory Access

```bash
# After login
ftp> ls

# Should show contents of /backup
# (which is nami's home directory)
```

### Download a File

```bash
# List files
ftp> ls

# Get a file
ftp> get filename

# Should successfully download
```

## Verify Security Requirements

### Anonymous Login Test

```bash
# Try to login as anonymous
ftp server-ip

# Name: anonymous
# Password: (leave blank)

# Expected response:
# 530 Login incorrect.
# Login failed.
```

### Write Access Test

```bash
# Try to upload (should fail - read-only)
ftp> put test.txt

# Expected response:
# 550 Permission denied.
```

## Troubleshooting

### Connection Refused

```bash
# Check vsftpd is running
sudo systemctl status vsftpd

# Check port 21 is listening
sudo netstat -tlnp | grep 21
```

### 500 OOPS Error

If you get "500 OOPS: cannot change directory":

```bash
# Check directory exists
ls -la /backup

# Fix ownership
sudo chown root:root /backup
```

### Firewall Block

```bash
# Allow FTP through firewall
sudo ufw allow 21/tcp

# For passive mode
sudo ufw allow 40000:40100/tcp
```

## FTP Commands Reference

| Command | Description |
|---------|-------------|
| `ftp server-ip` | Connect to FTP server |
| `ls` | List files |
| `get file` | Download file |
| `put file` | Upload file |
| `mget files` | Download multiple files |
| `mput files` | Upload multiple files |
| `cd directory` | Change directory |
| `pwd` | Print working directory |
| `quit` | Exit FTP |

## Security Best Practices

- **Disable Anonymous Access**: Prevents unauthorized access
- **Use Strong Passwords**: nami user should have strong password
- **Limit User Access**: nami only sees /backup
- **Use Read-Only**: nami cannot upload or delete files
- **Enable Logging**: Monitor FTP activity
