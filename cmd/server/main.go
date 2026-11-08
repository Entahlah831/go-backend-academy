package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gobackendacademy/platform/internal/config"
	"github.com/gobackendacademy/platform/internal/platform/database"
	httpplatform "github.com/gobackendacademy/platform/internal/platform/http"
	"github.com/gobackendacademy/platform/internal/platform/logger"
)

func main() {
	envFile := flag.String("env-file", envOr("ENV_FILE", ".env"), "path to a .env file (missing file is ignored; real environment variables take precedence)")
	migrate := flag.String("migrate", "", "run a migration command and exit: up | down | status | seed")
	steps := flag.Int("steps", 1, "number of migrations to revert with -migrate down")
	flag.Parse()

	loaded, err := config.LoadDotEnv(*envFile)
	if err != nil {
		slog.Error("loading env file failed", slog.String("error", err.Error()))
		os.Exit(1)
	}

	cfg, err := config.Load()
	if err != nil {
		slog.Error("configuration validation failed", slog.String("error", err.Error()))
		os.Exit(1)
	}

	log := logger.New(os.Stdout, cfg.AppEnv)
	if loaded {
		log.Info("loaded environment file", slog.String("path", *envFile))
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	if *migrate != "" {
		if err := runMigrationCommand(ctx, cfg, log, *migrate, *steps); err != nil {
			log.Error("migration command failed", slog.String("command", *migrate), slog.String("error", err.Error()))
			os.Exit(1)
		}
		return
	}

	store, err := database.Open(ctx, cfg)
	if err != nil {
		log.Error("database initialization failed; refusing to start without a working database",
			slog.String("db_driver", cfg.DBDriver),
			slog.String("db_target", cfg.DBTarget()),
			slog.String("error", err.Error()))
		os.Exit(1)
	}
	defer func() {
		if closeErr := store.Close(); closeErr != nil {
			log.Error("closing database store", slog.String("error", closeErr.Error()))
		}
	}()
	log.Info("database connected",
		slog.String("db_driver", store.DriverName()),
		slog.String("db_target", store.Target()),
		slog.Bool("persistent", store.Persistent()),
		slog.Bool("auto_migrate", cfg.DBAutoMigrate),
		slog.Bool("auto_seed", cfg.DBAutoSeed))
	if !store.Persistent() {
		log.Warn("DB_DRIVER=memory: all progress, notes, bookmarks, and attempts are lost when the server stops")
	}

	srv := httpplatform.NewServer(cfg, log, store)
	srv.StartBackgroundWorkers(ctx)

	if cfg.AIProvider != "none" {
		checkCtx, cancel := context.WithTimeout(ctx, 3*time.Second)
		if p, ok := srv.Analyzer().AIProvider(); ok {
			if err := p.CheckConnection(checkCtx); err != nil {
				log.Warn("optional local AI provider connection check failed; falling back to deterministic analysis",
					slog.String("ai_provider", cfg.AIProvider),
					slog.String("error", err.Error()))
			} else {
				log.Info("optional local AI provider connected",
					slog.String("ai_provider", cfg.AIProvider))
			}
		}
		cancel()
	}

	httpServer := &http.Server{
		Addr:              cfg.ListenAddr(),
		Handler:           srv.Handler(),
		ReadHeaderTimeout: cfg.ReadHeaderTimeout,
		ReadTimeout:       cfg.ReadTimeout,
		WriteTimeout:      cfg.WriteTimeout,
		IdleTimeout:       cfg.IdleTimeout,
	}

	go func() {
		log.Info("Go Backend Academy server listening",
			slog.String("addr", cfg.ListenAddr()),
			slog.String("env", cfg.AppEnv),
			slog.String("db_driver", cfg.DBDriver),
			slog.String("ai_provider", cfg.AIProvider),
		)
		if err := httpServer.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Error("http server error", slog.String("error", err.Error()))
			os.Exit(1)
		}
	}()

	<-ctx.Done()
	log.Info("shutdown signal received; marking /readyz 503 and draining active connections...")
	srv.SetShuttingDown(true)

	shutdownCtx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
	defer cancel()

	if err := httpServer.Shutdown(shutdownCtx); err != nil {
		log.Error("graceful shutdown failed", slog.String("error", err.Error()))
		os.Exit(1)
	}
	log.Info("server stopped cleanly")
}

// runMigrationCommand opens the database without auto-migration and runs one explicit command.
func runMigrationCommand(ctx context.Context, cfg *config.Config, log *slog.Logger, cmd string, steps int) error {
	if cfg.DBDriver == "memory" {
		return errors.New("migration commands need a persistent database (DB_DRIVER=sqlite or postgres)")
	}
	cfg.DBAutoMigrate = false
	cfg.DBAutoSeed = false
	store, err := database.Open(ctx, cfg)
	if err != nil {
		return err
	}
	defer store.Close()
	log.Info("migration target", slog.String("db_driver", store.DriverName()), slog.String("db_target", store.Target()))

	switch cmd {
	case "up":
		applied, err := store.MigrateUp(ctx)
		if err != nil {
			return err
		}
		seeded, err := store.Seed(ctx)
		if err != nil {
			return err
		}
		log.Info("migrate up complete", slog.Any("applied", applied), slog.Any("seeded", seeded))
	case "seed":
		seeded, err := store.Seed(ctx)
		if err != nil {
			return err
		}
		log.Info("seed complete", slog.Any("seeded", seeded))
	case "reseed":
		seeded, err := store.Reseed(ctx)
		if err != nil {
			return err
		}
		log.Info("reseed complete", slog.Any("seeded", seeded))
	case "down":
		reverted, err := store.MigrateDown(ctx, steps)
		if err != nil {
			return err
		}
		log.Info("migrate down complete", slog.Any("reverted", reverted))
	case "status":
		states, err := store.MigrationStatus(ctx)
		if err != nil {
			return err
		}
		for _, st := range states {
			mark := "pending"
			if st.Applied {
				mark = "applied"
			}
			fmt.Printf("%-28s %s\n", st.Version, mark)
		}
	default:
		return fmt.Errorf("unknown -migrate command %q (use up, down, status, or seed)", cmd)
	}
	return nil
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
