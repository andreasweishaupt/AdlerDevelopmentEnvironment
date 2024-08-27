import sys
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def find_element_coordinates(class_name, path=None):
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")

    service = Service('/usr/local/bin/chromedriver')
    driver = webdriver.Chrome(service=service, options=chrome_options)

    try:
        # Set the URL based on the optional path parameter
        url = "http://localhost:8001/app" if path is None else f"http://localhost:8001/{path}"
        driver.get(url)
        
        element = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CLASS_NAME, class_name))
        )
        
        location = element.location
        return location['x'], location['y']
    finally:
        driver.quit()

if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python find_element.py <class_name> [path]")
        sys.exit(1)
    
    class_name = sys.argv[1]
    path = sys.argv[2] if len(sys.argv) == 3 else None
    
    x, y = find_element_coordinates(class_name, path)
    print(f"{x},{y}")
