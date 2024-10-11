import time
import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options


def test_3d(url_3d, username, password, course_name):
	# Configuration
	TIMEOUT = 15  # seconds
	
	service = Service('/usr/bin/chromedriver')
	options = Options()
	# options.add_argument("--headless") 
	options.add_argument("--no-sandbox")
	options.add_argument("--disable-dev-shm-usage")
	options.add_argument("--disable-gpu")
	options.add_argument("--window-size=1920,1080")
	options.add_argument("--ignore-certificate-errors")
	options.add_argument("--ignore-ssl-errors")
	
	try:
		print("Initializing Chrome driver...")
		driver = webdriver.Chrome(service=service, options=options)
		print("Chrome driver initialized successfully")
		
		# Navigate to enrolment page
		print(f"Navigating to enrolment page: {url_3d}")
		driver.get(f"{url_3d}")
		
		print("Current page title:", driver.title)
		print("Current URL:", driver.current_url)
		# print("Page source:", driver.page_source) 
		print("Page body:", driver.find_element(By.TAG_NAME, 'body').get_attribute('innerHTML'))
		
		print("Waiting for username field...")
		username_field = WebDriverWait(driver, TIMEOUT).until(EC.presence_of_element_located((By.XPATH, "//data-testid[@value='userName']")))
		print("Username field found")
		username_field.send_keys(username)
		time.sleep(1)
		
		print("Entering password")
		password_field = driver.find_element(By.XPATH, "//data-testid[@value='password']")
		password_field.send_keys(password)
		time.sleep(1)
		
		print("Clicking login button")
		login_button = driver.find_element(By.XPATH, "//data-testid[@value='loginButton']")
		login_button.click()
		
		print("Current page title:", driver.title)
		print("Current URL:", driver.current_url)
		# print("Page source:", driver.page_source) 
		print("Page body:", driver.find_element(By.TAG_NAME, 'body').get_attribute('innerHTML'))
		
		# Wait for the success message
		try:
			success_message = WebDriverWait(driver, TIMEOUT).until(
				EC.presence_of_element_located((By.CLASS_NAME, "alert-success"))
			)
			print("Test 3d completed successfully")
			print("Success message:", success_message.text)
			return True
		except TimeoutException:
			print("Test 3d failed: Success message not found")
			return False
	
	except TimeoutException as e:
		print(f"Timeout occurred: {e}")
		print("Current page source:")
		# print(driver.page_source)
		print("Page body:", driver.find_element(By.TAG_NAME, 'body').get_attribute('innerHTML'))
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
		print("Usage: test_3d.py <url_3d> <username> <password> <course_name>")
		sys.exit(1)
	
	url_3d = sys.argv[1]
	username = sys.argv[2]
	password = sys.argv[3]
	course_name = sys.argv[4]
	
	success = test_3d(url_3d, username, password, course_name)
	if success:
		print("Test 3d process completed successfully")
		sys.exit(0)
	else:
		print("Test 3d process failed")
		sys.exit(1)
