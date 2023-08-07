# Versionen der Projekte auswählen

## Moodle

In der Datei `docker-compose.yaml` unter `services -> moodle -> args -> MOODLE_VERSION`.

Die verfügbaren Moodle Versionen können aus den Tags des Bitnami - Moodle Images entnommen werden.
[Bitnami Moodle Tags](https://hub.docker.com/r/bitnami/moodle/tags)

Die unterstützen Moodle Versionen sind in der Readme des `local_adler` Plugins dokumentiert.
[Local Adler Plugin](https://github.com/ProjektAdLer/MoodlePluginLocal)

Standardmäßig ist Version 4.2 eingestellt.

## Moodle Plugin

Wird in der Datei `docker-compose.yaml` unter `services -> moodle -> args -> PLUGIN_VERSION` gesetzt.

Standardmäßig wird der aktuelle main-Stand beider Plugins verwendet.
Dies kann auf eine spezifische Version geändert werden. Siehe:

[Moodle Plugin Local Release](https://github.com/ProjektAdLer/MoodlePluginLocal/releases/tag/1.0.0)

Beispiel: `PLUGIN_VERSION: main, 1.0.0, 1.0 oder 1` (das "v" muss weggelassen werden)

Es kann auch nur beispielsweise 1.0 angegeben werden. Dann wird die aktuellste Version mit dem Tag 1.0.x verwendet. Ebenso für "1".

## Backend

Wird in der Datei `docker-compose.yaml` unter `services -> backend -> image` gesetzt.

Standardmäßig wird der aktuelle main-Stand verwendet: `image: ghcr.io/projektadler/adlerbackend:main`

Hinter dem Doppelpunkt wird der jeweilige Tag angegeben. Diese können dem Container Registry des Backend Repositories entnommen werden:

[Adler Backend Container](https://github.com/ProjektAdLer/AdLerBackend/pkgs/container/adlerbackend)

## Frontend

Wird in der Datei `docker-compose.yaml` unter `services -> frontend -> image` gesetzt.

Standardmäßig wird der aktuelle latest-Stand verwendet: `image: ghcr.io/projektadler/2d_3d_adler:latest`

Hinter dem Doppelpunkt wird der jeweilige Tag angegeben. Diese können dem Container Registry des Frontend Repositories entnommen werden:

[2D 3D Adler Container](https://github.com/ProjektAdLer/2D_3D_AdLer/pkgs/container/2d_3d_adler)

# User

Folgende User werden automatisch erstellt:

## Admin (Kann keine Kurse erstellen)

- **Username:** admin
- **Password:** pass

## Manager (Kann Kurse erstellen)

- **Username:** manager
- **Password:** Manager1234!1234

## User (Student)

- **Username:** student
- **Password:** Student1234!1234

# URLs

- URL MOODLE: `localhost:8085`
- URL BACKEND: `localhost:8086`
- URL Frontend: `localhost:8087`
- URL phpMyAdmin: `localhost:8088`

Dementsprechend ist die eigentliche API des Backends unter `localhost:8086/api` erreichbar. Diese Adresse wird dann auch im AMG verwendet.

# Starten der Umgebung

1. Repo klonen
2. Terminal im Ordner öffnen (Unter Windows Shift + Rechtsklick -> "Terminal öffnen")
3. `docker compose up -d --build` ausführen

# Stoppen der Umgebung

1. Terminal im Ordner öffnen (Unter Windows Shift + Rechtsklick -> "Terminal öffnen")
2. `docker compose down` ausführen (oder `docker compose down -v` um auch alle Daten zu löschen (Werkszustand))

# Docker Desktop

Die laufenden Container können in Docker Desktop eingesehen werden. Dort kann auch der Status der Container angezeigt werden. Außerdem kann man sich über diese Oberfläche auch in die Container mit einem Terminal verbinden.

# Technical stuff

## Hostname

Moodle erfordert Docker internen (Backend) und externen (Docker-Host) Zugriff über denselben Hostnamen. Es gibt einige Möglichkeiten, dies zu erreichen:

- `host.docker.internal`: Sollte theoretisch funktionieren, da dieser Hostname auf dem Docker-Host und innerhalb der Docker-Container verfügbar ist. Wenn er innerhalb eines Containers nicht verfügbar ist (was aus verschiedenen Gründen manchmal vorkommen kann), kann er über `extra_hosts: host.docker.internal:host-gateway` gesetzt werden. Nach einiger Zeit funktionierte dies auf meinem System und Test-VM nicht mehr (Eintrag im Hostsystem hatte die falsche IP).
- `localhost`: Der aktuelle Ansatz, der derzeit gut zu funktionieren scheint. Aus irgendeinem Grund scheint es gut zu funktionieren, localhost auf zwei verschiedene IPs in der Hosts-Datei des Backend-Containers zu setzen (siehe [Commit](https://github.com/ProjektAdLer/AdlerTestEnvironment/commit/f6947345beb9a52f64d66d385d24a8c9e9da2b64)). Kein Zugriff über LAN möglich.
- Hostsystem-Hostname: Sollte innerhalb der Container verfügbar sein und falls nicht, kann er über extra_hosts übergeben werden. Offensichtlich auch auf dem Hostsystem verfügbar. Würde auch den Zugriff über LAN ermöglichen. Das Templating ist jedoch nur mit Swarm verfügbar ([1](https://github.com/docker/compose/issues/4964), [2](https://docs.docker.com/engine/reference/commandline/service_create/#create-services-using-templates)) -> würde eine manuelle Konfiguration auf jedem Host erfordern (eine Variable setzen).
- Benutzerdefinierte Domain: erfordert erheblichen zusätzlichen Aufwand (ähnlich wie der Hostsystem-Hostname + mehr).
- Hostsystem-IP oder 127.10.0.1: Die Host-IP ändert sich je nach Netzwerk, etc. Würde den LAN-Zugriff ermöglichen, aber es wäre lästig, wenn sie sich ändert (diese Änderung könnte auch die Moodle-Installation beeinträchtigen). Der Docker host_gateway (standardmäßig 127.10.0.1) könnte gut funktionieren, aber nur für localhost, nicht für LAN.
