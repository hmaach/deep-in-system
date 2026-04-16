# Static IP Configuration

## Overview

This section documents how to configure a static IP on an Ubuntu Server VM running in VirtualBox.

The goal is to:

- Disable DHCP
- Assign a fixed IP to the VM
- Ensure internet connectivity through the host's network

---

## Network Context

Before configuring, gather these values from your **host machine**:

### 1 — Host IP and Subnet

```bash
ip route
```

Look for the line like:

```
192.168.11.0/24 dev wlp0s20f3 proto kernel scope link src 192.168.11.106
```

- **Host IP**: the value after `src` → e.g. `192.168.11.106`
- **Subnet prefix**: the `/24` part of the network → e.g. `/24`

### 2 — Gateway

From the same output, look for:

```
default via 192.168.11.1 dev wlp0s20f3
```

- **Gateway**: the value after `via` → e.g. `192.168.11.1`

### 3 — Choose a Static IP for the VM

Pick any unused IP in the same subnet as the host. Example: if host is `192.168.11.106/24`, choose something like `192.168.11.50`.

Verify it's free before using it:

```bash
ping -c 2 <CHOSEN_VM_IP>
# No reply = free to use
```

### 4 — Host Network Interface

```bash
ip route
```

Look for the interface name in the default route line:

```
default via 192.168.11.1 dev wlp0s20f3
```

- **Host interface**: `wlp0s20f3` (use this in VirtualBox Bridged Adapter)

---

## Step 1 — Switch to Bridged Network

In VirtualBox (VM must be powered off):

```
Settings → Network → Adapter 1
```

Set:

```
Attached to: Bridged Adapter
Interface: <HOST_INTERFACE>       ← from Step 4 above (e.g. wlp0s20f3)
Promiscuous Mode: Allow All
```

This connects the VM directly to the same network as the host.

---

## Step 2 — Identify VM Network Interface

Boot the VM and run:

```bash
ip a
```

Look for an interface that is **not** `lo` (loopback). It is usually named:

```
enp0s3    ← typical VirtualBox interface name
```

Use this name in the Netplan config below.

---

## Step 3 — Configure Netplan

Edit the config file:

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Fill in your values:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    <VM_INTERFACE>: # from Step 2 — e.g. enp0s3
      dhcp4: false
      addresses:
        - <CHOSEN_VM_IP>/<PREFIX> # e.g. 192.168.11.50/24
      routes:
        - to: default
          via: <GATEWAY> # from Step 1 — e.g. 192.168.11.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

### Filled Example

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 192.168.11.50/24
      routes:
        - to: default
          via: 192.168.11.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

---

## Step 4 — Apply Configuration

```bash
sudo netplan try     # tests config for 120s, auto-reverts if broken
sudo netplan apply   # applies permanently
```

---

## Step 5 — Verification

```bash
ip a                         # confirm <CHOSEN_VM_IP> appears on <VM_INTERFACE>
ip route                     # confirm default route via <GATEWAY>
ping <GATEWAY>               # confirm local network connectivity
ping 8.8.8.8                 # confirm internet (IP level)
ping google.com              # confirm DNS resolution
```

---

## Summary Table

| Value          | How to get it                             | Example          |
| -------------- | ----------------------------------------- | ---------------- |
| Host IP        | `ip route` → `src` field                  | `192.168.11.106` |
| Subnet prefix  | `ip route` → prefix after network IP      | `/24`            |
| Gateway        | `ip route` → `default via` field          | `192.168.11.1`   |
| Host interface | `ip route` → `dev` field on default route | `wlp0s20f3`      |
| Chosen VM IP   | Any free IP in same subnet                | `192.168.11.50`  |
| VM interface   | `ip a` inside the VM                      | `enp0s3`         |

---

## Key Points

- `renderer: networkd` is correct for server environments (no desktop)
- `routes` with `to: default` replaces the deprecated `gateway4` key
- The VM IP, subnet, and gateway must all belong to the same network
- Bridged Adapter mode is required — NAT will not put the VM on your local network

---

## Common Mistakes

| Mistake                         | Fix                                                          |
| ------------------------------- | ------------------------------------------------------------ |
| Using NAT instead of Bridged    | Change Adapter 1 to Bridged in VM settings                   |
| Gateway from a different subnet | Gateway must match the host's `default via` value            |
| Chosen IP already in use        | Run `ping <IP>` on host first to confirm it's free           |
| Wrong renderer spelling         | Must be `networkd`, not `network`                            |
| Editing while VM is running     | Power off the VM before changing VirtualBox network settings |
