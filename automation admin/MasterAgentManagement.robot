*** Settings ***
Resource         resource.robot

Suite Setup      Run Keywords    Login Once As Admin    Navigate To Master Agent Management
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot
Suite Teardown   Safe Close Browser

*** Variables ***
${SEARCH_INPUT}      css:input[placeholder="Search By User Name"]
${STATUS_DROPDOWN}   css:select.select-search
${ADD_AGENT_BTN}     css:button.blue-btn
${TABLE_ROWS}        css:table.table tbody tr
${SUCCESS_BADGE}     css:span.success-badge

*** Keywords ***
Navigate To Master Agent Management
    [Documentation]    Navigates to the Master Agent screen from the dashboard.
    # Replace with the actual sidebar link or Go To URL
    Go To    http://18.134.97.4/admin/master-agent
    Wait Until Page Contains    Master Agent Management    timeout=15s

*** Test Cases ***

TC-01: UI Verification - Elements and Table Headers
    [Documentation]    Verify headers, buttons, and table structure.
    Element Text Should Be          css:h5.ps-3    Master Agent Management
    Page Should Contain Element     ${ADD_AGENT_BTN}
    Page Should Contain Element     ${SEARCH_INPUT}

    # Verify Table Headers
    @{expected_headers}=    Create List    Agent    Status    Devices    Minutes    Type    Actions
    FOR    ${header}    IN    @{expected_headers}
        Page Should Contain    ${header}
    END

TC-02: Search Functionality - By User Name
    [Documentation]    Verify searching for a unique agent filters the list.
    Input Text      ${SEARCH_INPUT}    Automation User
    Sleep           1s    # Allow table to filter
    Element Should Contain    ${TABLE_ROWS}    auto_test_unique@yopmail.com
    # Verify only the searched user is visible (or at least present)
    Page Should Not Contain    test_5334@yopmail.com

    # Reset Search
    Clear Element Text    ${SEARCH_INPUT}
    Press Keys            ${SEARCH_INPUT}    ENTER

TC-03: Filter Functionality - Active Status
    [Documentation]    Verify the status dropdown for 'Active'.
    Select From List By Label    ${STATUS_DROPDOWN}    Active
    Sleep           1s
    # Verify that visible badges are 'Active'
    Element Text Should Be       xpath:(//span[contains(@class,'success-badge')])[1]    Active

TC-04: Filter Functionality - Inactive Status
    [Documentation]    Verify the status dropdown for 'Inactive'.
    Select From List By Label    ${STATUS_DROPDOWN}    Inactive
    Sleep           1s
    # If no inactive agents exist, verify empty state or count
    # This assumes we are checking for the absence of success-badges if all are inactive
    ${count}=    Get Element Count    ${SUCCESS_BADGE}
    Log To Console    Found ${count} active agents after filtering for Inactive.

    # Reset Filter
    Select From List By Value    ${STATUS_DROPDOWN}    ${EMPTY}

TC-05: UI Verification - Action Icons Presence
    [Documentation]    Verify the eye, pencil, trash, and phone icons in the first row.
    Page Should Contain Element    css:i.bi-eye
    Page Should Contain Element    css:i.bi-pencil-square
    Page Should Contain Element    css:i.bi-trash
    Page Should Contain Element    css:i.bi-phone