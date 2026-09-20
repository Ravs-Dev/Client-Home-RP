import 'dart:io';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  static Future<void> downloadAndInstallData({
    required String zipUrl,
    required String targetPackageName,
    Function(double progress)? onProgress,
  }) async {
    // 1. Cek Koneksi Jaringan
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw Exception("Tidak ada koneksi internet. Silakan aktifkan Data Seluler atau Wi-Fi!");
    }

    // 2. Minta Izin Storage (MANAGE_EXTERNAL_STORAGE untuk Android 11+)
    if (Platform.isAndroid) {
      if (!await Permission.manageExternalStorage.request().isGranted) {
        await Permission.storage.request();
      }
    }

    try {
      String destinationDirPath = "/storage/emulated/0/Android/data/$targetPackageName/";
      String tempZipPath = "/storage/emulated/0/Download/temp_game_data.zip";

      // 3. Download File ZIP dari GitHub Release
      Dio dio = Dio();
      await dio.download(
        zipUrl,
        tempZipPath,
        options: Options(
          followRedirects: true, // Wajib aktif untuk GitHub Release Asset URL
          maxRedirects: 5,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      // 4. Ekstrak File ZIP langsung ke folder Android/data/
      File zipFile = File(tempZipPath);
      List<int> bytes = zipFile.readAsBytesSync();
      Archive archive = ZipDecoder().decodeBytes(bytes);

      for (ArchiveFile file in archive) {
        String filename = '$destinationDirPath${file.name}';
        if (file.isFile) {
          List<int> data = file.content as List<int>;
          File(filename)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(filename).createSync(recursive: true);
        }
      }

      // 5. Hapus File Temp ZIP
      if (await zipFile.exists()) {
        await zipFile.delete();
      }
    } catch (e) {
      throw Exception("Gagal mengunduh/mengekstrak data: $e");
    }
  }
}