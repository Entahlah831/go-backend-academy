// tools/expand_bridge_content.js
// Generates rich structured lesson_sections (goal, analogy, walkthrough, pitfalls, exercise, deep_dive)
// and expanded quizzes for all levels across SQLite and PostgreSQL seed files.

const fs = require('fs');
const path = require('path');

const sqliteSeedPath = path.join(__dirname, '..', 'seed', 'sqlite', '002_beginner_stages_seed.sql');
const postgresSeedPath = path.join(__dirname, '..', 'seed', 'postgres', '002_beginner_stages_seed.sql');

console.log('Reading existing seed files...');
let sqliteSeed = fs.readFileSync(sqliteSeedPath, 'utf8');

// List of the 17 bridge lessons with structured sections
const bridgeSections = [
  {
    lessonId: 'l0-stage-a-what-is-backend',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan & Konteks Backend',
        body: 'Memahami apa yang sebenarnya dilakukan server backend di balik layar: bagaimana proses sistem operasi membuka socket jaringan, menerima request dari client, berinteraksi dengan database yang aman, dan mengapa client tidak boleh mengakses database secara langsung.'
      },
      {
        type: 'analogy',
        title: 'Analogi Dapur Restoran',
        body: 'Bayangkan sebuah restoran: Menu di meja makan adalah Frontend (apa yang dilihat pelanggan). Dapur tempat memasak adalah Backend (tempat pesanan dicek dan diolah). Gudang bahan baku yang terkunci adalah Database. Pelanggan tidak boleh masuk ke gudang bahan makanan; mereka memberikan pesanan ke loket bernomor (Port jaringan seperti :8080), dan koki di dapur memprosesnya secara teratur.'
      },
      {
        type: 'walkthrough',
        title: 'Program Pertama: Server HTTP Sederhana',
        body: `Program Go berikut membuat server web minimal menggunakan pustaka standar net/http:

\`\`\`go
package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = ":8080"
	} else if port[0] != ':' {
		port = ":" + port
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(\`{"status":"ok","service":"auth-backend"}\`))
	})

	slog.Info("server listening", "port", port)
	if err := http.ListenAndServe(port, mux); err != nil {
		slog.Error("server halted", "error", err)
		os.Exit(1)
	}
}
\`\`\`

Jalankan di terminal laptopmu:
\`\`\`bash
$ go run main.go
2026/11/08 10:00:00 INFO server listening port=:8080
\`\`\`

Buka terminal kedua dan kirim request via curl:
\`\`\`bash
$ curl -i http://localhost:8080/healthz
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 42

{"status":"ok","service":"auth-backend"}
\`\`\``
      },
      {
        type: 'pitfalls',
        title: 'Jebakan Umum Pemula (Anti-Pattern vs Idiomatic)',
        body: `1. Port Hardcoded: Menulis http.ListenAndServe(":8080", nil) tanpa membaca environment variable PORT membuat aplikasi tidak bisa dideploy di Docker/K8s/Heroku/VPS yang membutuhkan port dinamis.
2. DefaultServeMux: Menggunakan http.HandleFunc() global tanpa membuat mux := http.NewServeMux() baru menyebabkan rute mudah tertimpa oleh pustaka pihak ketiga.
3. Mengabaikan Nil Return: ListenAndServe selalu mengembalikan error jika berhenti; periksa error tersebut!`
      },
      {
        type: 'exercise',
        title: 'Latihan Praktik: DefaultPort()',
        body: 'Buat fungsi DefaultPort() string yang mengembalikan string ":8080" secara deterministik tanpa dependensi eksternal, mempersiapkan pemahaman tentang konfigurasi port.'
      },
      {
        type: 'deep_dive',
        title: 'Mekanisme Internal Sistem Operasi & Port',
        body: 'Ketika proses backend memanggil net.Listen("tcp", ":8080"), kernel OS mengalokasikan file descriptor socket, mengikatnya ke port 8080 pada tabel TCP host, dan menyiapkan antrean koneksi (SYN backlog queue). Go netpoller mendaftarkan descriptor ini ke epoll (Linux) atau IOCP (Windows) sehingga ratusan ribu koneksi dapat ditangani tanpa memblokir thread OS.'
      }
    ]
  },
  {
    lessonId: 'l0-stage-a-git-go-workspace',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan Pembelajaran: Git & Toolchain Go',
        body: 'Menguasai workflow pengembangan modern: inisialisasi module Go (go mod init), manajemen package, kompilasi cepat (go build, go run), linter statis (go vet), dan version control dengan Git.'
      },
      {
        type: 'analogy',
        title: 'Buku Catatan Arsitek & Cetak Biru',
        body: 'Git adalah buku catatan revisi arsitek di mana setiap perubahan tercatat rapi dan bisa dibatalkan jika terjadi kesalahan. File go.mod adalah daftar bahan resmi yang menjamin siapa pun yang membangun proyek ini akan mendapatkan versi dependensi yang sama persis.'
      },
      {
        type: 'walkthrough',
        title: 'Langkah Praktis: Membuat Modul Go & Commit Pertama',
        body: `Langkah demi langkah di terminal laptop:

\`\`\`bash
# 1. Buat folder proyek dan inisialisasi modul
$ mkdir my-backend && cd my-backend
$ go mod init github.com/user/my-backend
go: creating new go.mod: module github.com/user/my-backend

# 2. Buat file main.go
$ cat << 'EOF' > main.go
package main

import "fmt"

func main() {
    fmt.Println("Halo Backend Go!")
}
EOF

# 3. Jalankan dan uji kompilasi
$ go run main.go
Halo Backend Go!

$ go vet ./...
# 0 warning!

# 4. Inisialisasi Git dan ignore file biner
$ git init
$ echo "bin/" >> .gitignore
$ echo "*.db" >> .gitignore
$ git add .
$ git commit -m "feat: initial go workspace"
\`\`\`

**Panduan Perintah Esensial Go CLI:**
- \`go run main.go\`: Kompilasi ke memori sementara dan langsung eksekusi. Bagus untuk siklus iterasi lokal cepat.
- \`go build -o bin/server main.go\`: Menghasilkan satu file biner mandiri yang siap dideploy ke server VPS atau container.
- \`go vet ./...\`: Menjalankan penganalisis statis resmi Go untuk mendeteksi kesalahan sintaksis, format string yang keliru, atau pemanggilan fungsi yang berisiko.
- \`go test -v ./...\`: Menjalankan seluruh test suite otomatis dalam proyek.`
      },
      {
        type: 'pitfalls',
        title: 'Jebakan Umum Pemula',
        body: `1. Melakukan commit file binary hasil kompilasi (misal main atau server.exe) ke dalam Git. Selalu tambahkan bin/ ke .gitignore.
2. Mengabaikan peringatan go vet. go vet menangkap kesalahan umum seperti format string yang salah atau unreachable code sebelum runtime.
3. Menyimpan token/rahasia (.env) di dalam Git. Gunakan .env.example untuk template dan simpan .env asli di .gitignore.
4. Mengubah file go.sum secara manual: file go.sum adalah cryptographic checksum yang diverifikasi otomatis oleh compiler Go; jangan pernah mengeditnya dengan tangan!`
      },
      {
        type: 'exercise',
        title: 'Latihan Praktik',
        body: 'Implementasikan fungsi InitWorkspace(name string) string yang memvalidasi nama modul dan mengembalikan pesan status inisialisasi.'
      },
      {
        type: 'deep_dive',
        title: 'Minimal Version Selection (MVS) pada Go Modules',
        body: 'Go tidak menggunakan algoritma pemecah dependensi yang kompleks seperti npm atau pip. Go menggunakan Minimal Version Selection (MVS): versi tertua yang masih memenuhi syarat minimum yang diminta adalah yang dipilih. Ini menjamin build yang 100% dapat direproduksi (reproducible builds) tanpa kejutan pembaruan liar. Jika modul A membutuhkan v1.2 dan modul B membutuhkan v1.3, Go akan memilih tepat v1.3 tanpa menebak-nebak versi terbaru v1.9.'
      }
    ]
  },
  {
    lessonId: 'l1-stage-b-variables-types-zerovalues',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Tipe Primitif & Zero Values',
        body: 'Memahami sistem tipe statis Go: integer (int, int64), floating-point (float64), boolean, string, dan aturan penting "Zero Value" di mana variabel tidak pernah berisi memori sampah.'
      },
      {
        type: 'analogy',
        title: 'Wadah Bersegel Bersih di Gudang',
        body: 'Di bahasa seperti C, mendeklarasikan variabel baru tanpa inisialisasi mengambil memori acak sisa program lain. Di Go, setiap wadah baru otomatis dibersihkan dan disegel dengan nilai nol: angka menjadi 0, boolean menjadi false, string menjadi "" (string kosong), dan pointer/slice menjadi nil.'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Deklarasi & Format String',
        body: `Pelajari kode berikut dan perhatikan perilakunya:

\`\`\`go
package main

import "fmt"

func main() {
	var count int          // Zero value: 0
	var active bool        // Zero value: false
	var title string       // Zero value: ""
	var balance float64    // Zero value: 0.0

	// Deklarasi pendek dengan inferensi tipe
	userID := "usr_9981"
	multiplier := 2.5

	summary := fmt.Sprintf("User: %s | Count: %d | Active: %t | Total: %.2f",
		userID, count, active, float64(count)*multiplier)

	fmt.Println(summary)
}
\`\`\`

Keluaran terminal:
\`\`\`bash
$ go run main.go
User: usr_9981 | Count: 0 | Active: false | Total: 0.00
\`\`\`

**Rincian Verifikasi Tipe Primitif:**
- \`int\` vs \`int64\`: \`int\` bergantung pada arsitektur mesin (32-bit atau 64-bit). Untuk data yang disimpan ke database seperti ID atau mata uang rupiah, selalu gunakan tipe eksplisit \`int64\`.
- \`byte\` adalah alias untuk \`uint8\`, digunakan untuk data mentah biner dan stream jaringan.
- \`rune\` adalah alias untuk \`int32\`, merepresentasikan satu karakter Unicode UTF-8 secara tepat.`
      },
      {
        type: 'pitfalls',
        title: 'Jebakan & Aturan Konversi Tipe',
        body: `1. Tidak ada konversi tipe implisit di Go. int32 tidak bisa langsung dijumlahkan dengan int64 tanpa konversi eksplisit int64(v).
2. Variabel lokal yang dideklarasikan tetapi tidak dipakai akan memicu compile error. Gunakan _ (blank identifier) jika sengaja tidak memakai nilai.
3. String di Go bersifat immutable (tidak bisa diubah sebagian lewat s[0] = 'X').
4. Konversi int ke string dengan string(65) mengembalikan 'A' (karakter ASCII), bukan "65"! Gunakan strconv.Itoa(65) untuk mengubah angka menjadi representasi teks.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: FormatStatus(name string, active bool) string',
        body: 'Buat fungsi FormatStatus yang mengembalikan representasi string berformat "Name: [name] | Active: [active]".'
      },
      {
        type: 'deep_dive',
        title: 'Representasi Memori String di Go',
        body: 'String di Go diwakili oleh struct internal 16 byte (pada arsitektur 64-bit): pointer ke byte array dasar (*byte) dan panjang (int len). Karena sifatnya immutable, operasi pemotongan string (slice s[0:4]) tidak mengalokasikan memori baru di heap, melainkan hanya membuat string header baru yang menunjuk ke array yang sama. Operasi penggabungan string dalam loop besar sebaiknya menggunakan strings.Builder untuk menghindari alokasi memori berlebih.'
      }
    ]
  },
  {
    lessonId: 'l1-stage-b-control-flow-loops-functions',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Alur Kendali, For Loops, Closure & Variable Capture',
        body: 'Menguasai struktur kendali if-else, switch, perulangan for (satu-satunya keyword perulangan di Go), fungsi dengan multiple return values, serta semantik closure dan penangkapan variabel loop [Celah 2].'
      },
      {
        type: 'analogy',
        title: 'Inspektur Jalur Perakitan & Kantong Data',
        body: 'If/switch adalah petugas pemeriksa kualitas di pabrik: jika barang rusak, langsung alihkan ke jalur reject (return err). Closure adalah pekerja yang membawa tas ransel berisi catatan dari meja sebelumnya (variabel tertangkap).'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Perulangan, Closure, dan Go 1.22+ Semantics',
        body: `Program berikut menunjukkan penggunaan closure dan perulangan:

\`\`\`go
package main

import "fmt"

func makeMultiplier(factor int) func(int) int {
	// Variabel factor tertangkap oleh closure
	return func(x int) int {
		return x * factor
	}
}

func main() {
	double := makeMultiplier(2)
	fmt.Printf("2 x 5 = %d\\n", double(5))

	items := []string{"auth", "payments", "orders"}
	var printFns []func()

	// Di Go 1.22+, variabel loop dibuat baru pada setiap iterasi
	for _, item := range items {
		printFns = append(printFns, func() {
			fmt.Printf("Processing service: %s\\n", item)
		})
	}

	for _, fn := range printFns {
		fn()
	}
}
\`\`\`

Keluaran terminal:
\`\`\`bash
$ go run main.go
2 x 5 = 10
Processing service: auth
Processing service: payments
Processing service: orders
\`\`\`

**Aturan Penting Multiple Return Values:**
Di Go, fungsi lazimnya mengembalikan nilai hasil dan error berdampingan: \`func Calculate(a, b int) (int, error)\`. Pola idiomatik Go adalah memeriksa error terlebih dahulu (\`if err != nil { return nil, err }\`) lalu membiarkan aliran kode utama tetap berada pada indentasi kiri (happy path unindented).`
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: Variable Shadowing & Pre-1.22 Capture',
        body: `1. Variable Shadowing: Menggunakan if v, err := fn(); err != nil di mana err menimpa err di luar scope, menyebabkan variabel di luar tidak terupdate.
2. Di Go versi sebelum 1.22, variabel loop dibagi di seluruh iterasi sehingga goroutine/closure menangkap nilai terakhir jika tidak di-pass sebagai parameter.
3. Switch tanpa break: Berbeda dengan C atau Java, switch di Go otomatis break di akhir setiap case; Anda tidak perlu menulis break di tiap baris. Jika ingin melanjutkan ke case berikutnya, gunakan kata kunci fallthrough secara eksplisit.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: FilterPositiveNumbers(nums []int) []int',
        body: 'Implementasikan fungsi yang menerima slice integer dan mengembalikan slice baru hanya berisi angka positif (> 0).'
      },
      {
        type: 'deep_dive',
        title: 'Escape Analysis pada Closure',
        body: 'Kompiler Go memeriksa apakah variabel yang ditangkap oleh closure keluar dari scope fungsi pembuatnya (escape to heap). Jika closure dikembalikan sebagai return value, variabel tertangkap dialokasikan di heap melalui GC agar tetap valid saat dipanggil kemudian. Anda dapat memeriksa keputusan escape compiler dengan menjalankan go build -gcflags="-m".'
      }
    ]
  },
  {
    lessonId: 'l1-stage-b-slices-maps-iteration',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Koleksi Data — Slices & Maps',
        body: 'Memahami bagaimana slice dan map bekerja di memori: pointer, length, capacity, pertumbuhan dinamis dengan append(), alokasi bucket pada map, dan pencegahan fatal error concurrent map writes.'
      },
      {
        type: 'analogy',
        title: 'Jendela Geser & Lemari Arsip Berindeks',
        body: 'Array di Go memiliki ukuran tetap. Slice adalah "jendela pandang" fleksibel di atas array. Map adalah lemari arsip dengan label nama kunci, di mana dokumen dapat dicari dalam waktu O(1).'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Slice Pre-Alokasi & Range Map',
        body: `\`\`\`go
package main

import "fmt"

func main() {
	// Pre-alokasi kapasitas mencegah alokasi ulang berulang
	users := make([]string, 0, 4)
	users = append(users, "Alice", "Bob", "Charlie")
	fmt.Printf("Slice len=%d cap=%d items=%v\\n", len(users), cap(users), users)

	// Inisialisasi Map
	roles := map[string]string{
		"usr_1": "admin",
		"usr_2": "member",
	}

	role, exists := roles["usr_1"]
	fmt.Printf("usr_1 role=%s (exists=%t)\\n", role, exists)

	missing, exists := roles["usr_99"]
	fmt.Printf("usr_99 role=%q (exists=%t)\\n", missing, exists)
}
\`\`\`

Keluaran terminal:
\`\`\`bash
$ go run main.go
Slice len=3 cap=4 items=[Alice Bob Charlie]
usr_1 role=admin (exists=true)
usr_99 role="" (exists=false)
\`\`\`

**Prinsip Kerja Perulangan Range:**
Ketika menggunakan \`for key, value := range collection\`, Go menyalin setiap elemen ke dalam variabel iterasi. Jika Anda mengubah \`value\`, elemen asli di dalam slice/map tidak akan berubah! Untuk mengubah elemen slice asli, akses lewat indeksnya: \`users[i] = "NewValue"\`.`
      },
      {
        type: 'pitfalls',
        title: 'Jebakan Umum',
        body: `1. Membaca map tanpa idiom "comma-ok" (val, ok := m[key]). Jika key tidak ada, Go mengembalikan zero value yang bisa salah diartikan sebagai data asli.
2. Mengubah slice yang diturunkan dari slice lain (sub-slicing a[1:3]) bisa memodifikasi array dasar yang sama secara tidak sengaja.
3. Map tidak aman untuk akses bersamaan dari banyak goroutine (bukan thread-safe); gunakan sync.RWMutex atau sync.Map.
4. Menghapus elemen map dengan aman: gunakan fungsi bawaan delete(m, key). Jika key tidak ada, delete() tidak menimbulkan panic.
5. Menahan Memori dengan Sub-slice: Mengambil irisan kecil dari slice raksasa (misal s := hugeSlice[:2]) tetap mengunci seluruh underlying array di RAM. Gunakan copy(dst, src) untuk membebaskan sisa memori ke Garbage Collector.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: CountWordFrequencies(words []string) map[string]int',
        body: 'Buat fungsi untuk menghitung frekuensi kemunculan tiap kata dalam slice string.'
      },
      {
        type: 'deep_dive',
        title: 'Struktur Internal Slice & Map di Runtime Go',
        body: 'Slice header adalah struct 3 kata: ptr *T, len int, cap int (24 byte). Map di Go adalah pointer ke struct runtime.hmap yang mengelola bucket (masing-masing 8 pasangan key-value). Jika load factor melebihi ambang batas (~6.5), map dialokasikan ulang ke jumlah bucket dua kali lipat secara incremental. Mulai Go 1.21+, tersedia fungsi built-in clear(s) dan clear(m) untuk menghapus semua elemen atau menyetel kembali ke zero value tanpa melepaskan kapasitas memori yang telah dialokasikan.'
      }
    ]
  },
  {
    lessonId: 'l1-stage-b-structs-methods-pointers',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Struct, Method, Pointer & Nil Safety',
        body: 'Menguasai perancangan tipe data buatan (struct), penambahan method, perbedaan mendasar antara Value Receiver vs Pointer Receiver, dan pencegahan nil pointer dereference panic.'
      },
      {
        type: 'analogy',
        title: 'Formulir Asli vs Salinan Fotokopi',
        body: 'Ketika Anda memanggil method dengan Value Receiver (func (u User)), Go membuat fotokopi formulir; perubahan pada salinan tidak mengubah yang asli. Dengan Pointer Receiver (func (u *User)), Anda membagikan alamat formulir asli sehingga perubahan langsung tersimpan.'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Pointer vs Value Receiver',
        body: `\`\`\`go
package main

import "fmt"

type Account struct {
	ID      string
	Balance int64
}

// Pointer Receiver: memodifikasi state asli
func (a *Account) Deposit(amount int64) {
	if a == nil {
		return // Nil safety guard!
	}
	a.Balance += amount
}

// Value Receiver: hanya membaca tanpa mutasi
func (a Account) Summary() string {
	return fmt.Sprintf("Account %s: $%d", a.ID, a.Balance)
}

func main() {
	acc := &Account{ID: "acc_001", Balance: 100}
	acc.Deposit(50)
	fmt.Println(acc.Summary())
}
\`\`\`

Keluaran terminal:
\`\`\`bash
$ go run main.go
Account acc_001: $150
\`\`\`

**Kapan Memilih Pointer vs Value?**
1. Jika method perlu memodifikasi isi struct: SELALU gunakan Pointer Receiver.
2. Jika struct berukuran besar (misal > 64 byte): Gunakan Pointer Receiver untuk menghindari penyalinan memori yang lambat pada setiap panggilan method.
3. Jika struct berukuran kecil dan immutable (seperti time.Time atau koordinat Point{X, Y}): Gunakan Value Receiver.
4. Idiom Konstruktor: Gunakan fungsi fabrikasi NewAccount(id string, bal int64) (*Account, error) untuk memvalidasi invariant bisnis sebelum mengembalikan pointer struct yang siap pakai.`
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: Nil Pointer Dereference & Konsistensi Receiver',
        body: `1. Nil Pointer Dereference: Memanggil field dari pointer nil (misal var a *Account; a.Balance) akan menyebabkan runtime panic. Selalu cek if a == nil.
2. Jangan mencampur value dan pointer receiver pada tipe yang sama secara acak. Jika satu method butuh pointer receiver untuk mutasi, buat semua method bertipe pointer receiver.
3. Struct embedding bukan inheritance: struct yang di-embed meneruskan method (composition), tetapi tipenya tetap independen dan tidak bisa di-cast sembarangan.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: NewAccount(id string, initial int64) *Account',
        body: 'Implementasikan constructor NewAccount dengan validasi saldo awal non-negatif.'
      },
      {
        type: 'deep_dive',
        title: 'Memory Alignment & Padding pada Struct',
        body: 'Urutan field dalam struct mempengaruhi ukuran total di RAM karena padding byte untuk alignment 8-byte CPU. Mengurutkan field dari yang berukuran terbesar (int64, string, pointer) ke yang terkecil (bool, byte) dapat menghemat memori hingga 30% pada jutaan instance struct. Gunakan tool "fieldalignment" dari golang.org/x/tools/go/analysis/passes/fieldalignment untuk mendeteksi struct yang boros memori secara otomatis.'
      }
    ]
  },
  {
    lessonId: 'l1-stage-b-interfaces-errors-fundamentals',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Interface, Error Wrapping & Membaca Stack Trace',
        body: 'Menguasai filosofi Go: "Errors are values". Memahami deklarasi interface implisit, teknik membungkus error dengan fmt.Errorf("%w"), pelacakan akar masalah dengan errors.Is dan errors.As, serta cara membaca stack trace panic [Celah 1].'
      },
      {
        type: 'analogy',
        title: 'Sertifikat Standar & Amplop Surat Berantai',
        body: 'Interface di Go tidak butuh kata kunci implements; jika bebek bisa berenang dan bersuara kwek-kwek, maka ia adalah bebek. Membungkus error (%w) ibarat memasukkan surat asli ke dalam amplop berstempel "gagal di modul X", sehingga rantai penyebab tetap utuh hingga ke akar masalah.'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Custom Error & Wrapping',
        body: `\`\`\`go
package main

import (
	"errors"
	"fmt"
)

var ErrNotFound = errors.New("resource not found")

type DatabaseError struct {
	Query string
	Err   error
}

func (e *DatabaseError) Error() string {
	return fmt.Sprintf("db error on query %q: %v", e.Query, e.Err)
}

func (e *DatabaseError) Unwrap() error {
	return e.Err
}

func findUser(id string) error {
	// Menambahkan konteks ke error dasar
	return &DatabaseError{
		Query: "SELECT * FROM users WHERE id = $1",
		Err:   fmt.Errorf("user %s: %w", id, ErrNotFound),
	}
}

func main() {
	err := findUser("usr_404")
	if err != nil {
		fmt.Printf("Log error: %v\\n", err)
		if errors.Is(err, ErrNotFound) {
			fmt.Println("Aksi: Kembalikan HTTP 404 ke client!")
		}
	}
}
\`\`\`

Keluaran terminal:
\`\`\`bash
$ go run main.go
Log error: db error on query "SELECT * FROM users WHERE id = $1": user usr_404: resource not found
Aksi: Kembalikan HTTP 404 ke client!
\`\`\``
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: Panic vs Error & Interface Nil Trap',
        body: `1. Jangan gunakan panic() untuk alur kendali normal atau kesalahan bisnis (seperti user tidak ditemukan). Gunakan return error.
2. Interface Nil Trap: Variabel interface bernilai nil HANYA jika tipe dan nilainya bernilai nil. Jika pointer bertipe konkret nil dimasukkan ke interface error, interface tersebut TIDAK nil (if err != nil akan bernilai true)!
3. Gunakan errors.Is(err, target) alih-alih err == target saat error dibungkus dengan %w.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: WrapNotFoundError(item string) error',
        body: 'Buat fungsi pembungkus yang menyertakan ErrNotFound dengan format yang dapat dideteksi oleh errors.Is.'
      },
      {
        type: 'deep_dive',
        title: 'Anatomi Interface & Cara Membaca Stack Trace',
        body: 'Interface di runtime diwakili oleh struct iface (dua pointer: tab *itab yang menyimpan tipe dan tabel method, serta data unsafe.Pointer). Ketika panic terjadi, Go mencetak stack trace: baris pertama menunjukkan pesan panic, diikuti oleh goroutine ID, nama fungsi, file path, dan nomor baris pemanggil dari dalam ke luar.'
      }
    ]
  },
  {
    lessonId: 'l1-stage-b-json-files-unit-testing',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: JSON Tags, io.Reader/Writer & Unit Testing',
        body: 'Menguasai serialisasi DTO dengan JSON struct tags, abstraksi streaming io.Reader dan io.Writer untuk efisiensi memori [Celah 3], membaca environment variable, dan menulis unit test otomatis dengan testing.T.'
      },
      {
        type: 'analogy',
        title: 'Pipa Air vs Wadah Ember Raksasa',
        body: 'Membaca file atau request HTTP dengan io.ReadAll ibarat menuangkan seluruh isi bendungan ke dalam ember di RAM laptop; jika ukurannya 2 GB, server akan mati (OOM). Abstraksi io.Reader mengalirkan data setetes demi setetes melalui pipa dengan batas aman.'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: json.Decoder dengan io.LimitReader & Test',
        body: `\`\`\`go
package main

import (
	"encoding/json"
	"io"
	"strings"
	"testing"
)

type Config struct {
	AppName string \`json:"app_name"\`
	Port    int    \`json:"port"\`
}

func ParseConfig(r io.Reader) (*Config, error) {
	// Batasi pembacaan maksimal 10 KB untuk mencegah serangan kehabisan memori
	limited := io.LimitReader(r, 10<<10)
	var cfg Config
	dec := json.NewDecoder(limited)
	dec.DisallowUnknownFields() // Tolak field asing
	if err := dec.Decode(&cfg); err != nil {
		return nil, err
	}
	return &cfg, nil
}

func TestParseConfig(t *testing.T) {
	input := \`{"app_name":"backend","port":8080}\`
	cfg, err := ParseConfig(strings.NewReader(input))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if cfg.Port != 8080 {
		t.Errorf("expected port 8080, got %d", cfg.Port)
	}
}
\`\`\`

Jalankan test di terminal:
\`\`\`bash
$ go test -v ./...
=== RUN   TestParseConfig
--- PASS: TestParseConfig (0.00s)
PASS
ok  	my-backend	0.012s
\`\`\`

**Panduan Opsi Tag JSON Go:**
- \`json:"name,omitempty"\`: Jangan menyertakan field jika nilainya adalah zero value (seperti 0, false, atau "").
- \`json:"-"\`: Jangan pernah menyerialisasi field ini (sangat krusial untuk field sensitif seperti PasswordHash).
- \`json:",string"\`: Mengubah angka menjadi string JSON (misal \`100\` menjadi \`"100"\`), bermanfaat untuk kompatibilitas JavaScript int64 precision limit.`
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: Unbounded io.ReadAll & Huruf Kapital Struct Field',
        body: `1. Struct field yang dimulai dengan huruf kecil (unexported) TIDAK AKAN diserialisasi oleh package encoding/json. Selalu gunakan huruf kapital diawal nama field (misal Port, bukan port).
2. Memakai io.ReadAll pada r.Body tanpa pembatasan ukuran membuka celah Denial-of-Service OOM.
3. Membaca file baris demi baris: Jangan membaca seluruh file log ke dalam slice memori; gunakan bufio.NewScanner(file) untuk iterasi streaming yang hemat RAM.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: ParseUserJSON(r io.Reader) (*User, error)',
        body: 'Implementasikan fungsi parser yang memvalidasi bahwa payload JSON memiliki field email non-kosong.'
      },
      {
        type: 'deep_dive',
        title: 'Kontrak io.Reader dan io.Writer di Standar Go',
        body: 'type Reader interface { Read(p []byte) (n int, err error) }. Aturan ketat Go: jika Read membaca n > 0 byte sebelum menemukan akhir stream, ia boleh mengembalikan err == io.EOF atau err == nil pada pemanggilan saat itu. Pengecekan data n > 0 harus selalu diproses sebelum memeriksa err. Pembuatan pipeline pemrosesan data (misal gzip.NewReader membungkus io.LimitReader membungkus net.Conn) adalah inti kekuatan I/O modular di Go.'
      }
    ]
  },
  {
    lessonId: 'l2-stage-c-goroutines-channels-waitgroup',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Konkurensi 101 — Goroutine, Channel & sync.WaitGroup',
        body: 'Mempelajari dasar konkurensi di Go: meluncurkan goroutine ringan (~2 KB), menyinkronkan penyelesaian tugas dengan sync.WaitGroup, mengirim data antar thread secara aman menggunakan channel, dan membedakan konkurensi dari paralelisme [Celah 5].'
      },
      {
        type: 'analogy',
        title: 'Koki Memasak Sarapan',
        body: 'Menyiapkan sarapan secara sekuensial: memanggang roti (2 menit), menunggu selesai, baru merebus air (3 menit) = 5 menit total. Konkurensi berarti memasukkan roti ke pemanggang (go toast()), langsung menyalakan pemanas air (go boilWater()), lalu menunggu di meja (wg.Wait()) sampai keduanya berbunyi = cukup 3 menit!'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Menjalankan Tugas Konkuren Secara Aman',
        body: `\`\`\`go
package main

import (
	"fmt"
	"sync"
	"time"
)

func fetchMetric(id int, ch chan<- string, wg *sync.WaitGroup) {
	defer wg.Done() // Pastikan Done() dipanggil saat fungsi selesai
	time.Sleep(10 * time.Millisecond) // Simulasi I/O
	ch <- fmt.Sprintf("metric_%d: 42.0", id)
}

func main() {
	var wg sync.WaitGroup
	results := make(chan string, 3) // Buffered channel

	for i := 1; i <= 3; i++ {
		wg.Add(1) // Wajib dipanggil sebelum meluncurkan goroutine!
		go fetchMetric(i, results, &wg)
	}

	wg.Wait()
	close(results) // Tutup channel setelah semua produser selesai

	for res := range results {
		fmt.Println("Hasil diterima:", res)
	}
}
\`\`\`

Keluaran terminal:
\`\`\`bash
$ go run main.go
Hasil diterima: metric_1: 42.0
Hasil diterima: metric_2: 42.0
Hasil diterima: metric_3: 42.0
\`\`\``
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: Data Race & Pemanggilan wg.Add di Tempat Salah',
        body: `1. Memanggil wg.Add(1) DI DALAM goroutine: Jika main goroutine mencapai wg.Wait() sebelum anak goroutine mulai dieksekusi, Wait() akan kembali lebih awal!
2. Data Race: Mengubah variabel bersama tanpa sinkronisasi (seperti total += val dari banyak goroutine). Selalu gunakan race detector: go test -race ./...
3. Goroutine Leak: Meluncurkan goroutine yang menunggu channel yang tidak pernah ditulis/ditutup.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: SumSquaresSafe(nums []int) int',
        body: 'Implementasikan kalkulasi jumlah kuadrat yang aman dan bebas dari race condition.'
      },
      {
        type: 'deep_dive',
        title: 'Mekanisme Internal sync.WaitGroup',
        body: 'sync.WaitGroup mengemas penghitung tugas (task counter) 32-bit dan penghitung waiter 32-bit ke dalam satu kata atomic.Uint64 64-bit. Hal ini memungkinkan operasi Add dan Done dieksekusi tanpa lock kernel, hanya memanfaatkan runtime_Semacquire dan runtime_Semrelease saat counter mencapai 0.'
      }
    ]
  },
  {
    lessonId: 'l3-stage-d-first-http-server-crud',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Server CRUD HTTP, Client Timeout & Envelope Error',
        body: 'Membangun API REST JSON lengkap dengan router net/http Go 1.22+, membatasi ukuran payload, mengkonfigurasi http.Client dengan timeout aman [Celah 4], dan mengimplementasikan format response standar RFC 9457 Problem Details [Celah 6].'
      },
      {
        type: 'analogy',
        title: 'Loket Pelayanan Terpadu & Standar Dokumen',
        body: 'Server HTTP adalah loket kantor pos yang memeriksa izin, mengukur berat paket sebelum diterima (MaxBytesReader), dan menolak jika melebihi batas. Jika terjadi kesalahan, kantor pos tidak hanya bilang "gagal", tetapi memberikan lembar resmi berstempel dengan kode masalah yang jelas (RFC 9457).'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Server & Client yang Diberi Batas Waktu',
        body: `\`\`\`go
package main

import (
	"context"
	"encoding/json"
	"net/http"
	"time"
)

type ProblemDetails struct {
	Type   string \`json:"type"\`
	Title  string \`json:"title"\`
	Status int    \`json:"status"\`
	Detail string \`json:"detail"\`
}

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("POST /api/v1/items", func(w http.ResponseWriter, r *http.Request) {
		r.Body = http.MaxBytesReader(w, r.Body, 64<<10) // Maksimal 64 KB
		defer r.Body.Close()

		var payload struct {
			Name string \`json:"name"\`
		}
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			w.Header().Set("Content-Type", "application/problem+json")
			w.WriteHeader(http.StatusBadRequest)
			_ = json.NewEncoder(w).Encode(ProblemDetails{
				Type:   "https://api.example.com/errors/invalid-json",
				Title:  "Bad Request",
				Status: 400,
				Detail: "Body must be valid JSON under 64 KB",
			})
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		_ = json.NewEncoder(w).Encode(map[string]string{"status": "created", "name": payload.Name})
	})

	srv := &http.Server{
		Addr:              ":8080",
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second, // Melindungi dari Slowloris DoS
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      15 * time.Second,
	}
	_ = srv.ListenAndServe()
}
\`\`\``
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: http.DefaultClient & Kebocoran Response Body',
        body: `1. Jangan gunakan http.DefaultClient atau http.Get(): client default TIDAK memiliki batas waktu (timeout = 0), sehingga goroutine akan hang selamanya jika server tujuan tidak merespons.
2. Selalu panggil resp.Body.Close() setelah mengecek err == nil, jika tidak koneksi TCP tidak bisa digunakan kembali oleh connection pool (socket leak).`
      },
      {
        type: 'exercise',
        title: 'Tantangan: NewHardenedClient() *http.Client',
        body: 'Buat konfigurasi client HTTP yang menyetel Timeout 10 detik dan Transport dengan ResponseHeaderTimeout 5 detik.'
      },
      {
        type: 'deep_dive',
        title: 'Koneksi Keep-Alive & Connection Pooling pada net/http',
        body: 'http.Transport mengelola pool koneksi TCP idle menggunakan sync.Mutex dan map host. Membaca seluruh resp.Body hingga io.EOF dan menutupnya memungkinkan koneksi TCP dialihkan kembali ke pool idle tanpa overhead 3-way handshake baru pada request berikutnya.'
      }
    ]
  },
  {
    lessonId: 'l4-stage-e-sql-relational-fundamentals',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Fundamental SQL Relasional',
        body: 'Memahami dasar database relasional: tabel, tipe data SQL, PRIMARY KEY, FOREIGN KEY, SELECT dengan klausa WHERE, operasi JOIN (INNER vs LEFT), aggregasi GROUP BY, dan indeks B-Tree.'
      },
      {
        type: 'analogy',
        title: 'Buku Kas Terhubung & Label Unik',
        body: 'Database relasional ibarat sekumpulan tabel catatan di mana setiap baris memiliki nomor unik (Primary Key). Tabel Pesanan merujuk ke nomor pelanggan di Tabel Pengguna (Foreign Key). Relasi ini mencegah pesanan fiktif tanpa pemilik yang jelas.'
      },
      {
        type: 'walkthrough',
        title: 'Contoh SQL: Skema, Relasi & Kueri Agregasi',
        body: `\`\`\`sql
-- 1. Buat Tabel Users
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Buat Tabel Orders dengan Foreign Key
CREATE TABLE orders (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
);

-- 3. Kueri JOIN dan Agregasi
SELECT u.name, COUNT(o.id) AS total_orders, COALESCE(SUM(o.amount_cents), 0) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_spent DESC;
\`\`\``
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: Foreign Key Tanpa Index & Pelanggaran 1NF',
        body: `1. Menyimpan data jamak dalam satu kolom teks (misal tag: "tech,golang,sql") melanggar First Normal Form (1NF) dan membuat pencarian menjadi lambat.
2. Tidak membuat indeks pada kolom Foreign Key (orders.user_id) menyebabkan database melakukan Full Table Scan setiap kali baris pada tabel parent dihapus atau diperbarui.
3. Mengabaikan Aksi ON DELETE: Jika tabel pesanan mengacu ke pengguna, tentukan apakah penghapusan pengguna memicu ON DELETE CASCADE (menghapus pesanan terkait) atau ON DELETE RESTRICT (mencegah penghapusan pengguna selama ada pesanan aktif).`
      },
      {
        type: 'exercise',
        title: 'Tantangan: Buat Skema SQL Berelasi',
        body: 'Rancang skema tabel products dan categories dengan foreign key constraint yang tepat.'
      },
      {
        type: 'deep_dive',
        title: 'Struktur Indeks B-Tree pada Database Relasional',
        body: 'Indeks relasional umumnya menggunakan struktur B-Tree seimbang di disk. Pencarian, penambahan, dan penghapusan bernilai O(log N). Indeks komposit (kolom A, kolom B) hanya dapat digunakan jika klausa WHERE mencantumkan kolom paling kiri (Leftmost Prefix Rule). Selain itu, pahami perbedaan antara Clustered Index (data fisik tabel diurutkan berdasarkan primary key) dan Non-Clustered / Secondary Index (daun B-Tree berisi pointer ke baris fisik tabel).'
      }
    ]
  },
  {
    lessonId: 'l5-stage-e-database-sql-crud-basics',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Menghubungkan Go ke SQL dengan database/sql',
        body: 'Menguasai penggunaan package standar database/sql: pembukaan pool *sql.DB, eksekusi QueryRowContext dan QueryContext, pencegahan SQL Injection dengan parameterized queries ($1 / ?), pemindaian Scan(), dan transaksi BeginTx.'
      },
      {
        type: 'analogy',
        title: 'Armada Taksi & Surat Kuasa',
        body: '*sql.DB bukan satu koneksi ke server, melainkan pengelola armada taksi (connection pool). Ketika Anda memanggil QueryContext, satu taksi diambil, mengantarkan kueri ke database, mengembalikan data, dan kembali ke pangkalan saat rows.Close() dipanggil.'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: QueryRowContext & Transaksi Aman',
        body: `\`\`\`go
package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"
)

type User struct {
	ID    string
	Email string
}

func GetUserEmail(ctx context.Context, db *sql.DB, id string) (string, error) {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()

	var email string
	// Selalu gunakan parameter binding $1 (atau ? di SQLite/MySQL)
	err := db.QueryRowContext(ctx, "SELECT email FROM users WHERE id = $1", id).Scan(&email)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return "", fmt.Errorf("user %s: not found", id)
		}
		return "", fmt.Errorf("querying user: %w", err)
	}
	return email, nil
}
\`\`\``
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: SQL Injection & Kebocoran rows',
        body: `1. SQL Injection: Menyusun string SQL menggunakan fmt.Sprintf("SELECT * FROM users WHERE name = '%s'", name) memungkinkan penyerang menyisipkan perintah SQL jahat. SELALU gunakan placeholder parameter ($1 / ?).
2. Forgetting rows.Close(): Jika loop rows.Next() berhenti lebih awal karena return error sebelum selesai, koneksi tetap terkunci dan tidak kembali ke pool hingga memicu timeout pool.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: Parameterized Query Verification',
        body: 'Implementasikan fungsi query dengan context timeout dan penanganan sql.ErrNoRows yang tepat.'
      },
      {
        type: 'deep_dive',
        title: 'Konfigurasi Pool *sql.DB di Produksi',
        body: 'SetMaxOpenConns menentukan batas atas koneksi fisik ke server DB untuk mencegah server kehabisan memori. SetMaxIdleConns menentukan jumlah koneksi hangat yang siap digunakan tanpa handshake baru. SetConnMaxLifetime memastikan koneksi basi (misal ditutup oleh firewall/load balancer) disegarkan secara berkala.'
      }
    ]
  },
  {
    lessonId: 'l6-stage-f-password-hashing-bearer-auth',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Autentikasi, Password Hashing & Bearer Auth',
        body: 'Mempelajari prinsip keamanan autentikasi backend: mengapa password tidak boleh disimpan dalam plaintext atau MD5/SHA256, cara menggunakan bcrypt/Argon2id, serta pembuatan middleware autentikasi Bearer token.'
      },
      {
        type: 'analogy',
        title: 'Cap Lilin & Gelang Masuk Konser',
        body: 'Password hash adalah cap lilin satu arah yang tidak bisa dibalik menjadi password asli. Bearer token adalah gelang masuk konser: siapa pun yang menunjukkan gelang valid di pintu masuk berhak mengakses fasilitas di dalamnya.'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Middleware Autentikasi Token',
        body: `\`\`\`go
package main

import (
	"context"
	"net/http"
	"strings"
)

type contextKey string
const userContextKey contextKey = "user_id"

func BearerAuthMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			http.Error(w, \`{"error":"missing or invalid authorization header"}\`, http.StatusUnauthorized)
			return
		}

		token := strings.TrimPrefix(authHeader, "Bearer ")
		if token != "secret_token_val" { // Di produksi, verifikasi signature JWT / DB session
			http.Error(w, \`{"error":"invalid token"}\`, http.StatusUnauthorized)
			return
		}

		// Simpan user_id ke dalam context
		ctx := context.WithValue(r.Context(), userContextKey, "usr_100")
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}
\`\`\``
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: Algoritma Hashing Cepat & Timing Attacks',
        body: `1. Menggunakan MD5/SHA256 untuk password: Algoritma ini dirancang cepat untuk integritas data, sehingga penyerang dapat mencoba miliaran kombinasi per detik dengan GPU. Gunakan bcrypt atau Argon2id yang lambat dan membutuhkan memori.
2. Membandingkan token dengan operator == biasa rentan terhadap timing attacks; gunakan crypto/subtle.ConstantTimeCompare.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: VerifyBearerToken(token string) bool',
        body: 'Implementasikan verifikasi token konstan waktu dan format bearer header.'
      },
      {
        type: 'deep_dive',
        title: 'Struktur Internal Hash Bcrypt',
        body: 'Hash bcrypt berukuran 60 karakter yang memuat format: $2a$ (versi), cost factor (misal 12 = 2^12 iterasi), salt acak 128-bit (mencegah serangan Rainbow Table), dan hash ciphertext. Waktu verifikasi yang disengaja lambat (~100-300ms) membuat brute-force tidak ekonomis.'
      }
    ]
  },
  {
    lessonId: 'l7-stage-g-table-driven-tests-httptest',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Table-Driven Testing & net/http/httptest',
        body: 'Menguasai pola pengujian standar industri Go: Table-Driven Tests dengan t.Run(), penanda pembantu t.Helper(), serta pengujian handler HTTP tanpa membuka port jaringan nyata menggunakan httptest.ResponseRecorder [Celah 7].'
      },
      {
        type: 'analogy',
        title: 'Simulator Kokpit Pesawat',
        body: 'Membuka server jaringan nyata saat unit test ibarat menerbangkan pesawat sungguhan hanya untuk mengetes apakah lampu indikator menyala. httptest adalah simulator kokpit di darat: menguji handler secara presisi dalam milidetik tanpa bergantung pada port atau jaringan OS.'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Table Test Handler dengan httptest',
        body: `\`\`\`go
package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func StatusHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte("OK"))
}

func TestStatusHandler(t *testing.T) {
	tests := []struct {
		name       string
		method     string
		wantStatus int
		wantBody   string
	}{
		{"valid GET", http.MethodGet, http.StatusOK, "OK"},
		{"invalid POST", http.MethodPost, http.StatusMethodNotAllowed, "method not allowed\\n"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(tt.method, "/status", nil)
			rec := httptest.NewRecorder()

			StatusHandler(rec, req)

			if rec.Code != tt.wantStatus {
				t.Errorf("status = %d, want %d", rec.Code, tt.wantStatus)
			}
			if rec.Body.String() != tt.wantBody {
				t.Errorf("body = %q, want %q", rec.Body.String(), tt.wantBody)
			}
		})
	}
}
\`\`\`

Jalankan test:
\`\`\`bash
$ go test -v -run TestStatusHandler ./...
=== RUN   TestStatusHandler
=== RUN   TestStatusHandler/valid_GET
=== RUN   TestStatusHandler/invalid_POST
--- PASS: TestStatusHandler (0.00s)
PASS
\`\`\``
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: State Bersama Antar Test Case',
        body: `1. Memodifikasi variabel global atau state database yang sama di dalam loop test tanpa reset membuat hasil test tidak deterministik (flaky tests).
2. Lupa memanggil t.Helper() pada helper function membuat nomor baris kegagalan di stack trace menunjuk ke helper, bukan ke baris test yang bermasalah.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: TestTableDrivenValidation',
        body: 'Tulis table-driven test untuk memvalidasi fungsi parsing email dengan berbagai kasus uji valid dan invalid.'
      },
      {
        type: 'deep_dive',
        title: 'Mekanisme httptest.ResponseRecorder & Buffer Memori',
        body: 'httptest.ResponseRecorder mengimplementasikan interface http.ResponseWriter dengan menyimpan header dalam map bawaan dan payload dalam bytes.Buffer di memori. Tidak ada socket kernel yang dialokasikan, sehingga ribuan test handler dapat dieksekusi dalam hitungan milidetik.'
      }
    ]
  },
  {
    lessonId: 'l8-stage-h-handler-service-repo-layers',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Arsitektur 3-Layer (Handler, Service, Repository)',
        body: 'Memahami pemisahan tanggung jawab pada backend Go: Handler bertanggung jawab atas protokol HTTP/JSON DTO, Service menangani aturan bisnis murni, dan Repository bertanggung jawab atas persistensi database [Celah 8].'
      },
      {
        type: 'analogy',
        title: 'Resepsionis, Manajer & Petugas Gudang',
        body: 'Di sebuah toko: Resepsionis (Handler) menyapa pelanggan dan memvalidasi formulir pemesanan. Manajer (Service) memeriksa apakah pesanan memenuhi diskon dan aturan perusahaan. Petugas Gudang (Repository) mengambil barang fisik dari rak database. Manajer tidak perlu tahu apakah pesanan datang lewat telepon atau web.'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Injeksi Dependensi Antar Lapisan',
        body: `\`\`\`go
package main

import (
	"context"
	"errors"
	"fmt"
)

// Repository Interface
type UserRepository interface {
	GetByID(ctx context.Context, id string) (*UserEntity, error)
}

type UserEntity struct {
	ID    string
	Email string
}

// Service Layer
type UserService struct {
	repo UserRepository // Tergantung pada interface, bukan struct konkret!
}

func NewUserService(repo UserRepository) *UserService {
	return &UserService{repo: repo}
}

func (s *UserService) CanAccessService(ctx context.Context, id string) (bool, error) {
	user, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return false, err
	}
	return user.Email != "", nil
}
\`\`\``
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: Bocornya Abstraksi Antar Lapisan',
        body: `1. Mengirim *http.Request atau w http.ResponseWriter ke dalam Service atau Repository layer merusak isolasi arsitektur dan membuat kode bisnis tidak bisa diuji tanpa mock HTTP.
2. Membocorkan entitas database SQL langsung ke JSON response client tanpa DTO mapper (mengakibatkan field internal bocor).
3. Mengabaikan pemetaan error: Repository harus mengembalikan domain error (seperti ErrUserNotFound) alih-alih sql.ErrNoRows, sehingga Handler dapat memetakannya ke HTTP 404 tanpa mengetahui jenis database yang digunakan.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: Implementasi Interface Repository Mock',
        body: 'Buat struct MockUserRepo untuk menguji UserService tanpa koneksi database nyata.'
      },
      {
        type: 'deep_dive',
        title: 'Dependency Injection Murni Tanpa Reflection Framework',
        body: 'Go lebih menyukai Dependency Injection eksplisit melalui fungsi konstruktor (NewService(repo)) daripada framework berbasis reflection seperti Spring atau Guice. Hal ini menjaga dependensi tetap jelas, type-safe saat kompilasi, dan waktu kompilasi yang instan. Jika proyek berkembang menjadi modular monolith, paket internal/ menjamin batas arsitektur antar modul tidak dapat diimpor sembarangan oleh modul luar.'
      }
    ]
  },
  {
    lessonId: 'l9-stage-i-redis-cache-aside-backoff',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Redis Cache-Aside & Exponential Backoff',
        body: 'Memahami strategi caching terdistribusi: pola Cache-Aside (Lazy Loading), penentuan TTL (Time-To-Live), penanganan Cache Miss, serta algoritma Exponential Backoff dengan Jitter untuk retry panggilan jaringan.'
      },
      {
        type: 'analogy',
        title: 'Meja Bartender & Gudang Bawah Tanah',
        body: 'Bartender menyimpan botol minuman yang paling sering dipesan di atas meja saji (Redis cache). Jika ada pesanan minuman langka, ia turun ke gudang bawah tanah (Database), membawanya ke meja, dan meletakkannya di rak depan untuk pesanan berikutnya.'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Pola Cache-Aside & Exponential Backoff',
        body: `\`\`\`go
package main

import (
	"context"
	"fmt"
	"math/rand"
	"time"
)

func RetryWithBackoff(ctx context.Context, maxAttempts int, op func() error) error {
	baseDelay := 100 * time.Millisecond
	for attempt := 0; attempt < maxAttempts; attempt++ {
		err := op()
		if err == nil {
			return nil
		}
		// Full Jitter: rand(0, base * 2^attempt)
		backoff := time.Duration(float64(baseDelay) * float64(1<<attempt))
		jitter := time.Duration(rand.Int63n(int64(backoff)))
		select {
		case <-time.After(jitter):
		case <-ctx.Done():
			return ctx.Err()
		}
	}
	return fmt.Errorf("operation failed after %d attempts", maxAttempts)
}
\`\`\`

**Perbandingan Strategi Caching:**
- *Cache-Aside (Lazy Loading)*: Aplikasi membaca cache; jika miss, baca DB lalu tulis ke cache. Bagus untuk data yang lebih sering dibaca daripada ditulis.
- *Write-Through*: Aplikasi menulis ke cache dan database secara bersamaan. Menjamin cache selalu segar tapi menambah latensi operasi tulis.
- *Write-Behind (Write-Back)*: Aplikasi menulis ke cache, worker background menyinkronkan ke DB. Cepat tapi berisiko kehilangan data jika cache crash sebelum sinkronisasi.`
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: Thundering Herd & Cache Tanpa TTL',
        body: `1. Menyimpan data di Redis tanpa TTL (expire): data akan bertahan selamanya, menyebabkan RAM server Redis penuh (OOM) dan menyajikan data basi.
2. Thundering Herd (Cache Stampede): Ketika key populer kedaluwarsa, ribuan request bersamaan langsung menghantam database. Gunakan singleflight untuk menduplikasi fetch ke DB.
3. Cache Penetration: Penyerang menanyakan ID yang tidak ada di database secara terus-menerus. Solusi: simpan hasil nil/kosong di cache dengan TTL pendek (misal 60 detik) atau gunakan Bloom Filter.`
      },
      {
        type: 'exercise',
        title: 'Tantangan: CacheKeyGenerator(prefix, id string) string',
        body: 'Buat fungsi pembangun cache key yang konsisten dengan pemisah titik dua (contoh: "users:profile:usr_123").'
      },
      {
        type: 'deep_dive',
        title: 'Mengapa Jitter Sangat Penting pada Backoff Terdistribusi',
        body: 'Tanpa jitter acak, jika 10.000 worker gagal bersamaan, mereka semua akan melakukan retry serentak pada detik ke-1, detik ke-2, dan detik ke-4. Hal ini menciptakan gelombang lonjakan beban (thundering herd) yang merobohkan server yang baru saja pulih. Jitter meratakan retry di sepanjang rentang waktu. Gabungkan backoff dengan Circuit Breaker (seperti sony/gobreaker) untuk memutus aliran request ketika kegagalan hilir melampaui batas toleransi.'
      }
    ]
  },
  {
    lessonId: 'l10-stage-j-capstone-production-blueprint',
    sections: [
      {
        type: 'goal',
        title: 'Tujuan: Cetak Biru Layanan Produksi Go',
        body: 'Menghubungkan seluruh kurikulum (Level 0 hingga Level 10) ke dalam satu blueprint layanan Go siap produksi: struktur folder terstandar, multi-stage Docker build, liveness/readiness probes, dan graceful shutdown.'
      },
      {
        type: 'analogy',
        title: 'Pembangunan Gedung Pencakar Langit',
        body: 'Dari pondasi cakar ayam (sintaks Go dasar) dan instalasi pipa air (HTTP & SQL) hingga sistem alarm darurat, genset cadangan, dan evakuasi aman (Graceful Shutdown) saat listrik padam.'
      },
      {
        type: 'walkthrough',
        title: 'Kode Contoh: Graceful Shutdown dengan Signal OS',
        body: `\`\`\`go
package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ready"))
	})

	srv := &http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	go func() {
		slog.Info("server starting on :8080")
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			slog.Error("server failure", "error", err)
			os.Exit(1)
		}
	}()

	<-ctx.Done() // Tunggu sinyal SIGINT / SIGTERM dari OS atau Docker
	slog.Info("shutting down gracefully...")

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		slog.Error("forced shutdown", "error", err)
	}
	slog.Info("server stopped cleanly")
}
\`\`\`

Keluaran terminal:
\`\`\`bash
$ go run main.go
2026/11/08 10:00:00 INFO server starting on :8080
^C
2026/11/08 10:00:05 INFO shutting down gracefully...
2026/11/08 10:00:05 INFO server stopped cleanly
\`\`\``
      },
      {
        type: 'pitfalls',
        title: 'Jebakan: Mengabaikan Sinyal SIGTERM pada Container',
        body: `1. Ketika Kubernetes atau Docker menghentikan container, ia mengirim SIGTERM. Jika aplikasi tidak menangani SIGTERM dan langsung keluar dengan os.Exit(0), request in-flight yang sedang diproses pengguna akan diputus secara mendadak (502 Bad Gateway).
2. Memasukkan seluruh compiler toolchain Go ke dalam image Docker produksi (ukuran > 1 GB alih-alih < 25 MB dengan scratch/distroless).`
      },
      {
        type: 'exercise',
        title: 'Tantangan: Verifikasi Readiness Probe',
        body: 'Konfigurasikan endpoint /readyz yang memverifikasi koneksi database aktif sebelum mengembalikan status 200 OK.'
      },
      {
        type: 'deep_dive',
        title: 'Multi-Stage Dockerfile & Distroless Go Binary',
        body: 'Stage 1 (Builder): Menggunakan golang:1.24-alpine untuk kompilasi CGO_ENABLED=0 go build -ldflags="-s -w". Stage 2 (Runner): Menyalin binary tunggal ke gcr.io/distroless/static-debian12. Hasil akhir adalah container tanpa shell, tanpa package manager, dan permukaan serangan keamanan (attack surface) mendekati nol.'
      }
    ]
  }
];

// Quizzes to add or expand across levels
const levelQuizzes = [
  {
    id: 'qz-l3-http-servers',
    levelId: 4,
    title: 'Level 3 — HTTP Routing, Middleware & Server Hardening Quiz',
    questions: [
      {
        id: 'qq-l3-01',
        orderIndex: 1,
        questionText: 'Apa fungsi utama http.MaxBytesReader(w, r.Body, maxBytes) dalam handler HTTP di Go?',
        options: [
          'Mempercepat proses parsing JSON secara asinkron',
          'Membatasi pembacaan stream request body agar server tidak mengalami Out-Of-Memory (OOM) DoS',
          'Mengompres payload HTTP secara otomatis dengan gzip',
          'Menghapus header HTTP yang tidak dikenal'
        ],
        correctIndex: 1,
        explanation: 'http.MaxBytesReader membungkus r.Body sehingga pembacaan melebihi batas ukuran langsung dihentikan dan menghasilkan error, melindungi memori server.'
      },
      {
        id: 'qq-l3-02',
        orderIndex: 2,
        questionText: 'Mengapa menyetel ReadHeaderTimeout penting pada struct http.Server produksi?',
        options: [
          'Untuk mempercepat rendering file HTML',
          'Mencegah serangan Slowloris di mana penyerang membuka ribuan koneksi lambat dan menahan file descriptor',
          'Mengaktifkan fitur HTTP/3 QUIC secara otomatis',
          'Mengatur batas waktu koneksi database'
        ],
        correctIndex: 1,
        explanation: 'ReadHeaderTimeout membatasi waktu pembacaan header request. Tanpa timeout ini, client jahat dapat mengirim 1 byte per menit untuk menahan socket terbuka selamanya.'
      },
      {
        id: 'qq-l3-03',
        orderIndex: 3,
        questionText: 'Bagaimana perilaku json.NewDecoder(r.Body).DisallowUnknownFields() saat menerima payload JSON?',
        options: [
          'Menolak payload jika memuat field yang tidak terdefinisi pada struct target DTO',
          'Menghapus field asing secara diam-diam tanpa menghasilkan error',
          'Mengubah nama field menjadi huruf kapital semua',
          'Mencegah enkripsi data di jaringan'
        ],
        correctIndex: 0,
        explanation: 'DisallowUnknownFields menjamin kepatuhan kontrak API (API contract) dengan menolak payload yang memuat field tak dikenal dengan error.'
      }
    ]
  },
  {
    id: 'qz-l5-database-sql',
    levelId: 6,
    title: 'Level 5 — database/sql, Transactions & Connection Pool Quiz',
    questions: [
      {
        id: 'qq-l5-01',
        orderIndex: 1,
        questionText: 'Apa yang terjadi jika defer rows.Close() diabaikan setelah db.QueryContext() dan perulangan rows.Next() berhenti lebih awal?',
        options: [
          'Database otomatis melakukan rollback transaksi',
          'Koneksi fisik database tetap tertahan dan tidak kembali ke connection pool hingga pool kehabisan koneksi',
          'Tabel database terkunci secara permanen',
          'Compiler Go memicu panic saat kompilasi'
        ],
        correctIndex: 1,
        explanation: 'Koneksi database tetap terikat pada object *sql.Rows sampai rows.Close() dipanggil atau rows.Next() mengembalikan false. Tanpa Close(), terjadi connection pool exhaustion.'
      },
      {
        id: 'qq-l5-02',
        orderIndex: 2,
        questionText: 'Mengapa parameter binding ($1 / ?) mencegah serangan SQL Injection?',
        options: [
          'Karena input pengguna dienkripsi dengan AES-256',
          'Input pengguna dikirim terpisah sebagai nilai literal dan tidak pernah dievaluasi sebagai kode perintah SQL oleh parser DB',
          'Database mengubah huruf kapital menjadi huruf kecil',
          'Server memblokir semua karakter tanda petik'
        ],
        correctIndex: 1,
        explanation: 'Parameter binding memisahkan instruksi SQL dari data literal sehingga input pengguna tidak pernah dapat mengubah struktur sintaks pohon perintah SQL.'
      },
      {
        id: 'qq-l5-03',
        orderIndex: 3,
        questionText: 'Kapan method db.QueryRowContext() mengembalikan error sql.ErrNoRows?',
        options: [
          'Ketika tabel database belum dibuat',
          'Ketika query tidak menghasilkan baris data apapun saat Scan() dipanggil',
          'Ketika koneksi database terputus di tengah jalan',
          'Ketika tipe kolom tidak cocok dengan pointer target'
        ],
        correctIndex: 1,
        explanation: 'QueryRowContext mengembalikan sql.ErrNoRows saat Scan() dipanggil pada hasil query yang tidak menemukan baris yang cocok.'
      }
    ]
  },
  {
    id: 'qz-l7-testing-qa',
    levelId: 8,
    title: 'Level 7 — Table-Driven Testing & httptest Quiz',
    questions: [
      {
        id: 'qq-l7-01',
        orderIndex: 1,
        questionText: 'Apa keuntungan utama menggunakan httptest.ResponseRecorder dalam pengujian handler HTTP?',
        options: [
          'Menguji handler di memori tanpa membuka port TCP nyata pada sistem operasi',
          'Menguji kecepatan koneksi internet eksternal',
          'Menghasilkan dokumentasi Swagger secara otomatis',
          'Menghapus database setelah setiap pengujian'
        ],
        correctIndex: 0,
        explanation: 'httptest.ResponseRecorder mengimplementasikan http.ResponseWriter di memori, memungkinkan ribuan test handler dieksekusi dalam hitungan milidetik tanpa alokasi port jaringan.'
      },
      {
        id: 'qq-l7-02',
        orderIndex: 2,
        questionText: 'Apa fungsi pemanggilan t.Helper() di dalam fungsi pembantu pengujian (test helper)?',
        options: [
          'Membuat helper berjalan secara konkuren',
          'Menghapus jejak baris helper dari log kegagalan agar stack trace menunjuk langsung ke baris pemanggil di fungsi test',
          'Menghentikan eksekusi test seketika saat terjadi error',
          'Menyimpan hasil test ke file eksternal'
        ],
        correctIndex: 1,
        explanation: 't.Helper() menandai fungsi sebagai pembantu sehingga jika terjadi kegagalan, pesan error menunjuk ke nomor baris test yang memanggil helper tersebut.'
      },
      {
        id: 'qq-l7-03',
        orderIndex: 3,
        questionText: 'Mengapa pola Table-Driven Tests sangat dianjurkan di komunitas Go?',
        options: [
          'Karena hanya tabel yang bisa dieksekusi oleh perintah go test',
          'Memungkinkan penambahan kasus uji baru (edge cases) secara mudah tanpa menduplikasi kode setup eksekusi',
          'Mempercepat kompilasi binary produksi',
          'Mencegah penggunaan interface di kode aplikasi'
        ],
        correctIndex: 1,
        explanation: 'Table-driven tests memisahkan data kasus uji dari logika pengujian, mempermudah pengujian berbagai kondisi batas (boundary conditions) secara deklaratif.'
      }
    ]
  },
  {
    id: 'qz-l8-architecture',
    levelId: 9,
    title: 'Level 8 — Layered Architecture & Domain Boundaries Quiz',
    questions: [
      {
        id: 'qq-l8-01',
        orderIndex: 1,
        questionText: 'Mengapa Service Layer sebaiknya tidak menerima parameter *http.Request?',
        options: [
          'Karena struct *http.Request terlalu lambat untuk di-copy',
          'Menjaga logika bisnis murni dan independen dari protokol HTTP sehingga mudah diuji dan dapat dipanggil dari gRPC/CLI',
          'Kompiler Go melarang import net/http di luar package main',
          'Mencegah data race pada request context'
        ],
        correctIndex: 1,
        explanation: 'Service layer harus berfokus pada aturan bisnis; mengaitkannya dengan *http.Request merusak portabilitas dan mempersulit penulisan unit test.'
      },
      {
        type: 'mc',
        id: 'qq-l8-02',
        orderIndex: 2,
        questionText: 'Apa peran Repository Pattern dalam arsitektur layered?',
        options: [
          'Mengelola rute URL dan parsing cookie',
          'Mengabstraksikan akses data persistensi di balik interface sehingga logika bisnis tidak bergantung pada detail SQL/DB tertentu',
          'Mengkompilasi kode Go menjadi web assembly',
          'Menjalankan background cron job'
        ],
        correctIndex: 1,
        explanation: 'Repository pattern memisahkan logika persistensi dari logika domain, memungkinkan penggantian atau mocking database dengan mudah.'
      },
      {
        id: 'qq-l8-03',
        orderIndex: 3,
        questionText: 'Mengapa Dependency Injection dianjurkan menggunakan constructor fungsi biasa (NewService) di Go?',
        options: [
          'Karena Go tidak mendukung library pihak ketiga',
          'Constructor eksplisit menjamin type-safety saat kompilasi tanpa overhead reflection runtime',
          'Untuk menghemat memori swap pada Linux',
          'Agar semua struct bertipe private'
        ],
        correctIndex: 1,
        explanation: 'DI manual di Go memberikan transparansi dependensi, keterlacakan kode statis, dan kecepatan kompilasi tanpa black-magic reflection.'
      }
    ]
  },
  {
    id: 'qz-l9-distributed',
    levelId: 10,
    title: 'Level 9 — Caching, Sagas & Distributed Patterns Quiz',
    questions: [
      {
        id: 'qq-l9-01',
        orderIndex: 1,
        questionText: 'Mengapa pola Transactional Outbox digunakan saat mengirim event ke message broker (Kafka/RabbitMQ)?',
        options: [
          'Untuk mempercepat serialisasi pesan JSON',
          'Menjamin konsistensi bahwa perubahan database dan penerbitan event terjadi secara atomik (tidak ada event hilang jika crash)',
          'Menghapus data lama di database secara otomatis',
          'Mencegah enkripsi TLS pada message broker'
        ],
        correctIndex: 1,
        explanation: 'Transactional Outbox menyimpan mutasi bisnis dan catatan event dalam satu transaksi ACID database yang sama, menghindari inkonsistensi saat kegagalan jaringan.'
      },
      {
        id: 'qq-l9-02',
        orderIndex: 2,
        questionText: 'Apa fungsi Full Jitter dalam algoritma Exponential Backoff saat melakukan retry?',
        options: [
          'Membuat interval retry menjadi acak untuk mencegah thundering herd yang merobohkan server yang sedang pulih',
          'Menghapus cache yang kedaluwarsa seketika',
          'Memaksa request berikutnya dialihkan ke server cadangan',
          'Mengurangi penggunaan bandwidth jaringan sebesar 50%'
        ],
        correctIndex: 0,
        explanation: 'Jitter menyebarkan waktu retry secara acak di seluruh klien sehingga mereka tidak membanjiri server tujuan pada detik yang sama persis.'
      },
      {
        id: 'qq-l9-03',
        orderIndex: 3,
        questionText: 'Apa peran singleflight.Group dalam mencegah Cache Stampede?',
        options: [
          'Mengizinkan hanya satu eksekusi fungsi duplikat secara konkuren untuk key yang sama dan membagikan hasilnya ke semua pemanggil',
          'Mengompresi nilai cache sebelum dikirim ke Redis',
          'Mengunci seluruh tabel database saat cache miss',
          'Mematikan server cache secara otomatis saat kelebihan beban'
        ],
        correctIndex: 0,
        explanation: 'singleflight menahan ribuan request konkuren untuk key yang sama dan hanya mengirim 1 query ke database, membagikan hasil ke ribuan penunggu.'
      }
    ]
  }
];

function escapeSql(str) {
  return str.replace(/'/g, "''");
}

function buildSectionSql(sec, isSqlite) {
  const onConflict = isSqlite
    ? "ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;"
    : "ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, body_text = EXCLUDED.body_text, diagram_text = EXCLUDED.diagram_text, code_incorrect = EXCLUDED.code_incorrect, code_corrected = EXCLUDED.code_corrected, reasoning = EXCLUDED.reasoning;";

  return `INSERT INTO lesson_sections (id, lesson_id, section_type, title, body_text, diagram_text, code_incorrect, code_corrected, reasoning) VALUES ('${sec.id}', '${sec.lessonId}', '${sec.type}', '${escapeSql(sec.title)}', '${escapeSql(sec.body)}', '${escapeSql(sec.diagram || '')}', '${escapeSql(sec.codeIncorrect || '')}', '${escapeSql(sec.codeCorrected || '')}', '${escapeSql(sec.reasoning || '')}') ${onConflict}`;
}

function buildQuizSql(q, isSqlite) {
  const onConflictQ = "ON CONFLICT (id) DO UPDATE SET level_id = EXCLUDED.level_id, title = EXCLUDED.title;";
  const onConflictQQ = "ON CONFLICT (id) DO UPDATE SET question_text = EXCLUDED.question_text, options_json = EXCLUDED.options_json, correct_index = EXCLUDED.correct_index, explanation = EXCLUDED.explanation;";

  const lines = [];
  lines.push(`INSERT INTO quizzes (id, level_id, title) VALUES ('${q.id}', ${q.levelId}, '${escapeSql(q.title)}') ${onConflictQ}`);
  for (const qq of q.questions) {
    const optsJson = JSON.stringify(qq.options);
    lines.push(`INSERT INTO quiz_questions (id, quiz_id, order_index, question_text, options_json, correct_index, explanation) VALUES ('${qq.id}', '${q.id}', ${qq.orderIndex}, '${escapeSql(qq.questionText)}', '${escapeSql(optsJson)}', ${qq.correctIndex}, '${escapeSql(qq.explanation)}') ${onConflictQQ}`);
  }
  return lines.join('\n');
}

// Generate the SQL additions
function generateAdditions(isSqlite) {
  const lines = [];
  lines.push(`\n-- ============================================================================`);
  lines.push(`-- Task T4.4 Curriculum Expansion: Structured Sections & Comprehensive Quizzes`);
  lines.push(`-- ============================================================================\n`);

  for (const b of bridgeSections) {
    for (const s of b.sections) {
      const secObj = {
        id: `${b.lessonId}-sec-${s.type}`,
        lessonId: b.lessonId,
        type: s.type,
        title: s.title,
        body: s.body,
        diagram: s.diagram || '',
        codeIncorrect: s.codeIncorrect || '',
        codeCorrected: s.codeCorrected || '',
        reasoning: s.reasoning || ''
      };
      lines.push(buildSectionSql(secObj, isSqlite));
    }
  }

  lines.push(`\n-- Expanded Quizzes for all curriculum levels\n`);
  for (const q of levelQuizzes) {
    lines.push(buildQuizSql(q, isSqlite));
  }

  return lines.join('\n') + '\n';
}

console.log('Generating additions...');
const sqliteAdditions = generateAdditions(true);
const postgresAdditions = generateAdditions(false);

// Check if additions already in file, if so replace or append cleanly
function appendCleanly(filePath, additions) {
  let content = fs.readFileSync(filePath, 'utf8');
  const marker = '-- Task T4.4 Curriculum Expansion: Structured Sections & Comprehensive Quizzes';
  const idx = content.indexOf(marker);
  if (idx !== -1) {
    // Find the section before marker
    content = content.slice(0, content.lastIndexOf('-- ============================================================================', idx));
  }
  content = content.trimEnd() + '\n' + additions;
  fs.writeFileSync(filePath, content, 'utf8');
  console.log(`Updated ${filePath}`);
}

appendCleanly(sqliteSeedPath, sqliteAdditions);
appendCleanly(postgresSeedPath, postgresAdditions);

console.log('Seed expansion complete!');
