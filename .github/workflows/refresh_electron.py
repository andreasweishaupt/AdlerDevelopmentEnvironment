from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

def refresh_electron_app():
    # Initialisieren Sie den WebDriver (z.B. Chrome)
    driver = webdriver.Chrome()

    try:
        # Öffnen Sie die URL Ihrer Electron-Anwendung
        driver.get("http://localhost:8001")  # Passen Sie die URL an

        # Warten Sie, bis die Seite geladen ist
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )

        # Führen Sie einen Refresh durch
        driver.refresh()

        # Oder alternativ, senden Sie F5
        # driver.find_element(By.TAG_NAME, 'body').send_keys(Keys.F5)

        # Oder führen Sie ein JavaScript-Reload aus
        # driver.execute_script("location.reload(true);")

        # Warten Sie kurz, um sicherzustellen, dass der Refresh abgeschlossen ist
        time.sleep(5)

        print("Refresh erfolgreich durchgeführt")

    finally:
        # Schließen Sie den Browser
        driver.quit()

if __name__ == "__main__":
    refresh_electron_app()