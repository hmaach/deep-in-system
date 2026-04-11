#!/bin/bash

# ============================================
# Backup Database Script
# File: scripts/backup-db.sh
#
# This script backs up the WordPress database
# to the /backup directory.
# ============================================

# Configuration
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="StrongPassword123!"  # Update this
BACKUP_DIR="/backup"
LOG_FILE="/var/log/backup.log"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Get date for filename
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# Backup filename
BACKUP_FILE="$BACKUP_DIR/wordpress-${DATE}.sql.gz"

echo "Starting backup at $TIMESTAMP..."

# Create backup
mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "[$TIMESTAMP] WordPress backup created: wordpress-${DATE}.sql.gz" >> "$LOG_FILE"
    echo "Backup completed: $BACKUP_FILE"
else
    echo "[$TIMESTAMP] ERROR: Backup failed!" >> "$LOG_FILE"
    echo "Backup failed!"
    exit 1
fi

# Cleanup old backups (keep 7 days)
find "$BACKUP_DIR" -name "wordpress-*.sql.gz" -mtime +7 -delete

echo "Backup process completed."
