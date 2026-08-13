package app

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestProductionNginxAgentRelayContract(t *testing.T) {
	configPath := filepath.Join("..", "..", "..", "deploy", "nginx", "fittin.hammerscholar.net.conf")
	contents, err := os.ReadFile(configPath)
	if err != nil {
		t.Fatalf("read production nginx config: %v", err)
	}
	config := string(contents)
	required := []string{
		"limit_req_zone $binary_remote_addr zone=fittin_agent:10m rate=12r/m;",
		"location = /api/v1/agent/chat-completions {",
		"limit_req zone=fittin_agent burst=4 nodelay;",
		"limit_req_status 429;",
		"error_page 413 = @fittin_agent_request_too_large;",
		"error_page 429 = @fittin_agent_rate_limited;",
		"client_max_body_size 512k;",
		"client_body_buffer_size 512k;",
		"proxy_pass http://127.0.0.1:24181/v1/agent/chat-completions;",
		"proxy_set_header Connection \"\";",
		"proxy_request_buffering off;",
		"proxy_buffering off;",
		"proxy_cache off;",
		"proxy_read_timeout 125s;",
		"location @fittin_agent_request_too_large {",
		`return 413 '{"error":"Agent request is too large","code":"relay_request_too_large"}';`,
		"location @fittin_agent_rate_limited {",
		`return 429 '{"error":"too many Agent requests","code":"agent_rate_limited"}';`,
	}
	for _, directive := range required {
		if !strings.Contains(config, directive) {
			t.Errorf("production nginx config is missing %q", directive)
		}
	}

	agentLocationStart := strings.Index(config, "location = /api/v1/agent/chat-completions {")
	apiLocationStart := strings.Index(config, "location /api/ {")
	if agentLocationStart < 0 || apiLocationStart < 0 || agentLocationStart > apiLocationStart {
		t.Fatal("exact Agent streaming route must precede the general /api/ route")
	}
}
