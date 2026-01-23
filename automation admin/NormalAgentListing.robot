*** Settings ***
Resource         resource.robot

Suite Setup      Run Keywords    Login Once As Admin    Navigate To Normal Agent Management
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot
Suite Teardown   Safe Close Browser

*** Variables ***
${SEARCH_INPUT}      css:input[placeholder="Search By User Name"]
${STATUS_DROPDOWN}   css:select.select-search
${TABLE_ROWS}        css:table.table tbody tr
${SUCCESS_BADGE}     css:span.success-badge
${DANGER_BADGE}      css:span.bg-danger-subtle
${VIEW_ICON}         css:i.bi-eye

*** Keywords ***
Navigate To Normal Agent Management
    [Documentation]    Navigates to the Normal Agent screen.
    # Adjust the URL path below if it differs in your environment
    Go To    http://18.134.97.4/admin/normal-agent
    Wait Until Page Contains    Normal Agent Management    timeout=15s

*** Test Cases ***

TC-01: UI Verification - Header and Table Structure
    [Documentation]    Verify page header and that the table contains correct columns.
    Element Text Should Be          css:h5.ps-3    Normal Agent Management
    Page Should Contain Element     ${SEARCH_INPUT}
    Page Should Contain Element     ${STATUS_DROPDOWN}

    # Verify Table Headers based on OuterHTML
    @{headers}=    Create List    Agent    Status    Devices    Minutes    Type    Actions
    FOR    ${header}    IN    @{headers}
        Table Header Should Contain    css:table.table    ${header}
    END

TC-02: Search Functionality - By User Name
    [Documentation]    Search for a specific user and verify results.
    Input Text      ${SEARCH_INPUT}    testuser user
    Sleep           1s
    # Verify the specific email for this user appears in the first row
    Element Should Contain    ${TABLE_ROWS}    testuser22@yopmail.com

    # Clear search
    Clear Element Text    ${SEARCH_INPUT}
    Press Keys            ${SEARCH_INPUT}    ENTER

TC-03: Filter Functionality - Active Status
    [Documentation]    Select 'Active' from dropdown and verify visible badges.
    Select From List By Label    ${STATUS_DROPDOWN}    Active
    Sleep           1s
    # Verify the first row shows an Active badge
    Element Should Contain       xpath:(//tr/td[2])[1]    Active
    # Ensure no Inactive badges are visible
    Page Should Not Contain Element    ${DANGER_BADGE}

TC-04: Filter Functionality - Inactive Status
    [Documentation]    Select 'Inactive' from dropdown and verify visible badges.
    Select From List By Label    ${STATUS_DROPDOWN}    Inactive
    Sleep           1s
    # Verify the Inactive badge appears (test user 123 or vvv)
    Element Should Contain       xpath:(//tr/td[2])[1]    Inactive
    # Ensure no Success (Active) badges are visible
    Page Should Not Contain Element    ${SUCCESS_BADGE}

    # Reset filter to All Status
    Select From List By Value    ${STATUS_DROPDOWN}    ${EMPTY}

TC-05: UI Verification - Action Items
    [Documentation]    Verify that Normal Agents only have the 'View' action icon.
    Wait Until Element Is Visible    ${VIEW_ICON}    timeout=5s
    # Check first row's action column
    Page Should Contain Element      ${VIEW_ICON}
    # Verify that Edit/Delete icons (pencil/trash) are NOT present for Normal Agents
    Page Should Not Contain Element  css:i.bi-pencil-square
    Page Should Not Contain Element  css:i.bi-trash

TC-06: Verify Specific Data Entry
    [Documentation]    Check device count for 'normal agent' (agent123@yopmail.com).
    Input Text      ${SEARCH_INPUT}    agent123@yopmail.com
    Sleep           1s
    # In your HTML, normal agent has 4 devices
    Element Should Contain    xpath://tr[contains(.,'agent123@yopmail.com')]/td[3]    4