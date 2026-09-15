import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class OfflineService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'offline_absensi.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE absensi(id INTEGER PRIMARY KEY AUTOINCREMENT, latitude REAL, longitude REAL, jarak REAL, timestamp TEXT, tipe_absen TEXT)",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE absensi ADD COLUMN tipe_absen TEXT DEFAULT "masuk"');
        }
      },
    );
  }

  static Future<void> saveOffline(double lat, double lng, double jarak, String tipeAbsen) async {
    final db = await database;
    await db.insert(
      'absensi',
      {
        'latitude': lat,
        'longitude': lng,
        'jarak': jarak,
        'timestamp': DateTime.now().toIso8601String(),
        'tipe_absen': tipeAbsen,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> syncData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('absensi');

    if (maps.isEmpty) return;

    for (var item in maps) {
      try {
        await ApiService.submitAbsensi(
          latitude: item['latitude'],
          longitude: item['longitude'],
          distansiaMetru: item['jarak'],
          tipuAbsensi: item['tipe_absen'] ?? 'masuk',
        );
        // Jika berhasil terkirim, hapus dari database lokal
        await db.delete('absensi', where: 'id = ?', whereArgs: [item['id']]);
      } catch (e) {
        // Jika gagal lagi (karena server mati atau yang lain), simpan dulu
        debugPrint("Gagal sinkronisasi data id ${item['id']}: $e");
      }
    }
  }

  static Future<int> getPendingSyncCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM absensi'));
    return count ?? 0;
  }
}
