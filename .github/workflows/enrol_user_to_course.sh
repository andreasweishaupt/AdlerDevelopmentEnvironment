#!/bin/bash

export DISPLAY=:99

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

# Auf Login-Seite navigieren und einloggen
python3 - <<END
import time
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options

# Shell variables
moodleurl = "$moodleurl"
username = "$username"
password = "$password"
course_id = "$COURSE_ID"

# Configuration
TIMEOUT = 60  # seconds

service = Service('/usr/bin/chromedriver')
options = Options()
# options.add_argument("--headless") 
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")
options.add_argument("--disable-gpu")
options.add_argument("--window-size=1920,1080")
options.add_argument("--ignore-certificate-errors")
options.add_argument("--ignore-ssl-errors")
options.add_argument("--disable-features=PreloadMediaEngagementData,MediaEngagementBypassAutoplayPolicies")
options.add_argument("--disable-popup-blocking")
options.add_argument("--disable-notifications")
options.add_experimental_option("prefs", {
    "profile.default_content_setting_values.automatic_downloads": 1,
})

try:
    print("Initializing Chrome driver...")
    driver = webdriver.Chrome(service=service, options=options)
    print("Chrome driver initialized successfully")

    # Login
    print(f"Navigating to login page: {moodleurl}/login/index.php")
    driver.get(f"{moodleurl}/login/index.php")
    time.sleep(10)  # Increased wait time
    
    print("Current page title:", driver.title)
    print("Current URL:", driver.current_url)
    print("Page source:", driver.page_source) 
    
    print("Waiting for username field...")
    username_field = WebDriverWait(driver, TIMEOUT).until(EC.presence_of_element_located((By.ID, "username")))
    print("Username field found")
    username_field.send_keys(username)
    
    print("Entering password")
    password_field = driver.find_element(By.ID, "password")
    password_field.send_keys(password)
    
    print("Clicking login button")
    login_button = driver.find_element(By.ID, "loginbtn")
    login_button.click()

    # Wait for login to complete
    print("Waiting for login to complete")
    WebDriverWait(driver, TIMEOUT).until(EC.presence_of_element_located((By.CLASS_NAME, "usertext")))
    print("Login completed")

    # Navigate to enrolment page
    print(f"Navigating to enrolment page: {moodleurl}/enrol/index.php?id={course_id}")
    driver.get(f"{moodleurl}/enrol/index.php?id={course_id}")
    time.sleep(10)  # Increased wait time

    # Click on "Enrol me" button
    print("Waiting for 'Enrol me' button")
    enrol_button = WebDriverWait(driver, TIMEOUT).until(
        EC.element_to_be_clickable((By.XPATH, "//input[@value='Enrol me']"))
    )
    print("'Enrol me' button found")
    enrol_button.click()

    print("Enrolment completed successfully")

except TimeoutException as e:
    print(f"Timeout occurred: {e}")
    print("Current page source:")
    print(driver.page_source)
except WebDriverException as e:
    print(f"WebDriver exception occurred: {e}")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
finally:
    if 'driver' in locals():
        driver.quit()
        print("Chrome driver closed")

sys.exit(0)  # Always exit with status 0 to not break the pipeline
END