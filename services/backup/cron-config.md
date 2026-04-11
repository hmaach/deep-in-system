# Cron Configuration Guide

## Overview

This guide explains how to configure cron jobs for the backup system in the deep-in-system project.

## What is Cron?

Cron is a time-based job scheduler in Unix-like operating systems. It allows users to schedule commands or scripts to run automatically at specified times, dates, or intervals.

## Backup Schedule Requirements

According to the project requirements:
- Backup must run every day at **00:00** (midnight)
- Cron syntax: `0 0 * * *`

## Cron Syntax

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday=0)
│ │ │ │ │
* * * * * command
```

### Common Examples

| Schedule | Cron Expression | Description |
|----------|----------------|-------------|
| Every minute | `* * * * *` | Run every minute |
| Every hour | `0 * * * *` | Run at minute 0 of every hour |
| Daily at midnight | `0 0 * * *` | Run at 00:00 daily |
| Weekly at Sunday | `0 0 * * 0` | Run at midnight every Sunday |
| Monthly | `0 0 1 * *` | Run at midnight on 1st of month |

## Configure Backup Cron Job

### Method 1: Using crontab

```bash
# Open crontab editor
crontab -e
```

Add the following line:

```
# WordPress Database Backup - Runs daily at 00:00
0 0 * * * /usr/local/bin/backup-db.sh >> /var/log/backup.log 2>&1
```

### Method 2: Using /etc/cron.d

```bash
# Create cron job file
sudo vim /etc/cron.d/backup
```

Add:

```
# WordPress Database Backup
# Runs daily at 00:00
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/local/bin/backup-db.sh >> /var/log/backup.log 2>&1
```

### Make Backup Script Executable

```bash
# Set executable permission
sudo chmod +x /usr/local/bin/backup-db.sh

# Verify
ls -la /usr/local/bin/backup-db.sh
```

## Verify Cron Job

### List Current Cron Jobs

```bash
# View current user's crontab
crontab -l

# View system cron jobs
sudo ls -la /etc/cron.d/

# View daily cron jobs
ls -la /etc/cron.daily/
```

### Check Cron Service

```bash
# Check cron status
sudo systemctl status cron

# Restart cron service
sudo systemctl restart cron
```

## Testing the Cron Job

### Run Manually

```bash
# Test the backup script
sudo /usr/local/bin/backup-db.sh

# Check if backup was created
ls -la /backup/wordpress-*.sql.gz

# Check log
cat /var/log/backup.log
```

### Test with Different Schedule

For testing, you can change the schedule to run every minute:

```bash
# Edit crontab
crontab -e

# Change to run every minute for testing
* * * * * /usr/local/bin/backup-db.sh >> /var/log/backup.log 2>&1
```

After testing, change back to daily:

```bash
# Change back to daily at midnight
0 0 * * * /usr/local/bin/backup-db.sh >> /var/log/backup.log 2>&1
```

## Cron Log

### Check Cron Logs

```bash
# View cron logs
sudo tail -f /var/log/syslog | grep cron

# Or view auth log
sudo less /var/log/auth.log | grep cron
```

### Common Log Entries

```
# Cron started job
CRON[1234]: (username) CMD (/usr/local/bin/backup-db.sh)

# Cron job completed
... cron[1234]: (username) CMD (/usr/local/bin/backup-db.sh)
```

## Troubleshooting

### Cron Not Running

```bash
# Check cron is enabled
sudo systemctl is-enabled cron

# Start cron if not running
sudo systemctl start cron

# Enable on boot
sudo systemctl enable cron
```

### Permission Denied

```bash
# Check script permissions
ls -la /usr/local/bin/backup-db.sh

# Fix if needed
sudo chmod +x /usr/local/bin/backup-db.sh
```

### Path Issues

Add PATH to crontab:

```bash
# Edit crontab
crontab -e

# Add at top
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
HOME=/root

# Then add cron job
0 0 * * * /usr/local/bin/backup-db.sh >> /var/log/backup.log 2>&1
```

### Email Notifications

Disable email if not needed:

```bash
# Add at top of crontab
MAILTO=""

# Or redirect to /dev/null
0 0 * * * /usr/local/bin/backup-db.sh > /dev/null 2>&1
```

## Cron Commands Reference

| Command | Description |
|---------|-------------|
| `crontab -e` | Edit crontab |
| `crontab -l` | List crontab |
| `crontab -r` | Remove crontab |
| `crontab -u user -e` | Edit user's crontab |
| `sudo systemctl restart cron` | Restart cron |

## Backup Cron Best Practices

1. **Use Absolute Paths**: Always use full paths in scripts
2. **Log Everything**: Redirect output to log files
3. **Test First**: Run script manually before scheduling
4. **Check Permissions**: Ensure script is executable
5. **Monitor Logs**: Check logs after cron runs
