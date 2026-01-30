*** Settings ***
Library          SeleniumLibrary

*** Variables ***
${LOGIN_URL}      http://18.134.97.4/admin
${BROWSER}        chrome
${ADMIN_USER}     admin123@yopmail.com
${ADMIN_PASS}     Admin@12345

*** Keywords ***
Login Once As Admin
    [Documentation]    Logs into the admin panel and handles pop-ups.
    # Setup WebDriver using webdriver-manager
    ${driver_path}=    Evaluate    __import__('webdriver_manager.chrome', fromlist=['ChromeDriverManager']).ChromeDriverManager().install()
    ${service}=    Evaluate    __import__('selenium.webdriver.chrome.service', fromlist=['Service']).Service(r'${driver_path}')
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}=    Create Dictionary
    ...    credentials_enable_service=${False}
    ...    profile.password_manager_enabled=${False}
    ...    password_manager_leak_detection=${False}

    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-save-password-bubble
    # Helps prevent the browser from hanging on exit
    Call Method    ${options}    add_argument    --disable-gpu

    Open Browser    ${LOGIN_URL}    ${BROWSER}    options=${options}    service=${service}
    Maximize Browser Window
    Set Selenium Speed    0.2 seconds

    # Login Steps
    Wait Until Element Is Visible    css:input[type='email']    timeout=15s
    Input Text       css:input[type='email']       ${ADMIN_USER}
    Input Password   css:input[type='password']    ${ADMIN_PASS}
    Click Button     css:button[type='submit']

    # Handle Chrome password manager alerts
    Sleep    2s

    # Try to close the password change alert if it appears
    ${alert_present}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath://button[contains(text(), 'OK')]    timeout=5s
    Run Keyword If    ${alert_present}    Click Button    xpath://button[contains(text(), 'OK')]
    Sleep    1s

    # Dismiss any remaining pop-ups via Reload
    Reload Page
    Sleep    1s
    Press Keys       None    ESC
    Sleep    1s

    Wait Until Page Contains    Admin Dashboard    timeout=20s

Safe Close Browser
    [Documentation]    Closes the browser while trying to prevent the ProactorBasePipeTransport error.
    # Clearing cookies and closing slowly can sometimes prevent the asyncio pipe error
    Delete All Cookies
    Close Browser