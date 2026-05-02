# LAPORAN TUGAS AKHIR
**MATA KULIAH TEKNOLOGI DAN PEMROGRAMAN MOBILE**

---

## 1. HALAMAN COVER
**Judul Laporan:** Pengembangan Aplikasi FootyHub (Sistem Informasi Sepakbola Terpadu)
**Mata Kuliah:** Teknologi dan Pemrograman Mobile (TPM)
**Disusun Oleh:** 
- **Nama:** Nama Anda
- **NIM:** NIM Anda

**Program Studi:** [Nama Program Studi Anda]
**Fakultas:** [Nama Fakultas Anda]
**Universitas:** [Nama Universitas Anda]
**Tahun:** 2026

---

## 2. HALAMAN PENGESAHAN
**LEMBAR PENGESAHAN PROYEK TUGAS AKHIR**

1. **Judul Proyek:** Aplikasi FootyHub
2. **Identitas Mahasiswa:**
   - Nama: Nama Anda
   - NIM: NIM Anda
3. **Deskripsi Singkat:** FootyHub adalah aplikasi mobile lintas *platform* berbasis framework Flutter yang menyediakan ekosistem terpadu bagi penggemar sepakbola. Fitur utama mencakup sajian berita dan jadwal pertandingan, ensiklopedia data klub, konversi mata uang (tools), fitur peta/pencarian stadion (Location-Based Service), integrasi chatbot cerdas (Pundit AI), serta mengimplementasikan berbagai pembacaan hardware dan sensor (Accelerometer, Proximity, Light Sensor, dan Biometrik).

*Telah disetujui dan disahkan pada tanggal: ..................................*
**Dosen Pengampu Mata Kuliah**
<br><br><br>
*(Tanda Tangan & Nama Dosen)*

---

## 3. HALAMAN PERANCANGAN (RBPL/RPL)

### 3.1. Deskripsi Umum Sistem
Aplikasi FootyHub dirancang untuk memiliki *user experience* yang interaktif. Arsitektur pada aplikasi ini dibangun untuk memastikan pemisahan tugas yang baik antara *State Management*, komponen antarmuka (*View*), dan layanan akses data (*Service/Data Layer*). 

### 3.2. Analisis Kebutuhan Fungsional
1. **Autentikasi Terpadu:** Pengguna dapat mengakses aplikasi menggunakan kredensial surel/sandi standar atau dengan autentikasi perangkat keras Biometrik (Sidik Jari / FaceID).
2. **Beranda & Ensiklopedia:** Modul aplikasi mengambil dan memuat data eksternal (*Football API*) untuk menyajikan klasemen, pertandingan, serta ensiklopedia klub dan liga.
3. **Alat Konversi:** Terdapat utilitas *World Clock* dan Kalkulator Kurs yang mengambil *real-time exchange rate* menggunakan API eksternal.
4. **Peta Integratif:** Menampilkan Maps untuk melacak dan mencari lokasi fasilitas olahraga (lapangan/stadion) di area pengguna.
5. **Chatbot Pundit:** Pengguna bisa mengobrol dengan "Pundit", *Artificial Intelligence* bertenaga Cohere API.

### 3.3. Analisis Kebutuhan Non-Fungsional (Perangkat Keras)
Sistem wajib menanamkan fungsionalitas integrasi *Hardware* dasar smartphone:
- **Biometric Sensor:** Untuk pengamanan login ganda yang lebih personal.
- **Accelerometer Sensor:** Mendeteksi guncangan perangkat untuk memicu interaksi tertentu (seperti *refresh* data atau reset interaksi).
- **Light & Proximity Sensor:** Mendeteksi intensitas cahaya dan jarak objek dari layar untuk memanipulasi *behavior* tampilan (misalnya fitur redup layar otomatis).

---

## 4. HALAMAN IMPLEMENTASI DAN PENJELASAN SOURCE CODE

### 4.1. Struktur Modul Aplikasi
Aplikasi dibagi secara rapi di dalam `lib/features/` dan `lib/data/`:
- `features/auth`: Menangani pendaftaran, masuk, dan inisialisasi sensor *Biometrics*.
- `features/dashboard`: Kendali *Bottom Navigation Bar* untuk berpindah menu.
- `features/home` & `features/encyclopedia`: Layar presentasi untuk memuat tampilan JSON API sepakbola.
- `features/maps`: Kontrol titik pemetaan, *marker*, dan kolom pencarian (*search bar*).
- `features/tools`: Berisi operasi konversi nilai mata uang dunia dan sensor interaktif.
- `features/pundit`: *View* obrolan interaktif yang menyambung dengan *AI service endpoint*.

### 4.2. Penjelasan Source Code (Potongan Utama)

**A. Autentikasi dan Keamanan Sesi (`auth_api_service.dart`)**
Berkas ini bertugas sebagai penghubung dan validasi. Ketika pengguna menekan masuk, aplikasi mencocokkan *token* atau biometrik perangkat. Sesi sukses akan disimpan ke dalam penyimpanan internal agar pengguna tidak perlu *login* berulang kali setiap membuka FootyHub.

**B. Pengambilan Data Jaringan (`football_api_service.dart` & `exchange_rate_service.dart`)**
Servis ini menggunakan modul HTTP. Data akan difetch dari server eksternal, didekode dari JSON menjadi *Model Objects* (misalnya list pertandingan atau rates kurs harian), lalu diumpan ke *Controller* masing-masing halaman untuk di-render oleh *Flutter Widgets*.

**C. Penerapan Peta Berbasis Lokasi (`maps_controller.dart`)**
*Controller* peta mengatur koordinat kamera awal (lintang/bujur). Fungsi tambahan pada fitur maps memungkinkan pengguna memasukkan kata kunci pada form pencarian, dan sistem akan menggeser fokus kamera (animasi *camera panning*) ke lokasi yang dicari dengan memberikan titik *marker*.

**D. Sensor Perangkat Keras (Accelerometer, Light, Proximity)**
Berbagai *listener* diterapkan pada perputaran siklus hidup aplikasi. Accelerometer berjalan secara sinkron pada `tools_controller.dart` atau di latar untuk mendeteksi *threshold* getaran. Light Sensor akan mengubah rasio kecerahan atau tema warna UI saat aplikasi berada dalam cahaya minim, sedangkan Proximity Sensor mencegah sentuhan layar tidak sengaja (saat dikantongi atau dekat telinga).

---

## 5. HALAMAN LEMBAR EVALUASI PENGUJIAN PERANGKAT LUNAK

Pengujian berikut dilakukan dengan metode *Black Box Testing*.

| No | Modul / Fitur yang Diuji | Skenario Pengujian | Hasil yang Diharapkan | Evaluasi |
|----|--------------------------|--------------------|-----------------------|----------|
| 1  | Autentikasi (Email/Password) | Input kredensial yang valid dan klik masuk. | Aplikasi sukses melakukan verifikasi dan memunculkan *Dashboard*. | [  ] Sukses / [  ] Gagal |
| 2  | Autentikasi Biometrik | Menekan ikon *Fingerprint* dan menempelkan sidik jari ke sensor. | Layar langsung terbuka dan *login bypass* berhasil dilakukan. | [  ] Sukses / [  ] Gagal |
| 3  | Navigasi Utama | Membuka *Home* dan *Encyclopedia* bergantian. | Konten termuat penuh melalui API tanpa *lag/crash*. | [  ] Sukses / [  ] Gagal |
| 4  | Modul Tools & Konversi | Memasukkan nominal angka di kalkulator uang. | Konversi mata uang tepat dan up-to-date berdasarkan rate API. | [  ] Sukses / [  ] Gagal |
| 5  | Modul Maps | Mengetik "Gelora Bung Karno" pada *Search Box*. | Peta bergeser ke koordinat dan memunculkan pin *marker* stadion. | [  ] Sukses / [  ] Gagal |
| 6  | Chatbot AI Pundit | Mengirim prompt "Siapa pemenang piala dunia 2022?". | Chatbot *Cohere* merespons secara informatif dan relevan. | [  ] Sukses / [  ] Gagal |
| 7  | Sensor Hardware (*Accelerometer*) | Melakukan gerakan mengocok/shake pada smartphone. | Antarmuka tertrigger untuk merefresh halaman / menjalankan aksi tertentu. | [  ] Sukses / [  ] Gagal |
| 8  | Sensor Hardware (*Proximity*) | Menutup ujung sensor di dekat kamera depan. | Layar masuk mode proteksi sentuhan / redup secara otomatis. | [  ] Sukses / [  ] Gagal |
| 9  | Manajemen Sesi | Merestart aplikasi (*force close* dan buka kembali). | Aplikasi masuk otomatis tanpa melalui halaman login kembali. | [  ] Sukses / [  ] Gagal |
| 10 | Logout Aplikasi | Menekan opsi "Keluar" dari tab profil. | Akses diputus, memori lokal dibersihkan, dan kembali ke *Screen Login*. | [  ] Sukses / [  ] Gagal |

<br>

**Catatan Tambahan Evaluator:**
<br>.......................................................................................................................................<br>
<br>.......................................................................................................................................<br>

<br><br><br>
**Tanda Tangan Evaluator:** ________________________
