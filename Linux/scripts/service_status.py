import subprocess

def get_service_status(services):
	results={}
	for service in services:
		try:
			result=subprocess.run(
				["systemctl", "is-active", service],
				capture_output=True,
				text=True,
				check=False
			)
			results[service] = result.stdout.strip()
		except Exception as e:
			results[service] = f"Error: {e}"
	return results

if __name__ == '__main__':
	services_to_check = ["ssh","cron","tailscaled"]
	statuses = get_service_status(services_to_check)

	for service, status in statuses.items():
		print(f"{service} Status: {status}")
