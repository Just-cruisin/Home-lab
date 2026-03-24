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
