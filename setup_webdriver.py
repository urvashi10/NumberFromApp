#!/usr/bin/env python
"""Setup WebDriver for Robot Framework tests"""

import os
import sys

try:
    from webdriver_manager.chrome import ChromeDriverManager
    from selenium.webdriver.chrome.service import Service

    # Download and install ChromeDriver
    driver_path = ChromeDriverManager().install()
    print(f"ChromeDriver installed at: {driver_path}")

    # Set environment variable for SeleniumLibrary
    os.environ['PATH'] = os.path.dirname(driver_path) + os.pathsep + os.environ.get('PATH', '')
    print(f"PATH updated with: {os.path.dirname(driver_path)}")

except Exception as e:
    print(f"Error setting up WebDriver: {e}", file=sys.stderr)
    sys.exit(1)
