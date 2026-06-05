# Flowchart Aplikasi FootyHub

Dokumen ini berisi struktur visual diagram **Flowchart** dari alur sistem aplikasi FootyHub saat ini. Struktur ini disesuaikan sepenuhnya dengan fitur mutakhir: navigasi 5-tab Riverpod, integrasi model prediksi Machine Learning lokal (.tflite), AI Tactical Brief, dan alur pembacaan sensor fisik realtime dengan mode simulasi.

> **Cara Menggunakan ke dalam Draw.io:**
> 1. Salin (Copy) kode yang ada di dalam blok kode `mermaid` di bawah ini (Mulai dari baris `graph TD` hingga akhir).
> 2. Buka **app.diagrams.net** (Draw.io).
> 3. Pilih menu **Arrange** > **Insert** > **Advanced** > **Mermaid...**
> 4. Tempel (Paste) kode tersebut ke dalam kotak teks yang muncul, lalu tekan **Insert**.
> 5. Flowchart otomatis akan terbuat secara instan dan dapat Anda sesuaikan posisinya.

```mermaid
graph TD
    %% Mulai & Autentikasi
    Mulai([Mulai Aplikasi]) --> CekSesi{Cek Sesi Lokal}
    
    CekSesi -- Sesi Aktif --> Dashboard[Dasbor Utama]
    CekSesi -- Sesi Tidak Aktif --> LayarLogin([Layar Login])
    
    LayarLogin --> PilihMetode{Pilih Metode}
    PilihMetode -- Email/Password --> InputKredensial[Input Kredensial & Validasi SQLite]
    PindaiBiometrik[Pindai Sidik Jari / Wajah local_auth]
    PilihMetode -- Biometrik --> PindaiBiometrik
    
    InputKredensial --> Validasi[Autentikasi Berhasil]
    PindaiBiometrik --> Validasi
    Validasi --> SimpanSesi[Simpan Token Sesi JWT & SharedPreferences]
    SimpanSesi --> Dashboard
    
    %% Dashboard Tab Spine (Vertically Stacked to prevent horizontal stretch)
    Dashboard --> Tab0[Tab 0: Menu Beranda]
    
    %% Tab 0: Beranda & Fitur
    Tab0 --> JadwalBeranda[Jadwal & Berita Terkini]
    Tab0 --> ChatbotService[Pundit AI - Gemini Chatbot]
    Tab0 --> KonversiService[Konversi Mata Uang & Jam Dunia]
    Tab0 --> MiniGameService[Bounce Ball Mini Game & High Scores]
    Tab0 --> ShakeSensor[Sensor Akselerometer - Shake to Refresh]
    
    %% Link to Tab 1
    ShakeSensor --> Tab1[Tab 1: Menu Kompetisi / League Hub]
    
    %% Tab 1: Kompetisi & Fitur
    Tab1 --> KlasemenLiga[Klasemen Real-time 6 Liga Elit]
    Tab1 --> JadwalLiga[Jadwal Liga - Konversi Zona Waktu]
    JadwalLiga --> SetReminder[Setel Pengingat Jadwal - Bell Icon]
    SetReminder --> ScheduleNotif[Jadwal Notifikasi - local_notifications]
    Tab1 --> MatchCenter[Match Center & Visual Line-up]
    MatchCenter --> GeminiAI[Gemini AI Tactical Brief]
    
    %% Link to Tab 2
    GeminiAI --> Tab2[Tab 2: Menu Lapangan / Maps]
    
    %% Tab 2: Maps & Fitur
    Tab2 --> GPS[Minta Akses Lokasi GPS]
    GPS --> RenderMap[Render Custom Dark Map & Pitches Markers]
    RenderMap --> SearchBox[Cari Lapangan Spesifik]
    RenderMap --> SensorCahaya[Sensor Cahaya - Auto-dim Map <10 Lux]
    RenderMap --> SensorDashboard[Dashboard Info Sensor Hardware]
    RenderMap --> DetailSewa[Detail Lapangan & Konversi Harga Sewa]
    DetailSewa --> SewaAction[Sewa Lapangan & Suara Kick - just_audio]
    
    %% Link to Tab 3
    SewaAction --> Tab3[Tab 3: Menu Prediktor ML]
    
    %% Tab 3: Prediktor ML & Fitur
    Tab3 --> LoadModel[Muat Local Trained Model match_predictor.tflite]
    LoadModel --> InputParams[Form input parameter: possession, shots, dll]
    InputParams --> MLInference[Inference Machine Learning - flutter_litert]
    MLInference --> ProbabilitasHasil[Prediksi Win/Draw/Loss & Grafik Hasil]
    ProbabilitasHasil --> PoissonDistribution[Probabilitas Skor Tepat - Poisson Distribution]
    
    %% Link to Tab 4
    PoissonDistribution --> Tab4[Tab 4: Menu Akun / Profil]
    
    %% Tab 4: Akun, Sensor & Logout
    Tab4 --> TampilProfil[Identitas Mahasiswa: Nama - NIM]
    Tab4 --> SQLiteFeedback[Simpan Saran Kesan TPM ke SQLite]
    Tab4 --> Keamanan[Kelola Pengaturan Login Biometrik]
    Tab4 --> SensorSetting[Pengaturan & Simulasi Sensor Dashboard]
    SensorSetting --> SensorSim{Gunakan Mode Simulasi?}
    SensorSim -- Ya --> ManualSlider[Atur Lux Slider & Switch Proximity]
    SensorSim -- Tidak --> RealSensor[Gunakan Sensor Fisik Asli Perangkat]
    
    %% Proximity Flow
    RealSensor --> ProximityCheck[Deteksi Proximity Sensor Fisik]
    ManualSlider --> ProximityCheck
    ProximityCheck -- Dekat/Tertutup --> PocketMode[Pocket Protection Mode - Layar Terkunci]
    ProximityCheck -- Jauh/Terbuka --> Tab4
    
    %% Logout Flow
    Tab4 --> AksiKeluar[Aksi Logout]
    AksiKeluar --> HapusSesi[Hapus Data Sesi Lokal]
    HapusSesi --> LayarLogin

    %% Style
    classDef startEnd fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef process fill:#e2e3e5,stroke:#6c757d,stroke-width:1px;
    classDef sensor fill:#cce5ff,stroke:#004085,stroke-width:1.5px;
    classDef ml fill:#f8d7da,stroke:#721c24,stroke-width:1.5px;

    class Mulai,LayarLogin startEnd;
    class CekSesi,PilihMetode,SensorSim decision;
    class Validasi,SimpanSesi,Dashboard,AksiKeluar,HapusSesi,PocketMode process;
    class ShakeSensor,SensorCahaya,ProximityCheck,SensorSetting sensor;
    class LoadModel,MLInference,PoissonDistribution ml;
```
