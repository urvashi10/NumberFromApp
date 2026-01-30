*** Settings ***
Library          SeleniumLibrary

Suite Setup      Log    Starting test suite
Suite Teardown   Safe Suite Teardown

*** Variables ***
${URL}                  http://18.134.97.4/
${BROWSER}              chrome
${USER_NAME}            testuser22@yopmail.com
${PASSWORD}             Test@1234

# Locators
${EMAIL_FIELD}          css:input[type='email']
${PASSWORD_FIELD}       css:input[type='password']
${LOGIN_BUTTON}         css:button[type='submit']
${DASHBOARD_NAV_LINK}   xpath://a[@href='/agent-dashboard']

# Specific Header Locator (from your earlier OuterHTML)
${BILLING_COMP_HEADER}  css:h5.d-none.d-lg-block.ps-3

# New Section Locators (using text-based XPath for accuracy)
${MY_DEVICES_SEC}       xpath://*[contains(text(), 'My Devices')]
${RECENT_CALLS_SEC}     xpath://*[contains(text(), 'Recent Call Logs')]

*** Test Cases ***
TC-01: Successful Login
    [Documentation]    Verify user can log in.
    Initialize Chrome Driver And Login
    Wait Until Location Contains    /agent-dashboard    timeout=10s


TC-02: Dashboard Sidebar Highlight
    [Documentation]    Verify the Dashboard tab is highlighted on the left.
    ${classes}=    Get Element Attribute    ${DASHBOARD_NAV_LINK}    class
    Should Contain    ${classes}    active-link

TC-03: Verify Billing and Compensation Header
    [Documentation]    Verify the header text exactly matches the requirement.
    Wait Until Element Is Visible    ${BILLING_COMP_HEADER}    timeout=5s
    Element Text Should Be           ${BILLING_COMP_HEADER}    Billing and Compensation
    Log To Console    Verified: Header "Billing and Compensation" is correct.

TC-04: Verify Additional Dashboard Sections
    [Documentation]    Verify "My Devices" and "Recent Call Logs" sections are present.
    # Check "My Devices"
    Wait Until Element Is Visible    ${MY_DEVICES_SEC}    timeout=5s
    Element Should Be Visible        ${MY_DEVICES_SEC}

    # Check "Recent Call Logs"
    Wait Until Element Is Visible    ${RECENT_CALLS_SEC}    timeout=5s
    Element Should Be Visible        ${RECENT_CALLS_SEC}

    Log To Console    Verified: "My Devices" and "Recent Call Logs" sections are visible.
    Capture Page Screenshot          dashboard_sections.png

TC-05: Negative Login Shows Error
    [Documentation]    Verify that login with an invalid password does not redirect to the agent dashboard.
    Log To Console    Starting negative login test...

    # Setup WebDriver using webdriver-manager
    ${chrome_path}=    Evaluate    __import__('webdriver_manager.chrome').chrome.ChromeDriverManager().install()
    ${service}=    Evaluate    __import__('selenium.webdriver.chrome.service', fromlist=['Service']).Service(r'${chrome_path}')
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}=    Create Dictionary    credentials_enable_service=${False}    profile.password_manager_enabled=${False}    password_manager_leak_detection=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-gpu

    # Open a fresh browser instance for negative login test
    Open Browser    ${URL}    ${BROWSER}    options=${options}    service=${service}
    Maximize Browser Window

    # Wait for login form and attempt login with invalid credentials
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Input Text    ${EMAIL_FIELD}    ${USER_NAME}
    Input Password    ${PASSWORD_FIELD}    InvalidPass123
    Click Button    ${LOGIN_BUTTON}

    # Allow time for the response
    Sleep    2s

    # Verify that we are NOT redirected to the dashboard
    ${loc}=    Get Location
    Log To Console    Current location after failed login: ${loc}
    Should Not Contain    ${loc}    /agent-dashboard

    # Capture screenshot showing the error state
    Capture Page Screenshot    negative_login.png
    Log To Console    Negative login test passed - user stayed on login page

    Close Browser

*** Keywords ***
Initialize Chrome Driver And Login
    [Documentation]    Initialize ChromeDriver and perform login.
    Log To Console    Initializing Chrome Driver...

    # Auto-install chromedriver via webdriver-manager
    ${chrome_path}=    Evaluate    __import__('webdriver_manager.chrome').chrome.ChromeDriverManager().install()
    ${service}=    Evaluate    __import__('selenium.webdriver.chrome.service', fromlist=['Service']).Service(r'${chrome_path}')
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}=    Create Dictionary    credentials_enable_service=${False}    profile.password_manager_enabled=${False}    password_manager_leak_detection=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-gpu

    Log To Console    ChromeDriver initialized at: ${chrome_path}

    Open Browser    ${URL}    ${BROWSER}    options=${options}    service=${service}
    Maximize Browser Window
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Input Text                       ${EMAIL_FIELD}    ${USER_NAME}
    Input Password                   ${PASSWORD_FIELD}    ${PASSWORD}
    Click Button                     ${LOGIN_BUTTON}
    Wait Until Location Contains     /agent-dashboard    timeout=10s
    Log To Console    Login successful.


Safe Suite Teardown
    [Documentation]    Safe cleanup of browser resources.
    Sleep    1.5s
    Run Keyword And Ignore Error    Close All Browsers