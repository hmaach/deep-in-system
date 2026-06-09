#!/usr/bin/env bash
set -eu

DB_NAME="${DB_NAME:-wordpress}"
DB_USER="${DB_USER:-wpuser}"
DB_PASS_FILE="${DB_PASS_FILE:-/etc/wordpress-db-password}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
LOG_FILE="${LOG_FILE:-/var/log/backup.log}"

if [ ! -r "$DB_PASS_FILE" ]; then
    echo "Missing readable database password file: $DB_PASS_FILE" >&2
    exit 1
fi

DB_PASS="$(cat "$DB_PASS_FILE")"
DATE="$(date +%Y-%m-%d)"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
BACKUP_FILE="$BACKUP_DIR/wordpress-$DATE.sql.gz"

mkdir -p "$BACKUP_DIR"

if mysqldump --single-transaction -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" | gzip > "$BACKUP_FILE"; then
    chmod 644 "$BACKUP_FILE"
    echo "wordpress backup created!, date: $TIMESTAMP, file: $BACKUP_FILE" >> "$LOG_FILE"
else
    rm -f "$BACKUP_FILE"
    echo "wordpress backup failed!, date: $TIMESTAMP" >> "$LOG_FILE"
    exit 1
fi
