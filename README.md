# Versionen der Projekte auswählen
## Moodle
In der Datei `docker-compose.yaml unter services -> moodle -> args -> MOODLE_VERSION`.

Die verfügbaren Moodle Versionen können aus den Tags des Bitnami - Moodle Images entnommen werden.
https://hub.docker.com/r/bitnami/moodle/tags

Die unterstützen Moodle Versionen sind in der Readme des local_adler Plugins dokumentiert.
https://github.com/ProjektAdLer/MoodlePluginLocal


Standartmäßig ist Version 4.2 eingestellt

## Moodle Plugin

Wir in der Datei `docker-compose.yaml unter services -> moodle -> args -> PLUGIN_VERSION` gesetzt.

Standartmäßig wird der aktuelle main-Stand beider Plugins verwendet.
Dies kann auf eine Spezifische Version geändert werden. Siehe:

https://github.com/ProjektAdLer/MoodlePluginLocal/releases/tag/1.0.0

Beispiel: `PLUGIN_VERSION: main, 1.0.0, 1.0 oder 1` (das "v" muss weg gelassen werden)

Es kann auch nur beispielweise 1.0 angeben werden. Dann wird die aktuellste Version mit dem Tag 1.0.x verwendet. Ebenso für "1".

## Backend
Wird in der Datei `docker-compose.yaml unter services -> backend -> image gesetzt`.

Standartmäßig wird der aktuelle main-Stand verwendet: `image: ghcr.io/projektadler/adlerbackend:main`

Hinter dem Doppelpunkt wird der jeweilige Tag angegeben. Diese können dem Container Registry des Backend Repositories entnommen werden:

https://github.com/ProjektAdLer/AdLerBackend/pkgs/container/adlerbackend

## Frontend
Wird in der Datei `docker-compose.yaml unter services -> frontend -> image gesetzt`.

Standartmäßig wird der aktuelle latest-Stand verwendet: `image: ghcr.io/projektadler/2d_3d_adler:latest`

Hinter dem Doppelpunkt wird der jeweilige Tag angegeben. Diese können dem Container Registry des Frontend Repositories entnommen werden:

https://github.com/ProjektAdLer/2D_3D_AdLer/pkgs/container/2d_3d_adler

# User
Folgende User werden automatisch erstellt:
## Admin (Kann keine Kurse erstellen)
Username: admin
Password: admin

## Manager (Kann Kurse erstellen)
Username: manager
Password: Manager1234!1234

## User (Student)
Username: user
Password: User1234!1234

# URL
- URL MOODLE: `localhost:8085`
- URL BACKEND: `localhost:8086`
- URL Frontend: `localhost:8087`
- URL phpMyAdmin: `localhost:8088`

**Wichtig**: localhost funktioniert NICHT. Also müssen die oben genannten URLs verwendet werden!

Dementsprechend ist die eigentliche API des Backends unter localhost:8086/api erreichbar.

# Starten der Umgebung
1. Repo Clonen
2. Terminal im Ordner öffnen (Unter Windows Shift + Rechtsklick -> Terminal öffnen)
3. `docker compose up -d --build` ausführen

# Stoppen der Umgebung
1. Terminal im Ordner öffnen (Unter Windows Shift + Rechtsklick -> Terminal öffnen)
2. `docker compose down` ausführen (oder docker compose down -v um auch alle Daten zu löschen (Werkszustand))


# Docker Desktop
Die Laufenden Container können in Docker Desktop eingesehen werden. Dort kann auch der Status der Container angezeigt werden. Außerdem kann man sich über diese Oberfläche auch in die Container mit einem Terminal verbinden.