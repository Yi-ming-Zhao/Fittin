package app

import (
	"errors"
	"io"
	"net/http"
	"strconv"
	"sync/atomic"
	"time"
)

type agentTermination string

const (
	agentTermCompleted   agentTermination = "completed"
	agentTermRejected    agentTermination = "rejected"
	agentTermCancelled   agentTermination = "client_cancelled"
	agentTermTimeout     agentTermination = "total_timeout"
	agentTermIdleTimeout agentTermination = "idle_timeout"
	agentTermUnavailable agentTermination = "upstream_unavailable"
	agentTermSizeLimit   agentTermination = "response_size_limit"
)

// Only fixed labels and aggregate numbers live here. No user/provider IDs,
// request bodies, URLs, keys, prompts, tool results or model content.
type agentRelayMetrics struct {
	Terminations map[agentTermination]uint64 `json:"terminations"`
	Bytes        int64                       `json:"bytes"`
	DurationMs   int64                       `json:"durationMs"`
}

func (s *Server) recordAgentRelay(reason agentTermination, bytes int64, elapsed time.Duration) {
	s.agentMu.Lock()
	defer s.agentMu.Unlock()
	if s.agentStats.Terminations == nil {
		s.agentStats.Terminations = make(map[agentTermination]uint64)
	}
	s.agentStats.Terminations[reason]++
	s.agentStats.Bytes += bytes
	s.agentStats.DurationMs += elapsed.Milliseconds()
}

var errAgentIdleTimeout = errors.New("agent stream idle timeout")

type agentIdleBody struct {
	io.ReadCloser
	idle time.Duration
}

func (b *agentIdleBody) Read(p []byte) (int, error) {
	var expired atomic.Bool
	timer := time.AfterFunc(b.idle, func() { expired.Store(true); _ = b.ReadCloser.Close() })
	n, err := b.ReadCloser.Read(p)
	timer.Stop()
	if expired.Load() {
		return n, errAgentIdleTimeout
	}
	return n, err
}

func safeAgentRetryAfter(value string, now time.Time) string {
	seconds, err := strconv.Atoi(value)
	if err != nil {
		date, parseErr := http.ParseTime(value)
		if parseErr != nil {
			return ""
		}
		seconds = int(date.Sub(now).Seconds())
	}
	return strconv.Itoa(max(0, min(300, seconds)))
}
