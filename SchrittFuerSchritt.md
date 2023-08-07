1. Git installieren
   - Beim Schritt "Configuring the line ending vonversions" eine der beiden unteren Optionen auswählen (Wenn man sich unsicher ist, dann die Mittlere)  
2. Docker Desktop installieren
    - Default Settings verwenden
3. Reboot
4. WSL Updaten
    - WIN + R -> `cmd` -> `wsl --update`
5. Evtl muss die Virtualisierung im BIOS aktiviert werden. Sollte Docker desswegen meckern, dann den namen des eigenen Mainboards + "virtualisierung aktivieren" googlen und die Schritte befolgen
6. Dieses Repo Klonen
7. Terminal im Ordner öffnen (Unter Windows Shift + Rechtsklick -> "Terminal öffnen")
8. `docker compose up -d --build` ausführen
9. Die Moodle URL öffnen (localhost:8085) und warten, bis Moodle gestartet ist