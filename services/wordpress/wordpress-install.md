# WordPress Installation Guide

## Overview

This guide covers installing and configuring WordPress on the Ubuntu Server for the deep-in-system project.

## Requirements

- Web server (Nginx or Apache) installed
- PHP installed and configured
- MySQL database created (see mysql-setup.md)
- WordPress must be accessible at `http://{host}/`
- wp-config.php must NOT be publicly accessible

## Install Prerequisites

### Install Nginx

```bash
# Install Nginx
sudo apt install nginx

# Start Nginx
sudo systemctl start nginx

# Enable on boot
sudo systemctl enable nginx
```

### Install PHP

```bash
# Install PHP and required extensions
sudo apt install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-xmlrpc \
    php-zip \
    php-intl
```

### Verify PHP

```bash
# Check PHP version
php --version
```

## Download WordPress

```bash
# Navigate to web root
cd /var/www

# Download WordPress
sudo wget https://wordpress.org/latest.tar.gz

# Extract
sudo tar -xzvf latest.tar.gz

# Remove tarball
sudo rm latest.tar.gz
```

## Configure Permissions

```bash
# Set ownership to www-data
sudo chown -R www-data:www-data /var/www/wordpress

# Set permissions
sudo chmod -R 755 /var/www/wordpress
```

## Configure Nginx

```bash
# Create Nginx configuration
sudo vim /etc/nginx/sites-available/wordpress
```

Add the following configuration:

```nginx
server {
    listen 80;
    server_name _;

    root /var/www/wordpress;
    index index.php index.html index.htm;

    access_log /var/log/nginx/wordpress-access.log;
    error_log /var/log/nginx/wordpress-error.log;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

Enable the site:

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

## Complete WordPress Setup via Browser

1. Open browser and navigate to `http://{server-ip}/`
2. Select language and click "Continue"
3. Click "Let's go!"
4. Enter database information:
   - Database Name: `wordpress`
   - Username: `wpuser`
   - Password: (your wpuser password)
   - Database Host: `localhost`
   - Table Prefix: `wp_`
5. Click "Submit"
6. Click "Run the installation"
7. Fill in site information:
   - Site Title: (your choice)
   - Username: (admin username)
   - Password: (strong password)
   - Email: (your email)
8. Click "Install WordPress"
9. Login to WordPress admin at `http://{server-ip}/wp-admin`

## Secure wp-config.php

The wp-config.php file contains sensitive information (database credentials). Make sure it's not publicly accessible:

```bash
# Verify by accessing directly
curl http://server-ip/wp-config.php

# Should return 403 Forbidden or 404 Not Found
```

The Nginx configuration above includes:
```nginx
location ~ /\.ht {
    deny all;
}
```

This blocks access to any file starting with `.ht` which includes wp-config.php protection.

## Test WordPress

### Create a Post

1. Login to WordPress admin
2. Go to Posts > Add New
3. Create a test post
4. Publish it

### Verify Public Access

```bash
# Check homepage loads
curl http://server-ip/
```

Should show the WordPress homepage.

### Check wp-config.php Protection

```bash
# Try to access wp-config.php
curl -I http://server-ip/wp-config.php
```

Should return HTTP 403 or 404.

## Troubleshooting

### 502 Bad Gateway

```bash
# Check PHP-FPM status
sudo systemctl status php-fpm

# Restart PHP-FPM
sudo systemctl restart php-fpm
```

### Database Connection Error

```bash
# Check database credentials in wp-config.php
sudo vim /var/www/wordpress/wp-config.php

# Verify database is running
sudo systemctl status mysql
```

### Permission Denied

```bash
# Fix permissions
sudo chown -R www-data:www-data /var/www/wordpress
sudo chmod -R 755 /var/www/wordpress
```

## WordPress Commands

| Command | Description |
|---------|-------------|
| `curl http://server-ip/` | Test homepage |
| `curl http://server-ip/wp-admin` | Test admin |
| `curl -I http://server-ip/wp-config.php` | Verify security |

## Security Checklist

- [ ] wp-config.php not publicly accessible
- [ ] Use strong WordPress admin password
- [ ] Keep WordPress updated
- [ ] Use security plugin
- [ ] Disable file editing in dashboard
