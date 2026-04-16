# Integrated DevOps Project Roadmap

**Projects fused:**

- deep-in-system (Linux system administration)
- buy-01 (microservices platform)
- Jenkins CI/CD pipeline
- SonarQube code quality platform

Goal: **build a production-like DevOps environment on one Ubuntu server.**

---

# Phase 0 — Architecture Design

## Target Architecture

```
Ubuntu Server VM
│
├── OS Layer
│   ├── Static networking
│   ├── Firewall (UFW)
│   ├── SSH hardened
│   └── User management
│
├── Core Services
│   ├── Nginx/Apache
│   ├── WordPress
│   ├── MySQL
│   └── FTP server
│
├── Container Runtime
│   └── Docker + Docker Compose
│
├── DevOps Stack
│   ├── Jenkins
│   └── SonarQube
│
└── Application Layer
    └── buy-01 microservices
```

---

# Phase 1 — Virtual Machine Creation

## 1. Create Ubuntu Server VM

Requirements:

```
Disk: 30GB
RAM: 4GB recommended
CPU: 2 cores
```

Install **Ubuntu Server LTS**.

---

## 2. Disk Partitioning

Partition exactly as required.

| Partition | Size |
| --------- | ---- |
| swap      | 4G   |
| /         | 15G  |
| /home     | 5G   |
| /backup   | 6G   |

Verify:

```
lsblk
df -h
```

---

# Phase 2 — Base System Configuration

## 1. Hostname

```
sudo hostnamectl set-hostname <username>-host
```

Update hosts file:

```
/etc/hosts
```

---

## 2. Update System

```
sudo apt update
sudo apt upgrade -y
```

---

## 3. Essential Packages

Install baseline tools.

```
sudo apt install -y \
git \
curl \
wget \
vim \
ufw \
openssh-server \
build-essential \
vsftpd
```

---

# Phase 3 — Network Configuration

## 1. Identify interface

```
ip a
```

Example:

```
ens33
```

---

## 2. Configure Static IP

Edit netplan:

```
/etc/netplan/00-installer-config.yaml
```

Example:

```
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
```

Apply:

```
sudo netplan apply
```

Test:

```
ping google.com
```

---

# Phase 4 — Security Hardening

## 1. Configure SSH

Edit:

```
/etc/ssh/sshd_config
```

Change:

```
Port 2222
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
```

Restart:

```
sudo systemctl restart ssh
```

---

## 2. Firewall Setup

Enable UFW.

```
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

Open required ports:

```
sudo ufw allow 2222
sudo ufw allow 80
sudo ufw allow 21
sudo ufw allow 8080
sudo ufw allow 9000
```

Enable firewall:

```
sudo ufw enable
```

Verify:

```
sudo ufw status
```

---

# Phase 5 — User Management

Create required users.

## luffy

```
sudo adduser luffy
sudo usermod -aG sudo luffy
```

Generate SSH key.

```
ssh-keygen
```

Add to server:

```
/home/luffy/.ssh/authorized_keys
```

---

## zoro

```
sudo adduser zoro
```

No sudo access.

---

# Phase 6 — FTP Server

Install VSFTPD.

```
sudo apt install vsftpd
```

---

## Create FTP User

```
sudo adduser nami
```

Restrict directory:

```
/backup
```

Permissions:

```
sudo chown root:root /backup
sudo chmod 755 /backup
```

Configure vsftpd:

```
/etc/vsftpd.conf
```

Important settings:

```
anonymous_enable=NO
write_enable=NO
chroot_local_user=YES
```

Restart:

```
sudo systemctl restart vsftpd
```

---

# Phase 7 — Database Server

Install MySQL.

```
sudo apt install mysql-server
```

Secure installation:

```
sudo mysql_secure_installation
```

Disable remote root access.

---

## Create WordPress DB

```
CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
```

---

# Phase 8 — WordPress Installation

Install web server.

Example: Nginx.

```
sudo apt install nginx php-fpm php-mysql
```

Download WordPress.

```
cd /var/www
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvf latest.tar.gz
```

Set permissions.

```
sudo chown -R www-data:www-data wordpress
```

Configure Nginx site.

Restart services.

---

# Phase 9 — Backup System

Create backup script.

Example:

```
/usr/local/bin/backup-db.sh
```

Script:

```
mysqldump wordpress > /backup/wp-$(date +%F).sql
tar -czf /backup/wp-$(date +%F).tar.gz /backup/wp-$(date +%F).sql
echo "Backup success $(date)" >> /var/log/backup.log
```

Make executable:

```
chmod +x backup-db.sh
```

---

## Cron Job

```
crontab -e
```

Add:

```
0 0 * * * /usr/local/bin/backup-db.sh
```

---

# Phase 10 — Docker Installation

Install Docker.

```
sudo apt install docker.io
```

Start service.

```
sudo systemctl enable docker
```

Install Compose.

```
sudo apt install docker-compose
```

---

# Phase 11 — SonarQube Setup

Create directory:

```
/opt/sonarqube
```

Docker compose example:

```
version: "3"

services:

  sonarqube:
    image: sonarqube:latest
    ports:
      - "9000:9000"
```

Run:

```
docker compose up -d
```

Access:

```
http://server-ip:9000
```

---

# Phase 12 — Jenkins Setup

Create Jenkins container.

Example:

```
docker run -d \
-p 8080:8080 \
-p 50000:50000 \
jenkins/jenkins:lts
```

Access:

```
http://server-ip:8080
```

Install plugins:

- Git
- Docker
- Pipeline
- SonarQube Scanner

---

# Phase 13 — Connect Jenkins to GitHub

Add credentials.

Configure webhook in GitHub.

Trigger builds on push.

---

# Phase 14 — SonarQube Integration

Add SonarQube server in Jenkins.

Add token.

Pipeline stage:

```
sonar-scanner
```

Configure **Quality Gate**.

Pipeline must fail if gate fails.

---

# Phase 15 — buy-01 Deployment

Create deployment directory.

```
/opt/buy01
```

Add Docker Compose.

Example:

```
services:
  gateway
  user-service
  product-service
  media-service
```

---

# Phase 16 — Jenkins Pipeline

Pipeline stages:

1. Clone repo
2. Install dependencies
3. Run tests
4. SonarQube analysis
5. Build docker images
6. Deploy via docker compose

Example structure:

```
pipeline
 ├── Checkout
 ├── Build
 ├── Test
 ├── SonarQube
 ├── Docker Build
 └── Deploy
```

---

# Phase 17 — Rollback Strategy

Keep previous images.

Deployment logic:

```
docker-compose down
docker-compose up -d
```

Rollback:

```
docker-compose -f previous.yml up -d
```

---

# Phase 18 — Monitoring

Basic monitoring:

```
docker stats
htop
journalctl
```

Optional:

Prometheus + Grafana.

---

# Phase 19 — Documentation

Your README must explain:

1. System architecture
2. Network configuration
3. Security configuration
4. Services installation
5. Jenkins pipeline design
6. SonarQube integration
7. Deployment process
8. Backup strategy

---

# Phase 20 — Final Validation

Verify:

### System Admin

✔ static IP
✔ firewall
✔ SSH port 2222
✔ users
✔ FTP
✔ MySQL
✔ WordPress
✔ backups

### DevOps

✔ Jenkins CI/CD
✔ SonarQube analysis
✔ automated deployments

---

# Result

You finish with a **complete DevOps infrastructure** containing:

- Linux system administration
- service deployment
- container orchestration
- CI/CD automation
- static code analysis
- backup management

This resembles a **real small production platform**.
