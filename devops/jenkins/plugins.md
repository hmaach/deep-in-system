# Jenkins Plugins Guide

## Overview

This guide covers essential Jenkins plugins for the deep-in-system project CI/CD pipeline.

## Recommended Plugins

### Version Control

| Plugin | Purpose |
|--------|---------|
| Git | Git repository integration |
| GitHub | GitHub integration |
| GitLab | GitLab integration |
| Bitbucket | Bitbucket integration |

### Build Tools

| Plugin | Purpose |
|--------|---------|
| Pipeline | Pipeline as Code support |
| Docker | Docker integration |
| Maven Integration | Maven project support |
| Gradle | Gradle project support |

### Code Quality

| Plugin | Purpose |
|--------|---------|
| SonarQube Scanner | SonarQube integration |
| Checkstyle | Java code style checking |
| PMD | Source code analysis |
| FindBugs | Bug detection |

### Deployment

| Plugin | Purpose |
|--------|---------|
| Publish Over SSH | SSH deployment |
| Docker Pipeline | Docker in pipelines |
| Kubernetes | Kubernetes deployment |

### Notifications

| Plugin | Purpose |
|--------|---------|
| Email Extension | Email notifications |
| Slack Notification | Slack integration |
| Discord Webhook | Discord notifications |

## Installing Plugins

### Via Jenkins UI

1. Go to: Manage Jenkins → Manage Plugins
2. Click "Available" tab
3. Search for plugin
4. Check "Install without restart"
5. Click "Download now and install after restart"

### Via Command Line

```bash
# List plugins
jenkins-cli.jar -s http://jenkins:8080 list-plugins

# Install plugin
jenkins-cli.jar -s http://jenkins:8080 install-plugin git
```

### Via Jenkinsfile

```groovy
plugins {
    id 'git' version '4.11.0'
    id 'pipeline-stage-view' version '2.24'
}
```

## Essential Plugin Configuration

### Git Plugin Configuration

```bash
# Configure in Manage Jenkins → Configure System
# Git installations:
# - Name: Default
# - Path to git: /usr/bin/git
```

### Docker Plugin Configuration

```bash
# Configure cloud providers
# Manage Jenkins → Manage Nodes → Configure Clouds
# Add Docker Cloud
```

### SonarQube Scanner Configuration

```bash
# Configure in Manage Jenkins → Configure System
# SonarQube servers:
# - Name: SonarQube
# - Server URL: http://localhost:9000
# - Server authentication token
```

## Pipeline Plugins

### Declarative Pipeline

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
    }
}
```

### Scripted Pipeline

```groovy
node {
    stage('Build') {
        echo 'Building...'
    }
}
```

## Plugin Dependencies

### Common Dependencies

- Pipeline → Plain Credentials
- Git → Credentials
- Docker → Pipeline

### Check Dependencies

```bash
# View plugin dependencies
cat /var/lib/jenkins/plugins/<plugin>/META-INF/MANIFEST.MF
```

## Updating Plugins

### Update All

1. Go to: Manage Jenkins → Manage Plugins
2. Click "Updates" tab
3. Select all
4. Click "Download now and install after restart"

### Update One

```bash
# Using Jenkins CLI
jenkins-cli.jar update-plugin <plugin-name>
```

## Troubleshooting

### Plugin Installation Fails

- Check internet connectivity
- Check Jenkins log: `/var/log/jenkins/jenkins.log`
- Verify correct permissions

### Plugin Causes Errors

```bash
# Disable plugin
mv /var/lib/jenkins/plugins/<plugin>.jpi /var/lib/jenkins/plugins/<plugin>.jpi.disabled
```

### Plugin Version Conflicts

```bash
# Check plugin manager logs
tail -f /var/log/jenkins/jenkins.log | grep plugin
```

## Recommended Plugin List

For this project:

```
git
github
pipeline-stage-view
docker-workflow
ssh-agent
credentials-binding
timestamper
ansi-color
workspace-cleanup
