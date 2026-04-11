# SonarQube Configuration Guide

## Overview

This guide covers SonarQube configuration options for code quality analysis in the deep-in-system project.

## Configuration Files

### sonar-scanner.properties

Location: `/opt/sonar-scanner/conf/sonar-scanner.properties`

```properties
# SonarQube server URL
sonar.host.url=http://localhost:9000

# SonarQube authentication
sonar.login=admin
sonar.password=admin

# Project settings
sonar.projectKey=deep-in-system
sonar.projectName=deep-in-system

# Source directory
sonar.sources=.

# Exclusions
sonar.exclusions=**/node_modules/**,**/vendor/**,**/dist/**
```

## Quality Profiles

### Default Profile: Sonar Way

The "Sonar Way" profile is the default and recommended quality profile.

#### Key Rules

| Category | Description |
|----------|-------------|
| Bugs | Critical programming errors |
| Code Smells | Maintainability issues |
| Vulnerabilities | Security concerns |
| Coverage | Test coverage requirements |
| Duplications | Code duplication checks |

### Create Custom Profile

1. Go to: Quality Profiles
2. Click "Create"
3. Enter name
4. Extend from "Sonar Way"
5. Activate/deactivate rules as needed

## Quality Gates

### Default Quality Gate

The default quality gate includes:

| Metric | Condition | Value |
|--------|-----------|-------|
| Bugs | > | 0 |
| Vulnerabilities | > | 0 |
| Code Smells | > | 0 |
| Coverage | < | 80% |
| Duplicated Lines | > | 3% |

### Create Custom Quality Gate

1. Go to: Quality Gates
2. Click "Create"
3. Add conditions
4. Set as default

## Project Configuration

### sonar-project.properties

Create in project root:

```properties
# Project identification
sonar.projectKey=deep-in-system
sonar.projectName=deep-in-system Project

# Source code
sonar.sources=src
sonar.tests=test

# Language
sonar.language=py

# Exclusions
sonar.exclusions=**/vendor/**,**/node_modules/**

# Inclusions
sonar.inclusions=**/*.py,**/*.js
```

## Analysis Parameters

### Common Parameters

```bash
sonar-scanner \
  -Dsonar.projectKey=my-project \
  -Dsonar.projectName="My Project" \
  -Dsonar.sources=src \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=TOKEN \
  -Dsonar.branch=feature-branch
```

### Parameters Reference

| Parameter | Description |
|-----------|-------------|
| `sonar.projectKey` | Unique project identifier |
| `sonar.projectName` | Human-readable name |
| `sonar.sources` | Source directories |
| `sonar.language` | Language (overrides auto-detect) |
| `sonar.branch` | Branch name |
| `sonar.login` | Authentication token |

## Security Configuration

### Enable Authentication

1. Go to: Administration → Security
2. Enable "Force user authentication"
3. Configure session timeout

### Manage Users

1. Go to: Administration → Security → Users
2. Create/edit/delete users
3. Assign groups

### Manage Groups

1. Go to: Administration → Security → Groups
2. Create groups
3. Assign permissions

## Webhooks

### Configure Webhook

1. Go to: Project → Settings → Webhooks
2. Add webhook URL
3. Configure events

Example payload:

```json
{
  "serverUrl": "http://localhost:9000",
  "projectKey": "my-project",
  "analysisId": "abc123",
  "qualityGate": {
    "name": "Sonar way",
    "status": "OK"
  }
}
```

## Integration Settings

### Jenkins Integration

```groovy
stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh 'sonar-scanner'
        }
    }
}
```

### GitHub Integration

1. Install SonarQube GitHub app
2. Configure repository
3. Enable analysis on PRs
