package app

import (
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
)

// This opt-in canary uses a synthetic local Fittin session and no fitness data.
// The provider credential is process-only and never included in test output.
func TestAgentRelayRealProviderCanary(t *testing.T) {
	key := os.Getenv("FITTIN_AGENT_CANARY_KEY")
	if key == "" {
		t.Skip("ephemeral provider key not supplied")
	}
	model := os.Getenv("FITTIN_AGENT_CANARY_MODEL")
	if model == "" {
		t.Fatal("explicit canary model is required")
	}
	body, err := json.Marshal(map[string]any{
		"providerBaseUrl": "https://api.deepseek.com/v1", "apiKey": key,
		"payload": map[string]any{
			"model": model, "stream": true, "max_tokens": 512,
			"messages": []map[string]string{{"role": "user", "content": "Call the ping function exactly once."}},
			"tools": []map[string]any{{"type": "function", "function": map[string]any{
				"name": "ping", "description": "Verify tool calling", "parameters": map[string]any{
					"type": "object", "properties": map[string]any{}, "additionalProperties": false,
				},
			}}},
		},
	})
	if err != nil {
		t.Fatal("unable to encode synthetic request")
	}
	server := newAgentRelayTestServer(net.DefaultResolver, nil, Config{JWTSecret: "local-canary-signing-secret"})
	token, err := server.issueToken("synthetic-canary", "synthetic@example.invalid")
	if err != nil {
		t.Fatal("unable to create synthetic session")
	}
	request := httptest.NewRequest(http.MethodPost, "/v1/agent/chat-completions", strings.NewReader(string(body)))
	request.Header.Set("Authorization", "Bearer "+token)
	recorder := httptest.NewRecorder()
	server.withAuth(server.handleAgentChatCompletions)(recorder, request)
	if recorder.Code != http.StatusOK || !recorder.Flushed {
		t.Fatalf("real relay failed: status=%d flushed=%v", recorder.Code, recorder.Flushed)
	}
	if strings.Contains(recorder.Body.String(), key) {
		t.Fatal("provider credential leaked in response")
	}
	var names strings.Builder
	completed := false
	for _, line := range strings.Split(recorder.Body.String(), "\n") {
		if !strings.HasPrefix(line, "data: ") || line == "data: [DONE]" {
			continue
		}
		var event struct {
			Choices []struct {
				FinishReason string `json:"finish_reason"`
				Delta        struct {
					ToolCalls []struct {
						Function struct {
							Name string `json:"name"`
						} `json:"function"`
					} `json:"tool_calls"`
				} `json:"delta"`
			} `json:"choices"`
		}
		if json.Unmarshal([]byte(strings.TrimPrefix(line, "data: ")), &event) != nil {
			t.Fatal("relay returned an invalid SSE event")
		}
		for _, choice := range event.Choices {
			completed = completed || choice.FinishReason == "tool_calls"
			for _, call := range choice.Delta.ToolCalls {
				names.WriteString(call.Function.Name)
			}
		}
	}
	if names.String() != "ping" || !completed {
		t.Fatal("relay did not complete the synthetic ping tool")
	}
}
