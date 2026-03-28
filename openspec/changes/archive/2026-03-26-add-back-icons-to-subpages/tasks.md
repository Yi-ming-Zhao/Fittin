## 1. Subpage Back Navigation Audit

- [x] 1.1 Inventory screens opened via push/navigation that should expose a back icon
- [x] 1.2 Identify root-level pages that must not show a misleading back icon

## 2. Shared Navigation Treatment

- [x] 2.1 Add or adapt a shared back-icon pattern for premium/custom subpage headers
- [x] 2.2 Ensure standard `AppBar` pages also use consistent back-icon visibility rules

## 3. Screen Integration

- [x] 3.1 Apply the back icon treatment to subpages that currently lack a visible return affordance
- [x] 3.2 Verify back actions pop to the immediate previous route without affecting root navigation

## 4. Verification

- [x] 4.1 Add or update widget tests covering subpages that should show a back icon
- [x] 4.2 Add or update widget tests confirming root pages do not expose a misleading back icon
- [x] 4.3 Validate the behavior on macOS navigation flows and premium/custom header screens
