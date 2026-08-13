# in-app-agent-harness Specification

## Purpose
Define the device-local provider configuration, bounded model loop, local conversation history, and mobile Agent interface.

## Requirements

### Requirement: Device-local provider configuration
The application SHALL let a user configure one OpenAI-compatible Base URL, model ID, and API key per device, SHALL keep native keys in secure storage, and SHALL keep Web keys only in process memory.

#### Scenario: Native configuration is restored securely
- **WHEN** a native user saves valid provider settings and restarts the application
- **THEN** the Base URL and model are restored and the key is read from platform secure storage without appearing in ordinary preferences or logs

#### Scenario: Web refresh forgets the key
- **WHEN** a Web user refreshes after configuring a provider
- **THEN** the Base URL and model remain available but the API key must be entered again

### Requirement: Compatible connection test
The application SHALL offer a disclosed, minimal real request that verifies authentication, streaming response handling, and forced function calling before marking a configuration ready.

#### Scenario: Provider lacks tool calling
- **WHEN** text generation succeeds but the forced ping tool call is not returned
- **THEN** the configuration is reported as chat-capable but unavailable for Fittin Agent tools

### Requirement: Bounded streaming Agent runs
The Agent SHALL stream visible output, support cancellation and retry, preserve interrupted user input, and stop after eight model turns or twelve tool calls.

#### Scenario: User cancels a slow response
- **WHEN** the user taps stop while a response is streaming
- **THEN** the network request is cancelled, partial text remains visible, and no local mutation occurs

#### Scenario: A write proposal is generated
- **WHEN** the model calls a proposal-only write tool
- **THEN** the run pauses with one pending approval card and performs no further model or write calls until the user decides

### Requirement: Device-local conversation history
The application SHALL persist user-visible messages and compact tool/action summaries locally, SHALL allow starting and deleting conversations, and SHALL not sync raw model traffic or conversation history.

#### Scenario: Conversation is reopened
- **WHEN** the user selects a prior local conversation
- **THEN** the visible messages and action summaries are restored without requiring the provider key

### Requirement: Bilingual themed Agent interface
The Agent tab and settings SHALL use semantic colors from all five Fittin palettes, bilingual copy, keyboard-safe composition, accessible semantics, and no hard-coded teal or cyan color.

#### Scenario: Phone chat layout
- **WHEN** the Agent runs at 390 by 844 pixels with the keyboard visible
- **THEN** the composer, current response, stop action, and bottom navigation remain reachable without horizontal overflow
