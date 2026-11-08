# FIX PLAN — go-backend-academy v2.5.0 → v2.6

Pasangan: `REPORT_Review_go-backend-academy-fixed.md` (ID F-01…F-12 merujuk ke sana).

> **Semua kode di bawah belum saya kompilasi** (Go tidak tersedia di sandbox saya). Perlakukan sebagai patch usulan: jalankan `gofmt`, `go vet`, `go test -race` sebelum dipakai.

## 0. Aturan untuk agent Antigravity
1. Kerjakan per fase (§6). Satu fase = satu branch. Jangan campur.
2. Sebelum mengubah, jalankan baseline: `go vet ./... && go test -race -count=1 ./...` dan simpan hasilnya di `docs/BASELINE.md`.
3. Jangan menghapus materi lesson; perluas.
4. Jangan menulis "Verified/PASS" di dokumen tanpa menyertakan perintah dan output nyata.
5. Setiap perubahan perilaku harus punya test.

---

## 1. Quick wins (±1–2 jam, risiko rendah)

### 1.1 Tutup folder dot dari static handler (F-05)
Di `handleStaticFrontend`, setelah `cleanRel` dihitung:
```go
for _, seg := range strings.Split(filepath.ToSlash(cleanRel), "/") {
    if strings.HasPrefix(seg, ".") {
        WriteProblem(w, r, http.StatusNotFound, "NOT_FOUND", "Resource Not Found", "The requested resource does not exist.")
        return
    }
}
```
Tambahkan `.dockerignore`:
```
.git
.agents
.hallmark
web/.hallmark
tests/academy.db
docs
*.md
```
Lalu hapus `web/.hallmark/` dan `.agents/` dari repo (pindahkan ke luar repo atau ke `tools/`), tambahkan `.gitignore`:
```
.env
*.db
*.db-wal
*.db-shm
bin/
coverage.out
node_modules/
```

### 1.2 Perbaiki compose agar benar-benar Postgres (F-02)
`docker-compose.yml`, bagian `academy-server.environment`:
```yaml
      - DB_DRIVER=postgres          # jangan diinterpolasi dari .env
      - SQLITE_PATH=/app/data/academy.db   # bila suatu saat memakai sqlite di container
```
Dan di README tambahkan: "Untuk jalur SQLite lokal pakai `make run`; untuk Docker gunakan Postgres." Tambahkan di `config.Load()` pada `APP_ENV=production`: tolak `POSTGRES_PASSWORD` kosong atau berisi `change_this`, dan peringatkan `sslmode=disable`.

### 1.3 Hapus angka palsu (F-01)
- `exercises/service.go`: ganti `ExecutionMs: 12` dengan `0` (kolom sudah `DEFAULT 0`) dan jangan tampilkan `(…ms)` di `app-bridge.js` bila 0.
- `app-bridge.js` fungsi `wrapExerciseRunner`: hapus baris `'$ go test -v -race ./...'`, hapus penambahan `expectedOutput` + `ok gobackendacademy/exercise 0.008s`. Ganti judul konsol menjadi **"Cek pola kode (bukan go test)"** dan daftar tiap pola sebagai "Kode harus memuat: …".
- Ubah `expected_output` di seed menjadi deskripsi hasil yang diharapkan ("Fungsi mengembalikan ':8080' saat PORT kosong"), bukan "PASS: TestX".

### 1.4 Perbaikan kecil lain
- `Dockerfile`: `ARG TARGETARCH` dan `GOARCH=${TARGETARCH}`; `alpine:3.22` atau versi terbaru yang didukung [verifikasi ke alpinelinux.org/releases].
- `.env.example`: `ENABLE_LOCAL_GO_TOOLCHAIN=false`.
- `Makefile`: tambahkan `bench` ke `.PHONY`.
- Self-host font (unduh woff2 ke `web/fonts/`) dan hapus `<link>` Google Fonts agar klaim offline jujur; atau ubah klaim menjadi "tanpa API AI/cloud".
- Ganti `Math.random()` di `getActiveUserId` dengan `crypto.randomUUID()`:
```js
uid = 'usr_' + crypto.randomUUID().replace(/-/g, '').slice(0, 32);
```
- Ubah test `TestAll36Exercises…` → `TestAllExercisesServerSideVerification` dan hitung dari jumlah baris tabel `exercises`, bukan angka 41.
- Header komentar `migrations/sqlite/001_initial_schema.up.sql` perbaiki menjadi SQLite.

---

## 2. Perbaikan backend (P0/P1)

### 2.1 Rate limiter di balik proxy (F-03)
Tambah config `TRUSTED_PROXY_CIDRS` (mis. `127.0.0.1/32,172.16.0.0/12`). Fungsi IP klien:
```go
func clientIP(r *http.Request, trusted []*net.IPNet) string {
    host, _, err := net.SplitHostPort(r.RemoteAddr)
    if err != nil {
        host = r.RemoteAddr
    }
    ip := net.ParseIP(host)
    if ip == nil || !inNets(ip, trusted) {
        return host // koneksi langsung: jangan percaya header apa pun
    }
    parts := strings.Split(r.Header.Get("X-Forwarded-For"), ",")
    for i := len(parts) - 1; i >= 0; i-- { // dari kanan: lewati proxy tepercaya
        cand := net.ParseIP(strings.TrimSpace(parts[i]))
        if cand != nil && !inNets(cand, trusted) {
            return cand.String()
        }
    }
    return host
}

func inNets(ip net.IP, nets []*net.IPNet) bool {
    for _, n := range nets {
        if n.Contains(ip) {
            return true
        }
    }
    return false
}
```
Pakai `clientIP` di `RateLimiter.Middleware` menggantikan `SplitHostPort(r.RemoteAddr)`. Test: request dari 127.0.0.1 dengan dua `X-Forwarded-For` berbeda harus punya bucket berbeda; request dari IP tak tepercaya yang memalsukan header harus tetap memakai IP aslinya. Tambahkan juga batas bucket dan pembersihan periodik (goroutine dengan ticker) menggantikan scan O(n) per request.

### 2.2 Runner `go vet` yang aman (F-04)
```go
var vetSem = make(chan struct{}, 2) // maks 2 proses bersamaan

func (a *Analyzer) runIsolatedGoVet(ctx context.Context, goBinary, code string) (executed bool, out string) {
    select {
    case vetSem <- struct{}{}:
        defer func() { <-vetSem }()
    case <-ctx.Done():
        return false, ""
    }
    tmpDir, err := os.MkdirTemp("", "gba-vet-*")
    if err != nil { return false, "" }
    defer os.RemoveAll(tmpDir)

    src := code
    if !regexp.MustCompile(`(?m)^\s*package\s+\w+`).MatchString(src) {
        src = "package main\n\n" + src
    }
    file := filepath.Join(tmpDir, "snippet.go")
    if err := os.WriteFile(file, []byte(src), 0o600); err != nil { return false, "" }

    vctx, cancel := context.WithTimeout(ctx, a.sandboxTimeout)
    defer cancel()
    cmd := exec.CommandContext(vctx, goBinary, "vet", file)
    cmd.Dir = tmpDir
    cmd.Env = []string{ // JANGAN mewarisi env server
        "PATH=" + os.Getenv("PATH"),
        "HOME=" + tmpDir,
        "GOCACHE=" + filepath.Join(os.TempDir(), "gba-gocache"),
        "CGO_ENABLED=0",
        "GOPROXY=off",
        "GOFLAGS=-mod=mod",
        "GOTOOLCHAIN=local",
    }
    b, err := cmd.CombinedOutput()
    if vctx.Err() != nil { // timeout: bukan "bersih"
        return false, "go vet dihentikan (melebihi batas waktu)"
    }
    if err != nil { return true, strings.TrimSpace(string(b)) }
    return true, ""
}
```
Untuk deploy publik, jalankan analyzer di container terpisah (`--network=none --read-only --memory=128m --pids-limit=64 --cpus=0.5`) atau matikan `ENABLE_LOCAL_GO_TOOLCHAIN`. Beri label error kompilasi akibat snippet tanpa import sebagai **"Snippet tidak lengkap"** (bukan `confirmed_diagnostic`).

### 2.3 SQL sandbox (F-10)
Setelah bootstrap dan (bila perlu) drop index, kunci di level engine, lalu ganti cek awalan:
```go
if _, err := db.ExecContext(ctx, `PRAGMA query_only = ON`); err != nil {
    return QueryResponse{}, fmt.Errorf("locking sandbox read-only: %w", err)
}
```
```go
func firstKeyword(q string) string {
    f := strings.FieldsFunc(strings.TrimSpace(q), func(r rune) bool {
        return unicode.IsSpace(r) || r == '(' || r == ';'
    })
    if len(f) == 0 { return "" }
    return strings.ToUpper(f[0])
}
// isReadOnlyStatement: terima bila firstKeyword ∈ {SELECT, WITH, EXPLAIN}
```
Tetap tolak token `ATTACH`, `DETACH`, `PRAGMA`, `load_extension` memakai pemisah kata (regex `\b(ATTACH|DETACH|PRAGMA|LOAD_EXTENSION)\b` pada kode yang literal stringnya sudah dihapus), karena `query_only` tidak mencegah `ATTACH`. Izinkan `;` di dalam string literal dengan menolak hanya bila ada >1 statement setelah literal dibuang. Ganti dataset: buat tabel `orders` ±50.000 baris dengan recursive CTE saat bootstrap (cache DB template per proses via `VACUUM INTO`/salinan, bukan seed ulang tiap request) supaya efek index terlihat.
Test: `SELECT\n1` diterima; `WITH x AS (SELECT 1) DELETE\nFROM customers` ditolak; `SELECT ';'` diterima.

### 2.4 Seed yang bisa diperbarui (F-07)
- Ubah seed menjadi *upsert* (`ON CONFLICT (id) DO UPDATE SET …`) untuk semua tabel konten, dan catat **hash isi** file seed di `schema_migrations` (`seed:<nama>:<sha256>`). Bila hash berubah, jalankan ulang. Tambahkan perintah `-migrate reseed`.
- Hapus `003_v2_5_stage_bridges_and_sections.sql` bila memang duplikat, atau isi dengan konten yang seharusnya (cek di `git log`/backup). Tambahkan test CI: tidak boleh ada dua file seed dengan hash sama.
- Perbaiki `order_index`: unik per `(level_id, order_index)` + kolom `display_no` (mis. `1.7`). Tambah constraint `UNIQUE(level_id, order_index)` pada migrasi 002. `ListLessons` urut `level_number, order_index`.

### 2.5 Satu sumber kebenaran konten (F-07)
Pilih satu: **DB sebagai sumber** (UI memanggil `/api/v1/curriculum` dan `/lessons/{id}`) atau **file konten (YAML/JSON) sebagai sumber** yang membangkitkan seed SQL dan `curriculum-stages.js`. Rekomendasi: file `content/lessons/*.yaml` + generator `go run ./tools/gen-content` yang menghasilkan seed `sqlite/postgres` dan JSON untuk UI; CI gagal bila hasil generate berbeda dari yang ter-commit.

### 2.6 Kuis dinilai di server (F-08)
UI memakai `GET /api/v1/quizzes/{id}` (tanpa kunci) dan `POST …/attempts`. Buang `correctIndex` dari data inline. Rapikan ID (`qz-l04-…`), target ≥3 soal per kuis dan 1 kuis per lesson jembatan.

### 2.7 Autentikasi minimal (P2)
Server menerbitkan sesi saat kunjungan pertama: `Set-Cookie: gba_sid=<32 byte acak base64url>; HttpOnly; Secure; SameSite=Lax`, simpan hash-nya di tabel `sessions`, turunkan `user_id` dari sesi, dan **hentikan** menerima `user_id` dari body/query. Batasi pembuatan sesi per IP dan jumlah/ukuran catatan & percobaan per pengguna. Perbaiki `noteID` memakai UUID.

---

## 3. Verifikasi latihan yang jujur (F-01) — tiga tingkat

### Tier A — jujur sekarang (hari ini)
Lihat §1.3. Tujuan: tidak ada klaim "test lulus" yang tidak nyata. Ganti label tombol menjadi **"Cek Pola Kode"**, dan tampilkan "Ini pengecekan pola, bukan menjalankan program. Jalankan `go test` di laptopmu (perintah di bawah) untuk bukti nyata."

### Tier B — verifikasi struktural dengan `go/parser` (1–2 hari)
Menggantikan substring; tahan terhadap string-stuffing dan perbedaan spasi. Sketsa (belum dikompilasi):
```go
package exercises

import (
    "go/ast"
    "go/parser"
    "go/token"
    "strings"
)

type Rule struct {
    Func     string   // fungsi yang harus ada
    MustCall []string // mis. "os.Getenv", "db.QueryRowContext"
    NoCall   []string // mis. "fmt.Sprintf" untuk SQL
    MustIdentErr bool  // harus memanggil errors.Is, dst. via MustCall
}

func CheckAST(src string, r Rule) (missing []string, err error) {
    fset := token.NewFileSet()
    f, err := parser.ParseFile(fset, "ex.go", src, 0)
    if err != nil {
        return nil, err // tampilkan sebagai "kode belum valid": beri baris/kolom
    }
    var fn *ast.FuncDecl
    for _, d := range f.Decls {
        if fd, ok := d.(*ast.FuncDecl); ok && fd.Name.Name == r.Func {
            fn = fd
        }
    }
    if fn == nil {
        return []string{"fungsi " + r.Func + " tidak ditemukan"}, nil
    }
    seen := map[string]bool{}
    ast.Inspect(fn.Body, func(n ast.Node) bool {
        if c, ok := n.(*ast.CallExpr); ok {
            if s, ok := c.Fun.(*ast.SelectorExpr); ok {
                if id, ok := s.X.(*ast.Ident); ok {
                    seen[id.Name+"."+s.Sel.Name] = true
                }
            }
        }
        return true
    })
    for _, want := range r.MustCall {
        if !seen[want] { missing = append(missing, "harus memanggil "+want) }
    }
    for _, bad := range r.NoCall {
        if seen[bad] { missing = append(missing, "jangan memakai "+bad) }
    }
    if strings.Contains(src, "// STEP:") {
        missing = append(missing, "hapus petunjuk // STEP: setelah selesai")
    }
    return missing, nil
}
```
Simpan aturan di tabel `exercise_rules` (JSON) menggantikan `required_pattern`. Catatan UX: komentar `// STEP:` sebaiknya tidak membuat gagal; cukup abaikan atau beri peringatan lunak.

### Tier C — eksekusi `go test` sungguhan (disarankan sebagai tujuan)
1. Tambah tabel `exercise_tests(exercise_id, filename, test_code)`; satu `_test.go` per latihan. Contoh untuk 0.0A:
```go
package main

import "testing"

func TestResolvePort(t *testing.T) {
    t.Setenv("PORT", "")
    if got := ResolvePort(":8080"); got != ":8080" {
        t.Fatalf("PORT kosong: got %q, want :8080", got)
    }
    t.Setenv("PORT", ":9000")
    if got := ResolvePort(":8080"); got != ":9000" {
        t.Fatalf("PORT diisi: got %q, want :9000", got)
    }
}
```
2. **Opsi lokal (disarankan untuk pemula, tetap "offline")**: unduh paket latihan dan jalankan di laptop:
```bash
go run ./cmd/academy fetch ex-l0-stage-a-what-is-backend   # menulis main.go + main_test.go
go test -v ./...                                            # hasil nyata di terminal sendiri
```
3. **Opsi server**: worker terpisah yang menjalankan `go test` di container `--network=none --read-only --memory=128m --pids-limit=64 --cpus=0.5`, tanpa env server, `CGO_ENABLED=0`, antrean dengan batas konkurensi dan timeout 10 detik. Tampilkan output `go test -json` apa adanya.
4. **Opsi browser**: interpreter Go di WASM (mis. Yaegi) hanya untuk latihan tanpa I/O.
5. Setelah salah satu aktif, "mastered" ditentukan oleh hasil server/test, bukan localStorage.

Uji bukti F-01 (sebelum dan sesudah perbaikan):
```go
// Harus GAGAL setelah Tier B/C diterapkan
package repo
var x = `db.QueryRowContext $1 errors.Is(err, sql.ErrNoRows)`
```

---

## 4. Diagnostik (F-09)

### 4.1 Satu mesin, jelas sumbernya
- Server adalah satu-satunya sumber. Fallback JS hanya saat `file://`, dan UI **wajib** menampilkan badge: `Server (Go)` atau `Browser (versi sederhana)`; jangan menelan error diam-diam.
- Sinkronkan tabel `diagnostic_rules` dengan kode (tambah SEC-007, HTTP-001, VET-001, INFO-000) dan buat test yang gagal bila ada rule ID di kode tanpa baris di tabel atau sebaliknya. Hapus rule yang tak ada (SEC-005, CONC-003, DB-003) dari dokumen atau implementasikan.

### 4.2 Pindah dari substring ke AST
Sketsa untuk rule SQL dinamis dan kueri tanpa context, termasuk SQL yang dibangun di variabel (kasus sampel "Multi-Bug"):
```go
func AnalyzeAST(src string) ([]Finding, error) {
    if !strings.Contains(src, "package ") {
        src = "package main\n" + src
    }
    fset := token.NewFileSet()
    f, err := parser.ParseFile(fset, "snippet.go", src, 0)
    if err != nil {
        return nil, err // "Snippet belum valid Go: baris X" — pesan ramah pemula
    }
    dynamic := map[string]bool{}
    var out []Finding
    add := func(rule string, p token.Pos, msg string) {
        out = append(out, Finding{RuleID: rule, Line: fset.Position(p).Line, Message: msg})
    }
    // Pass 1: variabel yang berisi SQL hasil Sprintf / penjumlahan string
    ast.Inspect(f, func(n ast.Node) bool {
        if as, ok := n.(*ast.AssignStmt); ok && len(as.Lhs) == len(as.Rhs) {
            for i, l := range as.Lhs {
                if id, ok := l.(*ast.Ident); ok && isDynamicSQL(as.Rhs[i], dynamic) {
                    dynamic[id.Name] = true
                }
            }
        }
        return true
    })
    // Pass 2: panggilan database/sql
    ast.Inspect(f, func(n ast.Node) bool {
        c, ok := n.(*ast.CallExpr)
        if !ok { return true }
        s, ok := c.Fun.(*ast.SelectorExpr)
        if !ok { return true }
        name := s.Sel.Name
        switch name {
        case "Query", "QueryRow", "Exec", "QueryContext", "QueryRowContext", "ExecContext":
            idx := 0
            if strings.HasSuffix(name, "Context") { idx = 1 } else {
                add("GO-DB-004", c.Pos(), "Gunakan varian *Context agar kueri bisa dibatalkan")
            }
            if len(c.Args) > idx && isDynamicSQL(c.Args[idx], dynamic) {
                add("GO-SEC-001", c.Pos(), "SQL dibangun dinamis; gunakan placeholder ($1 / ?)")
            }
        }
        return true
    })
    return out, nil
}

func isDynamicSQL(e ast.Expr, dyn map[string]bool) bool {
    switch v := e.(type) {
    case *ast.Ident:
        return dyn[v.Name]
    case *ast.BinaryExpr:
        return v.Op == token.ADD
    case *ast.CallExpr:
        if s, ok := v.Fun.(*ast.SelectorExpr); ok {
            if id, ok := s.X.(*ast.Ident); ok && id.Name == "fmt" && strings.HasPrefix(s.Sel.Name, "Sprint") {
                return true
            }
        }
    }
    return false
}
```
Rule baru yang layak (bernomor tak bentrok dengan yang ada): GO-NET-001 `http.Get`/client tanpa timeout, GO-NET-002 `resp.Body` tak ditutup, GO-DB-003 `rows` tak `Close()` (berbasis variabel, bukan substring file), GO-DB-005 `rows.Err()` tak dicek, GO-HTTP-002 `http.Server` tanpa `ReadHeaderTimeout`, GO-SEC-008 `InsecureSkipVerify: true`, GO-CONC-003 `time.Sleep` sebagai sinkronisasi.

### 4.3 Klasifikasi jujur
- Heuristik regex **tidak boleh** `confirmed_diagnostic`. Hanya hasil compiler/`go vet`/AST pasti yang boleh. Turunkan SEC-007 ke `potential_issue`; kecualikan nilai yang tampak seperti nama env var (`^[A-Z0-9_]+$`) dan kata "Env/Name/Key" pada akhir identifier.
- Turunkan severity CONC-002 menjadi `medium` kecuali variabel dikonfirmasi dibagi antar goroutine (AST: variabel dideklarasikan di luar closure).

### 4.4 AI: selesaikan atau hapus
Bila `AI_PROVIDER=ollama` dipertahankan: panggil `CheckConnection` saat start, tambahkan `Explain(ctx, finding)` yang hanya **menjelaskan** temuan deterministik dalam Bahasa Indonesia, tampil di panel terpisah berlabel "Penjelasan AI (bisa keliru)", timeout 10 detik, tanpa mengubah status temuan. Bila tidak: hapus `OllamaLocalProvider` dan ubah teks status.

### 4.5 Test golden
Buat `internal/modules/diagnostics/testdata/*.go.txt` + `*.expected.json`: 12 sampel bug (satu per rule), 5 sampel bersih (harus 0 temuan serius), dan kasus false positive: `secretEnv := "APP_SECRET"`, `for i := 0; i < n; i++` dalam goroutine, string berisi `panic(`, kata "UPDATE" dalam pesan log. CI gagal bila hasil berubah tanpa memperbarui expected.

---

## 5. Kurikulum & UI pemula (F-06, F-08, F-11)

### 5.1 Perbaikan cepat
1. `recommendations/engine.go`: pengguna tanpa progres → rekomendasikan `l0-stage-a-what-is-backend`; setelah itu urut mengikuti urutan lesson (prasyarat berikutnya yang belum selesai). Hapus hard-code `rec-slice-memory-model` sebagai default. Tambahkan test: snapshot kosong → target 0.0A.
2. Latihan 0.0A: ganti dengan tugas tanpa `os`/`if`, mis. "kembalikan string `\":8080\"` dari fungsi `DefaultPort()`" dan pindahkan `ResolvePort` ke 1.0B/1.0E setelah kondisional diajarkan.
3. Mode **Pemula** (default untuk pengguna baru): tampilkan hanya Tujuan → Analogi → Contoh → Latihan; tab Intermediate/Advanced dan 12 pilar dilipat ("Pelajari lebih dalam").
4. Penomoran ulang dan `order_index` per level sesuai Lampiran A laporan.
5. Hero: satu kalimat ("Belajar backend Go dari nol, 41 pelajaran, praktik langsung") + satu tombol "Mulai Pelajaran 0.1". Pindahkan badge "Zero Cloud AI/100% Offline" ke halaman "Tentang".
6. Ganti nama "Go Code Playground" → "Template Kode" (isinya salin-lalu-jalankan-lokal), tampilkan badge `SIMULASI` / `NYATA (SQLite)` / `JALANKAN DI LAPTOP` di setiap lab.
7. Tambah `lang="id"` bagi konten Indonesia; mulai terjemahkan dashboard, 0.0A–1.0F, glosarium.

### 5.2 Perluasan materi
- Pecah isi satu blok `core` menjadi beberapa `lesson_sections` bertipe: `goal`, `analogy`, `walkthrough`, `pitfalls`, `exercise`, `deep_dive`.
- Target ukuran lesson jembatan: ≥ 5 KB dengan program kecil yang bisa dijalankan (+ keluaran yang diharapkan nyata dari `go run`).
- Tambah lesson (lihat Laporan §5 celah 1–8): membaca error/stack trace; closure; `io.Reader/Writer`; HTTP client; concurrency dipecah; pagination/CORS/envelope error; `httptest`.
- Kuis: ≥3 soal per lesson jembatan (diagnostik pemula), 1 kuis akhir per level.

### 5.3 Perbaikan akurasi konten (kata-kata siap pakai)
- Lesson 5.0 pilar 7: ganti "100% immunity to SQL injection" → "Parameter binding mencegah nilai dari pengguna diubah menjadi bagian dari perintah SQL. Nama tabel/kolom dan `ORDER BY` tidak bisa diparameterkan; gunakan allowlist."
- Pilar 10 dan GO-DB-001: "Jika `rows` tidak ditutup dan iterasi berhenti sebelum `Next()` mengembalikan false (mis. `return` lebih awal atau `break`), koneksi tetap terpakai sampai `rows.Close()` dipanggil. Selalu `defer rows.Close()` dan cek `rows.Err()`."
- Kuis qz-3: tambahkan "(tanpa *skip scan*)" atau perbarui opsi/penjelasan untuk PostgreSQL 18.
- Ganti `last_verified` global dengan tanggal nyata per referensi (hasil pengecekan tautan), atau hapus kolomnya sampai ada proses verifikasi.
- Samakan versi: ambil satu sumber (`go.mod`) dan hasilkan teks "Go x.y+" dari sana; samakan "PostgreSQL 17/18" dengan image compose; perbarui Redis/Alpine setelah dicek ke sumber resmi.
- "14 × 15 Sections" → "14 × 14" atau tambahkan section ke-15.

---

## 6. Backlog terurut untuk Antigravity

### Fase 0 — baseline (½ hari)
- [ ] T0.1 Jalankan `go vet`, `go test -race`, `docker compose config`; simpan output di `docs/BASELINE.md`. *Selesai bila* hasil nyata tercatat.
- [ ] T0.2 Bersihkan repo: `.gitignore`, `.dockerignore`, pindahkan `.agents/`, `web/.hallmark/`, `tests/academy.db`; gabung/hapus dokumen duplikat (`IMPROVEMENT_ROADMAP.md`, `REMEDIATION_REPORT.md` di root); satukan audit ke maksimal 5 dokumen.

### Fase 1 — kejujuran & keamanan dasar (1–2 hari)
- [x] T1.1 §1.3 hapus output `go test` palsu & `execution_ms` palsu. *Selesai bila* tidak ada string `$ go test` atau `ok  \tgobackendacademy` di `app-bridge.js`.
- [x] T1.2 §1.1 blokir dotfile + `.dockerignore`. *Selesai bila* `curl /.hallmark/compare.html` → 404.
- [x] T1.3 §1.2 compose memakai Postgres; guard produksi di config.
- [x] T1.4 §2.1 trusted proxy + test.
- [x] T1.5 §2.2 runner `go vet` aman; `ENABLE_LOCAL_GO_TOOLCHAIN=false` default.
- [x] T1.6 §2.3 sandbox `query_only` + perbaikan prefix; 3 test.
- [x] T1.7 Pernyataan klaim: perbaiki §5.3, versi, "14×15", font offline.

### Fase 2 — pemula (2–4 hari)
- [x] T2.1 §5.1 poin 1–7 (rekomendasi, 0.0A, mode Pemula, penomoran, hero, badge, i18n awal).
- [x] T2.2 Glosarium + tooltip (≥40 istilah, lihat daftar di audit pertama).
- [x] T2.3 Kuis server-side + ≥3 soal per lesson jembatan (§2.6).

### Fase 3 — verifikasi & diagnostik (1–2 minggu)
- [x] T3.1 Tier B AST verifier untuk 41 latihan (tabel `exercise_rules`).
- [x] T3.2 Tier C: tabel `exercise_tests`, CLI `academy fetch`, uji lokal. Opsional worker kontainer.
- [x] T3.3 §4.1–4.5 satu mesin diagnostik, AST rule, golden test, klasifikasi jujur.
- [x] T3.4 Selesaikan atau hapus stub AI (§4.4).

### Fase 4 — konten & arsitektur (selesai)
- [x] T4.1 §2.4 seed upsert + hash; hapus/perbaiki seed 003; unique `order_index`.
- [x] T4.2 §2.5 satu sumber konten + generator + CI diff.
- [x] T4.3 §2.7 sesi server-side.
- [x] T4.4 §5.2 perluasan materi dan celah kurikulum.
- [x] T4.5 CI: `gofmt -l`, `go vet`, `go test -race`, ekstraksi dan kompilasi seluruh `solution_code` dan blok kode lesson, cek tautan referensi (mingguan).

---

## 7. Prompt siap tempel untuk Antigravity

**Prompt 1 — baseline dan kebersihan**
```
Baca FIX_PLAN_go-backend-academy-fixed.md dan REPORT_Review_go-backend-academy-fixed.md.
Kerjakan HANYA Fase 0. Jalankan go vet, go test -race, docker compose config dan simpan output nyata di docs/BASELINE.md.
Lalu kerjakan T0.2. Jangan ubah kode produksi. Laporkan setiap temuan yang berbeda dari laporan.
```

---

## 8. Definisi selesai
- Tidak ada keluaran terminal yang tidak benar-benar dijalankan; "mastered" berasal dari hasil nyata.
- Pengguna baru melihat 0.0A sebagai langkah pertama, dalam bahasa Indonesia, tanpa istilah tak terjelaskan.
- `docker compose up` dari README menjalankan Postgres dan data bertahan; rate limit per IP pengguna di belakang proxy.
- Diagnostik: satu mesin, golden test lulus, tidak ada `confirmed_diagnostic` dari regex.
- Seed dapat diperbarui tanpa menghapus database; tidak ada file seed duplikat.
- Dokumen hanya mengklaim yang dapat dibuktikan dengan perintah di `docs/BASELINE.md`.
