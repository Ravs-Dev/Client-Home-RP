import 'dart:io';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  static Future<void> downloadAndInstallData({
    required String zipUrl, 
    required String targetPackageName,
  }) async {
    // 1. Cek Koneksi Jaringan
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      print("Error: Tidak ada koneksi internet. Aktifkan Data Seluler atau Wi-Fi!");
      return;
    }

    // 2. Minta Izin Storage All Files
    if (Platform.isAndroid) {
      if (!await Permission.manageExternalStorage.request().isGranted) {
        await Permission.storage.request();
      }
    }

    try {
      String destinationDirPath = "/storage/emulated/0/Android/data/$targetPackageName/";
      String tempZipPath = "/storage/emulated/0/Download/temp_data.zip";

      // 3. Proses Download
      Dio dio = Dio();
      print("Mulai mengunduh file data...");
      
      await dio.download(
        zipUrl, 
        tempZipPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            print("Download Progress: ${progress.toStringAsFixed(0)}%");
          }
        },
      );

      // 4. Ekstrak File ZIP
      print("Mengekstrak data ke $destinationDirPath ...");
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

      // 5. Hapus file temp ZIP
      if (await zipFile.exists()) {
        await zipFile.delete();
      }

      print("Berhasil memasang data!");

    } catch (e) {
      print("Gagal mendownload atau mengekstrak data: $e");
    }
  }
}