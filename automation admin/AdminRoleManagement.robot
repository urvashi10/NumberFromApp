*** Settings ***
Resource         resource.robot

Suite Setup      Run Keywords    Login Once As Admin    Navigate To Admin Role Management
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot
Suite Teardown   Safe Close Browser

*** Variables ***
${SEARCH_INPUT}      css:input[placeholder="Search By User Name"]
${ROLE_DROPDOWN}     css:select.select-search:nth-of-type(1)
${STATUS_DROPDOWN}   css:select.select-search:nth-of-type(2)
${TABLE_BODY}        css:table.table tbody
${TABLE_ROWS}        css:table.table tbody tr
${PAGINATION}        css:ul.pagination

*** Keywords ***
Navigate To Admin Role Management
    Go To    http://18.134.97.4/admin/role-management
    Wait Until Page Contains    Admin Role Management    timeout=15s

*** Test Cases ***

# ... (Previous TC-01 to TC-06 remain here) ...

TC-07: Search Negative Case - No Results Found
    [Documentation]    Search for a non-existent user and verify the table is empty.
    [Tags]             Negative
    Input Text      ${SEARCH_INPUT}    NonExistentUser_999
    Sleep           2s

    # 1. Verify the specific user data from HTML is no longer visible
    Page Should Not Contain    admin123@yopmail.com

    # 2. Check if the table body is empty or shows a 'No Data' message
    # Depending on your frontend, it will either have 0 rows or 1 row with a message
    ${row_count}=    Get Element Count    ${TABLE_ROWS}
    Run Keyword If    ${row_count} > 0    Element Should Not Contain    ${TABLE_ROWS}    admin123@yopmail.com

    Log To Console    Search returned ${row_count} rows for non-existent user.

TC-08: Filter Negative Case - No Matching Role and Status
    [Documentation]    Apply conflicting filters (e.g., Inactive + Sub Admin) to see if UI handles empty results.
    [Tags]             Negative
    # Select Sub Admin
    Select From List By Label    ${ROLE_DROPDOWN}      Sub Admin
    # Select Inactive (Value 0)
    Select From List By Label    ${STATUS_DROPDOWN}    Inactive
    Sleep           2s

    # Check if the "Active" badges disappear
    Page Should Not Contain Element    css:span.success-badge

    # Verify pagination is disabled or hidden when no results are found
    ${pagination_status}=    Run Keyword And Return Status    Element Should Be Visible    ${PAGINATION}
    IF    ${pagination_status}
        Element Should Has Class    ${PAGINATION}    disabled    # If the app adds a 'disabled' class
    END

TC-09: Search Integrity - Character Sensitivity
    [Documentation]    Verify that searching with special characters does not crash the UI.
    [Tags]             Negative
    Input Text      ${SEARCH_INPUT}    !@#$%^&*()
    Sleep           1s
    # Verify the page is still responsive and header is visible
    Element Should Be Visible    css:h5.ps-3

    # Clear to reset UI for next runs
    Clear Element Text    ${SEARCH_INPUT}
    Press Keys            ${SEARCH_INPUT}    ENTER