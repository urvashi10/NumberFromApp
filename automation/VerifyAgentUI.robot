*** Settings ***
Library          SeleniumLibrary

Suite Setup      Login Once As Agent
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot
Suite Teardown   Close All Browsers

*** Variables ***
${URL}                 http://18.134.97.4/
${ADMIN_EMAIL}         testuser22@yopmail.com
${ADMIN_PASS}          Test@1234

# UI Locators
${TITLE_BILLING}       xpath://h5[text()='Billing and Compensation']
${SECTION_DEVICES}     xpath://div[text()='My Devices']
${SECTION_NOTIF}       xpath://div[text()='Notification']
${SECTION_CALLS}       xpath://div[text()='Recent Call Logs']
${KPI_PANELS}          css:.panel.kpi
${DEVICE_ITEMS}        css:.device-item

*** Test Cases ***
TC-01: Verify Page Layout and Main Header
    [Documentation]        Verifies the main heading exists and has correct weight.
    Wait Until Element Is Visible        ${TITLE_BILLING}    timeout=15s
    ${style}=    Get Element Attribute        ${TITLE_BILLING}    style
    Should Contain        ${style}    font-weight: 700

TC-02: Verify KPI Section UI
    [Documentation]    Ensures exactly 4 KPI panels are displayed.
    ${count}=    Get Element Count    ${KPI_PANELS}
    Should Be Equal As Integers    ${count}    4
    Page Should Contain    Devices Online
    Page Should Contain    Total Earnings

TC-03: Verify My Devices UI and Badges
    [Documentation]    Verifies device list and status badge rendering.
    Element Should Be Visible    ${SECTION_DEVICES}
    # Verify specific badge types exist in the UI
    Page Should Contain Element    css:.badge.assigned-badge
    Page Should Contain Element    css:.badge.success-badge
    Page Should Contain Element    css:.badge.faulty-badge

TC-04: Verify Notification and Call Logs
    [Documentation]        Checks for the warning alert and call log table rows.
    Element Should Be Visible        ${SECTION_NOTIF}
    Page Should Contain          ⚠️
    # Verify there are 5 call log entries as per the HTML
    ${rows}=    Get Element Count    css:.call-row
    Should Be Equal As Integers    ${rows}    5

*** Keywords ***
Login Once As Agent
    [Documentation]    The critical setup keyword.
    ...    Ensure there are 4 SPACES before each command below.
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    ${prefs}=    Create Dictionary
    ...    credentials_enable_service=${False}
    ...    profile.password_manager_enabled=${False}
    ...    password_manager_leak_detection=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}

    Open Browser    ${URL}    chrome    options=${options}
    Maximize Browser Window
    Set Selenium Speed    0.1 seconds

    Wait Until Element Is Visible    css:input[type='email']    timeout=15s
    Input Text       css:input[type='email']       ${ADMIN_EMAIL}
    Input Password   css:input[type='password']    ${ADMIN_PASS}
    Click Button     css:button[type='submit']
    Wait Until Page Contains    Billing and Compensation    timeout=15s