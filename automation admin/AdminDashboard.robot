*** Settings ***
Resource         resource.robot

Suite Setup      Login Once As Admin
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot
# Use the new safe keyword here
Suite Teardown   Safe Close Browser

*** Test Cases ***
TC-01: Verify Successful Login and Dashboard Header
    [Documentation]    Verify the user has landed on the Dashboard.
    Element Text Should Be    css:h5.ps-3    Admin Dashboard

TC-02: Verify KPI Stats Presence
    [Documentation]    Verify that the data panels are rendered.
    Page Should Contain    Total Active Devices
    Page Should Contain    Active Agents