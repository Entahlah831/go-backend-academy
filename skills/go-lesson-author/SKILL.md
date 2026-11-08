---
name: go-lesson-author
description: Authoring rules for Go Backend Academy lessons, exercises, quizzes, prediction labs, and bug-hunt labs. Use when adding or editing curriculum content under content/ or seed/.
---

# go-lesson-author

Skill ini mengatur cara menulis dan memverifikasi konten di Go Backend Academy.
Tujuannya: setiap lesson, latihan, kuis, dan lab punya bentuk yang sama, bisa diverifikasi mesin, dan tidak memberi pass palsu.

Sumber kebenaran konten adalah `content/*.json`. Seed SQL dan data UI dihasilkan dari sana.
Jangan mengedit seed SQL atau `PLATFORM_DATA` di `web/index.html` secara manual.

## 0. Aturan dasar

1. Edit `content/*.json` (atau `content/*.yaml` bila sudah dipindah), lalu jalankan generator.
2. Jangan menulis "PASS", "lulus", atau "selesai" tanpa output perintah yang asli.
3. Kode Go di konten harus lolos `gofmt` dan `go vet`.
4. Jangan memasukkan jawaban (kunci kuis, solusi, klasifikasi bug) ke data yang dikirim ke browser sebelum siswa menjawab.

## 1. Lesson: enam section wajib

Setiap lesson wajib punya enam tipe section. Tipe ini sudah dipakai di `content/curriculum.json` (`section_type`):

| `section_type` | Isi | Syarat |
|---|---|---|
| `goal` | Tujuan dalam konteks backend nyata | 1 paragraf, bukan sintaks saja |
| `analogy` | Analogi dari kehidupan sehari-hari | Tanpa jargon di kalimat pertama |
| `walkthrough` | Program Go kecil yang bisa dijalankan | Lolos `gofmt` dan `go vet`; sertakan output `go run` yang benar |
| `pitfalls` | Minimal 2 kesalahan umum | Tiap kesalahan: kode salah, dampak, perbaikan |
| `exercise` | Instruksi latihan | Harus menunjuk fungsi target yang sama dengan latihan |
| `deep_dive` | Mekanisme internal | Boleh membahas runtime, GC, scheduler, atau storage engine |

Gerbang:
- Total ukuran teks lesson (semua section) minimal **5.000 byte**.
- Tiap lesson harus memiliki enam tipe section di atas. Lesson inti (`core`) boleh ada tambahan, tetapi tidak menggantikan enam tipe tersebut.
- ID section mengikuti pola yang sudah dipakai di `content/curriculum.json`. Cek dulu polanya sebelum menambah lesson baru, jangan menebak.

## 2. Judul dan nomor

- Prefiks angka di `title` harus sama dengan `display_no`. Contoh: `display_no` `1.1` berarti judul dimulai dengan `1.1 `.
- `order_index` unik per `level_id`.

## 3. Latihan

Setiap latihan punya:
- `starter_code`: kerangka dengan komentar `// STEP:`. Starter harus **gagal** verifier.
- `solution_code`: solusi kanonik. Solusi harus **lulus** verifier dan lulus `exercise_tests`.
- Satu baris `exercise_rules` dengan `target_func`, `must_call`, `no_call`, `must_import`, dan `must_contain`.
- Satu baris `exercise_tests` berisi test Go yang menguji perilaku dengan `t.Fatalf` atau `t.Errorf`.

Aturan:
- `must_call` hanya dihitung bila pemanggilan ada di dalam badan `target_func`.
- Isi string literal tidak dihitung untuk `must_contain`.
- Dilarang test yang hanya berisi `t.Log` atau `t.Skip` tanpa asersi. Gunakan `t.Skip` hanya bila tesnya memang belum ada, dan latihan itu tidak boleh masuk gerbang rilis.
- Dilarang memakai `user_id` dari klien sebagai identitas.

Contoh `exercise_tests` yang benar:

```go
func TestDefaultPort(t *testing.T) {
    if got := DefaultPort(); got != ":8080" {
        t.Fatalf("DefaultPort() = %q, want %q", got, ":8080")
    }
}
```

## 4. Kuis

- Minimal **3 soal per level** (Level 0 sampai Level 10). Hitung per level, bukan per kuis.
- Setiap soal punya `options`, `correct_index` yang valid (0 sampai jumlah opsi - 1), dan `explanation`.
- Penjelasan harus menjelaskan kenapa jawaban benar **dan** kenapa pengecoh salah.
- Jangan mengirim `correct_index` ke browser. Penilaian dilakukan di server.

## 5. Lab prediksi output (`content/output_predictions.json`)

Tujuan: siswa menebak output sebelum melihat hasil eksekusi.

Skema per item:

```json
{
  "id": "pred-slice-append-cap",
  "level_id": 2,
  "related_lesson_id": "l1-memory-slices-maps-escape",
  "code": "package main\n\nimport \"fmt\"\n\nfunc main() {\n\ta := make([]int, 2, 3)\n\tb := append(a, 1)\n\tb[0] = 9\n\tfmt.Println(a[0], b[0])\n}",
  "options": ["0 0", "9 9", "9 0", "0 9"],
  "correct_index": 1,
  "explanation": "Kapasitas cukup, jadi b memakai array yang sama dengan a. ...",
  "common_wrong_reasoning": ["Mengira append selalu menyalin array"],
  "output_verified": "9 9"
}
```

Gerbang:
- `output_verified` harus sama dengan output `go run` asli. Generator menjalankan kode di sandbox offline (lihat bagian 8) dan menolak item yang tidak cocok.
- Versi Go yang dipakai harus disebut di item bila perilaku bergantung versi (misalnya semantik loop variable Go 1.22+).
- Minimal 2 item per topik yang ditandai di lesson terkait.

## 6. Lab bug hunt (`content/bug_hunts.json`)

Tujuan: siswa menandai baris yang bermasalah dan memilih klasifikasinya.

Skema per item:

```json
{
  "id": "bug-rows-not-closed-01",
  "related_lesson_id": "l5-stage-e-database-sql-crud-basics",
  "code": "package repo\n\nfunc List(db *sql.DB) ([]string, error) { ... }",
  "bugs": [
    {"line": 6, "class": "resource_leak", "explanation": "rows tidak ditutup pada jalur error."}
  ],
  "allowed_classes": ["security", "resource_leak", "concurrency", "correctness", "none"],
  "hint": "Perhatikan apa yang terjadi pada jalur return lebih awal."
}
```

Gerbang:
- Setiap bug punya `line` yang sesuai dengan kode. Generator memeriksa nomor baris tersebut berisi token yang disebut di `explanation` atau `hint`.
- Snippet harus lolos `gofmt` dan `go vet` agar tidak menjadi bug "sintaks".
- Kunci jawaban dan penjelasan **tidak boleh** dikirim ke browser sebelum siswa menjawab. Penilaian dilakukan di server.
- Jangan membandingkan jawaban siswa dengan dynamic AST. Yang dibandingkan adalah kunci deklaratif di file ini.

## 7. Verifikasi wajib sebelum commit

```powershell
go run ./tools/gen-content -export
go run ./tools/gen-content -verify
gofmt -l .
go vet ./...
go test -count=1 ./tests/... ./internal/...
```

Catatan:
- `gofmt -l .` harus tidak menghasilkan output.
- Untuk deteksi data race, jalankan `$env:CGO_ENABLED=1; go test -race -count=1 ./...`. Ini butuh compiler C (MinGW atau gcc).
- Output asli disimpan ke `docs\TEST_OUTPUT.txt`. Jangan menulis hasil test dari ingatan.

## 8. Gerbang rilis (ringkasan)

Sebuah perubahan konten hanya boleh di-commit bila semua ini benar:

- [ ] Enam tipe section ada, ukuran lesson ≥ 5.000 byte.
- [ ] Judul sesuai `display_no`.
- [ ] Setiap level punya ≥ 3 soal kuis.
- [ ] Setiap latihan punya `exercise_rules`, `exercise_tests`, dan starter yang gagal verifier.
- [ ] Tidak ada test berbasis `t.Log` saja.
- [ ] Tidak ada `user_id` dari klien sebagai identitas.
- [ ] Setiap item prediksi punya `output_verified` yang cocok dengan hasil asli.
- [ ] Setiap item bug hunt punya nomor baris yang valid.
- [ ] `gen-content -verify`, `gofmt -l`, dan `go vet` bersih.

## 9. Yang tidak boleh dilakukan

- Menambah lesson atau latihan tanpa menjalankan `gen-content -verify`.
- Mengedit seed SQL secara manual.
- Menaruh soal atau kunci jawaban di `index.html`.
- Menulis test yang hanya mengecek string dalam kode pengguna.
- Mengubah `go.mod` ke versi lebih lama tanpa memeriksa dependensi dan dokumen versi.
