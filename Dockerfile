# Stage 1: Build static Go binary with embedded SQL migrations and seed data
FROM golang:1.26-alpine AS builder
WORKDIR /src

RUN apk add --no-cache ca-certificates tzdata

COPY go.mod go.sum ./
RUN go mod download

COPY cmd/ ./cmd/
COPY internal/ ./internal/
COPY migrations/ ./migrations/
COPY seed/ ./seed/

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-s -w" \
    -o /out/go-backend-academy ./cmd/server/main.go

# Stage 2: Minimal non-root runtime
FROM alpine:3.20
RUN adduser -D -u 10001 appuser && apk add --no-cache ca-certificates tzdata wget
WORKDIR /app

COPY --from=builder /out/go-backend-academy /app/go-backend-academy
COPY migrations/ /app/migrations/
COPY seed/ /app/seed/
COPY web/ /app/web/

RUN mkdir -p /app/data && chown -R appuser:appuser /app /app/data

USER appuser
ENV PORT=8080
EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- "http://127.0.0.1:${PORT:-8080}/readyz" || exit 1

ENTRYPOINT ["/app/go-backend-academy"]
