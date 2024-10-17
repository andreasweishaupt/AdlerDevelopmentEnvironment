import subprocess
import time


def check_container_log(container_name, success_pattern):
    max_attempts = 3
    for attempt in range(max_attempts):
        try:
            logs = subprocess.run(
                ["docker", "logs", container_name],
                capture_output=True,
                text=True,
                check=True,
                timeout=5
            ).stdout
            # Ausgabe nur der letzten 5 Zeilen
            # last_five_lines = '\n'.join(logs.splitlines()[-5:])
            # print(f"Logs for {container_name} (last 5 lines):")
            # print(last_five_lines)
            return success_pattern in logs
        except subprocess.TimeoutExpired:
            print(f"Timeout while fetching logs for {container_name}. Attempt {attempt + 1} of {max_attempts}")
        except subprocess.CalledProcessError as e:
            print(f"Error fetching logs for {container_name}: {e}")
            return False
        time.sleep(2)  # Wait before retrying
    print(f"Failed to fetch logs for {container_name} after {max_attempts} attempts")
    return False


containers = {
    "adlertestenvironment-backend-1": "Hosting started",
    "adlertestenvironment-phpmyadmin-1": "resuming normal operations",
    "adlertestenvironment-moodle-1": "finished adler setup/update script",
    "adlertestenvironment-frontend-1": "Configuration complete; ready for start up",
    "adlertestenvironment-db_backend-1": "ready for connections.",
    "adlertestenvironment-db_moodle-1": "ready for connections."
}

start_time = time.time()
timeout = 120  # 2 minutes timeout
ready_containers = set()

while len(ready_containers) < len(containers):
    print(f"\nÜberprüfe Container-Status (Vergangene Zeit: {int(time.time() - start_time)} Sekunden):")
    for container, pattern in containers.items():
        if container in ready_containers:
            print(f"  - {container}: Bereit")
        elif check_container_log(container, pattern):
            print(f"  - {container}: Gerade bereit geworden")
            ready_containers.add(container)
        else:
            print(f"  - {container}: Noch nicht bereit")

    if len(ready_containers) == len(containers):
        print("\nAlle Container sind bereit!")
        break

    if time.time() - start_time > timeout:
        print(f"\nTimeout erreicht. Nicht alle Container sind bereit geworden.")
        for container in containers:
            if container not in ready_containers:
                print(f"  - {container}: Nicht bereit")
        exit(0)

    time.sleep(10)  # Warte 10 Sekunden vor der nächsten Überprüfung

print(f"\nAlle Container wurden erfolgreich gestartet. Gesamtzeit: {int(time.time() - start_time)} Sekunden")
