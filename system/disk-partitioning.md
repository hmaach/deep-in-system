# Disk Partitioning Guide

## Overview

This document describes the disk partitioning scheme for the Ubuntu Server virtual machine in the deep-in-system project.

## Partition Requirements

The VM disk must be **30GB** and divided into the following partitions:

| Partition | Size | Mount Point | File System |
|-----------|------|-------------|-------------|
| swap      | 4G   | [SWAP]      | swap        |
| /         | 15G  | /           | ext4        |
| /home     | 5G   | /home       | ext4        |
| /backup   | 6G   | /backup     | ext4        |

## Why These Partitions?

### Swap Partition (4GB)
- **Purpose**: Extends available memory when RAM is exhausted
- **Usage**: Used when the system runs out of physical RAM
- **Recommendation**: Should be approximately equal to RAM size, minimum 2GB for servers

### Root Partition (15GB)
- **Purpose**: Stores system files, applications, and configurations
- **Usage**: Operating system, logs, packages, and application data
- **Consideration**: Should be large enough for system updates and growth

### Home Partition (5GB)
- **Purpose**: User home directories and user data
- **Usage**: `/home/{username}` directories for all users
- **Benefit**: Separates user data from system files, making backups easier

### Backup Partition (6GB)
- **Purpose**: Stores backup files created by the backup system
- **Usage**: Database backups, configuration backups
- **Benefit**: Isolated from system partition, prevents disk full issues

## Partitioning Commands

### Using fdisk

```bash
# List current disks
sudo fdisk -l

# Enter partition editor
sudo fdisk /dev/sda

# Create new partition table
o

# Create partitions:
n (new partition)
p (primary)
1 (partition number 1)
+4G (size)
n
p
2
+15G
n
p
3
+5G
n
p
4
+6G

# Set swap type
t
1
82

# Write changes
w
```

### Format Partitions

```bash
# Format root partition
sudo mkfs.ext4 /dev/sda1

# Format home partition
sudo mkfs.ext4 /dev/sda3

# Format backup partition
sudo mkfs.ext4 /dev/sda4

# Format swap
sudo mkswap /dev/sda2
```

### Mount Partitions

```bash
# Mount root
sudo mount /dev/sda1 /

# Create home directory
sudo mkdir /home

# Mount home
sudo mount /dev/sda3 /home

# Create backup directory
sudo mkdir /backup

# Mount backup
sudo mount /dev/sda4 /backup

# Enable swap
sudo swapon /dev/sda2
```

## Verify Partition Setup

```bash
# View all partitions
lsblk

# View disk usage
df -h

# Check swap
sudo swapon --show
```

## UUID Configuration

To ensure partitions are mounted correctly after reboot, add UUIDs to `/etc/fstab`:

```bash
# Get UUIDs
sudo blkid

# Edit fstab
sudo vim /etc/fstab
```

Example `/etc/fstab` entry:
```
UUID=<root-uuid> / ext4 defaults 0 0
UUID=<home-uuid> /home ext4 defaults 0 0
UUID=<backup-uuid> /backup ext4 defaults 0 0
UUID=<swap-uuid> none swap sw 0 0
```

## Troubleshooting

### Disk Not Visible
- Check if disk is properly attached to VM
- Verify disk is recognized: `lsblk` or `fdisk -l`

### Permission Issues
- Ensure proper ownership after mounting
- Use `chown` to set correct ownership

### Partition Full
- Check usage with `df -h`
- Clean up old logs or unused packages
- Move large files to /backup partition
