## ADDED Requirements

### Requirement: Recoverable tool lifecycle
The Agent SHALL validate model completion, return malformed or truncated tool calls as non-executed error results within the existing run limits, and preserve complete assistant/tool-result pairing across approval, failure, cancellation, and follow-up requests.

#### Scenario: Model repairs invalid arguments
- **WHEN** a completed response contains malformed tool JSON
- **THEN** the tool is not executed and the model receives a bounded error result and can issue a corrected call

#### Scenario: Model output is truncated
- **WHEN** a response ends with a length limit
- **THEN** no tool from that response is executed, even if its JSON parses, and the model is instructed to use smaller complete edits

#### Scenario: Stream disconnects
- **WHEN** the stream closes without a completion marker
- **THEN** the run reports an interrupted response, retains nonempty partial text, and does not execute partial calls

#### Scenario: Approval pauses a tool batch
- **WHEN** the first write proposal is ready and other tool calls remain
- **THEN** the remaining calls receive explicit non-executed outcomes and no further tool or model invocation occurs before a user decision

### Requirement: Focused Markdown conversation
Assistant messages SHALL render selectable themed Markdown without automatic image requests or executable HTML, SHALL hide whitespace-only output cards, and SHALL not display the three standalone data-insight cards.

#### Scenario: Empty failed assistant response
- **WHEN** a run fails before producing visible text
- **THEN** the chat displays the error directly without a blank assistant card

#### Scenario: Mobile Markdown
- **WHEN** a response includes headings, lists, a table, code, and links on a 320 or 390 pixel wide phone
- **THEN** content remains within the chat layout, links open only on user action, and colors follow the selected theme
