#!/bin/bash

moodleurl=$1
coursename=$2
username=$3
password=$4

echo "moodleurl: $moodleurl"
echo "coursename: $coursename"
echo "username: $username"
echo "password: $password"

# Token abrufen
TEST_URL="${moodleurl}/login/token.php?username=${username}&password=${password}&service=adler_services"
echo "TEST_URL: ${TEST_URL}"
TOKEN_RESPONSE=$(curl -s "${TEST_URL}")
echo "Token-Response erhalten: $TOKEN_RESPONSE"
TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.token')
echo "Token erhalten: $TOKEN"

# Kurs mit Name suchen
TEST_URL="${moodleurl}/webservice/rest/server.php?wstoken=${TOKEN}&wsfunction=core_course_search_courses&criterianame=search&criteriavalue=${coursename}&moodlewsrestformat=json"
echo "TEST_URL: ${TEST_URL}"
COURSES_RESPONSE=$(curl -s "${TEST_URL}")
echo "Kurse erhalten: $COURSES_RESPONSE"

# Kurs-ID extrahieren
COURSE_ID=$(echo $COURSES_RESPONSE | jq -r '.courses[0].id')
echo "Gefundene Kurs-ID: $COURSE_ID"

# Chrome starten und Aktionen ausführen
google-chrome --no-sandbox --headless --disable-gpu --remote-debugging-port=9222 &
CHROME_PID=$!

# Warten, bis Chrome gestartet ist
sleep 5

# Auf Login-Seite navigieren und einloggen
python3 - <<END
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options

# Shell variables
moodleurl = "$moodleurl"
username = "$username"
password = "$password"
course_id = "$COURSE_ID"

# Configuration
TIMEOUT = 5  # seconds

service = Service('/usr/bin/chromedriver')
options = Options()
options.add_argument("--headless")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")
options.add_argument("--disable-gpu")
options.add_argument("window-size=1200,800")
options.add_argument("--remote-debugging-port=9222")

try:
    driver = webdriver.Chrome(service=service, options=options)

    # Login
    driver.get(f"{moodleurl}/login/index.php")
    WebDriverWait(driver, TIMEOUT).until(EC.presence_of_element_located((By.ID, "username"))).send_keys(username)
    driver.find_element(By.ID, "password").send_keys(password)
    driver.find_element(By.ID, "loginbtn").click()

    # Wait for login to complete
    WebDriverWait(driver, TIMEOUT).until(EC.presence_of_element_located((By.CLASS_NAME, "usertext")))

    # Navigate to enrolment page
    driver.get(f"{moodleurl}/enrol/index.php?id={course_id}")

    # Click on "Enrol me" button
    enrol_button = WebDriverWait(driver, TIMEOUT).until(
        EC.element_to_be_clickable((By.XPATH, "//input[@value='Enrol me']"))
    )
    enrol_button.click()

    print("Enrolment completed successfully")

except TimeoutException as e:
    print(f"Timeout occurred: {e}")
except Exception as e:
    print(f"An error occurred: {e}")
finally:
    if 'driver' in locals():
        driver.quit()
END

# Chrome beenden
kill $CHROME_PID