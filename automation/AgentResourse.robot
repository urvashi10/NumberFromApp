*** Settings ***
Library          SeleniumLibrary

*** Keywords ***
Login Once As Agent
    [Documentation]    Configures browser and logs in as an Agent.
    # Setup WebDriver using webdriver-manager
    ${driver_path}=    Evaluate    __import__('webdriver_manager.chrome', fromlist=['ChromeDriverManager']).ChromeDriverManager().install()
    ${service}=    Evaluate    __import__('selenium.webdriver.chrome.service', fromlist=['Service']).Service(r'${driver_path}')
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}=    Create Dictionary
    ...    credentials_enable_service=${False}
    ...    profile.password_manager_enabled=${False}
    ...    password_manager_leak_detection=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-gpu

    # Open browser with specific options
    Open Browser    http://18.134.97.4/    chrome    options=${options}    service=${service}
    Maximize Browser Window
    Set Selenium Speed    0.1 seconds

    Wait Until Element Is Visible    css:input[type='email']    timeout=15s
    Input Text       css:input[type='email']       testuser22@yopmail.com
    Input Password   css:input[type='password']    Test@1234
    Click Button     css:button[type='submit']

    # Handle Chrome password manager alerts
    Sleep    2s

    # Try to close the password change alert if it appears
    ${alert_present}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://button[contains(text(), 'OK')]    timeout=5s
    Run Keyword If    ${alert_present}    Click Button    xpath://button[contains(text(), 'OK')]
    Sleep    1s

    # Additional pop-up dismissal
    Press Keys       None    ESC
    Sleep    1s

    # Wait for the Agent Dashboard Header to confirm login
    Wait Until Page Contains    Billing and Compensation    timeout=15s