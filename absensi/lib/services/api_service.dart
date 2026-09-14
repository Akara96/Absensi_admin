import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));
  
  static const _storage = FlutterSecureStorage();

  static Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> _saveSession({
    required String token,
    required String naran,
    required String nre,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _storage.write(key: 'jwt_token', value: token);
    await prefs.setString('naran_funsonariu', naran);
    await prefs.setString('nre_funsonariu', nre);
    await prefs.setBool('is_logged_in', true);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Amankan data biometrik sebelum menghapus semua konfigurasi
    String? bioNre = await _storage.read(key: 'bio_nre');
    String? bioPw = await _storage.read(key: 'bio_pw');
    String? bioEnabled = await _storage.read(key: 'bio_enabled');

    await _storage.deleteAll();
    await prefs.clear();

    // Kembalikan data biometrik jika sebelumnya aktif
    if (bioEnabled == 'true' && bioNre != null && bioPw != null) {
      await _storage.write(key: 'bio_nre', value: bioNre);
      await _storage.write(key: 'bio_pw', value: bioPw);
      await _storage.write(key: 'bio_enabled', value: 'true');
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // ── BIOMETRIC STORAGE ──────────────────────────────────────────────
  static Future<void> saveBiometricCredentials(String nre, String password) async {
    await _storage.write(key: 'bio_nre', value: nre);
    await _storage.write(key: 'bio_pw', value: password);
    await _storage.write(key: 'bio_enabled', value: 'true');
  }

  static Future<Map<String, String>?> getBiometricCredentials() async {
    String? nre = await _storage.read(key: 'bio_nre');
    String? pw = await _storage.read(key: 'bio_pw');
    if (nre != null && pw != null) {
      return {'nre': nre, 'password': pw};
    }
    return null;
  }

  static Future<bool> isBiometricEnabled() async {
    String? enabled = await _storage.read(key: 'bio_enabled');
    return enabled == 'true';
  }

  static Future<void> disableBiometric() async {
    await _storage.delete(key: 'bio_nre');
    await _storage.delete(key: 'bio_pw');
    await _storage.delete(key: 'bio_enabled');
  }

  static Future<String> login(String nre, String password) async {
    try {
      final response = await _dio.post(
        AppConfig.loginEndpoint,
        data: {'nre': nre, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = (data['token'] ?? data['tokens']?['access']) as String;
        final naran = data['naran_funsonariu'] as String? ?? data['naran'] as String? ?? 'Funsonáriu';

        await _saveSession(token: token, naran: naran, nre: nre);
        return naran;
      } else {
        throw Exception('Login fali. Favor haree fali NRE ho password Ita Boot nian.');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.containsKey('error')) {
          throw Exception(data['error']);
        }
      }

      if (e.response?.statusCode == 401 || e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        throw Exception('NRE ka password sala.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Ligasaun ba server liu ona tempu. Favor haree Ita nia rede.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('La bele liga ba server. Pelu garante server Django lakan hela.');
      }
      throw Exception('Mosu sala ida: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> submitAbsensi({
    required double latitude,
    required double longitude,
    required double distansiaMetru,
    required String tipeAbsen,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Sesaun la válidu. Favor tama fali.');

    try {
      final response = await _dio.post(
        AppConfig.absensiEndpoint,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'distansia_metru': distansiaMetru,
          'tipe_absen': tipeAbsen,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Fali hodi rai presensa iha server.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('detail')) {
            throw Exception(data['detail']);
          } else if (data.containsKey('pesan')) {
            throw Exception(data['pesan']);
          }
        }
        throw Exception('Fali: ${e.response?.data}');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Sesaun remata ona. Favor tama fali.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('La bele liga ba server. Haree ligasaun rede.');
      }
      throw Exception('Fali hodi haruka dadus: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> getTodayStatus() async {
    final token = await _getToken();
    if (token == null) throw Exception('Sesaun la válidu.');

    try {
      final response = await _dio.get(
        '${AppConfig.absensiEndpoint}status_hari_ini/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Fali hodi haree estadu: $e');
    }
  }

  static Future<List<dynamic>> getRiwayatAbsensi({int? bulan, int? tahun}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Sesaun la válidu. Favor tama fali.');

    try {
      final response = await _dio.get(
        AppConfig.riwayatEndpoint,
        queryParameters: {
          'bulan': bulan,
          'tahun': tahun,
        }..removeWhere((k, v) => v == null),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Sesaun remata ona. Favor tama fali.');
      }
      throw Exception('Fali hodi foti istória: ${e.message}');
    }
  }

  /// Kirim permohonan izin/cuti dengan foto bukti
  static Future<void> submitIzin({
    required String tipeIzin,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String keterangan,
    required String filePath,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Sesaun la válidu. Favor tama fali.');

    try {
      final formData = FormData.fromMap({
        'tipe_izin': tipeIzin,
        'tanggal_mulai': tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
        'keterangan': keterangan,
        'file_bukti': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        AppConfig.izinEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Fali haruka pedidu lisensa.');
      }
    } on DioException catch (e) {
      String errorMessage = 'Fali haruka pedidu';
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          // Mengambil pesan error spesifik dari field (misal: tipe_izin: "error message")
          errorMessage = data.values.join(', ');
        } else {
          errorMessage = data.toString();
        }
      }
      throw Exception(errorMessage);
    }
  }

  /// Ambil riwayat izin staff
  static Future<List<dynamic>> getHistoriIzin() async {
    final token = await _getToken();
    if (token == null) throw Exception('Sesaun la válidu.');

    try {
      final response = await _dio.get(
        AppConfig.historiIzinEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Fali foti história lisensa: ${e.message}');
    }
  }

  /// Ambil pengaturan sistem terbaru
  static Future<Map<String, dynamic>> getPengaturanSistem() async {
    final token = await _getToken();
    if (token == null) throw Exception('Sesaun la válidu.');

    try {
      final response = await _dio.get(
        AppConfig.pengaturanEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Fali foti pengaturan.');
    } on DioException catch (e) {
      throw Exception('Erro koneksaun: ${e.message}');
    }
  }

  /// Haruka update lokalizasaun hodi monitor geofence
  static Future<void> monitorLokalizasaun({
    required double latitude,
    required double longitude,
    required double distansiaMetru,
    required String statusAbsen,
  }) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await _dio.post(
        'monitor_lokalizasaun/',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'distansia_metru': distansiaMetru,
          'status_absen': statusAbsen,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      // Kita silent error untuk monitoring agar tidak mengganggu UI
      debugPrint("Error monitor lokalizasaun: $e");
    }
  }
}
