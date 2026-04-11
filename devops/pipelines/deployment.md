# Deployment Pipeline Guide

## Overview

This guide covers the deployment pipeline for the deep-in-system project using Jenkins and Docker.

## Pipeline Stages

### Stage 1: Checkout

```groovy
stage('Checkout') {
    steps {
        echo 'Checking out source code...'
        checkout scm
    }
}
```

### Stage 2: Build

```groovy
stage('Build') {
    steps {
        echo 'Building application...'
        sh 'echo "Building ${APP_NAME}"'
    }
}
```

### Stage 3: Test

```groovy
stage('Test') {
    steps {
        echo 'Running tests...'
        sh 'echo "Running tests for ${APP_NAME}"'
    }
}
```

### Stage 4: Code Analysis

```groovy
stage('Code Analysis') {
    steps {
        script {
            withSonarQubeEnv('SonarQube') {
                sh 'sonar-scanner'
            }
        }
    }
}
```

### Stage 5: Docker Build

```groovy
stage('Docker Build') {
    steps {
        echo 'Building Docker image...'
        sh '''
            docker build -t ${APP_NAME}:${VERSION} .
            docker tag ${APP_NAME}:${VERSION} ${DOCKER_REGISTRY}/${APP_NAME}:latest
        '''
    }
}
```

### Stage 6: Push to Registry

```groovy
stage('Push to Registry') {
    steps {
        echo 'Pushing Docker image...'
        sh '''
            docker push ${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}
            docker push ${DOCKER_REGISTRY}/${APP_NAME}:latest
        '''
    }
}
```

### Stage 7: Deploy to Staging

```groovy
stage('Deploy to Staging') {
    steps {
        echo 'Deploying to staging...'
        sh '''
            docker-compose -f docker-compose.staging.yml down
            docker-compose -f docker-compose.staging.yml up -d
        '''
    }
}
```

### Stage 8: Staging Tests

```groovy
stage('Staging Tests') {
    steps {
        echo 'Running staging tests...'
        sh 'curl -f http://staging.example.com/health'
    }
}
```

### Stage 9: Deploy to Production

```groovy
stage('Deploy to Production') {
    when {
        branch 'main'
    }
    steps {
        echo 'Deploying to production...'
        sh '''
            docker-compose -f docker-compose.yml down
            docker-compose -f docker-compose.yml up -d
        '''
    }
}
```

## Pipeline Configuration

### Jenkinsfile

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        APP_NAME = 'deep-in-system'
        VERSION = "${env.BUILD_NUMBER}"
    }
    
    stages {
        // Stages defined above
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            emailext body: 'Build succeeded!', subject: 'Jenkins Build', to: 'team@example.com'
        }
        failure {
            echo 'Pipeline failed!'
            emailext body: 'Build failed!', subject: 'Jenkins Build Failed', to: 'team@example.com'
        }
    }
}
```

## Docker Compose for Deployment

### docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    image: deep-in-system:latest
    ports:
      - "8080:8080"
    environment:
      - ENV=production
    restart: unless-stopped
```

## Deployment Best Practices

1. **Use Tags**: Always tag images with versions
2. **Health Checks**: Include health check endpoints
3. **Rollback Plan**: Always have rollback strategy
4. **Zero Downtime**: Use rolling updates
5. **Environment Variables**: Use secrets management
