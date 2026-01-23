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

    Clear Element Text    ${SEARCH_INPUT}
    Sleep           1s

    Select From List By Label    ${STATUS_DROPDOWN}    Inactive
    Sleep           1s