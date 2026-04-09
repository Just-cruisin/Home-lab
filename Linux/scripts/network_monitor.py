import platform
import subprocess

def get_network_status():
    results = {}
    file_path = 'hosts.txt'
    with open(file_path, 'r') as file:
        hosts = file.readlines()
    for host in hosts:
        host = host.strip()
        result = subprocess.run(
            ["ping", "-c", "1", host],
            capture_output=True,
            text=True)
        if result.returncode == 0:
            status = "UP"
        else:
            status = "DOWN"
        results[host] = status
    return results

if __name__ == '__main__':
    statuses = get_network_status()
    for host, status in statuses.items():
        print(f"{host}: {status}")
