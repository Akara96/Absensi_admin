# Absensi Admin System 🏢

Sistem Administrasi Absensi Pegawai berbasis **Django (Python)** dan **Flutter**. Absensi_admin ini adalah sebuah Sistem Presensi/Absensi Berbasis Geofencing yang ditujukan untuk memantau kehadiran pegawai, baik saat masuk kerja maupun pulang.

## 🌟 Fitur Utama

Proyek ini terbagi menjadi dua bagian utama:

### 💻 Backend & Dashboard Admin (Django + MySQL)
- Dibangun menggunakan Python dengan framework Django dan Django REST Framework (DRF).
- Menyediakan Dashboard Admin Web (menggunakan Django Templates, Bootstrap, dsb.) yang memungkinkan pihak HR atau Admin untuk memantau rekap absensi, menyetujui izin/cuti pegawai, mengelola data pegawai, hingga mengatur zona geofence (koordinat kantor dan radius yang diizinkan).
- Memiliki autentikasi berbasis JWT (JSON Web Tokens) untuk komunikasi aman ke aplikasi mobile.

### 📱 Aplikasi Mobile (Flutter)
- Dibangun menggunakan Flutter (berada di dalam folder `absensi/`).
- Aplikasi ini ditujukan untuk digunakan oleh para pegawai (klien).
- Fitur utamanya memungkinkan pegawai untuk Check-in (Tama), Istirahat (Deskansa), dan Check-out (Sai) menggunakan sensor GPS. Sistem akan memvalidasi apakah pegawai berada di dalam radius geofence kantor atau tidak.
- Pegawai juga wajib mengambil swafoto (selfie) sebagai bukti kehadiran, serta dapat mengajukan izin, sakit, atau cuti langsung melalui aplikasi.

---

## 🛠️ Teknologi yang Digunakan

- **Backend:** Python 3, Django 4.2.11, Django REST Framework (DRF)
- **Database:** MySQL / SQLite
- **Autentikasi API:** SimpleJWT (JSON Web Token)
- **API Documentation:** drf-spectacular (Swagger UI)
- **Frontend Dashboard:** HTML, CSS, JavaScript (Django Templates)

---



---

## 📂 Struktur URL Utama

- `/dashboard/` : Halaman utama Admin Dashboard.
- `/admin/` : Halaman bawaan Django Admin.
- `/api/` : Base URL untuk semua endpoint REST API (Mobile).
- `/api/docs/` : Halaman dokumentasi interaktif API (Swagger UI).
