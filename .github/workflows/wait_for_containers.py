import subprocess
import time
import re


def check_container_log(container_name, success_pattern):
    logs = subprocess.run(["docker", "logs", container_name], capture_output=True, text=True).stdout
    return bool(re.search(success_pattern, logs))


containers = {
    "adlertestenvironment-backend-1": r"Hosting started",
    "adlertestenvironment-phpmyadmin-1": r"configured -- resuming normal operations",
    "adlertestenvironment-moodle-1": r"finished adler setup/update script",
    "adlertestenvironment-frontend-1": r"Configuration complete; ready for start up",
    "adlertestenvironment-db_backend-1": r"ready for connections.",
    "adlertestenvironment-db_moodle-1": r"ready for connections."
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
