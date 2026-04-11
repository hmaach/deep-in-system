# Rollback Guide

## Overview

This guide covers how to rollback deployments in the deep-in-system project.

## When to Rollback

- Service is unresponsive
- Critical errors in logs
- Failed health checks
- Performance degradation
- Security issues detected

## Rollback Methods

### Method 1: Docker Compose Rollback

#### Stop Current Deployment

```bash
# List current containers
docker-compose ps

# Stop all services
docker-compose down
```

#### Deploy Previous Version

```bash
# Pull specific version
docker pull your-registry/app:v1.2.3

# Update docker-compose.yml
image: your-registry/app:v1.2.3

# Start services
docker-compose up -d

# Verify
docker-compose ps
```

### Method 2: Docker Image Rollback

#### List Image Tags

```bash
# List available tags
curl -s https://registry.hub.docker.com/v2/repositories/your-app/tags | jq '.results[].name'
```

#### Rollback Image

```bash
# Update service to use previous tag
docker-compose up -d --build

# Or specify image directly
docker-compose up -d your-service:previous-tag
```

### Method 3: Kubernetes Rollback

If using Kubernetes:

```bash
# Rollback deployment
kubectl rollout undo deployment/your-app

# Check status
kubectl rollout status deployment/your-app

# View revision history
kubectl rollout history deployment/your-app
```

## Emergency Rollback

### Quick Rollback Script

```bash
#!/bin/bash

# emergency-rollback.sh

# Stop current deployment
docker-compose down

# Pull previous version (assumes v1.x.x naming)
PREVIOUS_VERSION=$(git describe --tags --abbrev=0^1)
docker pull your-registry/app:$PREVIOUS_VERSION

# Update compose file
sed -i "s|image: your-registry/app:.*|image: your-registry/app:$PREVIOUS_VERSION|" docker-compose.yml

# Deploy
docker-compose up -d

# Verify
docker-compose ps
echo "Rollback to $PREVIOUS_VERSION complete!"
```

### Database Rollback

If database changes are included:

```bash
# Stop application
docker-compose stop app

# Restore database from backup
gunzip < /backup/wordpress-2024-01-01.sql.gz | mysql -u wpuser -p wordpress

# Start application
docker-compose start app
```

## Rollback Verification

### Check Service Health

```bash
# Check all services
docker-compose ps

# Check logs
docker-compose logs -f

# Test endpoint
curl http://localhost/health
```

### Check Database

```bash
# Verify database integrity
mysql -u wpuser -p -e "CHECK TABLE wordpress.wp_posts;"

# Check for data consistency
mysql -u wpuser -p -e "SELECT COUNT(*) FROM wordpress.wp_posts;"
```

## Rollback Best Practices

1. **Always Have Backups**: Before any deployment, backup databases
2. **Test Rollback**: Practice rollback procedure regularly
3. **Document Changes**: Keep deployment notes
4. **Monitor After Rollback**: Watch logs for issues
5. **Notify Team**: Inform team of rollback

## Rollback Checklist

- [ ] Stop current deployment
- [ ] Identify cause of issue
- [ ] Select rollback version
- [ ] Restore database if needed
- [ ] Deploy previous version
- [ ] Verify services running
- [ ] Test functionality
- [ ] Notify team
- [ ] Document incident
