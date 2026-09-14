import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';
import 'login_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  String _naranFunsonariu = "";
  String _nreFunsonariu = "";

  String _statusAbsensi = "Seidauk halo Presensa";
  String _waktuAbsensi = "";
  String _infoLokasi = "Lokalizasaun seidauk haree.";
  bool _isAuthenticating = false;
  int _pendingSyncCount = 0;

  double? _currentLat;
  double? _currentLng;
  double? _currentJarak;

  bool _sudahMasuk = false;
  bool _sudahIstirahat = false;
  bool _sudahMasukSiang = false;
  bool _sudahKeluar = false;

  late Timer _clockTimer;
  Timer? _monitorTimer; // Timer foun ba monitor lokalizasaun
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _checkPendingSync();
    _startClock();
    _fetchStatus().then((_) {
      _startMonitoring(); // Hahu monitor se tama ona
    });
  }

  Future<void> _fetchStatus() async {
    try {
      final status = await ApiService.getTodayStatus();
      setState(() {
        _sudahMasuk = status['sudah_masuk'] ?? false;
        _sudahIstirahat = status['sudah_istirahat'] ?? false;
        _sudahMasukSiang = status['sudah_masuk_siang'] ?? false;
        _sudahKeluar = status['sudah_pulang'] ?? status['sudah_keluar'] ?? false;
      });
    } catch (e) {
      debugPrint("Falaha foti Dadus: $e");
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _monitorTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  /// Hahu monitor lokalizasaun periodicamente se clock-in ona
  void _startMonitoring() {
    _monitorTimer?.cancel();
    
    // So monitor se tama ona maibe seidauk fila
    if (_sudahMasuk && !_sudahKeluar) {
      _runLocationCheck(); // Check immediatu dala ida
      
      _monitorTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
        _runLocationCheck();
      });
    }
  }

  Future<void> _runLocationCheck() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      
      double distance = Geolocator.distanceBetween(
        AppConfig.officeLat,
        AppConfig.officeLng,
        position.latitude,
        position.longitude,
      );

      String statusLabel = "Aktivu";
      if (_sudahMasukSiang) {
        statusLabel = "Masuk Lokraik";
      } else if (_sudahIstirahat) {
        statusLabel = "Deskansa";
      } else if (_sudahMasuk) {
        statusLabel = "Masuk Dadersan";
      }

      await ApiService.monitorLokalizasaun(
        latitude: position.latitude,
        longitude: position.longitude,
        distansiaMetru: distance,
        statusAbsen: statusLabel,
      );
      
      debugPrint("Monitor Geofence: Distansia ${distance.toStringAsFixed(1)}m");
    } catch (e) {
      debugPrint("Error check lokalizasaun: $e");
    }
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _naranFunsonariu = prefs.getString('naran_funsonariu') ?? "Funsonáriu";
      _nreFunsonariu = prefs.getString('nre_funsonariu') ?? "-";
    });
  }

  Future<void> _checkPendingSync() async {
    int count = await OfflineService.getPendingSyncCount();
    setState(() {
      _pendingSyncCount = count;
    });
  }

  Future<void> _syncData() async {
    if (_pendingSyncCount == 0) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sinkroniza hela dadus ba server...')),
    );

    await OfflineService.syncData();
    await _checkPendingSync();

    if (!mounted) return;
    if (_pendingSyncCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sinkronizasaun remata ona!')),
      );
    }
  }

  Future<void> _logout() async {
    await ApiService.clearSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _handleAbsen(String tipeAbsen) async {
    final now = DateTime.now();

    // 1. Validasi Waktu Lokal di Flutter
    if (tipeAbsen == 'keluar_istirahat') {
      if (now.hour < AppConfig.lunchBreakHour) {
        setState(() {
          _statusAbsensi =
              "Seidauk tempu deskansa (Husu hein oras ${AppConfig.lunchBreakHour}:00).";
          _waktuAbsensi = "";
        });
        return;
      }
    } else if (tipeAbsen == 'masuk_siang') {
      if (now.hour < AppConfig.afternoonInHour) {
        setState(() {
          _statusAbsensi =
              "Seidauk tempu tama fali (Husu hein oras ${AppConfig.afternoonInHour}:00).";
          _waktuAbsensi = "";
        });
        return;
      }
    } else if (tipeAbsen == 'keluar') {
      if (now.hour < AppConfig.eveningOutHour ||
          (now.hour == AppConfig.eveningOutHour &&
              now.minute < AppConfig.eveningOutMinute)) {
        setState(() {
          _statusAbsensi =
              "Presensa sai só bele hafoin tuku ${AppConfig.eveningOutHour}:${AppConfig.eveningOutMinute}.";
          _waktuAbsensi = "";
        });
        return;
      }
    }

    setState(() {
      _isAuthenticating = true;
      _statusAbsensi = "Husu Marka Liman...";
      _infoLokasi = "";
    });

    HapticFeedback.mediumImpact();

    try {
      // 2. Minta Sidik Jari
      bool authenticated = await auth.authenticate(
        localizedReason: 'Favor tau liman hodi halo presensa',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Presensa Biometria',
            cancelButton: 'Kansela',
          ),
          IOSAuthMessages(cancelButton: 'Kansela'),
        ],
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (!authenticated) {
        setState(() {
          _isAuthenticating = false;
          _statusAbsensi = "Marka liman kansela ona.";
        });
        return;
      }

      // 3. Jika sidik jari berhasil, cari lokasi GPS
      setState(() => _statusAbsensi = "Haree hela Ita nia Lokalizasaun...");

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Servisu GPS mate hela.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Kansela asesu lokalizasaun husi uza-nain.');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      double distanceInMeters = Geolocator.distanceBetween(
        AppConfig.officeLat,
        AppConfig.officeLng,
        position.latitude,
        position.longitude,
      );

      _currentLat = position.latitude;
      _currentLng = position.longitude;
      _currentJarak = distanceInMeters;

      setState(() {
        _infoLokasi =
            "Ita nia Distánsia: ${distanceInMeters.toStringAsFixed(1)} metru husi Edifisiu.";
      });

      if (distanceInMeters > AppConfig.allowedRadiusMeters) {
        throw Exception(
          'Ita Boot iha liur husi área Edifisiu nian. Presensa la simu.',
        );
      }

      // 4. Simpan data
      await _submitDataAbsensi(tipeAbsen);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _statusAbsensi = e.toString().replaceAll('Exception: ', '');
        _waktuAbsensi = "";
      });
    }
  }

  Widget _buildActionButton({
    required String title,
    required String type,
    required IconData icon,
    required Color color,
  }) {
    // Tentukan apakah tombol aktif
    bool isEnabled = false;
    final now = DateTime.now();

    if (type == 'masuk') {
      isEnabled = !_sudahMasuk;
    } else if (type == 'keluar_istirahat') {
      isEnabled =
          _sudahMasuk &&
          !_sudahIstirahat &&
          now.hour >= AppConfig.lunchBreakHour;
    } else if (type == 'masuk_siang') {
      isEnabled =
          _sudahIstirahat &&
          !_sudahMasukSiang &&
          now.hour >= AppConfig.afternoonInHour;
    } else if (type == 'keluar') {
      isEnabled =
          _sudahMasukSiang &&
          !_sudahKeluar &&
          (now.hour > AppConfig.eveningOutHour ||
              (now.hour == AppConfig.eveningOutHour &&
                  now.minute >= AppConfig.eveningOutMinute));
    }

    return Expanded(
      child: SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: isEnabled ? () => _handleAbsen(type) : null,
          icon: Icon(icon, size: 18),
          label: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? color : Colors.grey.shade400,
            foregroundColor: Colors.white,
            elevation: isEnabled ? 3 : 0,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitDataAbsensi(String tipeAbsen) async {
    bool online = await ApiService.isConnected();
    if (!online) {
      await OfflineService.saveOffline(
        _currentLat!,
        _currentLng!,
        _currentJarak!,
        tipeAbsen,
      );
      await _checkPendingSync();
      setState(() {
        _isAuthenticating = false;
        _statusAbsensi = "Presensa rai hela Offline (La iha rede).";
        _waktuAbsensi = DateTime.now().toString().split('.').first;
      });
      return;
    }

    setState(() => _statusAbsensi = "Rai hela ba server...");
    try {
      HapticFeedback.selectionClick();
      final result = await ApiService.submitAbsensi(
        latitude: _currentLat!,
        longitude: _currentLng!,
        distansiaMetru: _currentJarak!,
        tipeAbsen: tipeAbsen,
      );

      // Refresh status agar tombol langsung ter-update (abu-abu)
      await _fetchStatus();

      // Bangun pesan sukses yang lebih informatif
      final statusKehadiran = result['status_kehadiran'] ?? '';
      if (tipeAbsen == 'keluar') {
        final durasi = result['durasi_jam'];
        final durasiFmt = durasi != null
            ? ' (${durasi.toStringAsFixed(1)} oras)'
            : '';
        setState(() {
          _statusAbsensi =
              "Susesu Presensa Sai ona!$durasiFmt\nEstadu: $statusKehadiran";
          _waktuAbsensi = DateTime.now().toString().split('.').first;
        });
      } else {
        setState(() {
          _statusAbsensi = "Susesu Presensa ona!\nEstadu: $statusKehadiran";
          _waktuAbsensi = DateTime.now().toString().split('.').first;
        });
      }
      HapticFeedback.heavyImpact();
    } catch (e) {
      HapticFeedback.vibrate();
      setState(() {
        _statusAbsensi = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSuccess = _statusAbsensi.contains("Susesu");
    bool isOffline = _statusAbsensi.contains("Offline");
    bool isError =
        _statusAbsensi.contains("liur área") ||
        _statusAbsensi.contains("la simu") ||
        _statusAbsensi.contains("kansela") ||
        _statusAbsensi.contains("mate hela") ||
        _statusAbsensi.contains("Error") ||
        _statusAbsensi.contains("seidauk");

    Color statusColor = isSuccess
        ? Colors.green
        : (isOffline ? Colors.blue : (isError ? Colors.red : Colors.grey));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Presensa Harian'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_pendingSyncCount > 0)
            IconButton(
              icon: Badge(
                label: Text(_pendingSyncCount.toString()),
                child: const Icon(Icons.sync),
              ),
              onPressed: _syncData,
              tooltip: 'Sinkroniza Dadus',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sai husi Konta',
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Header Background with Gradient
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Profile Section (Inside Header)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Text(
                          _naranFunsonariu.isNotEmpty
                              ? _naranFunsonariu[0]
                              : "K",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Benvindu,",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _naranFunsonariu,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "NRE: $_nreFunsonariu",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Digital Clock
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('HH:mm:ss').format(_currentTime),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, dd MMM').format(_currentTime),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Main Body Card
                  Card(
                    elevation: 8,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.85),
                              Colors.white.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 36.0,
                            horizontal: 24.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Fingerprint Icon with Subtle Scale Animation
                              AnimatedScale(
                                scale: _isAuthenticating ? 1.1 : 1.0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOutSine,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: statusColor.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: statusColor.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: _isAuthenticating ? 24 : 12,
                                        spreadRadius: _isAuthenticating ? 8 : 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.fingerprint_rounded,
                                    size: 84,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Status Chip with AnimatedSwitcher for smooth text transitions
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  key: ValueKey<String>(_statusAbsensi),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _statusAbsensi,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.location_on_outlined,
                                _infoLokasi,
                              ),
                              if (_waktuAbsensi.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.access_time,
                                  "Oras: $_waktuAbsensi",
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action Buttons
                  if (_isAuthenticating)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    )
                  else
                    Column(
                      children: [
                        // Row 1: Masuk Pagi & Keluar Istirahat
                        Row(
                          children: [
                            _buildActionButton(
                              title: "TAMA DADERSAN",
                              type: 'masuk',
                              icon: Icons.login,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              title: "DESKANSA",
                              type: 'keluar_istirahat',
                              icon: Icons.timer_off_outlined,
                              color: Colors.orange.shade600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Row 2: Masuk Siang & Keluar Sore
                        Row(
                          children: [
                            _buildActionButton(
                              title: "TAMA LOKRAIK",
                              type: 'masuk_siang',
                              icon: Icons.wb_sunny_outlined,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              title: "SAI / FILA",
                              type: 'keluar',
                              icon: Icons.logout,
                              color: Colors.red.shade600,
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "Pelu garante GPS lakan & iha área kantór.\nDadus sei rai otomatis se rede la iha.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey.shade400, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasaun Sai / Logout'),
        content: const Text('Ita Boot hakarak sai husi aplikasaun ida ne\'e?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kansela'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Sai', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
