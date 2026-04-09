import psutil
from datetime import datetime
import subprocess
import socket

def get_disk_usage():
	hostname=socket.gethostname()
	disk = psutil.disk_usage('/')
	disk_percentage=(disk.percent)
	current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

	# --- Check ---
	if disk_percentage > 90:
		status="CRITICAL"
	elif disk_percentage > 80:
		status="WARNING"
	else:
		status="OK"

	# --- Alert ---
	if status=="WARNING" or status=="CRITICAL":
		subprocess.run(['msmtp', 'thomas.halling1999@gmail.com'], input=f'Subject: {status} Disk Usage Alert\n\nDisk usage on {hostname} is at {disk_percentage}%',text=True)

	# --- Log ---
	with open ('/var/log/disk_usage.log', 'a') as f:
		f.write(f"{current_time} | {status} | {disk_percentage}%\n")
	return disk_percentage, status

