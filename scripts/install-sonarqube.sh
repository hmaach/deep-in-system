#!/bin/bash

# ============================================
# SonarQube Installation Script
# File: scripts/install-sonarqube.sh
#
# This script installs SonarQube code quality
# platform using Docker for the deep-in-system project.
# ============================================

set -e  # Exit on error

echo "Starting SonarQube installation..."

# ============================================
# CHECK DOCKER
# ============================================

if ! command -v docker &> /dev/null; then
    echo "Docker not found. Please install Docker first."
    exit 1
fi

# ============================================
# SYSCTL CONFIGURATION
# ============================================

echo "Configuring system kernel settings..."
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072

# Make persistent
echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=131072" | sudo tee -a /etc/sysctl.conf

# ============================================
# SONARQUBE CONFIGURATION
# ============================================

SONARQUBE_PORT=9000
SONARQUBE_DATA_DIR="/opt/sonarqube"

echo "Creating SonarQube data directory..."
sudo mkdir -p "$SONARQUBE_DATA_DIR"
sudo chown -R $(id -u):$(id -g) "$SONARQUBE_DATA_DIR"

# ============================================
# RUN SONARQUBE CONTAINER
# ============================================

echo "Pulling SonarQube Docker image..."
docker pull sonarqube:latest

echo "Starting SonarQube container..."
docker run -d \
    --name sonarqube \
    -p $SONARQUBE_PORT:9000 \
    -p 9092:9092 \
    -v "$SONARQUBE_DATA_DIR:/opt/sonarqube/data" \
    -e SONARQUBE_JAVA_OPTS="-Xmx512m -Xms256m" \
    -e SONARQUBE_WEB_CONTEXT="/" \
    sonarqube:latest

# ============================================
# WAIT FOR SONARQUBE TO START
# ============================================

echo "Waiting for SonarQube to start (this may take a few minutes)..."
echo "Polling for readiness..."

MAX_ATTEMPTS=60
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$SONARQUBE_PORT/api/system/status | grep -q "UP"; then
        echo "SonarQube is ready!"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo "Waiting... ($ATTEMPT/$MAX_ATTEMPTS)"
    sleep 10
done

echo ""
echo "============================================"
echo "SonarQube installation completed!"
echo "============================================"
echo ""
echo "Access SonarQube at: http://localhost:$SONARQUBE_PORT"
echo "Default credentials: admin / admin"
echo ""
echo "IMPORTANT: Change the default password after first login!"
echo ""

# ============================================
# ALLOW THROUGH FIREWALL
# ============================================

if command -v ufw &> /dev/null; then
    echo "Opening port $SONARQUBE_PORT in firewall..."
    sudo ufw allow $SONARQUBE_PORT/tcp
fi

echo "Installation complete!"
