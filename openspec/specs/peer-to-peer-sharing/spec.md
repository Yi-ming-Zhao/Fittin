## Purpose

Define how training templates can be exported, shared as QR payloads, and imported back into the app through QR or deep-link flows.

## Requirements

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

### Requirement: Bounded Validated Template Import
Shared template decoding MUST cap encoded and decompressed sizes and MUST run domain validation before any template is persisted.

#### Scenario: Compressed payload expands beyond limit
- **WHEN** a shared code decompresses beyond the configured maximum
- **THEN** import stops with a validation error and does not allocate or persist the complete payload.
