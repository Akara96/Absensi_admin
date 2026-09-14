class AppConfig {
  // ── URL Base Server Django ──────────────────────────────────────
  // Ba EMULADOR Android  : uza 10.0.2.2 (alias localhost emulator)
  // Ba HP FISIK (LAN)    : troka ho IP komputadór Ita-boot nian, ezemplu 192.168.1.5
  // Ba produsaun/domíniu : troka ho https://absensi.instansi.go.id
  static const String baseUrl = 'http://10.227.66.48:8000';

  // ── Endpoints API ──────────────────────────────────────────────
  static const String loginEndpoint = '/api/login/';
  static const String absensiEndpoint = '/api/absensi/';
  static const String riwayatEndpoint = '/api/absensi/riwayat/';
  static const String izinEndpoint = '/api/izin/';
  static const String historiIzinEndpoint = '/api/izin/histori/';
  static const String pengaturanEndpoint = '/api/pengaturan/';

  // ── Raius Geofencing ──────────────────────────────────────────
  static const double officeLat = -8.553495;
  static const double officeLng = 125.524416;
  static const double allowedRadiusMeters = 500.0;

  // ── Oras Shift ────────────────────────────────────────────────
  static const int lunchBreakHour = 12;
  static const int afternoonInHour = 14;
  static const int eveningOutHour = 17;
  static const int eveningOutMinute = 30;

  // ── Kores Branding (Premium Teal/Navy) ──────────────────────────
  static const int primaryColorHex = 0xFF006064; // Teal 900
  static const int secondaryColorHex = 0xFF00363A; // Darker Teal
  static const int accentColorHex = 0xFF00BCD4; // Cyan
}
