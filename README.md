# 📱 PresensiKu - Aplikasi Presensi & Absensi Mobile

<div align="center">

  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white" alt="Node.js" />
  <img src="https://img.shields.io/badge/Express.js-000000?style=for-the-badge&logo=express&logoColor=white" alt="Express.js" />
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL" />
  <img src="https://img.shields.io/badge/JWT-black?style=for-the-badge&logo=JSON%20web%20tokens" alt="JWT" />

  <p align="center">
    <b>Sistem Pencatatan Kehadiran Modern Berbasis Swafoto (Live Selfie) & Verifikasi Waktu Server</b>
  </p>
  <p align="center">
    <i>Bebas kendala titik sinyal GPS indoor dan tanpa antrean fingerprint fisik!</i>
  </p>

</div>

---

## 📖 Daftar Isi
- [Tentang Proyek](#-tentang-proyek)
- [Fitur Utama](#-fitur-utama)
- [Teknologi yang Digunakan](#-teknologi-yang-digunakan)
- [Struktur Direktori](#-struktur-direktori)
- [Panduan Instalasi & Menjalankan](#-panduan-instalasi--menjalankan)
  - [1. Konfigurasi Database](#1-konfigurasi-database-mysql)
  - [2. Menjalankan Backend API](#2-menjalankan-backend-nodejs)
  - [3. Menjalankan Aplikasi Mobile](#3-menjalankan-aplikasi-flutter-mobile)
- [Dokumentasi Endpoint API](#-dokumentasi-endpoint-api)
- [Lisensi](#-lisensi)

---

## 📌 Tentang Proyek

**PresensiKu** adalah aplikasi presensi mobile (*fullstack*) yang dirancang untuk memudahkan pencatatan kehadiran karyawan, pegawai, atau mahasiswa secara cepat, transparan, dan akurat. 

Sistem ini menggunakan mekanisme **Swafoto Kamera Depan Langsung (Live Front Camera)** dan validasi **Timestamp Server**, sehingga:
- Menghindari manipulasi absensi (titip absen).
- Fleksibel digunakan di dalam gedung (*indoor*) tanpa kendala *GPS drift* / sinyal lemah.
- Menggantikan mesin sidik jari fisik (*fingerprint*) yang rentan antrean dan biaya pemeliharaan.

---

## ✨ Fitur Utama

- 📸 **Presensi Selfie Langsung (Masuk & Pulang)**: Mengambil foto selfie secara langsung menggunakan kamera depan dengan verifikasi waktu server.
- 📊 **Dashboard Informatif**: Kartu status presensi harian (Masuk/Pulang), jam digital real-time, dan menu aksi cepat.
- 🕒 **Riwayat Kehadiran Lengkap**: Rekap riwayat presensi dengan indikator status (*Tepat Waktu*, *Terlambat*, *Izin*, *Sakit*) beserta modal pratinjau foto bukti selfie.
- 📑 **Pengajuan Izin & Sakit**: Formulir digital permohonan izin/sakit disertai unggah dokumen bukti (surat dokter / keterangan dinas).
- 📈 **Statistik & Visualisasi Grafik**: Grafik interaktif persentase kehadiran bulanan ditenagai oleh `fl_chart`.
- 📅 **Jadwal & Shift Kerja**: Informasi kalender kerja dan jam operasional harian.
- 🛠️ **Bantuan & Koreksi Presensi**: Fasilitas pelaporan pengajuan revisi presensi jika terjadi kendala teknis pada sistem.
- 🔐 **Autentikasi Aman**: Registrasi akun dan login dengan enkripsi password `bcrypt` serta keamanan token `JSON Web Token (JWT)`.
- 🔄 **Smart Network & Mock Fallback**: Aplikasi Flutter dilengkapi sistem fallback lokal otomatis jika backend sedang offline/dalam pengujian.

---

## 🛠️ Teknologi yang Digunakan

### Frontend (Mobile App)
- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State & Storage**: `shared_preferences` (Session Management)
- **HTTP Client**: `http`
- **Charts & Visual**: `fl_chart`, `google_fonts`
- **Hardware Integration**: `image_picker` (Camera capture)
- **Formatting**: `intl`

### Backend (REST API)
- **Runtime**: [Node.js](https://nodejs.org/)
- **Framework**: [Express.js](https://expressjs.com/)
- **Database**: [MySQL](https://www.mysql.com/) (menggunakan `mysql2` driver)
- **File Upload**: `multer` (penyimpanan foto absensi dan bukti izin)
- **Security & Auth**: `jsonwebtoken` (JWT), `bcryptjs`, `cors`, `dotenv`

---

## 📁 Struktur Direktori

Repository ini menggunakan pola struktur monorepo yang memisahkan aplikasi mobile dan REST API backend:

```text
presensi-absen/
├── backend/                  # REST API Server (Node.js & Express)
│   ├── public/uploads/       # Direktori penyimpanan upload foto
│   │   ├── attendance/       # Foto selfie absensi masuk & pulang
│   │   └── leave/            # Bukti surat izin / sakit
│   ├── src/
│   │   ├── config/           # Koneksi database MySQL
│   │   ├── controllers/      # Logika bisnis API
│   │   ├── middleware/       # Autentikasi JWT & filter upload multer
│   │   ├── routes/           # Routing API (/api/...)
│   │   └── server.js         # Entry point backend
│   ├── database.sql          # Skema database & data awal (seeds)
│   ├── package.json          # Dependensi Node.js
│   └── .env.example          # Template konfigurasi environment
│
├── mobile/                   # Aplikasi Mobile (Flutter)
│   ├── android/              # Konfigurasi & native build Android
│   ├── ios/                  # Konfigurasi & native build iOS
│   ├── web/                  # Konfigurasi browser web (testing di Brave/Chrome)
│   ├── lib/                  # Source code aplikasi (Feature-First Architecture)
│   │   ├── core/             # Konfigurasi global, tema, konstanta, network
│   │   │   ├── constants/    # Konfigurasi endpoint & warna
│   │   │   ├── network/      # API Client & Mock Fallback
│   │   │   ├── theme/        # Tema Material & Typography
│   │   │   └── widgets/      # Komponen UI reusable (Button, Card, Badge)
│   │   ├── features/         # Modul fitur mandiri
│   │   │   ├── attendance/   # Layar foto selfie check-in / check-out
│   │   │   ├── auth/         # Login & Register
│   │   │   ├── correction/   # Pengajuan koreksi absensi
│   │   │   ├── dashboard/    # Dashboard & Ringkasan harian
│   │   │   ├── history/      # Riwayat presensi
│   │   │   ├── leave/        # Pengajuan cuti/izin/sakit
│   │   │   ├── profile/      # Profil & pengaturan pengguna
│   │   │   ├── schedule/     # Jadwal kerja / shift
│   │   │   └── statistics/   # Grafik & statistik kehadiran
│   │   ├── main.dart         # Entry point aplikasi Flutter
│   │   └── main_navigation.dart # Navigasi menu utama
│   ├── test/                 # Smoke & Unit Test Flutter
│   └── pubspec.yaml          # Dependensi Flutter
│
├── .gitignore                # Filter file sensitif & file kompilasi
└── README.md                 # Dokumentasi proyek
```

---

## 🚀 Panduan Instalasi & Menjalankan

### Prasyarat:
- [Git](https://git-scm.com/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.0.0 atau lebih baru)
- [Node.js](https://nodejs.org/) (versi LTS v18 atau v20+)
- [MySQL Database](https://www.mysql.com/) (atau via XAMPP / Laragon)

---

### 1. Konfigurasi Database (MySQL)
1. Nyalakan service **MySQL** (misal lewat XAMPP Control Panel).
2. Buka phpMyAdmin / DBeaver / MySQL CLI, lalu buat database baru:
   ```sql
   CREATE DATABASE presensi_db;
   ```
3. Import file `database.sql` yang ada di folder `backend/database.sql`:
   ```bash
   mysql -u root -p presensi_db < backend/database.sql
   ```

---

### 2. Menjalankan Backend (Node.js)
1. Masuk ke folder backend:
   ```bash
   cd backend
   ```
2. Salin template `.env.example` menjadi `.env`:
   ```bash
   cp .env.example .env
   # Pada Windows PowerShell:
   # Copy-Item .env.example .env
   ```
3. Sesuaikan konfigurasi port dan kredensial database di dalam file `.env`:
   ```env
   PORT=3000
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=presensi_db
   JWT_SECRET=super_secret_presensiku_key_2026
   ```
4. Install dependensi:
   ```bash
   npm install
   ```
5. Jalankan server:
   ```bash
   npm run dev
   ```
   > Server akan berjalan di: `http://localhost:3000`

---

### 3. Menjalankan Aplikasi Flutter (Mobile & Browser)
1. Buka terminal baru dan masuk ke folder `mobile`:
   ```bash
   cd mobile
   ```
2. Ambil seluruh dependensi:
   ```bash
   flutter pub get
   ```
3. **Catatan Alamat IP Backend (`mobile/lib/core/constants/api_constants.dart`)**:
   - Jika dijalankan di **Browser (Brave / Chrome)**, otomatis mengarah ke `http://localhost:3000/api`.
   - Jika menggunakan **Android Emulator**, otomatis mengarah ke `http://10.0.2.2:3000/api`.
   - Jika menggunakan **Real Android Device (HP Asli)** melalui kabel USB/WiFi, gunakan **IP LAN komputer** Anda (contoh: `http://192.168.1.10:3000/api`).
4. **Jalankan Aplikasi**:
   - **Di Browser Brave (atau Chrome)**:
     ```bash
     # Di Git Bash:
     export CHROME_EXECUTABLE="C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe"
     flutter run -d chrome

     # Atau via web-server lokal lalu buka di Brave (http://localhost:8080):
     flutter run -d web-server --web-port=8080
     ```
   - **Di HP / Emulator Android**:
     ```bash
     flutter run
     ```

---

## 📡 Dokumentasi Endpoint API

| Method | Endpoint | Deskripsi | Auth Token |
| :--- | :--- | :--- | :---: |
| `POST` | `/api/auth/register` | Mendaftarkan akun baru | ❌ |
| `POST` | `/api/auth/login` | Autentikasi user & generate JWT | ❌ |
| `GET` | `/api/auth/profile` | Mendapatkan profil user yang sedang login | ✅ |
| `GET` | `/api/attendance/today` | Mengambil status presensi hari ini | ✅ |
| `POST` | `/api/attendance/check-in` | Presensi Masuk (Upload selfie) | ✅ |
| `POST` | `/api/attendance/check-out` | Presensi Pulang (Upload selfie) | ✅ |
| `GET` | `/api/attendance/history` | Riwayat presensi user | ✅ |
| `POST` | `/api/leave/submit` | Pengajuan izin/sakit + upload lampiran | ✅ |
| `GET` | `/api/leave/history` | Daftar riwayat izin/sakit | ✅ |
| `GET` | `/api/stats/summary` | Rekap statistik persentase kehadiran | ✅ |
| `GET` | `/api/schedule/my-schedule` | Informasi jadwal kerja & shift | ✅ |
| `POST` | `/api/correction/submit` | Pengajuan revisi koreksi absensi | ✅ |
| `GET` | `/api/correction/list` | Riwayat pengajuan koreksi | ✅ |
| `GET` | `/api/help/faq` | Pusat bantuan & daftar FAQ presensi | ❌ |

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan akademik & pengembangan aplikasi presensi mandiri. Didistribusikan di bawah lisensi [MIT License](LICENSE).
