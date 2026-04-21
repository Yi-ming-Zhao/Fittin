package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/Yi-ming-Zhao/Fittin/backend/internal/app"
	"github.com/Yi-ming-Zhao/Fittin/backend/internal/importer"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	authPath := flag.String("auth-sql", "../.deploy/supabase_restore/generated/30_restore_auth_data.sql", "path to exported auth SQL")
	appPath := flag.String("app-sql", "../.deploy/supabase_restore/generated/20_restore_public_app_data.sql", "path to exported public app SQL")
	flag.Parse()

	cfg, err := app.LoadConfig()
	if err != nil {
		log.Fatal(err)
	}

	db, err := pgxpool.New(context.Background(), cfg.DatabaseURL)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	summary, err := importer.ImportBundle(context.Background(), db, *authPath, *appPath)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Fprintf(os.Stdout, "imported %d users, %d plans, %d instances, %d workout logs, %d body metrics, %d progress photos\n",
		summary.Users,
		summary.Plans,
		summary.PlanInstances,
		summary.WorkoutLogs,
		summary.BodyMetrics,
		summary.ProgressPhotos,
	)
}
