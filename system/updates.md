# System Updates Guide

## Overview

This guide covers how to keep the Ubuntu Server updated with the latest security patches and package updates.

## Why Updates Are Important

- **Security**: Patches vulnerabilities and security flaws
- **Stability**: Bug fixes improve system reliability
- **Features**: New features and improvements
- **Compliance**: Meeting audit requirements for updated systems

## Update Commands

### Basic Update Process

```bash
# Update package lists
sudo apt update

# Upgrade installed packages
sudo apt upgrade -y
```

### Full Upgrade

```bash
# Full system upgrade (includes kernel)
sudo apt full-upgrade -y
```

### Clean Up

```bash
# Remove old packages
sudo apt autoremove -y

# Clean package cache
sudo apt clean
```

## Understanding Update Types

### apt update
- Refreshes the package list from repositories
- Does NOT install any updates
- Must be run before upgrade

### apt upgrade
- Installs available updates
- Never removes packages
- Safe for production systems

### apt full-upgrade
- Installs updates and removes obsolete packages
- May change dependencies
- Use with caution

## Configure Automatic Updates

### Install Unattended Upgrades

```bash
# Install unattended-upgrades
sudo apt install -y unattended-upgrades
```

### Configure Automatic Updates

```bash
# Edit configuration
sudo vim /etc/apt/apt.conf.d/50unattended-upgrades

# Or use the interactive configuration
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Example Configuration

```bash
# Enable automatic updates
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}:${distro_codename}-updates";
};

// Automatically remove unused dependencies
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Automatically reboot when required
Unattended-Upgrade::Automatic-Reboot "false";
```

### Enable Automatic Updates

```bash
# Create configuration file
sudo vim /etc/apt/apt.conf.d/20auto-upgrades

# Add:
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::Unattended-Upgrade "1";
```

## Scheduling Updates

### Using Cron

```bash
# Edit crontab
sudo crontab -e

# Add daily update check at 2 AM
0 2 * * * /usr/bin/apt update && /usr/bin/apt upgrade -y
```

## Checking Update Status

### View Available Updates

```bash
# List packages with updates
apt list --upgradable

# Show upgrade details
sudo apt list --upgradable -a
```

### Show Package Changelog

```bash
# View changelog for a package
sudo apt changelog <package-name>

# Example
sudo apt changelog nginx
```

## Kernel Updates

### Check Current Kernel

```bash
# Show running kernel
uname -r

# List installed kernels
dpkg -l | grep linux-image
```

### Manage Kernel Updates

```bash
# Hold current kernel (prevent auto-upgrade)
sudo apt-mark hold linux-image-$(uname -r)

# Unhold for upgrade
sudo apt-mark unhold linux-image-$(uname -r)
```

## Troubleshooting Update Issues

### Lock File Issues

```bash
# Remove lock files (if not in use)
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock
```

### Fix Broken Packages

```bash
# Fix broken dependencies
sudo apt --fix-broken install -y

# Reconfigure dpkg
sudo dpkg --configure -a
```

### Network Issues

```bash
# Try different mirror
sudo sed -i 's|us.archive.ubuntu.com|old-releases.ubuntu.com|g' /etc/apt/sources.list
sudo apt update
```

## Best Practices

1. **Test Before Production**: Test updates in development environment first
2. **Backup First**: Always backup before major updates
3. **Schedule Maintenance Window**: Plan for potential downtime
4. **Monitor After Updates**: Watch logs for errors after updating

## Update Checklist

- [ ] Run `apt update` first
- [ ] Review changes with `apt list --upgradable`
- [ ] Check changelogs for critical packages
- [ ] Backup system if major updates pending
- [ ] Run during maintenance window
- [ ] Verify services after update
- [ ] Monitor logs for errors
