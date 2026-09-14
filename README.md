# Absensi Admin System 🏢

Sistem Administrasi Absensi Pegawai berbasis **Django (Python)**. Sistem ini menyediakan **Web Dashboard** untuk pengelolaan data oleh admin, serta **REST API** yang digunakan untuk integrasi dengan aplikasi mobile (absensi masuk/keluar, izin, dll).

## 🌟 Fitur Utama

Sistem ini terbagi menjadi dua bagian utama: **Web Dashboard Admin** dan **REST API**.

### 💻 Web Dashboard Admin
1. **Manajemen Pegawai (Funsonariu):**
   - Tambah, Edit, dan Nonaktifkan data pegawai.
   - Melihat detail informasi pegawai (NRE, Nama, Jabatan, dll).
2. **Riwayat Absensi (Presensa):**
   - Pemantauan real-time status kehadiran pegawai (Masuk, Keluar, Terlambat).
   - Melihat lokasi (koordinat GPS) saat pegawai melakukan absensi.
3. **Manajemen Izin (Pedido Licensa):**
   - Menerima dan memproses pengajuan izin/sakit/cuti dari pegawai.
   - Status persetujuan (Approved, Rejected, Pending).
4. **Pengaturan Sistem:**
   - Konfigurasi jam masuk, jam pulang, tarif lembur, dll.
   - Pengelolaan hari libur.
5. **Dokumentasi API Terintegrasi:**
   - Menyediakan antarmuka Swagger UI (`/api/docs/`) untuk mempermudah developer melihat spesifikasi API.

### 📱 REST API (Untuk Mobile)
- **Otentikasi:** Login menggunakan JSON Web Token (JWT).
- **Absensi:** Endpoint untuk absensi masuk dan pulang berdasarkan lokasi GPS.
- **Pengajuan Izin:** Endpoint untuk mengirim form pengajuan izin kerja.

---

## 🛠️ Teknologi yang Digunakan

- **Backend:** Python 3, Django 4.2.11, Django REST Framework (DRF)
- **Database:** MySQL / SQLite
- **Autentikasi API:** SimpleJWT (JSON Web Token)
- **API Documentation:** drf-spectacular (Swagger UI)
- **Frontend Dashboard:** HTML, CSS, JavaScript (Django Templates)

---

## 🚀 Cara Instalasi & Menjalankan Sistem Lokal

1. **Clone Repository**
   ```bash
   git clone https://github.com/Akara96/Absensi_admin.git
   cd Absensi_admin
   ```

2. **Buat & Aktifkan Virtual Environment**
   ```bash
   python -m venv appsensi
   # Untuk Windows:
   .\appsensi\Scripts\activate
   # Untuk Linux/Mac:
   source appsensi/bin/activate
   ```

3. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Konfigurasi Database**
   - Pastikan Anda sudah membuat database di MySQL.
   - (Opsional) Import file `db_absensi.sql` ke dalam database Anda.
   - Sesuaikan pengaturan kredensial database di `absensi_admin/settings.py`.

5. **Jalankan Migrasi Database**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

6. **Jalankan Server**
   ```bash
   python manage.py runserver
   ```
   Sistem dapat diakses melalui browser di: `http://127.0.0.1:8000/`

---

## 🔑 Akun Default Admin

Untuk mengakses Web Dashboard, gunakan kredensial berikut:
- **Username (NRE):** `admin01`
- **Password:** `admin123`

*(Sangat disarankan untuk segera mengganti password ini saat sistem di-deploy ke production)*

---

## 📂 Struktur URL Utama

- `/dashboard/` : Halaman utama Admin Dashboard.
- `/admin/` : Halaman bawaan Django Admin.
- `/api/` : Base URL untuk semua endpoint REST API (Mobile).
- `/api/docs/` : Halaman dokumentasi interaktif API (Swagger UI).
