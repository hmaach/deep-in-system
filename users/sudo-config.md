# Sudo Configuration Guide

## Overview

This document explains the sudo configuration on the Ubuntu Server for the deep-in-system project.

## What is Sudo?

**sudo** (Super User DO) is a program that allows users to execute commands with the security privileges of another user (typically root). It provides fine-grained access control, allowing administrators to grant elevated permissions to specific commands without giving full root access.

## Why Use Sudo Instead of Root?

- **Security**: Reduces risk of accidental damage
- **Audit Trail**: Logs who ran what commands
- **Granular Control**: Grant specific permissions, not full root
- **Accountability**: Each user is responsible for their actions

## Sudo Group in Linux

The `sudo` group is a special group in Linux that grants members permission to use the `sudo` command. Members of the sudo group can execute any command as root after entering their own password.

### Checking Sudo Group

```bash
# Check if user is in sudo group
groups username

# List all members of sudo group
getent group sudo

# Check current user's groups
id
```

## Sudo Configuration Files

### /etc/sudoers

The main sudo configuration file:

```bash
# View sudoers file (use visudo for editing)
sudo visudo

# Or view without editing
sudo cat /etc/sudoers
```

### Key Sections

```
# User privilege specification
root    ALL=(ALL:ALL) ALL

# Members of 'sudo' group can gain root privileges
%sudo   ALL=(ALL:ALL) ALL
```

### Syntax Explained

```
username  hosts=(users:groups) commands
%groupname hosts=(users:groups) commands
```

- **username**: User or group (prefix with % for groups)
- **hosts**: Hosts where this rule applies (ALL for all)
- **users**: Users that the command can be run as (ALL for any)
- **groups**: Groups that the command can be run as (ALL for any)
- **commands**: Commands that can be executed (ALL for all)

## Granting Sudo Access

### Method 1: Add User to Sudo Group (Recommended)

```bash
# Add user to sudo group
sudo usermod -aG sudo username

# Verify
groups username
```

This is the recommended method as it uses the existing sudo group configuration.

### Method 2: Edit sudoers File

```bash
# Edit sudoers file
sudo visudo

# Add a line for specific user
username ALL=(ALL) ALL
```

### Method 3: Create Custom Sudo Rules

```bash
# Edit sudoers
sudo visudo

# Add specific permissions (example: only restart nginx)
username ALL=(ALL) /bin/systemctl restart nginx
```

## Using Sudo

### Basic Usage

```bash
# Run command with sudo
sudo command

# Example: update system
sudo apt update

# Run command as another user
sudo -u username command

# Check sudo access
sudo -l
```

### Password Timeout

By default, sudo remembers your password for 15 minutes. You can change this:

```bash
# Edit sudoers
sudo visudo

# Add (timeout in minutes)
Defaults timestamp_timeout=30
```

## Users in This Project

### luffy (Sudo User)

```bash
# luffy has sudo access
$ id luffy
uid=1001(luffy) gid=1001(luffy) groups=1001(luffy),27(sudo)
```

**Verification:**
```bash
# luffy can use sudo
luffy:~$ sudo whoami
[sudo] password for luffy:
root
```

### zoro (Non-Sudo User)

```bash
# zoro does NOT have sudo access
$ id zoro
uid=1002(zoro) gid=1002(zoro) groups=1002(zoro)
```

**Verification:**
```bash
# zoro cannot use sudo
zoro:~$ sudo whoami
zoro is not in the sudoers file. This incident will be reported.
```

## Security Best Practices

1. **Follow Principle of Least Privilege**: Only grant sudo to users who need it
2. **Use Specific Commands**: Avoid ALL=(ALL) ALL when possible
3. **Enable Password**: Require password for sudo commands
4. **Log Sudo Usage**: Check logs regularly
5. **Audit Users**: Regularly review sudo group members

## Sudo Logging

### View Sudo Logs

```bash
# View auth log (includes sudo)
sudo less /var/log/auth.log | grep sudo

# Or use journalctl
sudo journalctl | grep sudo
```

### Example Log Entry

```
Apr 11 10:30:45 server sudo: luffy : TTY=pts/0 ; PWD=/home/luffy ; USER=root ; COMMAND=/usr/bin/apt update
```

## Troubleshooting

### User Can't Use Sudo

```bash
# Check if user is in sudo group
groups username

# If not, add to group
sudo usermod -aG sudo username

# Re-login for group changes to take effect
```

### Password Not Working

```bash
# Reset user's password
sudo passwd username

# Check if account is locked
sudo passwd -S username
```

### Sudo Not Found

```bash
# Install sudo package
sudo apt install sudo

# If can't sudo, use su
su - root
# Then: usermod -aG sudo username
```

## Sudo Command Reference

| Command | Description |
|---------|-------------|
| `sudo -l` | List allowed commands |
| `sudo -k` | Invalidate sudo timestamp |
| `sudo -s` | Run shell as root |
| `sudo -i` | Login as root |
| `sudo -u user` | Run as specific user |
| `sudoedit file` | Edit file safely |
