import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssetExtractor {
  // PATH LOKAL DI DALAM FOLDER ASSETS
  static const String _pathGrafikBiasa = 'assets/data/samp_data.zip';
  static const String _pathGrafikGangster = 'assets/data/gangster_data.zip';

  // === 1. SIMPAN PILIHAN GRAFIK USER ===
  static Future<void> saveGraphicsChoice(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('graphics_type', type);
  }

  // === 2. CEK PILIHAN GRAFIK USER ===
  static Future<String?> getGraphicsChoice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('graphics_type');
  }

  // === 3. CEK APAKAH DATA SUDAH PERNAH DIEKSTRAK ===
  static Future<bool> isDataExtracted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('data_extracted') ?? false;
  }

  // === 4. FUNGSI UTAMA: BACA DARI ASSETS & EKSTRAK ===
  static Future<bool> extractGraphicsData(
      String graphicsType, {
        Function(double)? onProgress,
      }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final targetPath = directory.path;

      debugPrint('📦 Mulai memproses grafik: $graphicsType');

      // Tentukan path assets berdasarkan pilihan
      final assetPath = graphicsType == 'gangster'
          ? _pathGrafikGangster
          : _pathGrafikBiasa;

      if (onProgress != null) onProgress(0.2);

      debugPrint('📂 Membaca file ZIP dari dalam APK: $assetPath');
      // Baca file langsung dari folder assets (TANPA INTERNET)
      final byteData = await rootBundle.load(assetPath);
      final fileBytes = byteData.buffer.asUint8List();

      if (onProgress != null) onProgress(0.5);

      debugPrint('⚙️ Mengekstrak isi file ZIP...');
      final archive = ZipDecoder().decodeBytes(fileBytes);

      int extractedCount = 0;
      for (final file in archive) {
        if (file.isFile) {
          final outFile = File('$targetPath/${file.name}');
          // Buat folder otomatis jika belum ada (recursive: true)
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          extractedCount++;
        }
      }

      // Tandai bahwa proses ekstrak sudah selesai
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('data_extracted', true);

      debugPrint('✅ BERHASIL! $extractedCount file diekstrak ke: $targetPath');
      if (onProgress != null) onProgress(1.0);

      return true;

    } catch (e) {
      debugPrint('❌ Gagal mengekstrak data: $e');
      return false;
    }
  }
}