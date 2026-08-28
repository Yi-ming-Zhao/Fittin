## MODIFIED Requirements

### Requirement: Compatible connection test
The application SHALL offer a disclosed minimal request that verifies authentication, streaming response handling, and a complete valid ping function call before marking a configuration ready. The test SHALL use compatible automatic tool selection instead of requiring named-tool forcing.

#### Scenario: Provider lacks tool calling
- **WHEN** text generation succeeds but no complete valid ping tool call is returned
- **THEN** the configuration is reported as chat-capable but unavailable for Fittin Agent tools

#### Scenario: DeepSeek rejects named-tool forcing
- **WHEN** the provider supports automatic tool use but rejects named tool_choice
- **THEN** the test can succeed using automatic selection and a real ping response

## ADDED Requirements

### Requirement: DeepSeek continuation compatibility
The Agent SHALL parse and retain optional reasoning_content separately from visible assistant text and replay it in subsequent DeepSeek tool requests, including after reopening a local conversation. This metadata SHALL remain local and secret-redacted.

#### Scenario: Reasoning precedes a tool call
- **WHEN** DeepSeek streams reasoning_content and then requests a local read tool
- **THEN** the next request includes the retained reasoning_content on the original assistant message and the UI shows only the final content and tool summary

### Requirement: Complete endpoint input normalization
Provider configuration SHALL accept either a Base URL or a complete chat/completions URL without duplicating the endpoint path, while retaining the existing HTTPS and URL safety checks.

#### Scenario: User pastes the full DeepSeek endpoint
- **WHEN** the user enters https://api.deepseek.com/v1/chat/completions
- **THEN** native requests use that endpoint once and Web relay sends https://api.deepseek.com/v1 as the provider Base URL
