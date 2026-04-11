# Essential Packages Installation

## Overview

This guide covers the essential packages that should be installed on the Ubuntu Server to support the deep-in-system project requirements.

## Why Essential Packages?

These packages form the foundation for:
- System administration
- Network configuration
- Security hardening
- Service installation
- Development tools

## Core Essential Packages

### System Update & Upgrade

```bash
# Update package lists
sudo apt update

# Upgrade all packages
sudo apt upgrade -y
```

### Install Essential Tools

```bash
# Install essential packages
sudo apt install -y \
    git \
    curl \
    wget \
    vim \
    nano \
    tree \
    htop \
    net-tools \
    ufw \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release
```

### Package Descriptions

| Package | Purpose |
|---------|---------|
| git | Version control system |
| curl | HTTP client for downloading files |
| wget | File download utility |
| vim | Text editor (alternative: nano) |
| tree | Directory structure visualization |
| htop | Process monitoring (interactive) |
| net-tools | Network utilities (ifconfig, netstat) |
| ufw | Uncomplicated Firewall |
| build-essential | C/C++ compilers and build tools |
| software-properties-common | Package management utilities |
| apt-transport-https | HTTPS support for apt |
| ca-certificates | SSL certificates |
| gnupg | GNU Privacy Guard for keys |
| lsb-release | Linux Standard Base info |

## Verify Installation

```bash
# Check installed versions
git --version
curl --version
wget --version
vim --version
htop --version
ufw --version
```

## Additional Recommended Packages

### System Monitoring

```bash
sudo apt install -y \
    iotop \
    sysstat \
    nmon
```

### Network Tools

```bash
sudo apt install -y \
    iputils-ping \
    traceroute \
    mtr-tiny \
    nmap \
    tcpdump
```

### Text Processing

```bash
sudo apt install -y \
    grep \
    sed \
    awk \
    cat-utils
```

## Keeping Packages Updated

### Regular Updates

```bash
# Check for updates
sudo apt update

# Upgrade with auto-remove
sudo apt upgrade -y
sudo apt autoremove -y

# Clean up
sudo apt clean
```

### Automatic Security Updates

```bash
# Install unattended-upgrades
sudo apt install -y unattended-upgrades

# Enable automatic updates
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Troubleshooting

### Package Installation Fails

```bash
# Clear apt cache
sudo apt clean

# Update again
sudo apt update

# Try installation again
sudo apt install -y <package-name>
```

### Dependency Issues

```bash
# Fix broken packages
sudo apt --fix-broken install -y

# Reconfigure packages
sudo dpkg --configure -a
```
