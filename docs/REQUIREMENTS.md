# deep-in-system — Project Requirements

Consolidated from [SUBJECT.md](SUBJECT.md) and [AUDIT.md](AUDIT.md). Only what is required.

## 1. Repository

| File | Requirement |
| --- | --- |
| `deep-in-system.sha1` | Output of `sha1sum {exported-vm} > deep-in-system.sha1`. Must match the VM being audited. |
| `README.md` | Explains everything learned, every setup step, the commands used, and all installed/configured services. |

> Naming mismatch: the subject says `deep-in-system.sha1`, the audit says `DeepInSystem.sha1`.

- The exported VM must be kept safe; a new VM is created from it for each audit.
- The VM must have **no aliases** that could alter audit command output.
- External scripts are forbidden. Every command used must be understood.

## 2. Virtual Machine

| Item | Required value | Audit check |
| --- | --- | --- |
| OS | Latest Ubuntu **Server** LTS | `cat /etc/os-release` |
| No desktop | `ubuntu-desktop` not installed | `dpkg -l ubuntu-desktop` → no packages found |
| Disk size | 30G | `lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT` |
| Partitions | swap 4G, `/` 15G, `/home` 5G, `/backup` 6G | same (tolerance ≤ 0.5G) |
| Username | Your login name | `id` |
| User groups | Main user is in `sudo` | `id` |
| Hostname | `{login}-host` | `hostname` |

- Do not use the `root` user for setup. Use `sudo`.

## 3. Network

- Static private IP. Any netmask.
- No interface may have a dynamic IP: `ip a | grep dynamic` must print nothing.
- Internet must work: `ping -c 5 google.com`.
- Be ready to show the modified network config file.

## 4. Security

### SSH

- `PermitRootLogin no`.
- `Port 2222`.
- Be ready to show the modified sshd config file.
- Must be reachable from outside the VM: `ssh {login}@{vm-ip} -p 2222`.

### Firewall

- Active.
- All incoming ports closed except those in use.
- Every open port must be justified.
- MySQL port (3306) must **not** be open.

## 5. Users

| User | Auth | Home | Sudo | Expected `groups` |
| --- | --- | --- | --- | --- |
| `luffy` | SSH public key only, no password prompt | `/home/luffy` | yes | `luffy sudo` |
| `zoro` | SSH password | `/home/zoro` | no | `zoro` |

- Keep `luffy`'s private key ready for the audit.
- `zoro` running `sudo cat /etc/shadow` must fail with "not in the sudoers file".

### Live exam during audit (fail = project fail)

In under 10 minutes, create user `kratos`:

1. Generate a new SSH key pair during the exam.
2. Create the user.
3. Install the public key for the user.
4. Add the user to `sudo`.
5. Show login with the private key.
6. Show a working `sudo` command.

## 6. FTP

- Install an FTP server.
- User `nami` with a custom password.
- `nami` can only access `/backup`, read-only.
- Anonymous login must fail (`530 Login incorrect`).
- Audit test: `sudo touch /backup/audit-check`, then `nami` must `ls` and `get audit-check` over FTP.

## 7. MySQL

- Install MySQL Server.
- `root` cannot connect remotely.
- MySQL must not accept connections from outside the server.
- A dedicated MySQL user with access only to the WordPress database.
- WordPress must not use MySQL `root`.

## 8. WordPress

- Installed at the web root: `http://{vm-ip}/` (https allowed if SSL is set up).
- Admin login works. Posting or creating users works.
- `http://{vm-ip}/wp-config.php` must not display its content.

## 9. Backup

- Cron job at `0 0 * * *` (every day at 00:00).
- Creates a **tar** file of the WordPress **database** in `/backup`.
- Backup file name contains the creation date.
- Appends a line to `/var/log/backup.log` saying the backup succeeded, with its time.
  Audit example: `wordpress backup created!, date: <...>`
- Backup files must be downloadable by `nami` over FTP.
- Audit test: auditor deletes old backups and the log, sets the cron to `* * * * *`, waits 1 minute, then expects today's backup in FTP and a new log line.

## 10. Concepts the student must explain

- The `sudo` group.
- The static IP configuration, what a netmask is, and why a web server needs a static IP.
- The sshd configuration and the role of an SSH server.
- The role of a firewall.
- The role of an FTP server.
- What a cron job is.
- Why backups matter.

## 11. Bonus (only after the mandatory part is perfect)

Suggested in the subject. Any extra counts.

- Minecraft server that is always running, including after reboot.
- Automate everything with Ansible.
- SSL on the web server and FTP server. Self-signed is fine.
