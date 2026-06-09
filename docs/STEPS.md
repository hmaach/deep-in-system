# Server Setup Steps

## 1. VM Installation

Install Ubuntu Server latest LTS in a VM with a **30 GB** disk.

During partitioning, create these partitions manually:

| Mount      | Size | Type |
| ---------- | ---: | ---- |
| swap       |   4G | swap |
| `/`        |  15G | ext4 |
| `/home`    |   5G | ext4 |
| `/backup`  |   6G | ext4 |

- Set your login as the first username.
- Set hostname to `{login}-host` (e.g. `hmaach-host`).

Verify after boot:

```bash
cat /etc/os-release          # confirm Ubuntu Server LTS
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT   # confirm partitions
hostname                     # confirm hostname
```

---

## 2. Static IP

Find your network interface name:

```bash
ip link show
```

Edit the netplan config (replace values with your network info):

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 10.1.18.50/16
      routes:
        - to: default
          via: 10.1.0.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

- `dhcp4: false` — disables dynamic IP assignment on this interface.
- `addresses` — your chosen static IP with CIDR notation for the netmask.
- `routes` — default gateway for outbound traffic.
- `nameservers` — DNS resolvers (Google and Cloudflare).

Apply and verify:

```bash
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo netplan apply
ip a | grep dynamic       # must return nothing
ping -c 5 google.com      # confirm internet works
```

---

## 3. Install Packages

```bash
sudo apt update
sudo apt install -y openssh-server ufw nginx mysql-server \
    php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-zip \
    unzip curl vsftpd ftp
```

---

## 4. SSH

Edit the SSH daemon config:

```bash
sudo nano /etc/ssh/sshd_config
```

Change or add these lines:

```
Port 2222
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
```

- `Port 2222` — moves SSH off the default port 22 to reduce automated attacks.
- `PermitRootLogin no` — prevents direct root login over SSH.
- `PubkeyAuthentication yes` — enables key-based login (needed for `luffy`).
- `PasswordAuthentication yes` — enables password login (needed for `zoro`).

Apply:

```bash
sudo systemctl restart ssh
```

Verify:

```bash
sudo sshd -T | grep -E 'port|permitrootlogin'
```

---

## 5. Users

### luffy (sudo + SSH key)

```bash
sudo adduser --disabled-password --gecos "" luffy
sudo usermod -aG sudo luffy
sudo mkdir -p /home/luffy/.ssh
```

Paste luffy's public key:

```bash
echo "ssh-ed25519 AAAA...yourkey..." | sudo tee /home/luffy/.ssh/authorized_keys
sudo chown -R luffy:luffy /home/luffy/.ssh
sudo chmod 700 /home/luffy/.ssh
sudo chmod 600 /home/luffy/.ssh/authorized_keys
```

- `authorized_keys` — SSH checks this file for allowed public keys on login.
- `chmod 700 / 600` — SSH refuses key-based auth if permissions are too open.

### zoro (password, no sudo)

```bash
sudo adduser zoro
sudo deluser zoro sudo 2>/dev/null || true
```

Confirm zoro is not in sudo:

```bash
groups zoro
```

---

## 6. Firewall (UFW)

```bash
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp
sudo ufw allow 80/tcp
sudo ufw allow 21/tcp
sudo ufw allow 40000:40100/tcp
sudo ufw --force enable
sudo ufw status numbered
```

- `default deny incoming` — blocks everything inbound unless explicitly allowed.
- `2222/tcp` — SSH remote access.
- `80/tcp` — HTTP for WordPress.
- `21/tcp` — FTP control connection.
- `40000:40100/tcp` — FTP passive data ports (required for passive-mode transfers).

MySQL port `3306` is intentionally **not opened** — WordPress and MySQL are on the same server, so MySQL only needs to be reachable locally.

---

## 7. FTP (vsftpd) and nami

Create the backup directory and `nami` user:

```bash
sudo mkdir -p /backup
sudo chmod 755 /backup
sudo adduser --disabled-password --home /backup --no-create-home --gecos "" nami
sudo passwd nami
sudo usermod -s /usr/sbin/nologin nami
grep -q '^/usr/sbin/nologin$' /etc/shells || echo '/usr/sbin/nologin' | sudo tee -a /etc/shells
```

- `--home /backup` — nami's home directory is `/backup`; FTP will chroot her there.
- `--no-create-home` — the directory already exists.
- `nologin` shell — nami cannot open an interactive shell; FTP only.

Write the vsftpd config:

```bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
sudo nano /etc/vsftpd.conf
```

Replace the content with:

```
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
chroot_local_user=YES
allow_writeable_chroot=YES
user_config_dir=/etc/vsftpd/user_conf
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100
xferlog_enable=YES
log_ftp_protocol=YES
```

- `anonymous_enable=NO` — anonymous FTP disabled.
- `chroot_local_user=YES` — locks every local user inside their home directory.
- `user_config_dir` — per-user config overrides (used to make nami read-only).
- `pasv_min_port / pasv_max_port` — passive-mode data port range (must match UFW rules).

Create nami's per-user config to make her read-only:

```bash
sudo mkdir -p /etc/vsftpd/user_conf
sudo nano /etc/vsftpd/user_conf/nami
```

```
local_root=/backup
write_enable=NO
cmds_allowed=USER,PASS,QUIT,CWD,CDUP,PWD,LIST,NLST,RETR,TYPE,PASV,PORT,SYST,FEAT,NOOP
```

- `write_enable=NO` — nami can download but not upload or delete.
- `cmds_allowed` — whitelist of FTP commands; excludes `STOR`, `DELE`, `MKD`, etc.

Apply:

```bash
sudo systemctl restart vsftpd
```

---

## 8. MySQL

Secure the installation (set root password, remove test DB):

```bash
sudo mysql_secure_installation
```

Create the WordPress database and a dedicated user:

```bash
sudo mysql
```

```sql
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

- `'wpuser'@'localhost'` — the `@'localhost'` part ensures this user can only connect from the server itself, not from outside.
- Minimal grants — `wpuser` has only the permissions WordPress actually needs.

Save the password to a file for use by the backup script:

```bash
echo -n "your_strong_password" | sudo tee /etc/wordpress-db-password
sudo chmod 600 /etc/wordpress-db-password
```

Verify MySQL is not listening on external interfaces:

```bash
sudo ss -tulpn | grep mysql    # should show 127.0.0.1:3306
```

---

## 9. WordPress

Download and place WordPress:

```bash
curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/latest.tar.gz
tar -xzf /tmp/latest.tar.gz -C /tmp
sudo mv /tmp/wordpress /var/www/wordpress
sudo cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
```

Edit the config:

```bash
sudo nano /var/www/wordpress/wp-config.php
```

Update these lines:

```php
define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'wpuser' );
define( 'DB_PASSWORD', 'your_strong_password' );
define( 'DB_HOST', 'localhost' );
```

Set permissions:

```bash
sudo chown -R www-data:www-data /var/www/wordpress
sudo find /var/www/wordpress -type d -exec chmod 755 {} \;
sudo find /var/www/wordpress -type f -exec chmod 644 {} \;
```

- `www-data` — Nginx and PHP-FPM run as this user; they need ownership to serve files.

---

## 10. Nginx

Find the PHP-FPM socket path:

```bash
find /run/php -name 'php*-fpm.sock'
```

Create the Nginx site config:

```bash
sudo nano /etc/nginx/sites-available/wordpress
```

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /var/www/wordpress;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    }

    location = /wp-config.php {
        deny all;
    }

    location ~ /\. {
        deny all;
    }
}
```

- `try_files` — handles WordPress pretty permalinks.
- `fastcgi_pass` — forwards PHP files to PHP-FPM over a Unix socket.
- `location = /wp-config.php { deny all; }` — blocks direct HTTP access to the config file.

Enable the site and reload:

```bash
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress
sudo nginx -t
sudo systemctl reload nginx
```

Open `http://<vm-ip>/` in a browser and complete the WordPress installer.

---

## 11. Backup Script

Create the script:

```bash
sudo nano /usr/local/bin/backup-db.sh
```

```bash
#!/usr/bin/env bash
set -eu

DB_NAME="wordpress"
DB_USER="wpuser"
DB_PASS_FILE="/etc/wordpress-db-password"
BACKUP_DIR="/backup"
LOG_FILE="/var/log/backup.log"

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
```

- `mysqldump --single-transaction` — exports the database without locking tables.
- `gzip` — compresses the dump on the fly; the output file is `.sql.gz`.
- The password is read from a file instead of being passed as a plain argument.

Make it executable:

```bash
sudo chmod 755 /usr/local/bin/backup-db.sh
```

---

## 12. Cron Job

Edit root's crontab:

```bash
sudo crontab -e
```

Add this line:

```cron
0 0 * * * /usr/local/bin/backup-db.sh
```

- `0 0 * * *` — runs at midnight every day (minute 0, hour 0, every day/month/weekday).

Verify:

```bash
sudo crontab -l
```

---

## 13. Enable Services on Boot

```bash
sudo systemctl enable ssh nginx mysql vsftpd
```

---

## 14. Final Checks

```bash
# OS
cat /etc/os-release

# Partitions
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT

# Hostname
hostname

# Static IP (no dynamic)
ip a | grep dynamic

# Internet
ping -c 5 google.com

# SSH config
sudo sshd -T | grep -E 'port|permitrootlogin'

# Firewall
sudo ufw status numbered

# Users
groups luffy
groups zoro

# MySQL not exposed
sudo ss -tulpn | grep mysql

# Cron
sudo crontab -l

# WordPress
curl -I http://localhost/
```
