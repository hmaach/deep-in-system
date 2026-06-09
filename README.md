# deep-in-system

![sysadmin](assets/sysadmin.jpeg)

## Repository content

```text
.
├── README.md
├── deep-in-system.sha1
├── assets/
│   └── sysadmin.jpeg
├── docs/
│   ├── SUBJECT.md
│   ├── AUDIT.md
│   └── STEPS.md
└── scripts/
    └── backup-db.sh
```

## Setup

All installation and configuration steps are documented in [docs/STEPS.md](docs/STEPS.md).

## Audit checklist

| Part | Expected result | Command to verify |
| --- | --- | --- |
| SHA1 | Exported VM matches submitted hash | `sha1sum exported-vm.ova > deep-in-system-toaudit.sha1 && diff deep-in-system.sha1 deep-in-system-toaudit.sha1` |
| OS | Latest Ubuntu Server LTS, no desktop | `cat /etc/os-release`, `dpkg -l ubuntu-desktop` |
| Disk | 30G: 4G swap, 15G `/`, 5G `/home`, 6G `/backup` | `lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT` |
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

## Open ports

| Port | Service | Reason |
| --- | --- | --- |
| `2222/tcp` | SSH | remote administration |
| `80/tcp` | HTTP | WordPress |
| `21/tcp` | FTP control | `nami` downloads backups |
| `40000:40100/tcp` | FTP passive data | passive-mode transfers |

MySQL `3306` is not opened — WordPress and MySQL run on the same server.

## SHA1 submission

```bash
sha1sum exported-deep-in-system.ova > deep-in-system.sha1
cat -e deep-in-system.sha1
```
