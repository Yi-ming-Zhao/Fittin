package importer

import (
	"bufio"
	"context"
	"errors"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Summary struct {
	Users          int
	Plans          int
	PlanInstances  int
	WorkoutLogs    int
	BodyMetrics    int
	ProgressPhotos int
}

func (s Summary) TotalRows() int {
	return s.Users + s.Plans + s.PlanInstances + s.WorkoutLogs + s.BodyMetrics + s.ProgressPhotos
}

type tableImportSpec struct {
	Name          string
	Prefix        string
	Columns       []string
	ExpectedCount int
}

var publicTableSpecs = []tableImportSpec{
	{
		Name:          "plans",
		Prefix:        "INSERT INTO public.plans VALUES ",
		Columns:       []string{"id", "user_id", "name", "description", "source_plan_id", "is_built_in", "raw_json", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id"},
		ExpectedCount: 12,
	},
	{
		Name:          "plan_instances",
		Prefix:        "INSERT INTO public.plan_instances VALUES ",
		Columns:       []string{"id", "user_id", "template_id", "current_workout_index", "current_states_json", "training_max_profile_json", "engine_state_json", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id"},
		ExpectedCount: 12,
	},
	{
		Name:          "workout_logs",
		Prefix:        "INSERT INTO public.workout_logs VALUES ",
		Columns:       []string{"id", "user_id", "instance_id", "workout_id", "workout_name", "raw_json", "completed_at", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id"},
		ExpectedCount: 12,
	},
	{
		Name:          "body_metrics",
		Prefix:        "INSERT INTO public.body_metrics VALUES ",
		Columns:       []string{"id", "user_id", "timestamp", "weight_kg", "body_fat_percent", "waist_cm", "note", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id"},
		ExpectedCount: 12,
	},
	{
		Name:          "progress_photos",
		Prefix:        "INSERT INTO public.progress_photos VALUES ",
		Columns:       []string{"id", "user_id", "captured_at", "label", "storage_path", "metadata_json", "created_at", "updated_at", "deleted_at", "version", "last_modified_by_device_id"},
		ExpectedCount: 11,
	},
}

func ImportBundle(ctx context.Context, db *pgxpool.Pool, authPath string, appPath string) (Summary, error) {
	var summary Summary

	if err := importAuthUsers(ctx, db, authPath, &summary); err != nil {
		return summary, err
	}
	if err := importPublicData(ctx, db, appPath, &summary); err != nil {
		return summary, err
	}

	return summary, nil
}

func importAuthUsers(ctx context.Context, db *pgxpool.Pool, authPath string, summary *Summary) error {
	file, err := os.Open(authPath)
	if err != nil {
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Buffer(make([]byte, 0, 64*1024), 8*1024*1024)

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if !strings.HasPrefix(line, "INSERT INTO auth.users VALUES ") {
			continue
		}

		values, err := ParseInsertValues(line, "INSERT INTO auth.users VALUES ")
		if err != nil {
			return fmt.Errorf("parse auth.users insert: %w", err)
		}
		if len(values) < 22 {
			return fmt.Errorf("auth.users insert had %d values; expected at least 22", len(values))
		}

		userID := values[1].String()
		email := values[4].String()
		passwordHash := values[5].String()
		createdAt, err := sqlValueTime(values[20], time.Now().UTC())
		if err != nil {
			return fmt.Errorf("parse auth.users created_at: %w", err)
		}
		updatedAt, err := sqlValueTime(values[21], createdAt)
		if err != nil {
			return fmt.Errorf("parse auth.users updated_at: %w", err)
		}

		if userID == "" || email == "" || passwordHash == "" {
			return errors.New("auth.users row missing required id/email/password_hash")
		}

		if _, err := db.Exec(
			ctx,
			`insert into users (id, email, password_hash, display_name, created_at, updated_at)
			 values ($1, $2, $3, $4, $5, $6)
			 on conflict (id) do update
			     set email = excluded.email,
			         password_hash = excluded.password_hash,
			         display_name = excluded.display_name,
			         created_at = least(users.created_at, excluded.created_at),
			         updated_at = greatest(users.updated_at, excluded.updated_at)`,
			userID,
			email,
			passwordHash,
			email,
			createdAt,
			updatedAt,
		); err != nil {
			return err
		}

		summary.Users++
	}

	return scanner.Err()
}

func importPublicData(ctx context.Context, db *pgxpool.Pool, appPath string, summary *Summary) error {
	file, err := os.Open(appPath)
	if err != nil {
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Buffer(make([]byte, 0, 64*1024), 16*1024*1024)

	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		for _, spec := range publicTableSpecs {
			if !strings.HasPrefix(line, spec.Prefix) {
				continue
			}

			values, err := ParseInsertValues(line, spec.Prefix)
			if err != nil {
				return fmt.Errorf("parse %s insert: %w", spec.Name, err)
			}
			if len(values) != spec.ExpectedCount {
				return fmt.Errorf("%s insert had %d values; expected %d", spec.Name, len(values), spec.ExpectedCount)
			}

			if err := insertPublicRow(ctx, db, spec, values); err != nil {
				return fmt.Errorf("import %s row: %w", spec.Name, err)
			}

			switch spec.Name {
			case "plans":
				summary.Plans++
			case "plan_instances":
				summary.PlanInstances++
			case "workout_logs":
				summary.WorkoutLogs++
			case "body_metrics":
				summary.BodyMetrics++
			case "progress_photos":
				summary.ProgressPhotos++
			}
		}
	}

	return scanner.Err()
}

func insertPublicRow(ctx context.Context, db *pgxpool.Pool, spec tableImportSpec, values []Value) error {
	placeholders := make([]string, 0, len(spec.Columns))
	args := make([]any, 0, len(spec.Columns))
	updateClauses := make([]string, 0, len(spec.Columns)-1)

	for index, column := range spec.Columns {
		placeholders = append(placeholders, fmt.Sprintf("$%d", index+1))
		normalized, err := normalizeValue(column, values[index])
		if err != nil {
			return fmt.Errorf("normalize %s.%s: %w", spec.Name, column, err)
		}
		args = append(args, normalized)
		if column != "id" {
			updateClauses = append(updateClauses, fmt.Sprintf("%s = excluded.%s", column, column))
		}
	}

	query := fmt.Sprintf(
		`insert into %s (%s)
		 values (%s)
		 on conflict (id) do update
		     set %s`,
		spec.Name,
		strings.Join(spec.Columns, ", "),
		strings.Join(placeholders, ", "),
		strings.Join(updateClauses, ", "),
	)
	_, err := db.Exec(ctx, query, args...)
	return err
}

func normalizeValue(column string, value Value) (any, error) {
	if value.IsNull || value.IsDefault {
		return nil, nil
	}

	switch column {
	case "is_built_in":
		return value.Bool()
	case "current_workout_index", "version":
		return value.Int()
	case "weight_kg", "body_fat_percent", "waist_cm":
		return value.Float64()
	case "created_at", "updated_at", "deleted_at", "completed_at", "captured_at", "timestamp":
		return value.Time()
	default:
		return value.String(), nil
	}
}

func sqlValueTime(value Value, fallback time.Time) (time.Time, error) {
	if value.IsNull {
		return fallback, nil
	}
	return value.Time()
}
