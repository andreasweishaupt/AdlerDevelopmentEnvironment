import time
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains

def enrol_student(moodleurl, username, password, course_id):
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
	prefs = {"profile.default_content_setting_values.notifications" : 2}
	options.add_experimental_option("prefs",prefs)
	
	try:
		print("Initializing Chrome driver...")
		driver = webdriver.Chrome(service=service, options=options)
		print("Chrome driver initialized successfully")
		
		print(f"Navigating to login page: {moodleurl}/login/index.php")
		driver.get(f"http://{moodleurl}/login/index.php")
		
		# Warte kurz, damit das Popup-Fenster erscheinen kann
		print("Wait")
		time.sleep(2)
		
		# Sende Return-Tastendruck um Popup-Fenster zu schließen
		#ActionChains(driver).send_keys(Keys.TAB).pause(1).key_down(Keys.SHIFT).send_keys(Keys.TAB).key_up(Keys.SHIFT).pause(1).perform()
		print("Press Return")
		#ActionChains(driver).send_keys(Keys.RETURN).perform()
		
		# Login
		print(f"Navigating to login page: {moodleurl}/login/index.php")
		driver.get(f"http://{moodleurl}/login/index.php")
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


if __name__ == "__main__":
	if len(sys.argv) != 5:
		print("Usage: python enrol_student.py <moodleurl> <username> <password> <course_id>")
		sys.exit(1)
	
	moodleurl = sys.argv[1]
	username = sys.argv[2]
	password = sys.argv[3]
	course_id = sys.argv[4]
	
	enrol_student(moodleurl, username, password, course_id)
	sys.exit(0)
