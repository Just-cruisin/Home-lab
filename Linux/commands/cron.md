# Cron Reference

Cron is a Linux task scheduler that runs commands automatically at specified times or intervals. Jobs are defined in a **crontab** (cron table).

## Managing Crontabs

```bash
crontab -e      # Edit your cron jobs
crontab -l      # List your current cron jobs
crontab -r      # Remove all your cron jobs
```

## Syntax

```
* * * * * /path/to/command
│ │ │ │ │
│ │ │ │ └── Day of week (0-7, Sunday = 0 or 7)
│ │ │ └──── Month (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
```

## Examples

| Expression | Meaning |
|---|---|
| `0 * * * *` | Every hour, on the hour |
| `*/5 * * * *` | Every 5 minutes |
| `0 9 * * *` | Every day at 9:00am |
| `0 9 * * 1` | Every Monday at 9:00am |
| `0 0 1 * *` | First day of every month at midnight |
| `30 6 * * 1-5` | Weekdays at 6:30am |
| `0 */6 * * *` | Every 6 hours |

## Tips

- Always use **full paths** for both the command and any files it references — cron doesn't know usual `$PATH`
- Cron has no terminal, so output is discarded unless redirected
- Redirect output to a log file to capture errors:
```bash
0 * * * * /home/tom/scripts/disk_usage.sh >> /var/log/disk_usage.log 2>&1
```
- `2>&1` captures both standard output and errors to the same file
- Test your script manually before adding it to cron
- Use [crontab.guru](https://crontab.guru) to check expressions

## Special Strings

Some cron implementations support shortcuts instead of expressions:

| String | Equivalent |
|---|---|
| `@hourly` | `0 * * * *` |
| `@daily` | `0 0 * * *` |
| `@weekly` | `0 0 * * 0` |
| `@monthly` | `0 0 1 * *` |
| `@reboot` | Run once at startup |
