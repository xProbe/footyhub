# Flowchart Aplikasi FootyHub

Dokumen ini berisi struktur visual diagram **Flowchart** dari alur sistem aplikasi FootyHub. Struktur ini dibuat identik dengan pola dari referensi (*flowcharttugasaakhir.drawio*) namun disesuaikan fiturnya untuk kasus FootyHub.

> **Cara Menggunakan ke dalam Draw.io:**
> 1. Salin (Copy) kode yang ada di dalam blok kode `mermaid` di bawah ini (Mulai dari baris `graph TD` hingga akhir).
> 2. Buka **app.diagrams.net** (Draw.io).
> 3. Pilih menu **Arrange** > **Insert** > **Advanced** > **Mermaid...**
> 4. Tempel (Paste) kode tersebut ke dalam kotak teks yang muncul, lalu tekan **Insert**.
> 5. Flowchart otomatis akan terbuat secara instan dan dapat Anda sesuaikan posisinya.

```mermaid
graph TD
    %% Mulai
    Mulai([Mulai Aplikasi]) --> CekSesi{Cek Sesi Lokal}
    
    %% Sesi
    CekSesi -- Sesi Aktif --> Dashboard[Dasbor Utama]
    CekSesi -- Sesi Tidak Aktif --> LayarLogin([Layar Login])
    
    %% Login Flow
    LayarLogin --> PilihMetode{Pilih Metode}
    PilihMetode -- Email/Password --> InputKredensial[Input Kredensial]
    PilihMetode -- Biometrik --> PindaiBiometrik[Pindai Sidik Jari / Wajah]
    
    InputKredensial --> Validasi[Validasi & Autentikasi API]
    PindaiBiometrik --> Validasi
    Validasi --> SimpanSesi[Enkripsi & Simpan Sesi Lokal]
    SimpanSesi --> Dashboard
    
    %% Navigasi Utama
    Dashboard --> NavBawah{Bilah Navigasi Bawah}
    
    %% 1. Beranda
    NavBawah -- Menu 1 --> MenuHome[Menu Beranda]
    MenuHome --> APIFootballHome[Ambil Data API Sepakbola]
    APIFootballHome --> SensorCahaya[Cek Sensor Ambient/Light]
    SensorCahaya --> ViewHome[Tampilan Beranda Berita & Jadwal]
    
    %% 2. Ensiklopedia
    NavBawah -- Menu 2 --> MenuEnsiklo[Menu Ensiklopedia]
    MenuEnsiklo --> APIFootballEnsiklo[Ambil Data Klub/Liga]
    APIFootballEnsiklo --> DaftarKlub[Daftar Katalog Tim]
    DaftarKlub --> DetailKlub[Detail Informasi Tim]
    
    %% 3. Konversi / Tools
    NavBawah -- Menu 3 --> MenuTools[Menu Konversi]
    MenuTools --> SubKonversi[Kalkulator Konversi API FloatRates]
    MenuTools --> SubJam[Jam Dunia]
    MenuTools --> SensorAkselerometer[Deteksi Sensor Accelerometer untuk Refresh]
    
    %% 4. Pundit AI
    NavBawah -- Menu 4 --> MenuPundit[Menu Pundit AI]
    MenuPundit --> APICohere[Kirim Prompt ke API Cohere]
    APICohere --> ChatResponse[Tampilan Respon Chat Cerdas]
    
    %% 5. Maps
    NavBawah -- Menu 5 --> MenuMaps[Menu Peta / Maps]
    MenuMaps --> GPS[Minta Akses Lokasi GPS]
    GPS --> RenderMap[Peta Berbasis Lokasi Lapangan Futsal/Stadion]
    RenderMap --> SearchBox[Pencarian Search Box Lokasi Spesifik]
    
    %% 6. Profil
    NavBawah -- Menu 6 --> MenuProfil[Menu Profil]
    MenuProfil --> TampilProfil[Identitas: Nama Anda - NIM Anda]
    TampilProfil --> Evaluasi[Formulir Evaluasi TPM]
    TampilProfil --> AksiKeluar[Aksi Logout]
    
    %% Logout Flow
    AksiKeluar --> HapusSesi[Hapus Data Sesi Lokal]
    HapusSesi --> LayarLogin

    %% Style
    classDef startEnd fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef process fill:#e2e3e5,stroke:#6c757d,stroke-width:1px;

    class Mulai,LayarLogin startEnd;
    class CekSesi,PilihMetode,NavBawah decision;
    class Validasi,SimpanSesi,Dashboard,AksiKeluar,HapusSesi process;
```
