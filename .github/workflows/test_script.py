import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import WebDriverException, TimeoutException

def get_driver():
    print("get_driver")
    service = Service('/usr/bin/chromedriver')
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("window-size=1200,800")
    options.add_argument("--remote-debugging-port=9222")
    driver = webdriver.Chrome(service=service, options=options)
    print("get_driver finish")
    return driver
    
def find_element_coordinates(identifier, identifier_type):
    driver = get_driver()
    max_retries = 3
    for attempt in range(max_retries):
        try:
            print(f"Attempt {attempt + 1} to find element with {identifier_type}: {identifier}")
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
            location = element.location
            size = element.size
            center_x = int(location['x'] + size['width'] / 2)
            center_y = int(location['y'] + size['height'] / 2)
            print(f"Element {element} found. Center at: ({center_x}, {center_y})")
            return center_x, center_y
        except TimeoutException:
            print(f"Timeout on attempt {attempt + 1}")
            if attempt == max_retries - 1:
                raise


if __name__ == "__main__":
    print("Called test_script.py")
    print(f"Script called with arguments: {sys.argv}")
    if len(sys.argv) < 2:
        print("Usage: python test_script.py <command> [args...]")
        print("Commands: find")
        sys.exit(1)

    command = sys.argv[1]
    print(f"Command: {command}")
    
    if command == "find":
        if len(sys.argv) < 4:
            print("Usage: python find_element.py find <identifier_type> <identifier>")
            sys.exit(1)
        identifier_type = sys.argv[2]
        identifier = sys.argv[3]
        print(f"Finding element: type={identifier_type}, identifier={identifier}")
        try:
            x, y = find_element_coordinates(identifier, identifier_type)
            x += 360
            y += 140 + 18
            print(f"{x},{y}", flush=True)
        except Exception as e:
            print(f"An error occurred: {str(e)}")
            sys.exit(1)