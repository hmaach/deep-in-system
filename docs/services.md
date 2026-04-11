# Services Guide

## Overview

This guide covers the services installed and configured for the deep-in-system project.

## Service Overview

| Service | Port | Purpose |
|---------|------|---------|
| SSH | 2222 | Remote administration |
| Nginx | 80 | Web server |
| MySQL | 3306 | Database |
| vsftpd | 21 | FTP server |
| Jenkins | 8080 | CI/CD |
| SonarQube | 9000 | Code analysis |

## SSH Service

### What is SSH?

SSH (Secure Shell) is a protocol for secure remote login and other secure network services.

### Configuration

- Port: 2222 (changed from default 22)
- Root login: Disabled
- Authentication: Keys for luffy, password for zoro

### Commands

```bash
# Connect to server
ssh user@server -p 2222

# Copy files
scp -P 2222 file.txt user@server:/path/
```

## Web Server (Nginx)

### What is Nginx?

Nginx is a high-performance HTTP server and reverse proxy.

### Configuration

- Document root: `/var/www/wordpress`
- Port: 80
- PHP-FPM: Enabled

### Commands

```bash
# Start Nginx
sudo systemctl start nginx

# Test configuration
sudo nginx -t

# View logs
sudo tail -f /var/log/nginx/wordpress-access.log
```

## MySQL Database

### What is MySQL?

MySQL is a popular open-source relational database management system.

### Configuration

- Port: 3306
- Bind address: 127.0.0.1 (local only)
- WordPress database: `wordpress`

### Commands

```bash
# Connect to MySQL
sudo mysql -u root -p

# Show databases
SHOW DATABASES;

# Create backup
mysqldump -u wpuser -p wordpress > backup.sql
```

## FTP Server (vsftpd)

### What is FTP?

FTP (File Transfer Protocol) is a standard network protocol for file transfers.

### Configuration

- Port: 21
- Anonymous: Disabled
- User: nami (read-only to /backup)

### Commands

```bash
# Connect to FTP
ftp server-ip

# Download file
get filename

# Upload file
put filename
```

## Jenkins

### What is Jenkins?

Jenkins is an open-source automation server for CI/CD pipelines.

### Configuration

- Port: 8080
- Access: Via browser
- Initial setup: Web interface

### Commands

```bash
# Start Jenkins
docker start jenkins

# View logs
docker logs jenkins
```

## SonarQube

### What is SonarQube?

SonarQube is a platform for continuous code quality inspection.

### Configuration

- Port: 9000
- Access: Via browser
- Default login: admin/admin

### Commands

```bash
# Start SonarQube
docker start sonarqube

# View logs
docker logs sonarqube
```

## Service Management

### Start/Stop Services

```bash
# Systemd services
sudo systemctl start service-name
sudo systemctl stop service-name
sudo systemctl restart service-name
sudo systemctl status service-name
```

### Docker Services

```bash
# Start all containers
docker-compose up -d

# Stop all containers
docker-compose down

# View logs
docker-compose logs -f
```

## Troubleshooting Services

### Check Service Status

```bash
# Systemd
systemctl status nginx

# Docker
docker ps
```

### View Service Logs

```bash
# Systemd journal
journalctl -u nginx -n 50

# Docker
docker logs container-name
```
