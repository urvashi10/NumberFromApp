*** Settings ***
Library          SeleniumLibrary

*** Keywords ***
Login Once As Agent
    [Documentation]    Configures browser and logs in as an Agent.
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}=    Create Dictionary
    ...    credentials_enable_service=${False}
    ...    profile.password_manager_enabled=${False}
    ...    password_manager_leak_detection=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}

    # Open browser with specific options
    Open Browser    http://18.134.97.4/    chrome    options=${options}
    Maximize Browser Window
    Set Selenium Speed    0.1 seconds

    Wait Until Element Is Visible    css:input[type='email']    timeout=15s
    Input Text       css:input[type='email']       testuser22@yopmail.com
    Input Password   css:input[type='password']    Test@1234
    Click Button     css:button[type='submit']

    # Wait for the Agent Dashboard Header to confirm login
    Wait Until Page Contains    Billing and Compensation    timeout=15s