# Go Backend Academy — Baseline Test & Configuration Audit (T0.1)

> Date: November 8, 2026 (04:58:30 +07:00)  
> Environment: Windows host (x86_64), Go 1.26.1  
> Git Branch: `fase-0` (initial baseline commit)

---

## 1. Go Vet Execution

### Perintah:
```powershell
cd c:\Users\12\Downloads\projects\go-backend-academy
go vet ./...
```

### Hasil Nyata:
```
Exit code: 0
Output: (clean, zero compiler or static analysis errors)
```

---

## 2. Go Test Execution

### Perintah A (dengan flag `-race`):
```powershell
cd c:\Users\12\Downloads\projects\go-backend-academy
go test -race -count=1 ./...
```

### Hasil Nyata A:
```
Exit code: 1
Output:
go: -race requires cgo; enable cgo by setting CGO_ENABLED=1
```
*Catatan teknis:* Pada host Windows lokal, tidak terpasang toolchain C/C++ (GCC/MinGW/Clang), sehingga flag `-race` memerlukan CGO. Di VPS Linux (CI / Docker container), GCC/musl tersedia sehingga `-race` dapat dieksekusi.

### Perintah B (unit test murni tanpa CGO):
```powershell
cd c:\Users\12\Downloads\projects\go-backend-academy
go test -count=1 ./...
```

### Hasil Nyata B:
```
Exit code: 0
Output:
?   	github.com/gobackendacademy/platform/cmd/server	[no test files]
?   	github.com/gobackendacademy/platform/internal/config	[no test files]
?   	github.com/gobackendacademy/platform/internal/modules/assessments	[no test files]
?   	github.com/gobackendacademy/platform/internal/modules/case_studies	[no test files]
?   	github.com/gobackendacademy/platform/internal/modules/curriculum	[no test files]
ok  	github.com/gobackendacademy/platform/internal/modules/diagnostics	0.159s
?   	github.com/gobackendacademy/platform/internal/modules/exercises	[no test files]
?   	github.com/gobackendacademy/platform/internal/modules/lessons	[no test files]
?   	github.com/gobackendacademy/platform/internal/modules/recommendations	[no test files]
?   	github.com/gobackendacademy/platform/internal/modules/sql_playground	[no test files]
?   	github.com/gobackendacademy/platform/internal/platform/database	[no test files]
?   	github.com/gobackendacademy/platform/internal/platform/http	[no test files]
?   	github.com/gobackendacademy/platform/internal/platform/logger	[no test files]
?   	github.com/gobackendacademy/platform/internal/shared	[no test files]
?   	github.com/gobackendacademy/platform/migrations	[no test files]
?   	github.com/gobackendacademy/platform/seed	[no test files]
ok  	github.com/gobackendacademy/platform/tests	1.027s
```

---

## 3. Docker Compose Configuration Audit

### Perintah:
```powershell
cd c:\Users\12\Downloads\projects\go-backend-academy
docker compose config
```

### Hasil Nyata:
```
Exit code: 1
Output:
docker : The term 'docker' is not recognized as the name of a cmdlet, function, script file, or operable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
```
*Catatan teknis:* CLI Docker tidak diinstal di environment Windows lokal ini.

### Audit Sintaks & Konfigurasi Statis `docker-compose.yml`:
Isi layanan yang terdefinisi pada `docker-compose.yml`:
1. `academy-server`:
   - Ports: `${PORT:-8080}:8080`
   - DB_DRIVER: `${DB_DRIVER:-postgres}` (perlu diubah menjadi hardcoded `DB_DRIVER=postgres` pada Fase 1 sesuai F-02).
   - Depends on: `postgres` (condition: `service_healthy`).
2. `postgres`:
   - Image: `postgres:17-alpine`
   - Healthcheck: `pg_isready -U ${POSTGRES_USER:-academy} -d ${POSTGRES_DB:-gobackendacademy}`.
3. `redis` (profil `cache`):
   - Image: `redis:7.4-alpine`
4. Volumes: `pgdata`, `appdata`.
