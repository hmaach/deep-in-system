#!/bin/bash

# ============================================
# Jenkins Installation Script
# File: scripts/install-jenkins.sh
#
# This script installs Jenkins CI/CD server
# using Docker for the deep-in-system project.
# ============================================

set -e  # Exit on error

echo "Starting Jenkins installation..."

# ============================================
# CHECK DOCKER
# ============================================

if ! command -v docker &> /dev/null; then
    echo "Docker not found. Please install Docker first."
    exit 1
fi

# ============================================
# JENKINS CONFIGURATION
# ============================================

JENKINS_PORT=8080
JENKINS_DATA_DIR="/opt/jenkins"

echo "Creating Jenkins data directory..."
sudo mkdir -p "$JENKINS_DATA_DIR"
sudo chown -R $(id -u):$(id -g) "$JENKINS_DATA_DIR"

# ============================================
# RUN JENKINS CONTAINER
# ============================================

echo "Pulling Jenkins Docker image..."
docker pull jenkins/jenkins:lts

echo "Starting Jenkins container..."
docker run -d \
    --name jenkins \
    -p $JENKINS_PORT:8080 \
    -p 50000:50000 \
    -v "$JENKINS_DATA_DIR:/var/jenkins_home" \
    -e JENKINS_OPTS="--prefix=/jenkins" \
    jenkins/jenkins:lts

# ============================================
# WAIT FOR JENKINS TO START
# ============================================

echo "Waiting for Jenkins to start..."
sleep 30

# ============================================
# GET INITIAL ADMIN PASSWORD
# ============================================

echo "Getting initial admin password..."
INITIAL_PASSWORD=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)

echo ""
echo "============================================"
echo "Jenkins installation completed!"
echo "============================================"
echo ""
echo "Access Jenkins at: http://localhost:$JENKINS_PORT"
echo "Initial Admin Password: $INITIAL_PASSWORD"
echo ""
echo "Save this password - you'll need it for first login!"
echo ""

# ============================================
# ALLOW THROUGH FIREWALL
# ============================================

if command -v ufw &> /dev/null; then
    echo "Opening port $JENKINS_PORT in firewall..."
    sudo ufw allow $JENKINS_PORT/tcp
fi

echo "Installation complete!"
