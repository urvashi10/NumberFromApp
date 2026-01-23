*** Settings ***
Library          SeleniumLibrary
Suite Setup      I Log Into The System
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

*** Keywords ***
I Log Into The System
    Open Browser                  ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Input Text                       ${EMAIL_FIELD}    ${USER_NAME}
    Input Password                   ${PASSWORD_FIELD}    ${PASSWORD}
    Click Button                     ${LOGIN_BUTTON}
    Wait Until Location Contains     /agent-dashboard    timeout=10s

Safe Suite Teardown
    Sleep    1.5s
    Run Keyword And Ignore Error    Close All Browsers