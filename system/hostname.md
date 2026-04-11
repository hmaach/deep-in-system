# Hostname Configuration Guide

## Overview

This document explains how to set and configure the hostname for the Ubuntu Server in the deep-in-system project.

## Hostname Requirements

According to the project requirements:
- The hostname must be in the format: `{username}-host`
- Example: If the login username is `potato`, the hostname must be `potato-host`

## Why Hostname Matters

- **Identification**: Helps identify the server on the network
- **Professionalism**: Follows naming conventions for servers
- **Audit Requirements**: Must match the project specification
- **DNS**: Used for local DNS resolution

## Set Hostname

### Method 1: Using hostnamectl (Recommended)

```bash
# Set hostname
sudo hostnamectl set-hostname <username>-host

# Verify
hostname
```

Example:
```bash
sudo hostnamectl set-hostname potato-host
```

### Method 2: Edit hostname File

```bash
# Display current hostname
cat /etc/hostname

# Edit hostname file
sudo vim /etc/hostname

# Set the hostname
<username>-host

# Save and exit
```

## Update /etc/hosts File

After changing the hostname, update the hosts file to ensure local resolution works:

```bash
# Open hosts file
sudo vim /etc/hosts

# Ensure it contains:
127.0.0.1       localhost
127.0.1.1       <username>-host

# The line with IP 127.0.1.1 should match your hostname
```

## Verify Configuration

```bash
# Check hostname
hostname

# Check detailed hostname info
hostnamectl

# Check if hostname resolves
getent hosts $(hostname)
```

Expected output:
```
$ hostname
potato-host

$ hostnamectl
   Static hostname: potato-host
         Icon name: computer-server
           Chassis: server
        Machine ID: <machine-id>
           Boot ID: <boot-id>
    Virtualization: vmware
  Operating System: Ubuntu 22.04 LTS
            Kernel: Linux 5.15.0--generic
      Architecture: x86-64
```

## Persistent Configuration

The hostname set with `hostnamectl` is persistent and survives reboots.

### Verification After Reboot

```bash
# Reboot the server
sudo reboot

# After reboot, check hostname
hostname
```

It should still show `<username>-host`.

## Troubleshooting

### Hostname Not Resolving

If you encounter issues with hostname resolution:

```bash
# Check /etc/hosts
cat /etc/hosts

# Ensure 127.0.1.1 line has correct hostname
sudo vim /etc/hosts
```

### SSH Connection Issues

If hostname changes cause SSH issues:

```bash
# Clear SSH known_hosts
vim ~/.ssh/known_hosts

# Remove old hostname entries
```

### Network Service Restart

After hostname change, you may need to restart networking:

```bash
# Restart systemd-resolved
sudo systemctl restart systemd-resolved

# Or restart networking
sudo systemctl restart networking
```

## Best Practices

1. **Use Consistent Naming**: Follow the `{username}-host` format
2. **Update Documentation**: Keep server documentation updated with hostname
3. **Avoid Special Characters**: Use only lowercase letters, numbers, and hyphens
4. **Meaningful Names**: The hostname should be easily identifiable

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Hostname resets after reboot | Use `hostnamectl` for persistent setting |
| Can't connect via hostname | Check `/etc/hosts` configuration |
| SSH warnings after change | Clear `~/.ssh/known_hosts` |
