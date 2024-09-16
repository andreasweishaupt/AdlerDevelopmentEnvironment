from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
import time

def wait_and_click(driver, locator, timeout=10):
    print(f"Waiting to click element: {locator}")
    try:
        element = WebDriverWait(driver, timeout).until(
            EC.element_to_be_clickable(locator)
        )
        element.click()
        print(f"Clicked element: {locator}")
    except Exception as e:
        print(f"Failed to click element: {locator}. Error: {str(e)}")
        raise

def wait_and_type(driver, locator, text, timeout=10):
    print(f"Waiting to type '{text}' into element: {locator}")
    try:
        element = WebDriverWait(driver, timeout).until(
            EC.element_to_be_clickable(locator)
        )
        element.send_keys(text)
        element.send_keys(Keys.RETURN)
        print(f"Typed '{text}' into element: {locator}")
    except Exception as e:
        print(f"Failed to type into element: {locator}. Error: {str(e)}")
        raise

def run_automation_steps():
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    
    print("Starting Chrome WebDriver")
    driver = webdriver.Chrome(options=options)
    
    try:
        WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )
        print("Body found")

        # Navigate to the authoring tool - MyLearningWorldsOverview
        print("Navigating to the authoring tool - MyLearningWorldsOverview")
        driver.get("http://localhost:8001/MyLearningWorldsOverview")
        print(f"Current URL: {driver.current_url}")
        
        # Click on create-world-button
        print("Attempting to click create-world-button")
        wait_and_click(driver, (By.CLASS_NAME, "create-world-button"))
        wait_and_type(driver, (By.XPATH, "//input"), "testWorld")
        
        # Navigate to the authoring tool - app
        print("Navigating to the authoring tool -app")
        driver.get("http://localhost:8001/app")
        print(f"Current URL: {driver.current_url}")
        
        # Click on space-metadata-icon
        print("Attempting to click space-metadata-icon")
        wait_and_click(driver, (By.XPATH, "//img[contains(@src, 'space-metadata-icon.png')]"))
        wait_and_type(driver, (By.XPATH, "//input"), "testSpace")
        
        # Click on adaptivityelement-icon
        print("Attempting to click adaptivityelement-icon")
        wait_and_click(driver, (By.XPATH, "//img[contains(@src, 'adaptivityelement-icon.png')]"))
        wait_and_type(driver, (By.XPATH, "//input"), "testElement")
        
        # Click on add-tasks
        print("Attempting to click add-tasks")
        wait_and_click(driver, (By.CLASS_NAME, "add-tasks"))
        
        # Click on Neue Aufgabe erstellen
        print("Attempting to click 'Aufgabe erstellen' button")
        wait_and_click(driver, (By.XPATH, "//button[@title='Aufgabe erstellen']"))
        
        # Click on mud-button-close
        print("Attempting to click mud-button-close")
        wait_and_click(driver, (By.CLASS_NAME, "mud-button-close"))
        wait_and_type(driver, (By.XPATH, "//input"), "testWorld")
        
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