from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
import time

def find_element(driver, identifier, identifier_type, timeout=10):
    print(f"Attempting to find element with {identifier_type}: {identifier}")
    try:
        if identifier_type == "class":
            element = WebDriverWait(driver, timeout).until(
                EC.visibility_of_element_located((By.CLASS_NAME, identifier))
            )
        elif identifier_type == "src":
            element = WebDriverWait(driver, timeout).until(
                EC.visibility_of_element_located((By.XPATH, f"//img[contains(@src, '{identifier}')]"))
            )
        elif identifier_type == "identifier":
            element = WebDriverWait(driver, timeout).until(
                EC.visibility_of_element_located((By.XPATH, f"//*[contains(@identifier, '{identifier}')]"))
            )
        elif identifier_type == "title":
            element = WebDriverWait(driver, timeout).until(
                EC.visibility_of_element_located((By.XPATH, f"//*[contains(@title, '{identifier}')]"))
            )
        else:
            raise ValueError("Invalid identifier_type. Use 'class', 'src', 'identifier', or 'title'.")
        
        print(f"Found element: {identifier}")
        return element
    except Exception as e:
        print(f"Failed to find element: {identifier}. Error: {str(e)}")
        raise

def wait_and_click(driver, identifier, identifier_type, timeout=10):
    element = find_element(driver, identifier, identifier_type, timeout)
    element.click()
    print(f"Clicked element: {identifier}")

def wait_and_type(driver, identifier, identifier_type, text, timeout=10):
    element = find_element(driver, identifier, identifier_type, timeout)
    element.send_keys(text)
    element.send_keys(Keys.RETURN)
    print(f"Typed '{text}' into element: {identifier}")

def run_automation_steps():
    options = Options()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('window-size=1200,800')

    service = Service('/usr/bin/chromedriver')
    driver = webdriver.Chrome(service=service, options=options)

    try:
        print("Starting Chrome WebDriver")
        driver.get("http://localhost:8001/MyLearningWorldsOverview")
        print(f"Current URL: {driver.current_url}")

        # Click on create-world-button
        wait_and_click(driver, "create-world-button", "class")
        wait_and_type(driver, "//input", "xpath", "testWorld")

        # Navigate to the authoring tool - app
        driver.get("http://localhost:8001/app")
        print(f"Current URL: {driver.current_url}")

        # Click on space-metadata-icon
        wait_and_click(driver, "space-metadata-icon.png", "src")
        wait_and_type(driver, "//input", "xpath", "testSpace")

        # Click on adaptivityelement-icon
        wait_and_click(driver, "adaptivityelement-icon.png", "src")
        wait_and_type(driver, "//input", "xpath", "testElement")

        # Click on add-tasks
        wait_and_click(driver, "add-tasks", "class")

        # Click on Neue Aufgabe erstellen
        wait_and_click(driver, "Aufgabe erstellen", "title")

        # Click on mud-button-close
        wait_and_click(driver, "mud-button-close", "class")
        wait_and_type(driver, "//input", "xpath", "testWorld")

        print("Automation completed successfully!")

    except Exception as e:
        print(f"An error occurred: {str(e)}")
        print("Current page source:")
        print(driver.page_source)

    finally:
        print("Closing WebDriver")
        driver.quit()

if __name__ == "__main__":
    run_automation_steps()