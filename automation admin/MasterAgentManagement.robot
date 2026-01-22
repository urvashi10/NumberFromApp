*** Settings ***
Library          SeleniumLibrary
Suite Setup      Open Browser To Site
Suite Teardown   Close Browser
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot

*** Variables ***
${URL}                  http://18.134.97.4/admin
${BROWSER}              Chrome
${USER_EMAIL}           Admin123@yopmail.com
${USER_PASS}            Admin@12345

# --- Locators ---
${LOGIN_EMAIL_FIELD}    xpath://input[@type='email' or @name='email']
${LOGIN_PASS_FIELD}     xpath://input[@type='password']
${LOGIN_SUBMIT_BTN}     xpath://button[@type='submit']

# Sidebar Navigation
${MASTER_AGENT_TAB}     xpath://*[@id="root"]/div/aside/ul/li[2]/a

# Page Components
${SEARCH_INPUT}         css:input.form-control[placeholder='Search By User Name']
${STATUS_DROPDOWN}      css:select.select-search
${TABLE}                css:table.table

*** Keywords ***
Open Browser To Site
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}=    Create Dictionary
    ...    credentials_enable_service=${False}
    ...    password_manager_enabled=${False}
    ...    profile.password_manager_leak_detection=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${options}    add_argument    --disable-notifications
    Create Webdriver    Chrome    options=${options}
    Go To               ${URL}
    Maximize Browser Window
    Set Selenium Implicit Wait    10s

Clear Search And Reset Filter
    Clear Element Text    ${SEARCH_INPUT}
    Press Keys            ${SEARCH_INPUT}    RETURN
    Select From List By Label    ${STATUS_DROPDOWN}    All Status
    Sleep                 1s

*** Test Cases ***

TC01: Login and Navigate
    Input Text       ${LOGIN_EMAIL_FIELD}    ${USER_EMAIL}
    Input Password   ${LOGIN_PASS_FIELD}     ${USER_PASS}
    Click Element    ${LOGIN_SUBMIT_BTN}
    Wait Until Page Contains    Dashboard    timeout=15s
    Wait Until Element Is Visible    ${MASTER_AGENT_TAB}
    Click Element                    ${MASTER_AGENT_TAB}
    Wait Until Page Contains    Master Agent Management

TC02: Status Filter - Active
    [Setup]          Clear Search And Reset Filter
    Select From List By Label    ${STATUS_DROPDOWN}    Active
    Wait Until Element Contains    xpath://table/tbody/tr[1]/td[2]    Active    timeout=10s
    Element Should Contain         xpath://table/tbody/tr[1]/td[2]    Active

TC03: Status Filter - Inactive
    [Setup]          Clear Search And Reset Filter
    Select From List By Label    ${STATUS_DROPDOWN}    Inactive
    Sleep            2s
    ${table_text}=    Get Text    ${TABLE}
    Should Not Contain    ${table_text}    Active

TC04: Verify Table Headers and Row Data
    [Documentation]    Corrected FOR loop structure.
    [Setup]          Clear Search And Reset Filter
    @{expected_headers}=     Create List    Agent    Status    Devices    Minutes    Type    Actions

    # Corrected Loop Structure
    FOR    ${index}    ${header_text}    IN ENUMERATE    @{expected_headers}
        ${col_num}=    Evaluate    ${index} + 1
        Element Should Contain    xpath://table/thead/tr/th[${col_num}]    ${header_text}
    END

    # Value Validation for Row 1
    Element Should Contain    xpath://table/tbody/tr[1]/td[1]    test name
    Element Should Contain    xpath://table/tbody/tr[1]/td[1]    user123@yopmail.com
    Element Should Contain    xpath://table/tbody/tr[1]/td[5]    Master

TC05: Search Functionality - Positive and Negative
    # Positive
    Input Text       ${SEARCH_INPUT}    test name
    Press Keys       ${SEARCH_INPUT}    RETURN
    Wait Until Element Contains    ${TABLE}    user123@yopmail.com

    # Negative
    Input Text       ${SEARCH_INPUT}    NonExistentAgent999
    Press Keys       ${SEARCH_INPUT}    RETURN
    Sleep            1s
    Element Should Not Contain    ${TABLE}    test name