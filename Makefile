.PHONY: run build test test-race bench vet migrate-up migrate-down migrate-status seed migrate-sqlite seed-sqlite migrate-postgres seed-postgres docker-up docker-up-cache docker-down docker-clean-volumes clean

BINARY_NAME=go-backend-academy

run:
	go run ./cmd/server/main.go

build:
	CGO_ENABLED=0 go build -ldflags="-s -w" -o bin/$(BINARY_NAME) ./cmd/server/main.go

vet:
	go vet ./...

test:
	go test -v ./...

test-race:
	go test -v -race -coverprofile=coverage.out ./...

bench:
	go test -bench=. -benchmem ./...

# Driver-agnostic migrations & seeding (automatically reads DB_DRIVER, POSTGRES_PORT, SQLITE_PATH, etc. from .env)
migrate-up:
	go run ./cmd/server/main.go -migrate up

migrate-down:
	go run ./cmd/server/main.go -migrate down

migrate-status:
	go run ./cmd/server/main.go -migrate status

seed:
	go run ./cmd/server/main.go -migrate seed

migrate-sqlite:
	DB_DRIVER=sqlite go run ./cmd/server/main.go -migrate up

seed-sqlite:
	DB_DRIVER=sqlite go run ./cmd/server/main.go -migrate seed

migrate-postgres:
	DB_DRIVER=postgres go run ./cmd/server/main.go -migrate up

seed-postgres:
	DB_DRIVER=postgres go run ./cmd/server/main.go -migrate seed

docker-up:
	docker compose up -d --build

docker-up-cache:
	docker compose --profile cache up -d --build

# Safe stop: preserves persistent PostgreSQL data volume!
docker-down:
	docker compose down

# Explicit destructive cleanup command with warning
docker-clean-volumes:
	@echo "WARNING: Destroying persistent database volumes (pgdata)..."
	docker compose --profile cache down -v

clean:
	rm -rf bin/ coverage.out academy.db
