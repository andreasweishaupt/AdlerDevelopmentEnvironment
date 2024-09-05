import sys
import logging
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import StaleElementReferenceException
import time

# Set up logging
logging.basicConfig(level=logging.DEBUG, stream=sys.stderr, format='find_element.py - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def find_element_coordinates(class_name, path=None, offset_x=0, offset_y=0):
    max_retries = 3
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("window-size=1200,800")

    service = Service('/usr/bin/chromedriver')
    driver = webdriver.Chrome(service=service, options=chrome_options)

    try:
        url = "http://localhost:8001/app" if path is None else f"http://localhost:8001/{path}"
        logger.debug(f"Navigating to URL: {url}")
        driver.get(url)

        for attempt in range(max_retries):
            try:
                logger.debug(f"Attempt {attempt + 1} to find element with class name: {class_name}")
                element = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.CLASS_NAME, class_name))
                )
                time.sleep(0.5)
                location = element.location
                logger.debug(f"window_size: {driver.get_window_size()}")
                logger.debug(f"Element found at location: {location}")
                return location['x'] + offset_x + 14, location['y'] + offset_y + 38  # Add offset of 14x38
            except StaleElementReferenceException:
                logger.warning("Stale element reference exception encountered.")
                if attempt < max_retries - 1:
                    time.sleep(1)
                else:
                    raise
    finally:
        driver.quit()

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 5:
        print("Usage: python find_element.py <class_name> [path] [offset_x] [offset_y]")
        sys.exit(1)
    
    class_name = sys.argv[1]
    path = sys.argv[2] if len(sys.argv) > 2 else None
    offset_x = int(sys.argv[3]) if len(sys.argv) > 3 and sys.argv[3] else 0
    offset_y = int(sys.argv[4]) if len(sys.argv) > 4 and sys.argv[4] else 0
    
    x, y = find_element_coordinates(class_name, path, offset_x, offset_y)
    print(f"{x},{y},ClassName:{class_name},Path:{path},Offset_x:{offset_x},Offset_y:{offset_y}")
