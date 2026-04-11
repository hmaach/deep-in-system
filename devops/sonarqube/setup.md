# SonarQube Setup Guide

## Overview

This guide covers setting up SonarQube code quality platform using Docker for the deep-in-system project.

## What is SonarQube?

SonarQube is an open-source platform for continuous code quality inspection. It provides automated code analysis tools to detect bugs, vulnerabilities, and code smells in over 20 programming languages.

## Installation Prerequisites

- Docker installed
- Port 9000 available
- At least 1GB RAM (2GB recommended)
- sysctl configured (vm.max_map_count)

## Installation Methods

### Method 1: Using Installation Script

```bash
# Run the installation script
sudo bash scripts/install-sonarqube.sh
```

### Method 2: Manual Docker Installation

```bash
# Configure kernel settings
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072

# Create data directory
sudo mkdir -p /opt/sonarqube

# Run SonarQube container
docker run -d \
    --name sonarqube \
    -p 9000:9000 \
    -p 9092:9092 \
    -v /opt/sonarqube:/opt/sonarqube/data \
    -e SONARQUBE_JAVA_OPTS="-Xmx512m -Xms256m" \
    sonarqube:latest
```

## Initial Setup

### Access SonarQube

1. Open browser: `http://server-ip:9000`
2. Login with default credentials: `admin` / `admin`
3. Change default password

### Initial Configuration

1. Create new project
2. Generate analysis token
3. Configure project settings

## Configure SonarQube

### Create Project

1. Click "Create new project"
2. Enter project key and name
3. Click "Set Up"

### Generate Token

1. Go to: My Account → Security
2. Enter token name
3. Click "Generate"
4. Copy token (shown only once)

### Quality Profiles

SonarQube comes with built-in quality profiles:

- Sonar Way (recommended)
- Security (strict rules)

### Quality Gates

Default quality gate includes:

- No blocker issues
- Coverage > 80%
- Duplicated code < 3%

## Analyze Code

### Using Scanner

#### Install Scanner

```bash
# Download scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.zip
unzip sonar-scanner-cli-4.7.0.zip
sudo mv sonar-scanner-4.7.0 /opt/sonar-scanner
```

#### Configure

```bash
# Edit sonar-scanner.properties
sudo vim /opt/sonar-scanner/conf/sonar-scanner.properties

# Add:
sonar.host.url=http://localhost:9000
```

#### Run Analysis

```bash
# Navigate to project
cd /path/to/project

# Run scanner
sonar-scanner \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=. \
  -Dsonar.login=TOKEN
```

### Using Jenkins

Install SonarQube Scanner plugin and configure in Jenkins.

## Troubleshooting

### SonarQube Not Starting

```bash
# Check logs
docker logs sonarqube

# Check system settings
sysctl vm.max_map_count
# Should return: 524288
```

### Out of Memory

```bash
# Increase memory
docker run -e SONARQUBE_JAVA_OPTS="-Xmx2g -Xms512m" ...
```

### Database Issues

```bash
# Check database
docker exec sonarqube psql -U sonar -c "SELECT 1"
```

### Slow Startup

First startup can take 5-10 minutes. Check logs:

```bash
# Monitor startup
docker logs -f sonarqube
```

## Security Best Practices

1. **Change Default Password**: Immediately change admin password
2. **Configure HTTPS**: Use reverse proxy for SSL
3. **Restrict Access**: Configure authentication
4. **Regular Updates**: Keep SonarQube updated
5. **Backup Data**: Backup data directory regularly

## SonarQube Commands

| Command | Description |
|---------|-------------|
| `docker start sonarqube` | Start SonarQube |
| `docker stop sonarqube` | Stop SonarQube |
| `docker logs -f sonarqube` | View logs |
| `docker exec sonarqube status` | Check status |

## Integration with Other Tools

### Jenkins Integration

1. Install SonarQube Scanner plugin
2. Configure SonarQube server in Jenkins
3. Add scanner to build
4. Add quality gate stage

### GitHub Integration

1. Install SonarQube GitHub app
2. Configure repository
3. Enable pull request analysis
