# User Creation Guide

## Overview

This guide explains how to create and configure users for the deep-in-system project.

## Project User Requirements

According to the project requirements, two users need to be created:

1. **luffy**: SSH with public key authentication, sudo access
2. **zoro**: SSH with password authentication, no sudo access

Additionally, an FTP user **nami** needs to be created for backup access.

## Creating the luffy User

### Step 1: Create the User

```bash
# Create luffy user with home directory
sudo adduser luffy
```

Follow the prompts:
- Enter a password (can be empty for key-only auth)
- Fill in optional information (name, phone, etc.)

### Step 2: Add to Sudo Group

```bash
# Add luffy to sudo group
sudo usermod -aG sudo luffy

# Verify
groups luffy
```

### Step 3: Generate SSH Key Pair

On your local machine (not the server):

```bash
# Generate SSH key (Ed25519 recommended)
ssh-keygen -t ed25519 -C "luffy@deep-in-system"

# Or RSA (if Ed25519 not supported)
ssh-keygen -t rsa -b 4096 -C "luffy@deep-in-system"
```

### Step 4: Add Public Key to Server

```bash
# Create .ssh directory
sudo mkdir -p /home/luffy/.ssh

# Set permissions
sudo chmod 700 /home/luffy/.ssh

# Create authorized_keys file
sudo touch /home/luffy/.ssh/authorized_keys

# Add your public key
sudo vim /home/luffy/.ssh/authorized_keys

# Set permissions
sudo chmod 600 /home/luffy/.ssh/authorized_keys

# Set ownership
sudo chown -R luffy:luffy /home/luffy/.ssh
```

### Step 5: Test Connection

```bash
# Connect with key
ssh -i ~/.ssh/id_ed25519 luffy@server-ip -p 2222
```

## Creating the zoro User

### Step 1: Create the User

```bash
# Create zoro user
sudo adduser zoro
```

Follow the prompts:
- Enter a password (required for password authentication)
- Fill in optional information

### Step 2: Verify No Sudo Access

```bash
# Check groups
groups zoro

# Verify not in sudo group
# Output should only show: zoro : zoro
```

### Step 3: Test Password Login

```bash
# Try connecting with password
ssh zoro@server-ip -p 2222
```

## Creating the nami FTP User

### Step 1: Create FTP User

```bash
# Create nami user for FTP access
sudo adduser nami
```

Enter a password (used for FTP login).

### Step 2: Configure FTP Access

The nami user should only have access to `/backup` with read-only permissions.

```bash
# Ensure /backup directory exists
sudo mkdir -p /backup
sudo chown root:root /backup
sudo chmod 755 /backup
```

### Step 3: Test FTP Connection

```bash
# Connect via FTP
ftp server-ip

# Use nami as username and the password set above
```

## User Management Commands

### View All Users

```bash
# List all users
cat /etc/passwd

# Or with getent
getent passwd
```

### Check User Info

```bash
# Show user details
id username

# Show last login
lastlog
```

### Modify User

```bash
# Change user's password
sudo passwd username

# Lock user account
sudo passwd -l username

# Unlock user account
sudo passwd -u username

# Add user to group
sudo usermod -aG groupname username

# Remove user from group
sudo gpasswd -d username groupname
```

### Delete User

```bash
# Delete user (keep home directory)
sudo userdel username

# Delete user and home directory
sudo userdel -r username
```

## User Audit Commands

### Verify luffy

```bash
# Check groups
luffy:~$ groups luffy
luffy : luffy sudo

# Check home directory
luffy:~$ echo $HOME
/home/luffy

# Check SSH key works
ssh -i ~/.ssh/id_ed25519 luffy@localhost -p 2222
```

### Verify zoro

```bash
# Check groups
zoro:~$ groups zoro
zoro : zoro

# Check home directory
zoro:~$ echo $HOME
/home/zoro

# Test sudo access (should fail)
zoro:~$ sudo cat /etc/shadow
zoro is not in the sudoers file. This incident will be reported.
```

## Security Best Practices

1. **Use Strong Passwords**: At least 12 characters with mixed case, numbers, and symbols
2. **Use Key-Based Auth**: Prefer SSH keys over passwords
3. **Limit Sudo Access**: Only give sudo to users who need it
4. **Regular Audits**: Review user list periodically
5. **Disable Unused Accounts**: Remove accounts no longer needed
