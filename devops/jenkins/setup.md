# Jenkins Setup Guide

## Overview

This guide covers setting up Jenkins CI/CD server using Docker for the deep-in-system project.

## What is Jenkins?

Jenkins is an open-source automation server that helps automate the building, testing, and deploying software projects. It enables continuous integration (CI) and continuous delivery (CD).

## Installation Prerequisites

- Docker installed
- Port 8080 available
- At least 2GB RAM

## Installation Methods

### Method 1: Using Installation Script

```bash
# Run the installation script
sudo bash scripts/install-jenkins.sh
```

### Method 2: Manual Docker Installation

```bash
# Create data directory
sudo mkdir -p /opt/jenkins

# Run Jenkins container
docker run -d \
    --name jenkins \
    -p 8080:8080 \
    -p 50000:50000 \
    -v /opt/jenkins:/var/jenkins_home \
    jenkins/jenkins:lts
```

## Initial Setup

### Access Jenkins

1. Open browser: `http://server-ip:8080`
2. You'll see "Unlock Jenkins" page

### Get Initial Password

```bash
# Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### Complete Setup Wizard

1. Enter the initial password
2. Click "Install suggested plugins"
3. Create admin user
4. Configure Jenkins URL

## Install Recommended Plugins

### Essential Plugins

- Git
- GitHub
- Pipeline
- Docker
- SonarQube Scanner

### Install via UI

1. Go to: Manage Jenkins → Manage Plugins
2. Click "Available" tab
3. Search and install plugins
4. Restart if needed

## Configure Jenkins

### Configure Global Tools

1. Manage Jenkins → Global Tool Configuration
2. Add JDK installations
3. Add Maven/Gradle if needed
4. Add Docker

### Configure Security

1. Manage Jenkins → Configure Global Security
2. Enable matrix-based security
3. Set appropriate permissions

## Create First Pipeline

### Using Jenkinsfile

1. Create new Item → Pipeline
2. Enter pipeline name
3. Check "Pipeline" type
4. Add Jenkinsfile to project
5. Save and build

### Basic Pipeline Example

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
            }
        }
    }
}
```

## Troubleshooting

### Port Already in Use

```bash
# Check what's using port 8080
sudo netstat -tlnp | grep 8080

# Change Jenkins port
docker run -d -p 8081:8080 ...
```

### Out of Memory

```bash
# Increase memory
docker run -d -e JENKINS_OPTS="-Xmx2g" ...
```

### Permission Issues

```bash
# Fix volume permissions
sudo chown -R 1000:1000 /opt/jenkins
```

## Jenkins Commands

| Command | Description |
|---------|-------------|
| `docker exec jenkins cat /path` | View file in container |
| `docker exec jenkins jenkins-cli` | Use CLI |
| `docker logs jenkins` | View logs |

## Security Best Practices

1. **Change Default Admin Password**: Immediately after setup
2. **Configure HTTPS**: Use SSL for production
3. **Limit Access**: Use matrix-based security
4. **Backup Regularly**: Backup Jenkins home directory
5. **Keep Updated**: Update Jenkins and plugins regularly
