# AUDIT REPO — Go Backend Academy
**Dokumen Pemetaan Arsitektur, Stack, Data Lesson & Mekanisme Progress (Fase 0 - T0.1)**

- Tanggal Audit: 7 November 2026
- Author: Antigravity Engineering Pair
- Standar: Zero external framework, Go standard library, Dual DB (PostgreSQL / SQLite), Hallmark v2.0.0 UI tokens

---

## 1. Pemetaan Struktur Repositori & Teknologi (Tech Stack)

### A. Backend Architecture & Runtime
- **Bahasa & Kompilator**: Go 1.26 (kompatibel dengan Go 1.22+).
- **Framework Web**: **Zero Framework** (Murni `net/http` standard library). Tidak menggunakan Gin, Fiber, Echo, atau Chi.
- **HTTP Routing & Middleware**: Menggunakan Go standard library HTTP mux dengan pipeline middleware berlapis:
  - `RequestIDMiddleware`: Menghasilkan atau meneruskan header `X-Request-ID`.
  - `StructuredLoggingMiddleware`: Menggunakan `log/slog` bawaan Go 1.21+.
  - `PanicRecoveryMiddleware`: Melindungi HTTP worker goroutine dari fatal abort.
  - `CORSAllowlistMiddleware`: Validasi origin dinamis berdasarkan variabel `CORS_ALLOWED_ORIGINS`.
  - `TokenBucketRateLimiter`: Rate limiter in-memory berbasis token-bucket (konfigurasi RPS & Burst via `.env`).
  - `MaxBytesBodyReader`: Pembatasan ukuran request body (`MAX_REQUEST_BODY_BYTES`, default 1 MiB) untuk mencegah serangan OOM DoS (OWASP API4:2023).
- **Database Engine & Driver**:
  - **PostgreSQL**: `github.com/jackc/pgx/v5/stdlib` untuk koneksi pooled produksi.
  - **SQLite**: `modernc.org/sqlite` (CGO-free pure Go SQLite) dengan konfigurasi WAL journal mode, busy timeout 5000ms, dan `foreign_keys=ON`.
  - **In-Memory**: Mode memori SQLite untuk unit test terisolasi (`DB_DRIVER=memory`).
- **Migrasi Database**:
  - Dikelola secara independen untuk dialek PostgreSQL (`migrations/postgres`) dan SQLite (`migrations/sqlite`).
  - Tabel pelacak versi: `schema_migrations` dengan tracking rollback berdasar jumlah langkah (`-migrate down -steps N`).

### B. Struktur Direktori Repositori
```text
go-backend-academy/
├── cmd/
│   └── server/
│       └── main.go              # Entrypoint server, flag parsing (-env-file, -migrate), graceful shutdown
├── internal/
│   ├── config/                  # LoadDotEnv & parsing environment variables yang ketat
│   ├── platform/
│   │   ├── database/            # Store interface, pgx & modernc sqlite initialization, connection pooling
│   │   ├── http/                # Server HTTP, routing mux, REST handlers, middleware
│   │   └── logger/              # slog text/json logger factory
│   └── modules/                 # Bounded contexts aplikasi:
│       ├── curriculum/          # Module kurikulum & stages
│       ├── exercises/           # Evaluasi latihan server-side & anti-tampering
│       ├── lessons/             # Repository & handlers lesson
│       ├── case_studies/        # 14 Production case study blueprints
│       ├── sql_playground/      # SQL executor & query plan analysis
│       ├── diagnostics/         # 100% offline static analyzer (11 deterministic rules)
│       └── recommendations/     # Algoritma rekomendasi jalur belajar berbasis state
├── migrations/                  # File DDL SQL migrasi (PostgreSQL & SQLite)
├── seed/                        # Data pembelajaran dasar & studi kasus (PostgreSQL & SQLite)
├── frontend/                    # Source tree Svelte + Vite
├── web/
│   ├── index.html               # Production standalone educational bundle (554 KB)
│   ├── app-bridge.js            # Client-server sync bridge & 4-step stepper logic (24 KB)
│   └── curriculum-stages.js     # Data stages L0-L10 lengkap offline (62 KB)
├── deployments/                 # Konfigurasi Caddy, Nginx, dan systemd unit
├── tests/
│   └── server_integration_test.go # 11 Integration test suites lengkap
├── docker-compose.yml           # Multi-service compose (app, postgres, optional redis)
└── Dockerfile                   # Multi-stage minimal container build (Alpine runtime)
```

---

## 2. Penyimpanan Data Lesson, Kurikulum & Studi Kasus

Aplikasi mendukung arsitektur **Dual-Storage** (Online dengan Database Server + Offline Fallback Mandiri di Browser):

1. **Penyimpanan di Sisi Server (PostgreSQL / SQLite)**:
   - Disimpan pada tabel `lessons`, `case_studies`, `sql_playground_datasets`, dan `exercise_test_cases`.
   - Diisi otomatis saat startup via file seed SQL:
     - `seed/postgres/001_seed.sql` & `002_beginner_stages_seed.sql`
     - `seed/sqlite/001_seed.sql` & `002_beginner_stages_seed.sql`
   - Total konten aktif: **41 Lessons**, **14 Case Studies**, **10 SQL Benchmarking Scenarios**, dan **36 Verified Exercises**.

2. **Penyimpanan di Sisi Client (Offline / In-Bundle)**:
   - Terletak pada file [web/curriculum-stages.js](file:///c:/Users/12/Downloads/projects/go-backend-academy/web/curriculum-stages.js) yang mengekspos objek global `STAGE_DATA` dan `CURRICULUM_STAGES`.
   - `web/app-bridge.js` menggabungkan data lokal ini dengan data server (`/api/v1/curriculum`, `/api/v1/lessons`) saat koneksi HTTP tersedia. Jika pengguna offline (misal membuka file HTML secara lokal), aplikasi tetap 100% berfungsi normal.

---

## 3. Mekanisme Penyimpanan Progress, Catatan & Bookmark

Aplikasi menjamin data pembelajar tidak pernah hilang dengan mekanisme *Graceful Degradation & Dual Sync*:

1. **Client-Side SafeStore (localStorage)**:
   - Menggunakan namespace token aman `gba_v2_*`:
     - `gba_v2_active_user_id`: UUID pengguna aktif.
     - `gba_v2_completed_lessons`: Peta lesson ID yang telah diselesaikan.
     - `gba_v2_passed_exercises`: Peta latihan yang telah lulus verifikasi.
     - `gba_v2_bookmarks`: Daftar penanda buku konten penting.
     - `gba_v2_personal_notes`: Catatan teknis pribadi pembelajar per lesson.
     - `gba_v2_theme_mode`: Preferensi tema gelap atau terang.

2. **Server-Side REST API Persistence**:
   - Setiap interaksi penyimpanan memanggil endpoint backend berikut:
     - `POST /api/v1/progress` (Menyimpan status selesai ke tabel `user_progress`).
     - `POST /api/v1/bookmarks` (Menyimpan item bookmark ke tabel `user_bookmarks`).
     - `POST /api/v1/notes` (Menyimpan catatan ke tabel `user_notes`).
     - `POST /api/v1/exercises/verify` (Mencatat attempt ke tabel `exercise_attempts`).
   - Saat aplikasi pertama kali dimuat, `app-bridge.js` melakukan *hydration* dengan memanggil `GET /api/v1/progress`, `GET /api/v1/bookmarks`, dan `GET /api/v1/notes` secara paralel menggunakan `Promise.all`. Jika server merespons, state lokal diselaraskan secara otomatis.

---

## 4. Analisis Stack Frontend

- **Bundle Utama**: [web/index.html](file:///c:/Users/12/Downloads/projects/go-backend-academy/web/index.html)
  - Dibangun dengan CSS berbasis Hallmark Token System (`--color-surface`, `--color-ink`, `--space-xs`, dll).
  - Mengimplementasikan genre **Modern Minimal** dengan rating `sloplint.mjs` **0 FAIL, 0 REFLEX, 0 WARN**.
  - Bebas dari CDN eksternal: seluruh font, stylesheet, dan logic tersimpan lokal di dalam repositori sehingga 100% dapat dijalankan secara terisolasi tanpa koneksi internet.
