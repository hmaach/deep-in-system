# Backup Structure Guide

## Overview

This document describes the backup structure for the deep-in-system project, including directory layout and file naming conventions.

## Backup Directory

### Location

All backups are stored in: `/backup`

### Directory Structure

```
/backup/
├── wordpress-2024-01-01.sql.gz    # Compressed database backup
├── wordpress-2024-01-02.sql.gz
├── wordpress-2024-01-03.sql.gz
└── ...
```

### Directory Permissions

```bash
# Set ownership to root (for security)
sudo chown root:root /backup

# Set permissions (755 = rwx-r-xr-x)
# Root can read/write, others can read
sudo chmod 755 /backup
```

## Backup Files

### Naming Convention

The backup script uses the following naming format:

```
wordpress-YYYY-MM-DD.sql.gz
```

- **YYYY**: 4-digit year
- **MM**: 2-digit month
- **DD**: 2-digit day
- **.sql.gz**: Compressed SQL dump

### Example Filenames

| Date | Filename |
|------|----------|
| January 1, 2024 | wordpress-2024-01-01.sql.gz |
| January 2, 2024 | wordpress-2024-01-02.sql.gz |
| December 31, 2024 | wordpress-2024-12-31.sql.gz |

### File Contents

Each backup file contains:

- Complete WordPress database dump
- All tables (posts, comments, users, options, etc.)
- Compressed with gzip for space efficiency

## Backup Verification

### List All Backups

```bash
# List all backup files
ls -lh /backup/wordpress-*.sql.gz

# Or with details
ls -lh /backup/
```

### Verify Backup Integrity

```bash
# Check if gzip file is valid
gunzip -t /backup/wordpress-2024-01-01.sql.gz

# View contents without extracting
gunzip -l /backup/wordpress-2024-01-01.sql.gz
```

### Test Restore

```bash
# Extract backup
gunzip < /backup/wordpress-2024-01-01.sql.gz > /tmp/test-restore.sql

# Verify SQL is valid
head -n 20 /tmp/test-restore.sql

# Clean up test file
rm /tmp/test-restore.sql
```

## Accessing Backups via FTP

The backup directory is accessible via FTP using the `nami` user:

```bash
# FTP connection
ftp server-ip

# Login with:
# Username: nami
# Password: (nami's password)

# After login:
ftp> ls

# Shows all backup files:
# 220 FTP server ready
# 200 PORT command successful
# 150 Opening BINARY mode data connection
# wordpress-2024-01-01.sql.gz
# wordpress-2024-01-02.sql.gz
# wordpress-2024-01-03.sql.gz
# 226 Transfer complete.

# Download a file:
ftp> get wordpress-2024-01-01.sql.gz
```

## Backup Log

### Log Location

All backup activities are logged to: `/var/log/backup.log`

### Log Format

```
[YYYY-MM-DD_HH-MM-SS] WordPress backup created: wordpress-YYYY-MM-DD.sql.gz
```

### Example Log Entries

```
[2024-01-01_00-00-01] WordPress backup created: wordpress-2024-01-01.sql.gz
[2024-01-02_00-00-02] WordPress backup created: wordpress-2024-01-02.sql.gz
[2024-01-03_00-00-01] WordPress backup created: wordpress-2024-01-03.sql.gz
```

### View Log

```bash
# View all backup logs
sudo cat /var/log/backup.log

# View last 10 entries
sudo tail -n 10 /var/log/backup.log

# Monitor log in real-time
sudo tail -f /var/log/backup.log
```

## Retention Policy

### Default Retention

Backups older than 7 days are automatically deleted by the backup script.

### Custom Retention

To change retention period, edit the backup script:

```bash
# Edit backup script
sudo vim /usr/local/bin/backup-db.sh

# Find and modify:
# find "$BACKUP_DIR" -name "wordpress-*.sql.gz" -mtime +7 -delete
#                  ^ Change 7 to desired number of days
```

## Disaster Recovery

### Restoring from Backup

```bash
# Stop web server (optional but recommended)
sudo systemctl stop nginx

# Create backup of current database (just in case)
mysqldump -uwpuser -p wordpress > /backup/pre-restore.sql

# Drop existing database
mysql -u root -p -e "DROP DATABASE wordpress;"

# Create fresh database
mysql -u root -p -e "CREATE DATABASE wordpress;"

# Restore from backup
gunzip < /backup/wordpress-2024-01-01.sql.gz | mysql -u wpuser -p wordpress

# Start web server
sudo systemctl start nginx
```

## Backup Commands Reference

| Command | Description |
|---------|-------------|
| `ls /backup/wordpress-*.sql.gz` | List all backups |
| `gunzip -t backup.sql.gz` | Test backup integrity |
| `tail /var/log/backup.log` | View recent backup logs |
| `crontab -l` | View scheduled backup jobs |
