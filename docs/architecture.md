# Architecture Guide

## Overview

This document describes the architecture of the deep-in-system project - a comprehensive Linux server administration learning project.

## Project Goals

1. **System Administration**: Learn to administer a Linux server
2. **Network Configuration**: Configure networking on Ubuntu
3. **Security Implementation**: Implement security measures
4. **Service Deployment**: Install and configure popular services

## System Architecture

### Virtual Machine

| Component | Specification |
|-----------|----------------|
| OS | Ubuntu Server LTS |
| Disk Size | 30GB |
| RAM | 4GB (recommended) |
| CPU | 2 cores (recommended) |

### Partition Layout

```
+----------------------------------+
|         30GB Disk               |
+----------------------------------+
| 4GB    | 15GB  | 5GB  | 6GB     |
| swap   | /     | /home| /backup|
+----------------------------------+
```

## Network Architecture

### Network Configuration

- **Type**: Static IP (private network)
- **Interface**: Configurable (ens33, eth0, etc.)
- **Netmask**: User-defined (/24 recommended)
- **Gateway**: User-defined

### Network Diagram

```
Internet
    |
    |
[Router/Switch]
    |
    |
[Ubuntu Server VM]
    |
    +--- eth0: 192.168.1.100/24
    |
    +--- Services
    |    +--- HTTP (80)
    |    +--- SSH (2222)
    |    +--- FTP (21)
    |    +--- Jenkins (8080)
    |    +--- SonarQube (9000)
```

## Security Architecture

### Firewall (UFW)

```
+-----------------------+
|     Firewall          |
+-----------------------+
| Deny: All Incoming   |
| Allow: 2222/tcp (SSH)|
| Allow: 80/tcp (HTTP) |
| Allow: 21/tcp (FTP)  |
+-----------------------+
```

### User Access

| User | Authentication | Sudo Access | Purpose |
|------|---------------|-------------|---------|
| luffy | SSH Key | Yes | Admin access |
| zoro | Password | No | Regular access |
| nami | FTP Password | No | Backup access |

## Service Architecture

### Core Services

```
+--------------------------------------------------------+
|                    Services                            |
+--------------------------------------------------------+
|                                                        |
|  +------------+    +------------+    +------------+   |
|  |   Nginx    |    |    MySQL   |    |  vsftpd   |   |
|  | (Port 80)  |    | (Port 3306)|    | (Port 21) |   |
|  +------------+    +------------+    +------------+   |
|        |                |                |              |
|        v                v                v              |
|  +---------------------------------------------+      |
|  |              WordPress                      |      |
|  |         (Web Application)                  |      |
|  +---------------------------------------------+      |
|                                                        |
+--------------------------------------------------------+
```

### DevOps Stack

```
+--------------------------------------------------------+
|                   DevOps Tools                         |
+--------------------------------------------------------+
|                                                        |
|  +------------+         +------------+                |
|  |  Jenkins   |-------->| SonarQube  |                |
|  | (Port 8080)|         | (Port 9000)|                |
|  +------------+         +------------+                |
|                                                        |
+--------------------------------------------------------+
```

## Backup Architecture

### Backup Flow

```
+------------------------------------------+
|              Backup System              |
+------------------------------------------+
|                                          |
|  Cron Job (00:00 daily)                   |
|         |                                 |
|         v                                 |
|  +--------------------+                  |
|  |  backup-db.sh      |                  |
|  +--------------------+                  |
|         |                                 |
|         v                                 |
|  /backup/*.sql.gz                        |
|         |                                 |
|         v                                 |
|  FTP Access (nami user)                  |
|                                          |
+------------------------------------------+
```

## Docker Architecture

### Container Overview

```
+--------------------------------------------------------+
|                   Docker Host                          |
+--------------------------------------------------------+
|                                                        |
|  +-----------+    +-----------+    +-----------+      |
|  |  Jenkins  |    | SonarQube |    |  MySQL    |      |
|  |  Docker   |    |  Docker   |    |  Docker   |      |
|  +-----------+    +-----------+    +-----------+      |
|                                                        |
+--------------------------------------------------------+
```

## Component Interactions

### User Access Flow

```
[User Browser]
     |
     v
[Firewall (UFW)]
     |
     +--- Port 80 ---> [Nginx] ---> [WordPress]
     |                      |
     |                      v
     |                 [MySQL]
     |
     +--- Port 2222 ---> [SSH] ---> [System]
     |
     +--- Port 21 ---> [FTP] ---> [/backup]
```

### Deployment Flow

```
[Git Repository]
     |
     v
[Jenkins CI/CD]
     |
     +--- Build ---> [Docker Image]
     |
     v
[Code Analysis]
     |
     v
[Deploy to Server]
```

## Technology Stack

| Category | Technology |
|----------|------------|
| OS | Ubuntu Server LTS |
| Web Server | Nginx |
| Database | MySQL 8.0 |
| CMS | WordPress |
| FTP Server | vsftpd |
| CI/CD | Jenkins |
| Code Analysis | SonarQube |
| Container | Docker |
| Firewall | UFW |
