import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart'; // Package untuk unzip
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssetExtractor {
  // Path file di dalam folder assets (BUKAN URL INTERNET)
  static const String sampDataUrl = "https://github.com/Ravs-Dev/Client-Home-RP/releases/download/v1.0.0/samp_data.zip";
  static const String gangsterDataUrl = "https://github.com/Ravs-Dev/Client-Home-RP/releases/download/v1.0.0/gangster_data.zip";

  // 1. Simpan pilihan grafik user
  static Future<void> saveGraphicsChoice(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('graphics_type', type);
  }

  // 2. Cek pilihan grafik user
  static Future<String?> getGraphicsChoice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('graphics_type');
  }

  // 3. Cek apakah data sudah pernah diekstrak
  static Future<bool> isDataExtracted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('data_extracted') ?? false;
  }

  // 4. FUNGSI UTAMA: Baca dari Assets & Ekstrak (TANPA INTERNET)
  static Future<bool> extractGraphicsData(
      String graphicsType, {
        Function(double)? onProgress,
      }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final targetPath = directory.path;

      debugPrint('📦 Memproses grafik: $graphicsType');

      // Pilih file ZIP berdasarkan pilihan user
      final assetPath = graphicsType == 'gangster'
          ? _pathGrafikGangster
          : _pathGrafikBiasa;

      if (onProgress != null) onProgress(0.2);

      debugPrint('📂 Membaca file dari dalam APK: $assetPath');
      // rootBundle.load adalah cara BENAR membaca file assets di Flutter
      final byteData = await rootBundle.load(assetPath);
      final fileBytes = byteData.buffer.asUint8List();

      if (onProgress != null) onProgress(0.5);

      debugPrint('⚙️ Mengekstrak isi file ZIP...');
      // Decode file ZIP
      final archive = ZipDecoder().decodeBytes(fileBytes);

      int extractedCount = 0;
      for (final file in archive) {
        if (file.isFile) {
          final outFile = File('$targetPath/${file.name}');
          // Buat folder otomatis jika belum ada
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
          extractedCount++;
        }
      }

      // Tandai bahwa ekstrak sudah selesai
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