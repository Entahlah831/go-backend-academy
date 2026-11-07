# Production VPS Deployment Guide (Ubuntu 22.04 / 24.04 LTS & Debian 12)

This guide covers two production-grade ways to deploy **Go Backend Academy** on a Linux VPS:
* **Method A (Recommended)**: Docker Compose (`Go 1.23 + PostgreSQL 17`) behind **Caddy** (automatic Let's Encrypt HTTPS).
* **Method B (Bare-Metal / Native Binary)**: Compiled static Go binary managed by **`systemd`** + **SQLite WAL** or **PostgreSQL**.

---

## 1. Initial VPS Hardening & Firewall (`ufw`)

SSH into your VPS and allow only SSH (`22`), HTTP (`80`), and HTTPS (`443`). Never expose port `8080` or `5432` to the public internet:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y ufw curl git unzip make sqlite3

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
sudo ufw status
```

---

## 2. Upload & Extract `go-backend-academy-source.zip`

```bash
sudo mkdir -p /opt/go-backend-academy
sudo chown -R $USER:$USER /opt/go-backend-academy

# Upload go-backend-academy-source.zip to your VPS, then extract:
unzip go-backend-academy-source.zip -d /opt/
cd /opt/go-backend-academy
```

---

## 3. Method A: Deploy with Docker Compose + PostgreSQL 17 (Recommended)

### Step 3.1 — Install Docker Engine & Docker Compose Plugin

Follow the [Official Docker Ubuntu/Debian Installation Docs](https://docs.docker.com/engine/install/ubuntu/):

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
newgrp docker
docker compose version
```

### Step 3.2 — Configure `.env` with a Strong Cryptographic Password

```bash
cd /opt/go-backend-academy
cp .env.example .env

# Generate a random 32-byte hex password and inject it into .env:
STRONG_PASS=$(openssl rand -hex 24)
sed -i "s/change_this_strong_password_in_prod/$STRONG_PASS/g" .env
sed -i "s|CORS_ALLOWED_ORIGINS=.*|CORS_ALLOWED_ORIGINS=https://academy.yourdomain.com|g" .env
```

### Step 3.3 — Build & Start Containers

Because `docker-compose.yml` binds both `127.0.0.1:8080:8080` and `127.0.0.1:5432:5432` strictly to loopback (`127.0.0.1`), PostgreSQL is completely unreachable from the outside internet while the Go container connects over the internal Docker bridge network:

```bash
make docker-up
docker compose ps
```

### Step 3.4 — Verify Health & Readiness Locally on the VPS

```bash
curl -i http://127.0.0.1:8080/healthz
curl -i http://127.0.0.1:8080/readyz
```

---

## 4. Method B: Deploy Native Static Binary with `systemd` (Low-RAM VPS)

If your VPS has only 512MB–1GB RAM and you prefer running without Docker:

```bash
# 1. Install Go 1.23+ (https://go.dev/doc/install)
wget https://go.dev/dl/go1.23.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# 2. Build static binary, initialize SQLite WAL database, and run tests
cd /opt/go-backend-academy
cp .env.example .env
make vet
make test-race
make build
make migrate-sqlite
make seed-sqlite

# 3. Create dedicated non-root system user and install systemd unit
sudo useradd --system --no-create-home --shell /usr/sbin/nologin academy || true
sudo chown -R academy:academy /opt/go-backend-academy
sudo cp deployments/go-backend-academy.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now go-backend-academy
sudo systemctl status go-backend-academy
```

---

## 5. Enable Automatic HTTPS with Caddy (or Nginx)

### Option 1: Caddy (Automatic Let's Encrypt TLS 1.3 in 1 File)

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install -y caddy

# Copy the included Caddyfile and replace academy.yourdomain.com with your domain:
sudo cp /opt/go-backend-academy/deployments/Caddyfile /etc/caddy/Caddyfile
sudo nano /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

### Option 2: Nginx + Certbot

See `/opt/go-backend-academy/deployments/nginx.conf` for the ready-to-use TLS 1.3 + reverse proxy configuration.

---

## 6. Safe Operations, Upgrades & Backups on VPS

* **Restart / Upgrade without losing data**:
  ```bash
  make docker-down
  git pull # or unzip new release
  make docker-up
  ```
* **Backup PostgreSQL Database**:
  ```bash
  docker exec -t academy-postgres pg_dump -U academy -d gobackendacademy -F c > backup_$(date +%F).dump
  ```
* **Backup SQLite Database Safely (WAL-safe)**:
  ```bash
  sqlite3 /opt/go-backend-academy/academy.db "VACUUM INTO '/opt/go-backend-academy/backup_$(date +%F).db';"
  ```
