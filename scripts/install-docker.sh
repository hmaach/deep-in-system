#!/bin/bash

# ============================================
# Docker Installation Script
# File: scripts/install-docker.sh
#
# This script installs Docker and Docker Compose
# on Ubuntu Server for the deep-in-system project.
# ============================================

set -e  # Exit on error

echo "Starting Docker installation..."

# ============================================
# UPDATE PACKAGES
# ============================================

echo "Updating package lists..."
sudo apt update

# ============================================
# INSTALL DEPENDENCIES
# ============================================

echo "Installing dependencies..."
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# ============================================
# ADD DOCKER REPOSITORY
# ============================================

echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Adding Docker repository..."
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ============================================
# INSTALL DOCKER
# ============================================

echo "Updating package lists..."
sudo apt update

echo "Installing Docker..."
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin

# ============================================
# CONFIGURE DOCKER
# ============================================

echo "Adding user to docker group..."
sudo usermod -aG docker $USER

echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# ============================================
# INSTALL DOCKER COMPOSE (Standalone)
# ============================================

echo "Installing Docker Compose (standalone)..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# ============================================
# VERIFY INSTALLATION
# ============================================

echo "Verifying Docker installation..."
docker --version
docker-compose --version

echo ""
echo "============================================"
echo "Docker installation completed!"
echo "============================================"
echo ""
echo "IMPORTANT: Please log out and log back in"
echo "for group membership to take effect."
echo ""
echo "Or run: newgrp docker"
echo ""
