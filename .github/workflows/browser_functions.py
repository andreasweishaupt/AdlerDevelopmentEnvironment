import sys
import logging
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import StaleElementReferenceException, TimeoutException
import time

logging.basicConfig(level=logging.DEBUG, stream=sys.stderr, format='find_element.py - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

driver = None
SESSION_FILE = 'session.json'

def get_driver():
    global driver
    if driver is None:
        if os.path.exists(SESSION_FILE):
            with open(SESSION_FILE, 'r') as f:
                session_data = json.load(f)
            try:
                driver = webdriver.Remote(command_executor=session_data['url'], desired_capabilities={})
                driver.session_id = session_data['session_id']
            except:
                os.remove(SESSION_FILE)
                driver = create_new_driver()
        else:
            driver = create_new_driver()
    return driver

def create_new_driver():
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("window-size=1200,800")
    service = Service('/usr/bin/chromedriver')
    driver = webdriver.Chrome(service=service, options=chrome_options)
    session_data = {
        'url': driver.command_executor._url,
        'session_id': driver.session_id
    }
    with open(SESSION_FILE, 'w') as f:
        json.dump(session_data, f)
    return driver

def initialize_browser():
    get_driver()
    print("Browser initialized")

def navigate_to_url(url):
    driver = get_driver()
    logger.debug(f"Navigating to URL: {url}")
    driver.get(url)

def find_element_coordinates(identifier, identifier_type, offset_x=0, offset_y=0):
    driver = get_driver()
    max_retries = 3
    for attempt in range(max_retries):
        try:
            logger.debug(f"Attempt {attempt + 1} to find element with {identifier_type}: {identifier}")
            if identifier_type == "class":
                element = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.CLASS_NAME, identifier))
                )
            elif identifier_type == "src":
                element = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.XPATH, f"//img[contains(@src, '{identifier}')]"))
                )
            elif identifier_type == "identifier":
                element = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.XPATH, f"//*[contains(@identifier, '{identifier}')]"))
                )
            elif identifier_type == "title":
                element = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.XPATH, f"//*[contains(@title, '{identifier}')]"))
                )
            else:
                raise ValueError("Invalid identifier_type. Use 'class', 'src', 'identifier', or 'title'.")
            
            time.sleep(0.5)
            location = element.location
            logger.debug(f"window_size: {driver.get_window_size()}")
            logger.debug(f"Element found at location: {location}")
            return location['x'] + offset_x + 14, location['y'] + offset_y + 38
        except (StaleElementReferenceException, TimeoutException) as e:
            logger.warning(f"Exception encountered: {str(e)}")
            if attempt < max_retries - 1:
                time.sleep(1)
            else:
                raise

def close_browser():
    global driver
    if driver:
        driver.quit()
    if os.path.exists(SESSION_FILE):
        os.remove(SESSION_FILE)
    driver = None
    print("Browser closed")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python find_element.py <command> [args...]")
        print("Commands: init, navigate, find, close")
        sys.exit(1)

    command = sys.argv[1]

    if command == "init":
        initialize_browser()
    elif command == "navigate":
        if len(sys.argv) < 3:
            print("Usage: python find_element.py navigate <url>")
            sys.exit(1)
        url = sys.argv[2]
        navigate_to_url(url)
        print(f"Navigated to {url}")
    elif command == "find":
        if len(sys.argv) < 4:
            print("Usage: python find_element.py find <identifier_type> <identifier> [offset_x] [offset_y]")
            sys.exit(1)
        identifier_type = sys.argv[2]
        identifier = sys.argv[3]
        offset_x = int(sys.argv[4]) if len(sys.argv) > 4 else 0
        offset_y = int(sys.argv[5]) if len(sys.argv) > 5 else 0
        try:
            x, y = find_element_coordinates(identifier, identifier_type, offset_x, offset_y)
            print(f"{x},{y}")
        except Exception as e:
            logger.error(f"An error occurred: {str(e)}")
            sys.exit(1)
    elif command == "close":
        close_browser()
        print("Browser closed")
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)