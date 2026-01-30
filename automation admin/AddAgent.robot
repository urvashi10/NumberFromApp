*** Settings ***
Library          SeleniumLibrary
Library          Collections
Library          String
Suite Setup      Login and Navigate to Dashboard
Suite Teardown   Close All Browsers

*** Variables ***
${URL}                  http://18.134.97.4/admin
${BROWSER}              Chrome
${USER_EMAIL}           Admin123@yopmail.com
${USER_PASS}            Admin@12345

# --- Locators ---
${LOGIN_EMAIL_FIELD}    xpath://input[@type='email' or @name='email']
${LOGIN_PASS_FIELD}     xpath://input[@type='password']
${LOGIN_SUBMIT_BTN}     xpath://button[@type='submit']
${MASTER_AGENT_TAB}     xpath://*[@id="root"]/div/aside/ul/li[2]/a

# Management Page Components
${SEARCH_INPUT}         css:input.form-control[placeholder='Search By User Name']
${TABLE}                css:table.table

# Add Agent Modal Locators
${ADD_AGENT_BTN}        xpath://button[@data-bs-target='#addAgentModal']
${INPUT_FULL_NAME}      xpath://label[contains(text(), 'Full Name')]/following-sibling::input
${INPUT_EMAIL}          xpath://label[contains(text(), 'Email Address')]/following-sibling::input
${INPUT_PASSWORD}       xpath://label[contains(text(), 'Password')]/following-sibling::input
${SELECT_COUNTRY}       xpath://label[contains(text(), 'Country')]/following-sibling::select
${SELECT_STATE}         xpath://label[contains(text(), 'State')]/following-sibling::select
${CREATE_AGENT_BTN}     xpath://button[contains(text(), 'Create Agent')]
${ERROR_TEXT}           xpath://div[contains(@class, 'invalid-feedback')] | //div[contains(@class, 'text-danger')]

*** Keywords ***
Login and Navigate to Dashboard
    [Documentation]    Configures Chrome to bypass 'Compromised Password' alerts and logs in.
    # Setup WebDriver using webdriver-manager
    ${driver_path}=    Evaluate    __import__('webdriver_manager.chrome', fromlist=['ChromeDriverManager']).ChromeDriverManager().install()
    ${service}=    Evaluate    __import__('selenium.webdriver.chrome.service', fromlist=['Service']).Service(r'${driver_path}')
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}=    Create Dictionary
    ...    credentials_enable_service=${False}
    ...    password_manager_enabled=${False}
    ...    profile.password_manager_leak_detection=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-notifications
    Call Method    ${options}    add_argument    --disable-gpu

    Open Browser    ${URL}    ${BROWSER}    options=${options}    service=${service}
    Maximize Browser Window
    Set Selenium Implicit Wait    10s

    Input Text       ${LOGIN_EMAIL_FIELD}    ${USER_EMAIL}
    Input Password   ${LOGIN_PASS_FIELD}     ${USER_PASS}
    Click Element    ${LOGIN_SUBMIT_BTN}
    Wait Until Page Contains    Dashboard    timeout=15s

Clear Search Field
    Clear Element Text    ${SEARCH_INPUT}
    Press Keys            ${SEARCH_INPUT}    RETURN
    Sleep                 1s

*** Test Cases ***

TC01: Navigate to Master Agent Management
    [Documentation]    Uses the specific sidebar XPath to reach the management screen.
    Wait Until Element Is Visible    ${MASTER_AGENT_TAB}
    Click Element                    ${MASTER_AGENT_TAB}
    Wait Until Page Contains         Master Agent Management
    Element Should Be Visible        ${SEARCH_INPUT}

TC02: Add New Agent and Verify
    [Documentation]    Generates alphabetic-only name, fills modal, and verifies record creation.
    Wait Until Element Is Visible    ${ADD_AGENT_BTN}
    Click Element                    ${ADD_AGENT_BTN}

    Wait Until Element Is Visible    ${INPUT_FULL_NAME}    timeout=5s

    # Generate unique ALPHABETIC data (No digits) for the name
    ${random_letters}=    Generate Random String    8    [LETTERS]
    ${random_num}=        Generate Random String    4    [NUMBERS]
    ${AGENT_NAME}=        Set Variable    RobotAgent${random_letters}
    ${AGENT_EMAIL}=       Set Variable    test_${random_num}@yopmail.com

    Input Text      ${INPUT_FULL_NAME}    ${AGENT_NAME}
    Input Text      ${INPUT_EMAIL}        ${AGENT_EMAIL}
    # Using strong password with mixed chars to avoid validation rejection
    Input Password  ${INPUT_PASSWORD}     Admin@12345678

    # Wait for Country to be populated (Wait until it contains actual data like 'India')
    Wait Until Element Contains    ${SELECT_COUNTRY}    India    timeout=10s
    Select From List By Index      ${SELECT_COUNTRY}    1

    # Wait for State to refresh based on Country
    Sleep           3s
    Select From List By Index      ${SELECT_STATE}      1

    # Attempt Submission via JavaScript click for better stability
    Execute JavaScript    document.evaluate("//button[contains(text(), 'Create Agent')]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.click();

    # Safety Check: If modal stays open, capture error message
    ${modal_closed}=    Run Keyword And Return Status    Wait Until Element Is Not Visible    ${CREATE_AGENT_BTN}    timeout=15s
    IF    not ${modal_closed}
        ${err}=    Run Keyword And Ignore Error    Get Text    ${ERROR_TEXT}
        Log To Console    \n[MODAL ERROR]: ${err}
        Fail    Create Agent modal did not close. Validation Error: ${err}
    END

    # Verification: Search for the new record
    Clear Search Field
    Input Text      ${SEARCH_INPUT}    ${AGENT_NAME}
    Press Keys      ${SEARCH_INPUT}    RETURN

    # Final check in the table
    Wait Until Element Contains    ${TABLE}    ${AGENT_NAME}    timeout=10s
    Element Should Contain         ${TABLE}    ${AGENT_EMAIL}