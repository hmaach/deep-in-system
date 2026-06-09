#!/usr/bin/env bash
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this script with sudo." >&2
    exit 1
fi

read -r -p "Public SSH key for luffy: " LUFFY_PUBLIC_KEY
read -r -s -p "Password for zoro: " ZORO_PASSWORD
echo
read -r -s -p "Password for nami FTP user: " NAMI_PASSWORD
echo
read -r -s -p "Password for MySQL user wpuser: " WP_DB_PASSWORD
echo

case "$WP_DB_PASSWORD" in
    *"'"*|*"\\"*)
        echo "Use a MySQL password without single quotes or backslashes for this simple audit script." >&2
        exit 1
        ;;
esac

apt update
apt install -y openssh-server ufw nginx mysql-server php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-zip unzip curl vsftpd ftp

sed -i.bak -E 's/^#?Port .*/Port 2222/' /etc/ssh/sshd_config
sed -i -E 's/^#?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
grep -q '^PasswordAuthentication yes' /etc/ssh/sshd_config || echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
grep -q '^PubkeyAuthentication yes' /etc/ssh/sshd_config || echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
systemctl restart ssh

id luffy >/dev/null 2>&1 || adduser --disabled-password --gecos "" luffy
usermod -aG sudo luffy
mkdir -p /home/luffy/.ssh
printf '%s\n' "$LUFFY_PUBLIC_KEY" > /home/luffy/.ssh/authorized_keys
chown -R luffy:luffy /home/luffy/.ssh
chmod 700 /home/luffy/.ssh
chmod 600 /home/luffy/.ssh/authorized_keys

id zoro >/dev/null 2>&1 || adduser --disabled-password --gecos "" zoro
echo "zoro:$ZORO_PASSWORD" | chpasswd
deluser zoro sudo >/dev/null 2>&1 || true

mkdir -p /backup
chmod 755 /backup
id nami >/dev/null 2>&1 || adduser --disabled-password --home /backup --no-create-home --gecos "" nami
echo "nami:$NAMI_PASSWORD" | chpasswd
usermod -s /usr/sbin/nologin nami
grep -q '^/usr/sbin/nologin$' /etc/shells || echo '/usr/sbin/nologin' >> /etc/shells

cp /etc/vsftpd.conf /etc/vsftpd.conf.bak.$(date +%Y%m%d%H%M%S)
cat > /etc/vsftpd.conf <<'EOF'
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
EOF

mkdir -p /etc/vsftpd/user_conf
cat > /etc/vsftpd/user_conf/nami <<'EOF'
local_root=/backup
write_enable=NO
cmds_allowed=USER,PASS,QUIT,CWD,CDUP,PWD,LIST,NLST,RETR,TYPE,PASV,PORT,SYST,FEAT,NOOP
EOF
systemctl restart vsftpd

mysql <<SQL
CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'wpuser'@'localhost' IDENTIFIED BY '$WP_DB_PASSWORD';
ALTER USER 'wpuser'@'localhost' IDENTIFIED BY '$WP_DB_PASSWORD';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, INDEX ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
SQL

printf '%s' "$WP_DB_PASSWORD" > /etc/wordpress-db-password
chmod 600 /etc/wordpress-db-password

rm -rf /tmp/latest.tar.gz /tmp/wordpress
curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/latest.tar.gz
tar -xzf /tmp/latest.tar.gz -C /tmp
rm -rf /var/www/wordpress
mv /tmp/wordpress /var/www/wordpress
cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
sed -i "s/database_name_here/wordpress/" /var/www/wordpress/wp-config.php
sed -i "s/username_here/wpuser/" /var/www/wordpress/wp-config.php
sed -i "s/password_here/$WP_DB_PASSWORD/" /var/www/wordpress/wp-config.php
chown -R www-data:www-data /var/www/wordpress
find /var/www/wordpress -type d -exec chmod 755 {} \;
find /var/www/wordpress -type f -exec chmod 644 {} \;

PHP_SOCK="$(find /run/php -name 'php*-fpm.sock' | head -n 1)"
cat > /etc/nginx/sites-available/wordpress <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    root /var/www/wordpress;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_SOCK;
    }

    location = /wp-config.php {
        deny all;
    }

    location ~ /\. {
        deny all;
    }
}
EOF
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress
nginx -t
systemctl reload nginx

install -m 755 "$(dirname "$0")/backup-db.sh" /usr/local/bin/backup-db.sh
(crontab -l 2>/dev/null | grep -v '/usr/local/bin/backup-db.sh'; echo '0 0 * * * /usr/local/bin/backup-db.sh') | crontab -

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp
ufw allow 80/tcp
ufw allow 21/tcp
ufw allow 40000:40100/tcp
ufw --force enable

systemctl enable ssh nginx mysql vsftpd

echo "Setup complete. Test with: ssh <user>@<vm-ip> -p 2222 and http://<vm-ip>/"
