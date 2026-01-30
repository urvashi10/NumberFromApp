#!/usr/bin/env python
"""Setup Chrome driver and run Robot Framework tests"""

import chromedriver_autoinstaller

# Install chromedriver
chromedriver_autoinstaller.install()
print("ChromeDriver installed successfully!")
