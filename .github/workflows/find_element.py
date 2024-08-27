import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def find_element_coordinates(class_name, path=None, offset_x=0, offset_y=0):
    max_retries=3
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")

    service = Service('/usr/bin/chromedriver')
    driver = webdriver.Chrome(service=service, options=chrome_options)

    try:
        url = "http://localhost:8001/app" if path is None else f"http://localhost:8001/{path}"
        driver.get(url)
        
        for attempt in range(max_retries):
            try:
                # Wait for the element to be present and visible
                element = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.CLASS_NAME, class_name))
                )
                
                # Get element location
                location = element.location
                return location['x'] + offset_x, location['y'] + offset_y
            except StaleElementReferenceException:
                if attempt < max_retries - 1:
                    time.sleep(1)  # Wait a bit before retrying
                    continue
                else:
                    raise  # Re-raise the exception if we've exhausted our retries
    finally:
        driver.quit()

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 5:
        print("Usage: python find_element.py <class_name> [path] [offset_x] [offset_y]")
        sys.exit(1)
    
    class_name = sys.argv[1]
    path = sys.argv[2] if len(sys.argv) > 2 else None
    offset_x = int(sys.argv[3]) if len(sys.argv) > 3 and sys.argv[3] else 360
    offset_y = int(sys.argv[4]) if len(sys.argv) > 4 and sys.argv[4] else 140
    
    x, y = find_element_coordinates(class_name, path, offset_x, offset_y)
    print(f"{x},{y}")
