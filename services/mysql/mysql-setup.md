# MySQL Server Installation and Configuration

## Overview

This guide covers installing and configuring MySQL Server for the deep-in-system project, specifically to support WordPress.

## Requirements

- MySQL Server installed
- Remote root access disabled
- No external MySQL connections allowed
- Dedicated user for WordPress database

## Installation

### Install MySQL Server

```bash
# Update package list
sudo apt update

# Install MySQL Server
sudo apt install mysql-server

# Start MySQL service
sudo systemctl start mysql

# Enable MySQL on boot
sudo systemctl enable mysql

# Check status
sudo systemctl status mysql
```

### Secure MySQL Installation

```bash
# Run security script
sudo mysql_secure_installation
```

Follow the prompts:
```
# Set root password (use strong password)
# Remove anonymous users: Yes
# Disallow root login remotely: Yes
# Remove test database: Yes
# Reload privilege tables: Yes
```

## Configuration

### Disable Remote Root Access

```bash
# Login to MySQL as root
sudo mysql

# Check current root user host
SELECT user, host FROM mysql.user WHERE user='root';

# Ensure root can only connect from localhost
CREATE USER 'root'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

### Bind Address Configuration

Edit MySQL configuration to only listen on localhost:

```bash
# Edit MySQL config
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf

# Find and change:
bind-address = 127.0.0.1
```

Restart MySQL:

```bash
# Restart service
sudo systemctl restart mysql
```

### Verify Bind Address

```bash
# Check MySQL listening address
sudo netstat -tlnp | grep 3306
```

Should show: `127.0.0.1:3306`

## Create WordPress Database

### Login to MySQL

```bash
# Login as root
sudo mysql -u root -p
```

### Create Database and User

```sql
-- Create WordPress database
CREATE DATABASE wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create dedicated user for WordPress
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'StrongPassword123!';

-- Grant privileges to wpuser (only for wordpress database)
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;

-- Show grants
SHOW GRANTS FOR 'wpuser'@'localhost';
```

### Exit MySQL

```sql
EXIT;
```

## Test Local Connection

```bash
# Test connection as wpuser
mysql -u wpuser -p -e "SHOW DATABASES;"

# Should show: Database, information_schema, wordpress
```

## Security Best Practices

### Don't Use Root for Applications

- Always create dedicated database users
- Grant minimum required privileges
- Use strong passwords

### Regular Password Updates

```sql
-- Change user password
ALTER USER 'wpuser'@'localhost' IDENTIFIED BY 'NewStrongPassword!';
FLUSH PRIVILEGES;
```

### Backup and Restore

```bash
# Create database backup
mysqldump -u wpuser -p wordpress > wordpress-backup.sql

# Restore database
mysql -u wpuser -p wordpress < wordpress-backup.sql
```

## MySQL Commands Reference

| Command | Description |
|---------|-------------|
| `sudo systemctl start mysql` | Start MySQL |
| `sudo systemctl stop mysql` | Stop MySQL |
| `sudo systemctl restart mysql` | Restart MySQL |
| `sudo systemctl status mysql` | Check status |
| `mysql -u root -p` | Login as root |
| `SHOW DATABASES;` | List databases |
| `CREATE DATABASE dbname;` | Create database |

## Troubleshooting

### Can't Connect to MySQL

```bash
# Check MySQL is running
sudo systemctl status mysql

# Check bind address
sudo netstat -tlnp | grep 3306

# Check firewall
sudo ufw status
```

### Access Denied

```bash
# Reset root password if needed
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
FLUSH PRIVILEGES;
```

### Create Database Error

```sql
-- Drop and recreate if needed
DROP DATABASE IF EXISTS wordpress;
CREATE DATABASE wordpress;
```
