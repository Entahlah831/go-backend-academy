# MASTER PLAN — Go Backend Academy
**Audit fitur · Kurikulum · Diagnostik · Penilaian UI · Backlog perbaikan**

- Situs: https://academy.entahlah831.uk/
- Tanggal audit: 7 November 2026
- Bahasa dokumen: Indonesia (kode & ID teknis tetap Inggris)

---

## 0. CARA PAKAI DI ANTIGRAVITY

1. Simpan file ini di root repo sebagai `MASTER_PLAN.md`.
2. Buka repo di Antigravity, lalu beri agent instruksi dari **Bagian 12**.
3. Kerjakan **per fase** (Bagian 10). Satu fase = satu branch/commit set. Jangan minta agent mengerjakan semuanya sekaligus.
4. Setelah tiap fase, jalankan **Checklist Tes Manual (Bagian 11)** dan minta agent menulis `CHANGELOG.md`.

**Aturan untuk agent (wajib):**
- Langkah pertama SELALU audit repo: struktur file, stack (single HTML? bundler? framework?), cara data lesson disimpan, cara progress disimpan. Dokumen ini tidak tahu isi repo.
- Jangan menghapus konten lesson yang sudah ada. Perluas, bukan ganti.
- Semua klaim versi/angka di Bagian 8 harus diverifikasi ke sumber resmi sebelum diubah.
- Setiap perubahan harus punya acceptance criteria yang lulus (Bagian 10).

---

## 1. BATASAN AUDIT (BACA DULU)

Audit ini **tidak sepenuhnya "klik satu-satu"**. Yang benar-benar bisa saya akses hanyalah **HTML statis** halaman utama. Konsekuensinya:

| Hal | Status |
|---|---|
| Struktur halaman, label menu, teks tombol, daftar fitur, contoh kode sampel | ✅ Terbaca |
| Isi 24 lesson (dirender JavaScript setelah klik) | ❌ Tidak terbaca |
| Hasil tombol "Run Verification Suite", "Execute SQL", "Run Offline Diagnostics", simulasi HTTP | ❌ Tidak bisa dijalankan |
| Tampilan visual nyata (warna, spasi, kontras, mobile) | ❌ Tidak terlihat, hanya dinilai dari struktur teks |
| Perilaku progress (apakah tersimpan di localStorage) | ❌ Tidak bisa diuji |

Karena itu setiap temuan diberi label:
- **[TERLIHAT]** dibuktikan dari HTML/teks halaman.
- **[VERIFIKASI]** dugaan beralasan, harus dites manual (Bagian 11) atau oleh agent di repo.
- **[REKOMENDASI]** saran perbaikan, bukan klaim tentang kondisi sekarang.

Penilaian UI di Bagian 4 bersifat **sementara** sampai dites di browser desktop + HP.

---

## 2. RINGKASAN EKSEKUTIF

**Konsep:** platform belajar Go backend satu halaman dengan siklus *Understand → Experiment → Implement → Debug → Compare → Optimize → Apply*, 24 lesson (Level 0–10), lab SQL, lab HTTP, lab concurrency, lab arsitektur, diagnostik kode, 14 studi kasus, flashcard, quiz, catatan.

**Kekuatan [TERLIHAT]**
- Ide kurikulum sangat lengkap dan berorientasi produksi (bukan sekadar sintaks).
- Setiap lesson punya 3 tingkat penjelasan (Beginner / Intermediate / Advanced) dan pasangan kode "salah vs benar".
- Jujur soal batas: simulasi ditandai "Deterministic Educational Middleware Simulation", diagnostik punya label `confirmed_diagnostic / potential_issue / educational_heuristic`.
- Tersedia dark mode, bookmark, catatan, flashcard, quiz.

**Masalah utama**
1. **Tidak ramah pemula pada halaman pertama** [TERLIHAT]: banyak istilah berat (BOLA, SSRF, GMP, WAL, hexagonal) tanpa penjelasan, 11 menu sekaligus, tidak ada "Mulai di sini".
2. **Klaim "100% Offline" membingungkan** [TERLIHAT]: situs dibuka lewat internet, dan ada link ke dokumentasi eksternal. Perlu definisi jelas (PWA? file ZIP?).
3. **Nama fitur lebih besar dari kemampuannya** [VERIFIKASI]: "Go Code Playground" tampaknya hanya template untuk disalin dan dijalankan lokal, bukan eksekusi Go di browser. "Run Verification Suite" dan "EXPLAIN ANALYZE" kemungkinan simulasi.
4. **Diagnostik berbasis aturan, bukan AI** [TERLIHAT: `AI_PROVIDER=none`]: cakupan hanya ±9 rule, sementara kode sampel sendiri mengandung ≥10 masalah (Bagian 7).
5. **Bahasa Inggris saja** [TERLIHAT]: hambatan besar untuk pembelajar Indonesia.
6. **Versi di konten perlu dicek** (Go 1.23+, Redis 7.4, dll.) [Bagian 8].

**Skor sementara (1–10)**

| Aspek | Skor | Catatan |
|---|---|---|
| Kelengkapan konsep | 8.5 | Sangat luas |
| Ramah pemula | 4.5 | Jargon dan beban kognitif tinggi |
| Kejelasan klaim fitur | 5.5 | "Offline", "Playground", "Verification" ambigu |
| Diagnostik | 5.0 | Aman tapi dangkal |
| Konsistensi konten | ? | Perlu tes isi lesson |

---

## 3. INVENTARIS FITUR & HASIL CEK

| # | Fitur | Yang terlihat | Status | Temuan | Solusi |
|---|---|---|---|---|---|
| 1 | Dashboard Home | Progress 0%, 4 statistik, kartu lab, "Recommendation Engine" | [TERLIHAT] | Teks hero panjang dan abstrak. Statistik "Zero fabricated activity" jargon internal, tidak berguna bagi pelajar | Ganti hero dengan: "Belajar backend Go dari nol, 24 lesson, praktik langsung." + 1 tombol "Mulai Lesson 1" |
| 2 | Learning Roadmap L0–L10 | Hierarki Path → Level → Module → Lesson | [TERLIHAT] | Menu #2 dan #3 (Roadmap vs Curriculum) tumpang tindih | Gabung jadi satu "Kurikulum"; tampilkan sebagai peta jalur dengan status (terkunci/terbuka/selesai) |
| 3 | Lesson viewer | Diagram internals, 3 level penjelasan, 12-Point Analysis, Defective vs Production, latihan, hint, compare solution, reset | [TERLIHAT] label, [VERIFIKASI] isi | "12-Point Engineering Decision Analysis" terlalu berat untuk pemula | Default tampil ringkas (Tujuan, Analogi, Contoh). 12-point disembunyikan di tab "Lanjutan" |
| 4 | Verification Suite | Tombol ▶ Run, output "Click ▶ Run…" | [VERIFIKASI] | Browser tidak bisa menjalankan Go tanpa WASM. Kemungkinan hanya cek string/regex, rawan lulus palsu | Tampilkan label jujur ("Cek pola, bukan eksekusi"), atau jalankan Go nyata (Bagian 7 Tier 1) |
| 5 | SQL Playground | Dataset terisolasi, toggle B-Tree/Partial Index, EXPLAIN (ANALYZE, BUFFERS) | [VERIFIKASI] | `EXPLAIN (ANALYZE, BUFFERS)` adalah sintaks PostgreSQL. Jika engine di browser SQLite (sql.js), output itu pasti simulasi | Beri badge "Simulasi" vs "Eksekusi nyata". Opsi: pakai PGlite (Postgres WASM) untuk eksekusi nyata |
| 6 | 10 skenario DB × 7 engine | PostgreSQL 18, MySQL 8.4, MariaDB 11.4, SQLite, MongoDB 8.0, Redis 7.4, Scylla/Cassandra | [TERLIHAT] | Perlu cek versi (Bagian 8). Matriks 15 dimensi bisa overwhelming | Tambah "pohon keputusan 5 pertanyaan" sebelum tabel besar |
| 7 | HTTP Lifecycle Simulator | Method GET/POST/PUT/PATCH/DELETE, 4 preset, header & body | [TERLIHAT] | Bagus dan jujur ("simulation"). Preset 2–4 (BOLA, PUT vs PATCH, SSRF) terlalu lanjut sebagai preset awal | Tambah preset 0: "GET /hello" dan "POST /users valid vs invalid" |
| 8 | Go Code Playground | 4 template + switcher 5 library DB (sqlc+pgx, database/sql, Bun, GORM, Ent) | [TERLIHAT] | Namanya menyiratkan eksekusi. Tombol "Run Offline Diagnostics" bukan run kode | Ganti nama jadi "Template Kode"; atau tambah runner Go WASM / link Go Playground |
| 9 | Concurrency Lab | Simulasi worker pool (workers, jobs, timeout), 4 hazard | [TERLIHAT] | Visual bagus untuk konsep. Tidak jelas apakah animasi sinkron dengan kode | Tampilkan kode di samping animasi dengan highlight baris aktif |
| 10 | Architecture Lab | 5 pola | [TERLIHAT] | Tidak ada isi terlihat | Tambah struktur folder interaktif + "kapan jangan pakai" |
| 11 | Code Review & Diagnostics | Sampel multi-bug, Run Offline Diagnostics, rule GO-SEC/DB/CONC/ERR/PERF | [TERLIHAT] | Cakupan rule < jumlah masalah di sampel sendiri | Bagian 7 |
| 12 | Real-World Projects | 14 blueprint × 15 bagian | [TERLIHAT] | Sangat besar, risiko tidak selesai/tidak konsisten | Tandai tingkat kesulitan, mulai dari 3 proyek "starter" |
| 13 | Flashcards (10) | Flip card | [TERLIHAT] | Hanya 10 kartu untuk 24 lesson | Target ≥ 5 kartu per lesson (≥ 120) |
| 14 | Quiz | Skor 0/5 | [TERLIHAT] | Hanya 5 soal, tidak jelas per lesson | Quiz per lesson (3–5 soal) + penjelasan jawaban salah |
| 15 | Catatan & Bookmark | Save Note, daftar bookmark | [VERIFIKASI] | Apakah tersimpan permanen? | Tes reload; tambah export/import JSON |
| 16 | Pencarian "Knowledge Base" | Hasil + tombol Clear | [VERIFIKASI] | Tidak diketahui kualitas pencarian | Tes query "goroutine", "index", "sql injection" |
| 17 | Dark/Light toggle | Tombol ☀/☾ | [TERLIHAT] | Hanya simbol, label aksesibilitas tidak jelas | Tambah `aria-label` dan simpan preferensi |
| 18 | Link dokumentasi resmi | go.dev, Go Spec, pkg.go.dev, PostgreSQL, SQLite, OWASP API 2023 | [TERLIHAT] | Bagus untuk kredibilitas | Tambah link per lesson, bukan hanya di header |

---

## 4. PENILAIAN UI — RAMAH PEMULA?

**Verdict sementara: BELUM ramah pemula (±4.5/10).** Cocok untuk developer menengah yang ingin naik level, bukan untuk orang yang baru belajar Go.

### 4.1 Rubrik

| Kriteria | Skor /5 | Alasan |
|---|---|---|
| Orientasi ("harus mulai dari mana?") | 2 | Tidak ada CTA "Mulai dari sini" yang jelas selain tombol kurikulum |
| Kejelasan bahasa | 2 | Jargon tinggi, bahasa Inggris saja |
| Beban kognitif | 2 | 11 menu + 7 level alur + 12 poin analisis |
| Progres & motivasi | 4 | Progress bar, checklist, rekomendasi, flashcard |
| Umpan balik latihan | 3 | Ada hint, solusi, reset (isi belum teruji) |
| Struktur belajar | 4 | Level 0–10 terurut, 3 kedalaman penjelasan |
| Aksesibilitas | 3 | Dark mode ada; label/kontras/keyboard belum teruji |
| Mobile | ? | Meta viewport ada; layout belum teruji. Tabel 15 dimensi dan 7 DB berisiko |

### 4.2 Temuan & solusi

1. **Tidak ada jalur "Mulai di sini".**
   Solusi: dashboard menampilkan 3 kartu — "Baru mulai", "Sudah bisa dasar Go", "Mau fokus backend/DB". Tiap kartu menuju lesson berbeda. Tambah placement quiz 8 soal.
2. **Navigasi 11 menu sekaligus.**
   Solusi: kelompokkan jadi 3 — *Belajar* (Kurikulum, Latihan), *Lab* (SQL, API, Concurrency, Arsitektur, Diagnostik), *Referensi* (Proyek, Flashcard/Quiz). Untuk pemula, lab disembunyikan sampai lesson terkait selesai atau diberi tanda "Lanjutan".
3. **Jargon tanpa penjelasan.**
   Solusi: komponen `<Term>` yang menampilkan tooltip definisi 1 kalimat + halaman Glosarium. Daftar minimal ada di Bagian 6.4.
4. **Pembukaan lesson langsung teknis.**
   Solusi: urutan wajib per lesson → Tujuan (1 kalimat) → Analogi kehidupan nyata → Contoh paling kecil → Latihan 5 menit → baru detail.
5. **Hanya Bahasa Inggris.**
   Solusi: i18n minimal `id` + `en`. Prioritas terjemahkan: dashboard, lesson L0–L3, tooltip, pesan error diagnostik.
6. **Pesan "Click ▶ Run…" tanpa panduan.**
   Solusi: empty state yang berisi "Apa yang akan terjadi / Contoh output / Tombol coba sekarang".
7. **Tidak jelas fitur mana simulasi vs nyata.**
   Solusi: badge konsisten di pojok tiap lab: `SIMULASI` / `EKSEKUSI NYATA` / `JALANKAN DI LAPTOP`.
8. **Istilah "Offline" ambigu.**
   Solusi: Bagian 8.1.
9. **Ikon ☀/☾ dan tombol tanpa teks.**
   Solusi: `aria-label`, fokus keyboard terlihat, kontras ≥ 4.5:1 (WCAG AA).
10. **Statistik dashboard tidak bermakna bagi pemula** ("Exercises Verified 0/24 Passed", "Zero fabricated activity").
    Solusi: ganti jadi "Lesson selesai", "Streak belajar", "Langkah berikutnya".

### 4.3 Checklist UI siap rilis

- [ ] Satu CTA utama di atas fold
- [ ] Alur pemula bisa selesai Lesson 1 tanpa membuka menu lain
- [ ] Semua istilah teknis pertama kali muncul punya tooltip
- [ ] Badge Simulasi/Nyata di semua lab
- [ ] Tes di layar 375 px: tabel scroll horizontal, tombol ≥ 44 px
- [ ] Navigasi keyboard lengkap (Tab/Enter/Esc)
- [ ] Preferensi tema & progress tersimpan setelah reload
- [ ] Bahasa Indonesia untuk jalur pemula

---

## 5. KURIKULUM — ANALISIS & TARGET

### 5.1 Analisis

- Terlihat: 24 lesson, Level 0–10 [TERLIHAT]. **Judul tiap lesson tidak terbaca**, jadi agent harus memetakan lesson yang ada ke tabel target di bawah.
- Risiko: kurikulum condong ke topik produksi (security, DB internals, arsitektur) sementara fondasi (error, interface, testing) mungkin tipis.
- Kriteria "lesson sehat": tujuan terukur, prasyarat jelas, latihan yang bisa dikoreksi, kesalahan umum, referensi resmi.

### 5.2 Kurikulum target (24 lesson, bisa dipetakan ke Level 0–10)

| Level | No | Lesson | Hasil belajar (bisa dilakukan setelahnya) |
|---|---|---|---|
| 0 | 0.1 | Setup & cara kerja Go | Install Go, `go mod init`, `go run`, baca pesan error compiler |
| 1 | 1.1 | Tipe, variabel, fungsi, control flow | Menulis fungsi dengan banyak return value |
| 1 | 1.2 | Slice, map, struct, pointer | Menjelaskan nilai vs pointer, kapan slice berbagi memori |
| 2 | 2.1 | Error handling | Membungkus error (`%w`), `errors.Is/As`, tidak `panic` untuk input user |
| 2 | 2.2 | Interface & composition | Membuat interface kecil di sisi pemakai |
| 2 | 2.3 | Package, module, testing dasar | Table-driven test, struktur folder sederhana |
| 3 | 3.1 | HTTP server dengan `net/http` | Handler, routing, status code benar |
| 3 | 3.2 | JSON, validasi, batas ukuran body | Decode aman, `http.MaxBytesReader`, error 400 |
| 3 | 3.3 | Middleware & `context` | Logging, timeout, request ID |
| 4 | 4.1 | SQL dasar & desain tabel | SELECT/JOIN, primary/foreign key, index dasar |
| 4 | 4.2 | `database/sql` aman | Query berparameter, `Rows.Close`, `Rows.Err`, `QueryContext` |
| 4 | 4.3 | Transaction & migration | Commit/rollback, isolation level dasar, migrasi versi |
| 5 | 5.1 | Goroutine & channel | Jelaskan buffered vs unbuffered, hindari goroutine bocor |
| 5 | 5.2 | `sync`, race, mutex | Deteksi race dengan `-race`, pilih Mutex vs channel |
| 5 | 5.3 | `context` & worker pool | Pool terbatas yang bisa dibatalkan |
| 6 | 6.1 | Testing HTTP & DB | `httptest`, fake/mocking, test integrasi |
| 6 | 6.2 | Profiling & benchmark | `go test -bench`, `pprof`, baca flame graph sederhana |
| 7 | 7.1 | Keamanan API (OWASP API Top 10) | Cegah BOLA, SSRF, SQL injection, mass assignment |
| 7 | 7.2 | AuthN/AuthZ | Hash password, JWT/session, kontrol akses per resource |
| 8 | 8.1 | Layered → Hexagonal | Memisahkan domain dari transport/DB |
| 8 | 8.2 | Modular monolith vs microservices | Memilih arsitektur dengan alasan |
| 9 | 9.1 | Config, logging, observability | `slog`, metrics, health check |
| 9 | 9.2 | Graceful shutdown, Docker, deploy | Menangani SIGTERM, image kecil, rolling deploy |
| 10 | 10.1 | Capstone | Membangun API lengkap + review diagnostik |

### 5.3 Prinsip pengurutan
- Level 0–2 wajib sebelum lab DB/Concurrency terbuka.
- Setiap lesson punya prasyarat eksplisit (field `prerequisites`).
- Studi kasus (14 blueprint) diberi level: 3 starter (URL shortener, todo API, auth sederhana), 6 menengah, 5 lanjutan.

---

## 6. MATERI — DIPERJELAS & DILENGKAPI

### 6.1 Template lesson (wajib untuk semua 24 lesson)

```yaml
id: "4.2"
title: "database/sql aman"
level: 4
prerequisites: ["2.1", "4.1"]
estimated_minutes: 25
goal: "Menjalankan query ke database tanpa celah SQL injection dan tanpa kebocoran koneksi."
analogy: "Query berparameter seperti formulir dengan kotak isian: isi orang lain tidak bisa mengubah pertanyaannya."
beginner: |
  (maks 150 kata, tanpa jargon)
intermediate: |
  (konsep + kode + alasan)
advanced: |
  (internals: pool koneksi, prepared statement, driver)
defective_code: |
  ...
production_code: |
  ...
why_it_fails: "..."
common_mistakes: ["...", "..."]
exercise:
  prompt: "..."
  starter_code: "..."
  tests: "..."        # test Go nyata, bukan cek string
  hint: ["petunjuk 1", "petunjuk 2"]
  solution: "..."
quiz: [ {q, options, answer, why} ]   # 3-5 soal
flashcards: [ {front, back} ]         # >= 5 kartu
references: ["https://go.dev/doc/..."]
```

Aturan: bagian `beginner` harus bisa dipahami tanpa membuka bagian lain. Bagian "12-Point Analysis" dipindah ke tab Lanjutan.

### 6.2 Contoh lesson yang sudah diperjelas

#### Lesson 2.1 — Error handling

**Tujuan:** menangani kegagalan tanpa `panic` dan tanpa kehilangan konteks.

**Analogi:** error itu seperti resi paket yang ditempeli catatan di tiap titik transit. Tiap fungsi menambah catatan ("gagal di gudang X"), bukan membuang resinya.

```go
// SALAH: error diabaikan, panic untuk input user
body, _ := io.ReadAll(r.Body)
if len(body) == 0 { panic("empty") }

// BENAR
var ErrNotFound = errors.New("user not found")

func GetUser(ctx context.Context, id string) (*User, error) {
    u, err := repo.Find(ctx, id)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrNotFound
        }
        return nil, fmt.Errorf("get user %q: %w", id, err)
    }
    return u, nil
}

// di handler
u, err := GetUser(r.Context(), id)
switch {
case errors.Is(err, ErrNotFound):
    http.Error(w, "not found", http.StatusNotFound)
case err != nil:
    log.Printf("get user: %v", err)
    http.Error(w, "internal error", http.StatusInternalServerError)
default:
    json.NewEncoder(w).Encode(u)
}
```

**Kesalahan umum:** (1) `_ =` pada error, (2) `panic` untuk input user, (3) membocorkan error internal ke klien, (4) membandingkan error dengan `==` padahal sudah dibungkus (pakai `errors.Is`).

**Latihan (5 menit):** ubah fungsi `ReadConfig` yang `panic` menjadi mengembalikan error berlapis, lalu tulis table test untuk 3 kasus.

#### Lesson 4.2 — `database/sql` aman

**Analogi:** menyusun kalimat SQL dengan string biasa seperti menyerahkan kertas kosong ke orang lain untuk dilengkapi; query berparameter mengunci kalimatnya dan hanya membiarkan isian kosong.

```go
// SALAH: SQL injection, tanpa context, rows tidak ditutup
q := fmt.Sprintf("SELECT email FROM users WHERE id = '%s'", id)
rows, err := db.Query(q)

// BENAR (PostgreSQL pakai $1; MySQL/SQLite pakai ?)
func GetEmail(ctx context.Context, db *sql.DB, id string) (string, error) {
    var email string
    err := db.QueryRowContext(ctx,
        "SELECT email FROM users WHERE id = $1", id,
    ).Scan(&email)
    if errors.Is(err, sql.ErrNoRows) {
        return "", ErrNotFound
    }
    if err != nil {
        return "", fmt.Errorf("get email: %w", err)
    }
    return email, nil
}

// Banyak baris
rows, err := db.QueryContext(ctx, "SELECT id, email FROM users WHERE active = $1", true)
if err != nil { return nil, err }
defer rows.Close()
for rows.Next() { /* Scan */ }
if err := rows.Err(); err != nil { return nil, err }
```

**Penting:** parameter tidak bisa dipakai untuk nama tabel/kolom. Untuk itu gunakan allowlist (`map[string]string`), jangan menyambung string dari input.

**Kesalahan umum:** lupa `rows.Close()` (kebocoran koneksi), lupa `rows.Err()`, memakai `SELECT *`, tidak memakai `Context` sehingga query menggantung.

**Latihan:** perbaiki fungsi `Search(name string)` yang rentan, lalu buktikan dengan input `' OR '1'='1`.

#### Lesson 5.3 — Context & worker pool

**Analogi:** worker pool seperti kasir di toko: jumlah kasir tetap, antrean (channel) dilayani bergantian. `context` adalah tombol "tutup toko sekarang" yang didengar semua kasir.

```go
func RunPool(ctx context.Context, workers int, jobs []int,
    fn func(context.Context, int) error) error {

    ctx, cancel := context.WithCancel(ctx)
    defer cancel()

    jobCh := make(chan int)
    errCh := make(chan error, 1) // buffer 1 agar worker tidak tertahan
    var wg sync.WaitGroup

    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for j := range jobCh {
                if err := fn(ctx, j); err != nil {
                    select { case errCh <- err: default: }
                    cancel()
                    return
                }
            }
        }()
    }

loop:
    for _, j := range jobs {
        select {
        case jobCh <- j:
        case <-ctx.Done():
            break loop
        }
    }
    close(jobCh)
    wg.Wait()

    select {
    case err := <-errCh:
        return err
    default:
        return ctx.Err()
    }
}
```

**Uji:** `go test -race ./...`. **Kesalahan umum:** goroutine tanpa jalur keluar, channel tidak ditutup, lupa menghormati `ctx.Done()`.

> Catatan untuk agent: contoh kode di atas harus dikompilasi dan diuji (`go vet`, `go test -race`) sebelum masuk ke konten. Jangan dipercaya mentah.

### 6.3 Materi tambahan yang disarankan (gap umum)

- Konsep dasar yang sering terlewat: zero value, `defer`, method receiver (pointer vs value), `iota`, generics dasar, `slog`, `embed`.
- Lab kesalahan: "Temukan bug" per level (kode kecil dengan 1–2 bug).
- Studi kasus mini 30 menit sebelum blueprint 15 bagian.
- Jalur "Cheat sheet" 1 halaman per level.
- Panduan setup Windows/macOS/Linux (termasuk editor dan `gopls`).

### 6.4 Glosarium minimal (untuk tooltip)

| Istilah | Penjelasan 1 kalimat |
|---|---|
| BOLA | Pengguna bisa mengakses data milik orang lain hanya dengan mengganti ID di URL |
| SSRF | Server dibujuk memanggil alamat internal yang seharusnya tak terjangkau penyerang |
| GMP | Model penjadwal goroutine Go: Goroutine, Machine (thread OS), Processor |
| WAL | Write-Ahead Log: perubahan dicatat dulu ke log sebelum ke file data, demi keamanan crash |
| Idempotency | Mengirim permintaan yang sama berkali-kali memberi hasil akhir yang sama |
| Race condition | Dua goroutine mengubah data yang sama tanpa koordinasi |
| Deadlock | Dua pihak saling menunggu selamanya |
| Middleware | Lapisan yang memproses request sebelum/sesudah handler |
| EXPLAIN | Perintah yang menampilkan rencana eksekusi query |
| Hexagonal | Arsitektur yang memisahkan logika inti dari detail luar (HTTP, DB) lewat interface |

---

## 7. DIAGNOSTIK — EVALUASI & ALTERNATIF

### 7.1 Kondisi sekarang [TERLIHAT]

- Bukan AI: `AI_PROVIDER=none`, rule deterministik: `GO-SEC-001..004`, `GO-DB-001..002`, `GO-CONC-001`, `GO-ERR-001`, `GO-PERF-001`.
- Output diklasifikasi: `confirmed_diagnostic`, `potential_issue`, `educational_heuristic`. Ini praktik yang baik.
- Catatan jujur sudah ada: "tidak ada match bukan berarti aman".

### 7.2 Celah cakupan

Sampel "Multi-Bug" di situs itu sendiri memuat masalah berikut. Agent harus mengecek mana yang terdeteksi dan mana yang lolos:

| # | Masalah di sampel | Usulan ID rule | Jenis |
|---|---|---|---|
| 1 | SQL dibangun dengan `fmt.Sprintf` | GO-SEC/DB (ada, verifikasi) | confirmed |
| 2 | `io.ReadAll(r.Body)` tanpa `MaxBytesReader` | GO-SEC-005 | potential |
| 3 | Error diabaikan (`body, _ :=`) | GO-ERR-001 | confirmed |
| 4 | `regexp.MustCompile` di dalam handler | GO-PERF-001 | confirmed |
| 5 | `panic` di handler untuk input user | GO-ERR-002 | confirmed |
| 6 | `db.Query` tanpa context | GO-DB-002 | potential |
| 7 | `rows` tidak `Close()` / `rows.Err()` tidak dicek | GO-DB-003 | confirmed |
| 8 | Goroutine fire-and-forget tanpa context/timeout | GO-CONC-001 | potential |
| 9 | `http.Get` memakai client default tanpa timeout | GO-NET-001 | confirmed |
| 10 | `resp.Body` tidak di-`Close()` | GO-NET-002 | confirmed |
| 11 | Blank import `net/http/pprof` (endpoint debug terbuka) | GO-SEC-006 | potential |
| 12 | Handler tidak menulis response / `rows` tak dipakai | GO-ERR-003 | heuristic |

Tambahan rule yang umum berguna: `GO-SEC-007` hardcoded secret, `GO-SEC-008` TLS `InsecureSkipVerify`, `GO-CONC-002` loop variable di goroutine (pra Go 1.22), `GO-CONC-003` `time.Sleep` untuk sinkronisasi, `GO-DB-004` transaksi tanpa rollback di jalur error, `GO-HTTP-001` `http.ListenAndServe` tanpa timeout server.

### 7.3 Alternatif diagnostik (dari ringan ke berat)

| Tier | Pendekatan | Cara kerja | Kelebihan | Kekurangan |
|---|---|---|---|---|
| 0 | Rule regex/heuristik (sekarang) | Pencocokan pola di browser | Cepat, offline, deterministik | Banyak false positive/negative, tidak paham struktur kode |
| 1 | **Analisis AST di browser** | Kompilasi `go/parser` + `go/ast` ke WASM (`GOOS=js GOARCH=wasm`), rule ditulis sebagai AST visitor | Akurat jauh lebih baik, tetap offline | Bundle WASM besar (beberapa MB), butuh build step |
| 2 | **CLI toolchain lokal** | Skrip `academy-diag` menjalankan `go vet`, `staticcheck`, `gosec`, `govulncheck`, `golangci-lint` (linter `errcheck`, `sqlclosecheck`, `bodyclose`, `noctx`), keluaran JSON/SARIF | Standar industri, hasil nyata | Perlu Go terpasang di laptop; tidak jalan di browser murni |
| 3 | Aturan Semgrep | Rule YAML mudah ditulis & dibaca pemula | Fleksibel, banyak rule komunitas | Perlu CLI Semgrep |
| 4 | **Penjelas AI opsional** | Rule/linter menemukan masalah, AI hanya *menjelaskan & menyarankan perbaikan*; model lokal (Ollama/WebLLM) atau API key milik pengguna | Penjelasan natural dan bisa Bahasa Indonesia | Bisa salah (halusinasi); jangan dijadikan penentu benar/salah; default OFF |
| 5 | CI | GitHub Actions menjalankan Tier 2 untuk semua template/blueprint | Konten selalu tervalidasi | Hanya di sisi pengembang |

**Rekomendasi:** Tier 0 → **Tier 1** (browser) + **Tier 2** (tombol "Jalankan di laptop" dengan perintah siap salin) + **Tier 4** opsional. Jangan jadikan AI sebagai sumber kebenaran; AI hanya lapisan penjelas.

### 7.4 Desain hibrida (usulan)

```
Kode pengguna
   ├─► Tier 1: AST rules (WASM)  ─┐
   ├─► Tier 2: toolchain lokal   ─┼─► Findings (JSON seragam)
   └─► Tier 0: heuristik         ─┘        │
                                            ├─► UI: severity, baris, penjelasan, tautan lesson
                                            └─► (opsional) AI explainer: "jelaskan temuan ini untuk pemula"
```

Skema temuan:

```json
{
  "rule_id": "GO-DB-003",
  "severity": "high",
  "confidence": "confirmed_diagnostic",
  "line": 18,
  "message_id": "rows tidak ditutup",
  "message_en": "rows is never closed",
  "fix_hint": "tambahkan defer rows.Close() setelah cek err",
  "lesson_link": "4.2",
  "source": "ast-wasm"
}
```

### 7.5 Penyempurnaan UX diagnostik
- Tampilkan tiap temuan dengan baris ditandai, bukan daftar teks saja.
- Tombol "Perbaiki contoh ini" yang menampilkan versi benar + penjelasan.
- Tautan langsung dari temuan ke lesson terkait.
- Dua bahasa (ID/EN) untuk `message` dan `fix_hint`.
- Ringkasan: "5 masalah serius, 3 peringatan, 2 saran" di atas hasil.

---

## 8. AKURASI KONTEN & KLAIM

### 8.1 Klaim "100% Offline"
- Masalah: halaman diakses lewat web dan memuat link eksternal; "offline" tidak jelas.
- Solusi: pilih dan tulis dengan jelas salah satu:
  - **PWA** dengan service worker (bisa diinstal, jalan tanpa internet setelah kunjungan pertama), atau
  - **Paket ZIP/`go run`** yang dijalankan lokal, atau
  - ubah teks menjadi "Berjalan di browser, tanpa API AI/cloud."
- Pastikan tidak ada CDN eksternal wajib (font, library) jika klaim offline dipertahankan.

### 8.2 Versi yang perlu diverifikasi (jangan diubah tanpa cek sumber)

| Item di situs | Catatan | Cek di |
|---|---|---|
| Go 1.23+ | Go hanya mendukung 2 rilis terbaru; 1.23 kemungkinan sudah di luar dukungan. Naikkan baseline | go.dev/doc/devel/release |
| PostgreSQL 18 | Kemungkinan sudah benar; cek rilis minor terbaru | postgresql.org/docs |
| MySQL 8.4 (InnoDB) | Rilis LTS; cek jalur 9.x | dev.mysql.com |
| MariaDB 11.4 | Cek apakah ada LTS yang lebih baru | mariadb.org |
| SQLite 3.40+ | Cek versi stabil terbaru | sqlite.org |
| MongoDB 8.0 | Cek versi terbaru | mongodb.com/docs |
| Redis 7.4 | Redis 8 sudah dirilis dengan perubahan lisensi; pertimbangkan sebut Valkey sebagai alternatif | redis.io, valkey.io |
| OWASP API 2023 | Cek apakah ada edisi baru | owasp.org |
| `alg: EdDSA` di header JWT contoh | Sudah wajar; jelaskan kenapa dipilih | RFC 8037 |

### 8.3 Konsistensi
- Angka "7 DBs • 10 Labs" vs "10 skenario" vs "10 Labs" di menu: samakan definisi dan sumber angka (jangan hardcode ganda).
- Semua contoh kode harus lolos `gofmt`, `go vet`, dan tes. Tambahkan CI yang memvalidasi.

---

## 9. KONSEP FITUR BARU (OPSIONAL, PRIORITAS RENDAH)

- Placement quiz (8 soal) → rekomendasi level awal.
- Mode "Latihan terpandu": satu layar, kode kiri, hasil kanan, hint bertahap.
- Export/import progress + catatan (JSON).
- Lencana per level, streak harian.
- Mode presentasi/cetak untuk lesson.
- Runner Go nyata: Go-WASM (mis. interpreter seperti Yaegi) atau tautan ke Go Playground (online). Beri label jelas.
- PGlite (Postgres WASM) untuk SQL Lab nyata.

---

## 10. BACKLOG UNTUK ANTIGRAVITY (URUT PRIORITAS)

### FASE 0 — Audit repo (wajib dulu)
- [ ] **T0.1** Petakan struktur repo, stack, lokasi data lesson, mekanisme progress. Tulis `docs/AUDIT_REPO.md`.
- [ ] **T0.2** Ekspor daftar 24 lesson (id, judul, level) ke `docs/lessons_inventory.md` dan petakan ke tabel Bagian 5.2.
- [ ] **T0.3** Jalankan checklist tes manual (Bagian 11) secara otomatis bila bisa (Playwright), catat hasil.
  - *Done jika:* ada dokumen audit + daftar lesson + hasil tes.

### FASE 1 — P0: kejujuran & orientasi (cepat, dampak besar)
- [ ] **T1.1** Rapikan hero dashboard + tombol "Mulai Lesson 1". *Done:* satu CTA utama di atas fold.
- [ ] **T1.2** Badge `SIMULASI / EKSEKUSI NYATA / JALANKAN DI LAPTOP` di semua lab. *Done:* tiap lab punya badge dan 1 kalimat penjelasan.
- [ ] **T1.3** Rename "Go Code Playground" → "Template Kode" (kecuali runner nyata dibuat). 
- [ ] **T1.4** Perbaiki teks "100% Offline" sesuai Bagian 8.1.
- [ ] **T1.5** Empty state informatif untuk semua tombol Run.
- [ ] **T1.6** Aksesibilitas dasar: `aria-label`, fokus keyboard, kontras, `lang` attribute.
- [ ] **T1.7** Gabungkan menu Roadmap + Curriculum; kelompokkan navigasi (Belajar/Lab/Referensi).

### FASE 2 — P1: pemula & materi
- [ ] **T2.1** Komponen tooltip istilah + halaman Glosarium (Bagian 6.4). *Done:* ≥ 40 istilah.
- [ ] **T2.2** Terapkan template lesson (Bagian 6.1). Mulai dari L0–L3, lalu sisanya. *Done:* tiap lesson punya tujuan, analogi, kesalahan umum.
- [ ] **T2.3** Pindahkan "12-Point Analysis" ke tab "Lanjutan".
- [ ] **T2.4** Tambah 3 lesson contoh dari Bagian 6.2 (2.1, 4.2, 5.3) bila belum ada atau perluas.
- [ ] **T2.5** Quiz per lesson (3–5 soal) + flashcard ≥ 5/lesson.
- [ ] **T2.6** i18n `id`/`en`; terjemahkan dashboard + L0–L3 + glosarium.
- [ ] **T2.7** Placement quiz + jalur pemula/menengah.
- [ ] **T2.8** Preset HTTP simulator "mudah" (GET /hello, POST valid/invalid).

### FASE 3 — P1: diagnostik
- [ ] **T3.1** Tambah rule 7.2 (GO-SEC-005..008, GO-ERR-002..003, GO-DB-003..004, GO-NET-001..002, GO-HTTP-001).
- [ ] **T3.2** Skema temuan JSON seragam (7.4) + UI baris ditandai + tautan ke lesson.
- [ ] **T3.3** Uji regresi: set kode sampel (bug & bersih) dengan hasil yang diharapkan; CI gagal bila rule berubah tanpa sengaja.
- [ ] **T3.4** Tier 2: skrip `scripts/diag.sh` (go vet, staticcheck, gosec, govulncheck, golangci-lint → JSON) + tombol "Salin perintah".
- [ ] **T3.5** Tier 1 (eksperimen): modul AST di WASM untuk 3 rule awal (SQL injection, rows close, bodyclose).
- [ ] **T3.6** Tier 4 (opsional, default OFF): adaptor `AI_PROVIDER` = `none | ollama | byok`; AI hanya menjelaskan temuan, tidak menentukan status.

### FASE 4 — P2: kualitas
- [ ] **T4.1** CI: `gofmt`, `go vet`, `go test -race` untuk semua blok kode lesson/template (ekstrak otomatis).
- [ ] **T4.2** Verifikasi semua versi (Bagian 8.2) dan perbarui dengan sumber resmi + tanggal "terakhir diperiksa".
- [ ] **T4.3** PWA/service worker bila memilih opsi offline sungguhan.
- [ ] **T4.4** SQL Lab nyata dengan PGlite, atau badge SIMULASI permanen.
- [ ] **T4.5** Export/import progress + catatan.
- [ ] **T4.6** Tes mobile 375 px dan audit Lighthouse (target aksesibilitas ≥ 90).

---

## 11. CHECKLIST TES MANUAL (KARENA TES OTOMATIS BELUM DILAKUKAN)

Jalankan di desktop dan HP. Catat PASS/FAIL.

**Dashboard & navigasi**
- [ ] Muat halaman: tidak ada error di console, tidak ada permintaan jaringan yang gagal
- [ ] Klik tiap dari 11 menu: halaman/section terbuka, tombol Back berfungsi
- [ ] Klik "Start Learning Curriculum" dan "Open Offline Code Diagnostics Lab"
- [ ] Toggle ☀/☾: tema berubah, bertahan setelah reload

**Kurikulum**
- [ ] Buka semua 24 lesson: tidak ada yang kosong/error; catat judul + level
- [ ] Ganti 3 level penjelasan: konten benar-benar berbeda
- [ ] Diagram "Internal Mechanics" tampil (tidak kosong)
- [ ] Kode DEFECTIVE vs PRODUCTION tampil dan bisa disalin
- [ ] Latihan: Show Hint, Compare Solution, Reset, Run Verification Suite
  - [ ] Jalankan dengan kode kosong → harus GAGAL dengan pesan jelas
  - [ ] Jalankan dengan solusi benar → harus LULUS
  - [ ] Jalankan dengan solusi yang diubah sedikit tapi tetap benar → apakah tetap lulus (uji lulus palsu/negatif palsu)
- [ ] Mark Completed → progress bar & statistik berubah, bertahan setelah reload
- [ ] Bookmark → muncul di daftar bookmark

**Lab**
- [ ] SQL Lab: jalankan semua preset; toggle index → rencana query berubah; cek apakah hasil nyata atau statis (jalankan dua kali, apakah angka identik)
- [ ] Skenario 10 DB × 7 engine: semua kombinasi terbuka; matriks terbaca di HP
- [ ] HTTP Simulator: tiap method × tiap preset; cek status code & trace masuk akal (mis. BOLA harus 403/404)
- [ ] Template Go: salin kode, jalankan di laptop `go vet` dan `go test -race`; semua harus kompilasi
- [ ] Concurrency Lab: ubah workers/jobs/timeout (nilai 0, 1, besar, negatif); tidak crash
- [ ] Architecture Lab: 5 pola terbuka dan berbeda

**Diagnostik**
- [ ] Load Multi-Bug Sample → Run: catat rule yang muncul, bandingkan dengan tabel 7.2
- [ ] Load Clean Sample → Run: harus 0 temuan serius
- [ ] Masukkan kode kosong, kode bukan Go, kode sangat panjang: tidak crash
- [ ] Quick Snippet Inspector (modal) sama hasilnya dengan lab penuh

**Latihan & lain-lain**
- [ ] Flashcard: Flip, Next, Previous, batas awal/akhir
- [ ] Quiz: jawab benar & salah, skor berubah, ada penjelasan
- [ ] Catatan: simpan, reload, masih ada
- [ ] Pencarian: "goroutine", "index", "sql injection", kata acak → hasil relevan / pesan kosong yang ramah

**Aksesibilitas & performa**
- [ ] Navigasi keyboard penuh, fokus terlihat
- [ ] Lighthouse: Performance, Accessibility, Best Practices
- [ ] Ukuran total halaman dan waktu muat pertama (3G cepat)

---

## 12. PROMPT SIAP PAKAI UNTUK ANTIGRAVITY

**Prompt A — Audit repo (jalankan dulu)**
```
Baca MASTER_PLAN.md. Kerjakan HANYA Fase 0.
1) Petakan struktur repo dan stack. Tulis docs/AUDIT_REPO.md.
2) Ekstrak 24 lesson (id, judul, level, prasyarat) ke docs/lessons_inventory.md dan petakan ke tabel di Bagian 5.2.
3) Jalankan aplikasi, lakukan checklist Bagian 11 dengan Playwright jika memungkinkan, simpan hasil di docs/TEST_REPORT.md.
Jangan ubah kode produksi. Laporkan temuan yang bertentangan dengan MASTER_PLAN.md.
```

**Prompt B — Fase 1**
```
Kerjakan Fase 1 (T1.1–T1.7) dari MASTER_PLAN.md. Satu commit per tugas.
Setelah selesai, tunjukkan screenshot sebelum/sesudah dashboard dan jalankan checklist UI di Bagian 4.3. Tulis CHANGELOG.md.
```

**Prompt C — Materi**
```
Kerjakan T2.1–T2.5. Gunakan template lesson di Bagian 6.1 dan jangan hapus konten yang ada.
Semua blok kode Go harus dikompilasi: ekstrak ke file sementara, jalankan gofmt, go vet, go test -race. Laporkan blok yang gagal.
```

**Prompt D — Diagnostik**
```
Kerjakan T3.1–T3.4. Buat suite uji regresi: 12 sampel (sesuai tabel 7.2) dengan rule ID yang diharapkan, ditambah 3 sampel bersih yang harus 0 temuan serius.
Pertahankan label confirmed_diagnostic / potential_issue / educational_heuristic.
```

**Prompt E — Verifikasi konten**
```
Kerjakan T4.2. Untuk setiap baris di Bagian 8.2, cari sumber resmi terkini, perbarui konten di situs, dan simpan tanggal + URL sumber di docs/VERSIONS.md.
```

---

## 13. DEFINISI SELESAI (DEFINITION OF DONE)

- Pemula bisa menyelesaikan Lesson 1 dalam < 15 menit tanpa membuka menu lain.
- Setiap lab punya badge jujur (simulasi/nyata/lokal).
- Semua kode Go di lesson lolos `gofmt`, `go vet`, dan tes.
- Diagnostik lulus suite regresi dan tiap temuan terhubung ke lesson.
- Versi/klaim di Bagian 8.2 telah diverifikasi dan bertanggal.
- Checklist Bagian 11 PASS di desktop dan 375 px.

*(Akhir dokumen)*
