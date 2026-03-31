import platform
import subprocess

# Read the file into a list
file_path = 'hosts.txt'
with open(file_path, 'r') as file:
	hosts = file.readlines()

for host.strip() in hosts:
	result=subprocess.run(
		["ping",host, "c -1"],
		capture_output=True,
		text=True)
