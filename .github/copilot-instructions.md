# AI Coding Agent Instructions for RobotFrameworks Automation

## Project Overview
**Purpose**: Selenium-based UI automation using Robot Framework testing agent and admin dashboard functionality.

**Tech Stack**: Robot Framework + SeleniumLibrary + PyYAML + Python

**Key URLs**: 
- Agent Dashboard: `http://18.134.97.4/`
- Admin Dashboard: `http://18.134.97.4/admin`

## Project Structure

```
automation/           # Agent-facing automation tests
  ├─ AgentResourse.robot    # Reusable login keywords for agent users
  ├─ DashboardAgent.robot   # Agent dashboard verification tests
  └─ VerifyAgentUI.robot    # Agent UI validation

automation admin/     # Admin-facing automation tests  
  ├─ resource.robot         # Shared admin keywords and login setup
  ├─ AdminDashboard.robot   # Admin dashboard verification
  ├─ AddAgent.robot         # Agent creation/management workflows
  ├─ AdminRoleManagement.robot
  └─ MasterAgentManagement.robot
```

## Critical Developer Workflows

### Running Tests
```bash
# Run all tests in a directory
robot automation/

robot "automation admin/"

# Run specific test file
robot automation/DashboardAgent.robot

# Generate reports (outputs: log.html, report.html, output.xml)
```

### Debugging Browser Issues
1. **ProactorBasePipeTransport Errors**: Use `Safe Close Browser` keyword instead of `Close All Browsers` - properly handles cleanup in teardown
2. **Chrome Password Manager Pop-ups**: Both resource files disable password manager via ChromeOptions (`credentials_enable_service=False`, `password_manager_leak_detection=False`)
3. **Page Load Timing**: Use `Wait Until Location Contains` or `Wait Until Page Contains` with explicit timeouts (default 10-15s)

## Architecture & Key Patterns

### Login Architecture (Two Distinct Contexts)
- **Agent Users**: [AgentResourse.robot](automation/AgentResourse.robot) - `Login Once As Agent` keyword
  - Email: `testuser22@yopmail.com` / Password: `Test@1234`
  - Waits for "Billing and Compensation" header as login confirmation
  
- **Admin Users**: [resource.robot](automation%20admin/resource.robot) - `Login Once As Admin` keyword  
  - Email: `admin123@yopmail.com` / Password: `Admin@12345`
  - Includes reload + ESC key press to dismiss pop-ups
  - Uses `Safe Close Browser` for cleanup

### Test Structure Convention
Each test suite follows:
1. **Suite Setup**: Login keyword (handles browser configuration)
2. **Test Cases**: Business logic with clear TC-01 naming
3. **Test Teardown**: Capture screenshots on failure
4. **Suite Teardown**: Browser cleanup via safe keywords

### Element Locator Strategy
Prefer in order:
1. **CSS selectors** for input fields: `css:input[type='email']`
2. **XPath with text** for buttons: `xpath://button[contains(text(), 'Create Agent')]`
3. **XPath with attributes** for form fields: `xpath://label[contains(text(), 'Full Name')]/following-sibling::input`
4. **ID-based selectors** when available

Avoid brittle positional XPath like `li[2]` - use data attributes or text matching.

### Chrome Configuration Pattern
All resource files apply this consistent browser setup:
```robot
${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()
${prefs}=    Create Dictionary
...    credentials_enable_service=${False}
...    profile.password_manager_enabled=${False}
...    password_manager_leak_detection=${False}
Call Method    ${options}    add_experimental_option    prefs    ${prefs}
Open Browser    ${URL}    chrome    options=${options}
```

## Project-Specific Conventions

1. **Test Naming**: Use `TC-##: Description` format (e.g., `TC-01: Verify Successful Login`)
2. **Locator Variables**: Prefix with element type in variables section (e.g., `${EMAIL_FIELD}`, `${LOGIN_BUTTON}`)
3. **Waits Over Sleep**: Always use `Wait Until *` keywords; `Sleep` only for workflow delays (1-3s)
4. **Error Handling**: Use `Run Keyword And Ignore Error` for teardown operations that may not exist
5. **Documentation**: [Documentation] tags required for all Keywords and Test Cases

## Common Tasks

### Adding a New Test
1. Create file in appropriate folder (`automation/` or `automation admin/`)
2. Reference resource file: `Resource         resource.robot` (admin) or import SeleniumLibrary directly (agent)
3. Use Suite Setup/Teardown with existing login keywords
4. Use existing CSS/XPath patterns for consistency
5. Run: `robot path/to/file.robot`

### Updating Locators
- Check both `DashboardAgent.robot` and admin resource files for existing patterns
- Update all references if changing core selectors (e.g., login fields appear in multiple files)
- Test with `Wait Until Element Is Visible` timeout to validate accuracy

### Adding New Keywords
- Place shared keywords in `automation admin/resource.robot` (for admin suite)
- Create keyword-specific files if needed (like `AgentResourse.robot`)
- Include `[Documentation]` tags and use descriptive parameter names

## External Dependencies

- **SeleniumLibrary**: Manage browser + element interaction
- **Collections Library**: For dictionary/list operations (used in AddAgent.robot)
- **String Library**: Random string generation (used in AddAgent.robot)
- **PyYAML**: Available but not actively used in current tests

## Critical Files Reference

| File | Purpose |
|------|---------|
| [automation admin/resource.robot](automation%20admin/resource.robot) | Shared admin login + utilities (extends to other admin tests) |
| [automation/AgentResourse.robot](automation/AgentResourse.robot) | Agent login + browser setup pattern template |
| [automation/DashboardAgent.robot](automation/DashboardAgent.robot) | Agent dashboard validation - exemplifies variable usage |
| [automation admin/AddAgent.robot](automation%20admin/AddAgent.robot) | Complex test with modal interaction + data generation |

## Known Issues & Workarounds

1. **Chrome hanging on exit**: Use `Call Method ${options} add_argument --disable-gpu` and `Safe Close Browser`
2. **Timing-sensitive tests**: Increase explicit waits in CI/CD environments (network latency)
3. **Password manager interference**: Disable via prefs in all new Chrome configurations
