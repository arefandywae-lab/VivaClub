#!/bin/bash
# VPS Backup Script with Google Drive Integration
# Run daily via cron: 0 2 * * * /home/deploy/vivaclub/backup.sh

set -e

BACKUP_DIR="/home/deploy/backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Create backup directory
mkdir -p $BACKUP_DIR

echo "=== Starting backup at $(date) ==="

# 1. Backup PostgreSQL
echo "Backing up PostgreSQL..."
docker exec vivaclub_db pg_dump -U vivaclub vivaclub | gzip > $BACKUP_DIR/db_$DATE.sql.gz
echo "PostgreSQL backup completed: db_$DATE.sql.gz"

# 2. Backup Redis
echo "Backing up Redis..."
docker exec vivaclub_redis redis-cli --pass $REDIS_PASSWORD SAVE
docker cp vivaclub_redis:/data/dump.rdb $BACKUP_DIR/redis_$DATE.rdb
echo "Redis backup completed: redis_$DATE.rdb"

# 3. Backup MinIO (Images)
echo "Backing up MinIO data..."
docker exec vivaclub_minio mc mirror /data/vivaclub-media /tmp/minio_backup
docker cp vivaclub_minio:/tmp/minio_backup $BACKUP_DIR/media_$DATE
tar -czf $BACKUP_DIR/media_$DATE.tar.gz -C $BACKUP_DIR media_$DATE
rm -rf $BACKUP_DIR/media_$DATE
echo "MinIO backup completed: media_$DATE.tar.gz"

# 4. Backup Docker Compose configs
echo "Backing up configurations..."
tar -czf $BACKUP_DIR/configs_$DATE.tar.gz \
  ~/vivaclub/docker-compose.prod.yml \
  ~/vivaclub/.env.production \
  ~/vivaclub/livekit.yaml \
  /etc/nginx/sites-available/vivaclub
echo "Config backup completed: configs_$DATE.tar.gz"

# 5. Upload to Google Drive using rclone
echo "Uploading to Google Drive..."
if command -v rclone &> /dev/null; then
    rclone sync $BACKUP_DIR gdrive:VivaClub-Backups --progress
    echo "Google Drive sync completed"
else
    echo "WARNING: rclone not installed. Skipping Google Drive upload."
    echo "Install with: curl https://rclone.org/install.sh | sudo bash"
fi

# 6. Cleanup old local backups (keep last 7 days)
echo "Cleaning up old backups..."
find $BACKUP_DIR -type f -mtime +$RETENTION_DAYS -delete
echo "Cleanup completed"

# 7. Create backup summary
BACKUP_SIZE=$(du -sh $BACKUP_DIR | cut -f1)
echo "=== Backup Summary ==="
echo "Date: $(date)"
echo "Total backup size: $BACKUP_SIZE"
echo "Files created:"
ls -lh $BACKUP_DIR/*_$DATE*
echo "======================"

echo "=== Backup completed successfully at $(date) ==="
