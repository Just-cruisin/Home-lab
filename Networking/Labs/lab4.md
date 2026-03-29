# Lab 4
## Capstone Project - Full Stack Web Infrastructure

### Architecture
```
Router (192.168.1.39)
    ↓ nginx (TLS termination)
    ↓ HAProxy (load balancing, port 8080)
    ↓
VLAN 10 - Web Tier
├── client1 (192.168.10.50) - Flask app
└── client3 (192.168.10.51) - Flask app
    ↓ port 5432 only (nftables firewall)
VLAN 20 - Database Tier
└── client2 (192.168.20.50) - PostgreSQL
```

### PostgreSQL Setup (client2)
* Installed postgresql
* Created database, user and granted privileges:
```sql
CREATE DATABASE labapp;
CREATE USER webuser WITH PASSWORD 'labpassword';
GRANT ALL PRIVILEGES ON DATABASE labapp TO webuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO webuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO webuser;
```
* Configured listen_addresses = '*' in postgresql.conf
* Added pg_hba.conf entry to allow web tier:
```
host    labapp    webuser    192.168.10.0/24    scram-sha-256
```

### Flask App (client1 + client3)
* Simple Python Flask app reading from PostgreSQL
* Displays hostname so you can see which backend is serving
* Runs as a systemd service on port 80
* Deployed to /opt/labapp/app.py

### Firewall (client2 - nftables)
* Default policy drop
* Only allows:
  - SSH from anywhere
  - PostgreSQL (5432) from web tier (192.168.10.0/24)
  - node_exporter (9100) from router
  - ICMP
  - Established/related connections
* Important: flush ruleset at top of config prevents rule duplication

### DNS
* Added app.lab.local → 192.168.10.1 in bind9 forward zone
* Tailscale was overriding resolv.conf on router - fixed with:
```bash
sudo tailscale set --accept-dns=false
sudo chattr +i /etc/resolv.conf
```

### NAT
* Added MASQUERADE rules so VLAN clients can reach internet:
```bash
sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o ens18 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 192.168.20.0/24 -o ens18 -j MASQUERADE
```
