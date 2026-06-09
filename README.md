# deep-in-system

![sysadmin](assets/sysadmin.jpeg)

This repository is intentionally small for the audit. The subject only requires `README.md` and `deep-in-system.sha1`; the `assets` and `scripts` folders are kept only to make the setup easy to explain and repeat.

## Repository content

```text
.
├── README.md
├── deep-in-system.sha1
├── assets/
│   └── sysadmin.jpeg
└── scripts/
    ├── 01-configure-static-ip.sh
    ├── 02-setup-server.sh
    └── backup-db.sh
```

## Audit checklist

| Part | Expected result | Command to show |
| --- | --- | --- |
| SHA1 | Exported VM matches submitted hash | `sha1sum exported-vm.ova > deep-in-system-toaudit.sha1 && diff deep-in-system.sha1 deep-in-system-toaudit.sha1` |
| OS | Latest Ubuntu Server LTS, no desktop package | `cat /etc/os-release`, `dpkg -l ubuntu-desktop` |
| Disk | 30G disk: 4G swap, 15G `/`, 5G `/home`, 6G `/backup` | `lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT` |
| Hostname | `{login}-host` | `hostname` |
| Static IP | No dynamic IP on internet interface | `ip a | grep dynamic` |
| Internet | VM can reach internet | `ping -c 5 google.com` |
| SSH | Port `2222`, root login disabled | `sudo sshd -T | grep -E 'port|permitrootlogin'` |
| Firewall | Active, only required ports open | `sudo ufw status numbered` |
| Users | `luffy` sudo/key, `zoro` password/no sudo | `groups luffy`, `groups zoro` |
| FTP | `nami` can read `/backup`, anonymous disabled | `ftp <vm-ip>` |
| MySQL | Root is local only, WordPress uses dedicated DB user | `sudo ss -tulpn | grep mysql` |
| WordPress | Available at `http://<vm-ip>/` | Browser test |
| Backup | Daily backup at midnight in `/backup` with log | `sudo crontab -l`, `cat /var/log/backup.log` |

## Manual VM installation

Install Ubuntu Server LTS in a VM with a 30GB disk. During partitioning, use:

| Mount | Size | Type |
| --- | ---: | --- |
| swap | 4G | swap |
| `/` | 15G | ext4 |
| `/home` | 5G | ext4 |
| `/backup` | 6G | ext4 |

Use your login as the first user. Set the hostname to `{login}-host`.

After the VM is installed, copy this repository into the VM and run the scripts below.

## Static IP

Edit these values before running:

```bash
sudo bash scripts/01-configure-static-ip.sh enp0s3 10.1.18.50/16 10.1.0.1
```

What it does:

- disables DHCP for the selected interface;
- writes `/etc/netplan/00-installer-config.yaml`;
- sets DNS servers to `8.8.8.8` and `1.1.1.1`;
- applies the netplan configuration.

A static IP matters because SSH, HTTP, and FTP clients need a stable server address.

## Server setup

Run:

```bash
sudo bash scripts/02-setup-server.sh
```

The script installs and configures the mandatory services:

- packages: `openssh-server`, `ufw`, `nginx`, `mysql-server`, `php-fpm`, `php-mysql`, `vsftpd`;
- SSH on port `2222`;
- `PermitRootLogin no`;
- UFW default deny incoming, allow `2222/tcp`, `80/tcp`, `21/tcp`, and FTP passive ports `40000:40100/tcp`;
- users `luffy`, `zoro`, and `nami`;
- `nami` FTP access restricted to `/backup`;
- MySQL database `wordpress` and user `wpuser`;
- WordPress under `/var/www/wordpress`;
- Nginx server for WordPress at `/`;
- backup script installed at `/usr/local/bin/backup-db.sh`;
- root cron job: `0 0 * * * /usr/local/bin/backup-db.sh`.

During the script, enter:

- the public SSH key for `luffy`;
- the password for `zoro`;
- the password for `nami`;
- the password for the MySQL user `wpuser`.

## Open ports

Justify every open port during the audit:

| Port | Service | Reason |
| --- | --- | --- |
| `2222/tcp` | SSH | remote administration; moved from default port 22 |
| `80/tcp` | HTTP | WordPress website |
| `21/tcp` | FTP control | `nami` downloads backup files |
| `40000:40100/tcp` | FTP passive data | needed for passive FTP transfers |

MySQL port `3306` is not opened because WordPress and MySQL run on the same server. MySQL should listen only locally.

## User notes

`luffy`:

- home: `/home/luffy`;
- authentication: public key;
- group: `sudo`.

`zoro`:

- home: `/home/zoro`;
- authentication: password;
- no `sudo`.

`nami`:

- used only for FTP;
- home points to `/backup`;
- read-only access;
- anonymous FTP is disabled.

For the audit exercise user `kratos`, the commands are:

```bash
ssh-keygen -t ed25519 -f ./kratos_key
sudo adduser kratos
sudo usermod -aG sudo kratos
sudo mkdir -p /home/kratos/.ssh
sudo cp ./kratos_key.pub /home/kratos/.ssh/authorized_keys
sudo chown -R kratos:kratos /home/kratos/.ssh
sudo chmod 700 /home/kratos/.ssh
sudo chmod 600 /home/kratos/.ssh/authorized_keys
ssh -i ./kratos_key kratos@<vm-ip> -p 2222
```

## Backup

The backup script creates `/backup/wordpress-YYYY-MM-DD.sql.gz` and appends a success line to `/var/log/backup.log`.

Audit test:

```bash
sudo rm -f /backup/wordpress-*.sql.gz /var/log/backup.log
sudo crontab -e
```

Temporarily change the schedule to:

```cron
* * * * * /usr/local/bin/backup-db.sh
```

Wait one minute, then check:

```bash
ls -lh /backup
cat /var/log/backup.log
ftp <vm-ip>
```

Put the cron entry back to:

```cron
0 0 * * * /usr/local/bin/backup-db.sh
```

## SHA1 submission

After exporting the final VM, generate the required hash:

```bash
sha1sum exported-deep-in-system.ova > deep-in-system.sha1
cat -e deep-in-system.sha1
```

`deep-in-system.sha1` is empty until the VM is exported. Fill it before final submission.
