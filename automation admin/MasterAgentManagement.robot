    Click Link    xpath://a[contains(text(), 'Master Agent Management')]
    Wait Until Page Contains    Master Agent Management    timeout=15s
*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}          https://your-dashboard-url.com
${BROWSER}      headlesschrome

*** Test Cases ***
Verify Dashboard Load
    [Documentation]    Test to verify the Dashboard Agent loads correctly.
    Setup Headless Browser
    Page Should Contain    Dashboard
    [Teardown]    Close Browser

*** Keywords ***
Setup Headless Browser
    # Using 'headlesschrome' is the shortcut for CI/CD environments
    Open Browser    ${URL}    ${BROWSER}
    Set Window Size    1920    1080
    Maximize Browser Window