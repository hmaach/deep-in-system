# deep-in-system

![sysadmin](assets/sysadmin.jpeg)

An Ubuntu server with SSH, a firewall, users, FTP, MySQL, WordPress and a daily backup.
I set up everything I could with Ansible (the bonus). The rest is done by hand and explained below.

## Quick audit

Login: `hmaach` · VM IP: `10.1.18.50` · SSH port: `2222`

```bash
# vm
cat /etc/os-release; dpkg -l ubuntu-desktop
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT
hostname; id

# network
cat /etc/netplan/01-static-ip.yaml
ip a | grep dynamic          # prints nothing
ping -c 5 google.com

# ssh + firewall
cat /etc/ssh/sshd_config.d/00-deep-in-system.conf
sudo ufw status

# users (from your machine)
ssh -i ~/.ssh/luffy -p 2222 luffy@10.1.18.50   # no password asked
ssh -p 2222 zoro@10.1.18.50               # then: sudo cat /etc/shadow -> refused
groups luffy zoro

# ftp (from your machine)
sudo touch /backup/audit-check
ftp 10.1.18.50                            # login nami, then: ls, get audit-check
                                          # anonymous -> 530 Login incorrect

# mysql
sudo ss -tlnp | grep 3306                 # 127.0.0.1 only

# wordpress (browser, accept the self-signed certificate)
#   http://10.1.18.50/               -> redirects to https, site works
#   http://10.1.18.50/wp-config.php  -> 403 Forbidden

# backup
sudo crontab -l                           # 0 0 * * * /usr/local/bin/backup.sh
sudo rm -f /backup/wordpress-* /var/log/backup.log
sudo crontab -e                           # change to * * * * *, wait 1 minute
ls /backup; cat /var/log/backup.log
```

Or check everything at once from my machine:

```bash
cd ansible && ansible-playbook verify.yml
```

## Open ports

| Port | Why |
| --- | --- |
| 2222 | SSH |
| 80 | WordPress (only redirects to 443) |
| 443 | WordPress over HTTPS |
| 21 | FTP for nami |
| 40000-40100 | FTP passive mode (file transfers) |
| 25565 | Minecraft |

3306 (MySQL) stays closed. WordPress and MySQL are on the same server, so it doesn't need to be open.

## Files in this repo

```text
.
├── README.md
├── deep-in-system.sha1
├── docs/                    subject, audit, my notes
└── ansible/
    ├── ansible.cfg          settings (asks for sudo and vault passwords)
    ├── inventory.yml        the vm ip and my user
    ├── requirements.yml     collections to install
    ├── site.yml             sets up the whole server
    ├── verify.yml           checks the audit points
    ├── group_vars/all/
    │   ├── vars.yml         all the settings
    │   └── vault.yml        passwords, encrypted (not pushed)
    └── roles/               one folder per part of the subject
```

## How to set it up

### 1. Create the VM (by hand)

Ansible can't do this part, it needs a running server first.

- New VM with a **30 GB** disk and a **bridged** network.
- Install the latest **Ubuntu Server LTS**.
- In the storage step pick *Custom storage layout*:

  | Mount | Size | Format |
  | --- | --- | --- |
  | swap | 4G | swap |
  | `/` | 15G | ext4 |
  | `/home` | 5G | ext4 |
  | `/backup` | 6G | ext4 |

- Username: my login (`hmaach`).
- Tick *Install OpenSSH server*.
- After the reboot, get the IP with `ip a`.

### 2. Prepare my machine

```bash
sudo apt install ansible-core python3-passlib
cd ansible
ansible-galaxy collection install -r requirements.yml

ssh-copy-id hmaach@<vm-ip>                  # so ansible can log in with my key
ssh-keygen -t ed25519 -f ~/.ssh/luffy       # luffy's key, keep it for the audit
```

### 3. Fill the settings

In `inventory.yml` put the VM IP and my login.
The VM keeps the IP it has now as its static IP.

In `group_vars/all/vars.yml` check `login` and `netmask`.

Then the passwords:

```bash
cp group_vars/all/vault.yml.example group_vars/all/vault.yml
nano group_vars/all/vault.yml               # zoro, nami, database, wordpress admin
ansible-vault encrypt group_vars/all/vault.yml
```

### 4. Run it

```bash
ansible-playbook site.yml
```

It asks for my sudo password and the vault password, then does everything.
I can run it again anytime. It only changes what's different.

To run only one part:

```bash
ansible-playbook site.yml --tags ftp
ansible-playbook site.yml --skip-tags minecraft
```

### 5. Check it

```bash
ansible-playbook verify.yml
```

Each task is one audit question. A red line means that point is broken.

### 6. Export the VM (by hand)

Export the VM from the hypervisor (VirtualBox: *File > Export Appliance*), then:

```bash
sha1sum deep-in-system.ova > deep-in-system.sha1
cat -e deep-in-system.sha1
```

Don't start the VM after this, it changes the hash.

## What each role does

They run in this order.

| Role | What it does |
| --- | --- |
| common | Installs the packages, sets the hostname to `hmaach-host`, keeps my user in sudo, removes aliases. |
| users | `luffy`: sudoer, logs in only with his key. `zoro`: logs in with a password, not a sudoer. |
| ssh | Port 2222, no root login, no password for luffy, nami can't use ssh. |
| firewall | Blocks everything coming in, then opens only the ports above. |
| mysql | Listens on 127.0.0.1 only, removes remote root, creates the `wordpress` database and `wp_user` who can only use it. |
| ssl | Creates a self-signed certificate for Apache and FTP. |
| wordpress | Installs Apache and PHP, installs WordPress with wp-cli, blocks `wp-config.php`. |
| ftp | vsftpd, read only, no anonymous. Only `nami` can log in and she's locked in `/backup`. |
| backup | A script that dumps the database into a dated `.tar.gz` in `/backup` and writes to `/var/log/backup.log`. Cron runs it at 00:00. |
| minecraft | Downloads the latest server and runs it as a service, so it starts again after a reboot. |
| network | Sets the static IP with netplan and turns off DHCP. Runs last because it can cut the connection. |

When I change a config file the original is kept as a backup (`.bak`, or a dated copy next to it).

## The kratos test (by hand during the audit)

On my machine:

```bash
ssh-keygen -t ed25519 -f kratos
cat kratos.pub
```

On the server:

```bash
sudo adduser kratos
sudo usermod -aG sudo kratos
sudo mkdir /home/kratos/.ssh
sudo nano /home/kratos/.ssh/authorized_keys     # paste kratos.pub
sudo chown -R kratos:kratos /home/kratos/.ssh
sudo chmod 700 /home/kratos/.ssh
sudo chmod 600 /home/kratos/.ssh/authorized_keys
```

Test it from my machine:

```bash
ssh -i kratos -p 2222 kratos@10.1.18.50
sudo whoami                                     # root
```
