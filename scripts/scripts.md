# Scripts

A collection of Bash scripts for monitoring and managing a Linux home lab.

## Requirements

- `msmtp` and `mailutils` for email alerts
- A configured `~/.msmtprc` file for Gmail (see Configuration)

## Configuration

Scripts that send email alerts require a `~/.msmtprc` file. See [msmtp documentation](https://marlam.de/msmtp/) for setup instructions.

Scripts with configurable variables have a `--- Config ---` section at the top of the file. Update these before running.

---

## Scripts

### disk_usage.sh

Checks disk usage on `/` and reports status.

**Usage:**
```bash
./disk_usage.sh
```

**Config:**
| Variable | Description | Default |
|---|---|---|
| `ALERT_EMAIL` | Email address for alerts | - |
| `LOGFILE` | Path to log file | `/var/log/disk_usage.log` |
| `THRESHOLD_WARN` | Warning threshold (%) | `80` |
| `THRESHOLD_CRIT` | Critical threshold (%) | `90` |

**Output:**
- Appends a timestamped entry to `$LOGFILE` on every run
- Sends an email alert if status is WARNING or CRITICAL
- Prints a report to stdout

**Cron example** (run every hour):
```
0 * * * * /path/to/disk_usage.sh
```

---

### compress_directory.sh

Creates a timestamped compressed backup of a directory and removes backups older than 7 days.

**Usage:**
```bash
./compress_directory.sh <source_directory> <backup_directory>
```

**Example:**
```bash
./compress_directory.sh /home/tom/Documents /home/tom/backups
```

---

### service_status_check.sh

Checks the status of key system services and reports whether they are running or stopped.

**Usage:**
```bash
./service_status_check.sh
```

Services checked: `ssh`, `cron`, `tailscaled`

To check different services, edit the `services` variable at the top of the script.

---

### failed_logins.sh

Parses an SSH log file and reports the number of failed login attempts and the top offending IP addresses.

**Usage:**
```bash
./failed_logins.sh <logfile>
```

**Example:**
```bash
./failed_logins.sh /var/log/auth.log
```

---

### process_report.sh

Displays the top 5 processes by CPU and memory usage on the current host.

**Usage:**
```bash
./process_report.sh
```

---

### system_dashboard.sh

Master script that runs `disk_usage.sh` and `service_status_check.sh` and produces a unified health report. Exits with code `1` if any check fails.

**Usage:**
```bash
./system_dashboard.sh
```

---

### user_audit.sh

Lists all users with a login shell and shows their last login time.

**Usage:**
```bash
./user_audit.sh
```

---

### network_monitor.sh

Pings a list of hosts and reports whether they are up or down. Sends an email alert and logs the result for any host that is unreachable.

**Usage:**
```bash
./network_monitor.sh
```

Hosts are read from `hosts.txt` in the same directory — one host per line:
```
192.168.1.1
8.8.8.8
google.com
```

**Config:**
| Variable | Description |
|---|---|
| `ALERT_EMAIL` | Email address for alerts |
| `LOGFILE` | Path to log file |

**Cron example** (run every 5 minutes):
```
*/5 * * * * /path/to/network_monitor.sh
```
## Python Scripts
 
### Requirements
 
Install required packages:
```bash
pip3 install flask psutil --break-system-packages
```
 
Built-in modules used (no install needed): `subprocess`, `socket`, `datetime`, `os`
 
---
 
### disk_usage.py
 
Checks disk usage on `/` and returns status. Can be run standalone or imported by the dashboard.
 
**Standalone usage:**
```bash
python3 disk_usage.py
```
 
**Config** (edit variables at top of file):
| Variable | Description | Default |
|---|---|---|
| `ALERT_EMAIL` | Email address for alerts | - |
| `LOGFILE` | Path to log file | `/var/log/disk_usage.log` |
| `THRESHOLD_WARN` | Warning threshold (%) | `80` |
| `THRESHOLD_CRIT` | Critical threshold (%) | `90` |
 
**Returns** (when imported):
```python
from disk_usage import get_disk_usage
disk_percentage, status = get_disk_usage()
```
 
---
 
### service_status.py
 
Checks whether a list of systemd services are active or inactive. Can be run standalone or imported by the dashboard.
 
**Standalone usage:**
```bash
python3 service_status.py
```
 
**Usage (when imported):**
```python
from service_status import get_service_status
statuses = get_service_status(["ssh", "cron", "tailscaled"])
```
 
To check different services, update the `services_to_check` list at the bottom of the file.
 
**Returns:** Dictionary of `{service_name: status}` where status is `active` or `inactive`.
 
---
 
### network_monitor.py
 
Pings a list of hosts from `hosts.txt` and returns their status. Can be run standalone or imported by the dashboard.
 
**Standalone usage:**
```bash
python3 network_monitor.py
```
 
Hosts are read from `hosts.txt` in the same directory — one host per line:
```
192.168.1.1
8.8.8.8
google.com
```
 
**Usage (when imported):**
```python
from network_monitor import get_network_status
statuses = get_network_status()
```
 
**Returns:** Dictionary of `{host: status}` where status is `UP` or `DOWN`.
 
---
 
### dashboard.py
 
Flask web dashboard that displays disk usage, service status, and network monitor data in a browser. Imports from `disk_usage.py`, `service_status.py`, and `network_monitor.py`.
 
**Usage:**
```bash
python3 dashboard.py
```
 
Access the dashboard at `http://<your-tailscale-ip>:5000`
 
**Requirements:**
- `flask_templates/index.html` must exist at the repo root level
- `hosts.txt` must exist in the scripts directory
- `~/.msmtprc` must be configured for email alerts
- All three Python monitoring scripts must be in the same directory
