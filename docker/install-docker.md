# Docker Installation Guide

## Overview

This guide covers installing Docker and Docker Compose on Ubuntu Server for the deep-in-system project.

## What is Docker?

Docker is an open platform for developing, shipping, and running applications using containerization technology. Containers are lightweight and include everything needed to run the software.

## Prerequisites

- Ubuntu Server 20.04 or later
- Root/sudo access
- At least 2GB RAM
- 20GB disk space

## Installation Methods

### Method 1: Using Installation Script

```bash
# Run the installation script
sudo bash scripts/install-docker.sh
```

### Method 2: Manual Installation

#### Update Package Index

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
```

#### Add Docker GPG Key

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

#### Add Docker Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

#### Install Docker

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Post-Installation Steps

### Add User to Docker Group

```bash
sudo usermod -aG docker $USER
```

**Note**: Log out and log back in for this to take effect.

### Start Docker Service

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Verify Installation

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Run test container
docker run hello-world
```

## Install Docker Compose (Standalone)

Docker Compose v2 is included in the Docker plugin. For standalone:

```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose

# Make executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker-compose --version
```

## Docker Basic Commands

### Container Management

```bash
# List running containers
docker ps

# List all containers
docker ps -a

# Start container
docker start container_name

# Stop container
docker stop container_name

# Remove container
docker rm container_name
```

### Image Management

```bash
# List images
docker images

# Pull image
docker pull image_name

# Build image
docker build -t image_name .

# Remove image
docker rmi image_name
```

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# List services
docker-compose ps
```

## Configuration

### Docker Daemon

Edit Docker daemon configuration:

```bash
sudo vim /etc/docker/daemon.json
```

Example configuration:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
```

Restart Docker after changes:

```bash
sudo systemctl restart docker
```

## Troubleshooting

### Permission Denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in
# Or use:
newgrp docker
```

### Docker Not Starting

```bash
# Check status
sudo systemctl status docker

# Check logs
sudo journalctl -u docker -n 50
```

### Out of Space

```bash
# Clean up unused data
docker system prune -a

# Remove unused volumes
docker volume prune
```

## Security Best Practices

1. **Don't Run as Root**: Create and use a regular user
2. **Use Official Images**: Only use trusted images
3. **Keep Updated**: Update Docker regularly
4. **Limit Capabilities**: Don't run with `--privileged`
5. **Scan Images**: Use security scanning tools
