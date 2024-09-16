from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
import time

def wait_and_click(driver, locator, timeout=10):
    element = WebDriverWait(driver, timeout).until(
        EC.element_to_be_clickable(locator)
    )
    element.click()

def wait_and_type(driver, locator, text, timeout=10):
    element = WebDriverWait(driver, timeout).until(
        EC.element_to_be_clickable(locator)
    )
    element.send_keys(text)
    element.send_keys(Keys.RETURN)

def automate_authoring_tool():
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    
    driver = webdriver.Chrome(options=options)
    
    try:
        # Navigate to the authoring tool
        driver.get("http://localhost:8001/app")
        
        # Click on create-world-button
        wait_and_click(driver, (By.CLASS_NAME, "create-world-button"))
        wait_and_type(driver, (By.XPATH, "//input"), "testWorld")
        
        # Click on space-metadata-icon
        wait_and_click(driver, (By.XPATH, "//img[contains(@src, 'space-metadata-icon.png')]"))
        wait_and_type(driver, (By.XPATH, "//input"), "testSpace")
        
        # Click on adaptivityelement-icon
        wait_and_click(driver, (By.XPATH, "//img[contains(@src, 'adaptivityelement-icon.png')]"))
        wait_and_type(driver, (By.XPATH, "//input"), "testElement")
        
        # Click on add-tasks
        wait_and_click(driver, (By.CLASS_NAME, "add-tasks"))
        
        # Click on Neue Aufgabe erstellen
        wait_and_click(driver, (By.XPATH, "//button[@title='Aufgabe erstellen']"))
        
        # Click on mud-button-close
        wait_and_click(driver, (By.CLASS_NAME, "mud-button-close"))
        wait_and_type(driver, (By.XPATH, "//input"), "testWorld")
        
        print("Automation completed successfully!")
        
    except Exception as e:
        print(f"An error occurred: {str(e)}")
    
    finally:
        driver.quit()

if __name__ == "__main__":
    automate_authoring_tool()