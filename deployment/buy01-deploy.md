# Buy-01 Deployment Guide

## Overview

This guide covers deploying the buy-01 microservices platform on the Ubuntu Server.

## Architecture

The buy-01 platform consists of:

| Service | Description | Port |
|---------|-------------|------|
| API Gateway | Nginx reverse proxy | 80, 443 |
| User Service | User management | Internal |
| Product Service | Product catalog | Internal |
| Order Service | Order processing | Internal |
| MySQL | Database | 3306 |
| Redis | Cache | 6379 |
| RabbitMQ | Message queue | 5672, 15672 |

## Prerequisites

- Docker installed
- Docker Compose installed
- At least 4GB RAM
- Ports 80, 443, 3306, 6379, 5672, 15672 available

## Deployment Steps

### 1. Clone Repository

```bash
git clone https://github.com/your-repo/buy-01.git
cd buy-01
```

### 2. Configure Environment

```bash
# Copy environment file
cp .env.example .env

# Edit environment variables
vim .env
```

### 3. Deploy Services

```bash
# Start all services
docker-compose -f deployment/docker-compose-buy01.yml up -d

# Verify services are running
docker-compose -f deployment/docker-compose-buy01.yml ps
```

### 4. Verify Deployment

```bash
# Check service health
curl http://localhost/health

# Check logs
docker-compose -f deployment/docker-compose-buy01.yml logs -f
```

## Service Access

### Web Interface

- **URL**: `http://localhost`
- **Admin Panel**: `http://localhost/admin`

### RabbitMQ Management

- **URL**: `http://localhost:15672`
- **Username**: `buy01`
- **Password**: `rabbitmq123`

### Database

- **Host**: `localhost`
- **Port**: `3306`
- **Database**: `buy01`
- **Username**: `buy01user`
- **Password**: `buy01pass123`

## Monitoring

### View Service Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f user-service

# Last 100 lines
docker-compose logs --tail=100 user-service
```

### Check Service Status

```bash
# Container status
docker-compose ps

# Resource usage
docker stats
```

## Scaling

### Scale Individual Services

```bash
# Scale user-service to 3 instances
docker-compose up -d --scale user-service=3

# Scale order-service to 2 instances
docker-compose up -d --scale order-service=2
```

## Troubleshooting

### Service Not Starting

```bash
# Check logs
docker-compose logs service-name

# Check resource usage
docker stats

# Restart service
docker-compose restart service-name
```

### Database Connection Issues

```bash
# Check MySQL is running
docker-compose ps mysql

# Check MySQL logs
docker-compose logs mysql

# Verify network connectivity
docker network inspect buy01_buy01-network
```

### Port Conflicts

```bash
# Check what's using the port
sudo netstat -tlnp | grep 80

# Change port in docker-compose.yml
ports:
  - "8080:80"
```

## Deployment Checklist

- [ ] Docker and Docker Compose installed
- [ ] Environment variables configured
- [ ] All services started
- [ ] Health checks passing
- [ ] Database initialized
- [ ] Services accessible
- [ ] Monitoring set up
- [ ] Logs rotating properly
