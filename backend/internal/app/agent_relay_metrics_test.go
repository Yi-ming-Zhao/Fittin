package app

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"strings"
	"testing"
	"time"
)

func TestAgentIdleBodyClosesBlockedRead(t *testing.T) {
	reader, writer := io.Pipe()
	defer writer.Close()
	body := &agentIdleBody{ReadCloser: reader, idle: 5 * time.Millisecond}
	_, err := body.Read(make([]byte, 16))
	if !errors.Is(err, errAgentIdleTimeout) {
		t.Fatalf("expected typed idle timeout, got %v", err)
	}
}

func TestAgentRelayMetricsContainOnlyAggregateMetadata(t *testing.T) {
	server := newAgentRelayTestServer(publicAgentResolver(), agentRoundTripFunc(func(*http.Request) (*http.Response, error) {
		return agentResponse(http.StatusOK, "application/json", `{"choices":[]}`), nil
	}), Config{})
	serveAgentRelay(server, validAgentRelayBody("sk-never-in-metrics"), "private-user-id", "198.18.0.42")
	if server.agentStats.Terminations[agentTermCompleted] != 1 || server.agentStats.Bytes == 0 {
		t.Fatal("missing completion metrics")
	}
	encoded, _ := json.Marshal(server.agentStats)
	for _, secret := range []string{"sk-never-in-metrics", "private-user-id", "choices", "providerBaseUrl"} {
		if strings.Contains(string(encoded), secret) {
			t.Fatal("metrics leaked request/response content")
		}
	}
}

func TestAgentRetryAfterIsBoundedAndAcceptsHTTPDate(t *testing.T) {
	now := time.Now().UTC().Truncate(time.Second)
	if safeAgentRetryAfter("600", now) != "300" {
		t.Fatal("unbounded retry delay")
	}
	if safeAgentRetryAfter(now.Add(60*time.Second).Format(http.TimeFormat), now) != "60" {
		t.Fatal("HTTP date not accepted")
	}
	if safeAgentRetryAfter("secret-key", now) != "" {
		t.Fatal("arbitrary header accepted")
	}
}
