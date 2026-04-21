package importer

import "testing"

func TestParseInsertValuesAuthUserLine(t *testing.T) {
	line := "INSERT INTO auth.users VALUES ('00000000-0000-0000-0000-000000000000', '58ad78be-67d1-415a-b82c-0793b41df2a3', 'authenticated', 'authenticated', '2434379504@qq.com', '$2a$10$hash', '2026-03-30 10:02:12.779414+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-03-30 10:02:12.800381+00', '{\"provider\": \"email\"}', '{\"sub\": \"58ad\"}', NULL, '2026-03-30 10:02:12.764955+00', '2026-03-30 10:02:12.806142+00', NULL, NULL, '', '', NULL, DEFAULT, '', 0, NULL, '', NULL, false, NULL, false);"

	values, err := ParseInsertValues(line, "INSERT INTO auth.users VALUES ")
	if err != nil {
		t.Fatalf("ParseInsertValues returned error: %v", err)
	}

	if got, want := len(values), 35; got != want {
		t.Fatalf("expected %d values, got %d", want, got)
	}
	if got := values[4].String(); got != "2434379504@qq.com" {
		t.Fatalf("unexpected email: %s", got)
	}
	if !values[7].IsNull {
		t.Fatalf("expected index 7 to be NULL")
	}
	if !values[26].IsDefault {
		t.Fatalf("expected index 26 to be DEFAULT")
	}
}

func TestParseInsertValuesPublicWorkoutLogLine(t *testing.T) {
	line := "INSERT INTO public.workout_logs VALUES ('log-1', 'user-1', 'instance-1', 'day1', 'Squat Focus', '{\"a\":1,\"quoted\":\"it''s fine\"}', '2026-04-13 12:58:36.82+00', '2026-04-13 12:58:36.82+00', '2026-04-13 12:58:36.82+00', NULL, 1, NULL);"

	values, err := ParseInsertValues(line, "INSERT INTO public.workout_logs VALUES ")
	if err != nil {
		t.Fatalf("ParseInsertValues returned error: %v", err)
	}

	if got, want := len(values), 12; got != want {
		t.Fatalf("expected %d values, got %d", want, got)
	}
	if got := values[5].String(); got != "{\"a\":1,\"quoted\":\"it's fine\"}" {
		t.Fatalf("unexpected raw_json: %s", got)
	}
	if !values[9].IsNull {
		t.Fatalf("expected deleted_at to be NULL")
	}
}
