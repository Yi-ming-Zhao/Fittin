## ADDED Requirements

### Requirement: JSON Export
The system MUST be capable of serializing a full training template definition into a compact JSON string.

#### Scenario: Exporting a selected template
- **WHEN** a user selects a template and clicks "Export to JSON"
- **THEN** the application generates the corresponding base64 encoded string or raw JSON of the rule-set without error.

### Requirement: QR Code Generation
The system MUST support displaying a generated QR code representation of the exported JSON payload.

#### Scenario: Generating a sharable QR
- **WHEN** the JSON export is completed and the user selects "Share as QR Code"
- **THEN** a readable high-contrast QR image appears on screen encapsulating the template payload.

### Requirement: QR / Deep Link Import
The system MUST interpret and deserialize QR-scanned data or captured Deep Link URIs back into functioning template documents.

#### Scenario: Importing from an external URI
- **WHEN** a user scans a generated QR code from another device
- **THEN** the engine accurately decodes the JSON, validates its schema against standard definitions, and imports it as a new distinct template under local storage.
