#!/bin/bash

# ============================================
# WordPress Database Backup Script
# File: /usr/local/bin/backup-db.sh
#
# This script creates a backup of the WordPress
# database and saves it to /backup directory.
#
# Schedule: Runs daily at 00:00 via cron
# ============================================

# ============================================
# CONFIGURATION
# ============================================

# Database credentials
DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS="StrongPassword123!"  # Change this to your actual password

# Backup destination
BACKUP_DIR="/backup"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# Log file
LOG_FILE="/var/log/backup.log"

# ============================================
# BACKUP PROCESS
# ============================================

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Database backup filename
BACKUP_FILE="$BACKUP_DIR/wordpress-${DATE}.sql"

# Create compressed backup
echo "Starting WordPress database backup..."

# Use mysqldump to create database backup
mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"

# Check if backup was successful
if [ $? -eq 0 ]; then
    # Compress the backup
    gzip "$BACKUP_FILE"
    
    COMPRESSED_FILE="${BACKUP_FILE}.gz"
    
    # Log success
    echo "[${TIMESTAMP}] WordPress backup created: $(basename $COMPRESSED_FILE)" >> "$LOG_FILE"
    
    echo "Backup completed successfully!"
    echo "Backup file: $COMPRESSED_FILE"
    echo "Log file: $LOG_FILE"
    
    # List backup files
    echo ""
    echo "Current backups in $BACKUP_DIR:"
    ls -lh "$BACKUP_DIR"/wordpress-*.sql.gz
else
    # Log failure
    echo "[${TIMESTAMP}] ERROR: WordPress backup failed!" >> "$LOG_FILE"
    
    echo "Backup failed! Check $LOG_FILE for details."
    exit 1
fi

# ============================================
# CLEANUP (Optional - keep last 7 days)
# ============================================

# Remove backups older than 7 days
find "$BACKUP_DIR" -name "wordpress-*.sql.gz" -mtime +7 -delete

echo "Cleanup completed. Backups older than 7 days have been removed."
