import sys
import logging
import json
import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import WebDriverException, TimeoutException

logging.basicConfig(level=logging.DEBUG, stream=sys.stderr, format='find_element.py - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

SESSION_FILE = 'session.json'
driver = None

def is_session_valid(driver):
    logger.info("Check driver")
    if driver is None:
        return False
    try:
        driver.title  # This will throw an exception if the session is invalid
        return True
    except WebDriverException:
        return False

def create_session_file(data):
    with open(SESSION_FILE, 'w') as f:
        json.dump(data, f)
    os.chmod(SESSION_FILE, 0o600)
    logger.debug(f"SESSION_FILE created with permissions: {oct(os.stat(SESSION_FILE).st_mode)[-3:]}")

def read_session_file():
    if os.path.exists(SESSION_FILE):
        with open(SESSION_FILE, 'r') as f:
            return json.load(f)
    return None

def reconnect_session():
    session_data = read_session_file()
    if session_data:
        try:
            options = Options()
            options.add_argument(f"debuggerAddress={session_data['debugger_address']}")
            driver = webdriver.Chrome(options=options)
            driver.session_id = session_data['session_id']
            return driver
        except WebDriverException:
            logger.error("Failed to reconnect to existing session")
    return create_new_driver()

def get_driver():
    global driver
    if driver is None:
        driver = reconnect_session()
    elif not is_session_valid(driver):
        driver = reconnect_session()
    return driver

def create_new_driver():
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("window-size=1200,800")
    driver = webdriver.Chrome(options=options)
    session_data = {
        'debugger_address': driver.capabilities['goog:chromeOptions']['debuggerAddress'],
        'session_id': driver.session_id
    }
    create_session_file(session_data)
    return driver

def initialize_browser():
    global driver
    if os.path.exists(SESSION_FILE):
        os.remove(SESSION_FILE)
    driver = create_new_driver()
    print("Browser initialized")

def navigate_to_url(url):
    driver = get_driver()
    try:
        logger.debug(f"Navigating to URL: {url}")
        driver.get(url)
    except WebDriverException as e:
        logger.error(f"WebDriver exception: {str(e)}")
        driver = create_new_driver()
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
            
            location = element.location
            logger.debug(f"Element found at location: {location}")
            return location['x'] + offset_x + 14, location['y'] + offset_y + 38
        except TimeoutException:
            logger.warning(f"Timeout on attempt {attempt + 1}")
            if attempt == max_retries - 1:
                raise

def close_browser():
    global driver
    if driver:
        driver.quit()
    if os.path.exists(SESSION_FILE):
        os.remove(SESSION_FILE)
    driver = None
    print("Browser closed and session file removed")

if __name__ == "__main__":
    logger.info(f"Script called with arguments: {sys.argv}")

    if len(sys.argv) < 2:
        print("Usage: python find_element.py <command> [args...]")
        print("Commands: init, navigate, find, close")
        sys.exit(1)

    command = sys.argv[1]
    logger.info(f"Command: {command}")

    if command == "init":
        logger.info("Initializing browser")
        initialize_browser()
    elif command == "navigate":
        if len(sys.argv) < 3:
            print("Usage: python find_element.py navigate <url>")
            sys.exit(1)
        url = sys.argv[2]
        logger.info(f"Navigating to URL: {url}")
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
        logger.info(f"Finding element: type={identifier_type}, identifier={identifier}, offset_x={offset_x}, offset_y={offset_y}")
        try:
            x, y = find_element_coordinates(identifier, identifier_type, offset_x, offset_y)
            print(f"{x},{y}")
        except Exception as e:
            logger.error(f"An error occurred: {str(e)}")
            sys.exit(1)
    elif command == "close":
        logger.info("Closing browser")
        close_browser()
        print("Browser closed")
    else:
        logger.warning(f"Unknown command: {command}")
        print(f"Unknown command: {command}")
        sys.exit(1)