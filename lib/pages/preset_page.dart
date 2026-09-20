import 'package:flutter/material.dart';
import '../services/download_service.dart'; // Cukup satu import ini saja

// Di dalam Widget Build (Halaman UI Preset/Grafik):
InkWell(
  onTap: () async {
    // 1. Tampilkan Dialog Loading Progress
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text("Sedang mengunduh & mengekstrak data...")),
          ],
        ),
      ),
    );

    // 2. Panggil fungsi download saat tombol Grafik Gangster diklik
    await DownloadService.downloadAndInstallData(
      zipUrl: "http://165.101.18.181/files/data_gangster.zip", // IP Laptop/Server Kamu
      targetPackageName: "com.rockstargames.gtasa",         // Package Target GTA SA
    );

    // 3. Tutup Pop-up Loading Setelah Selesai
    if (context.mounted) Navigator.of(context).pop();

    // 4. Tampilkan Notifikasi Sukses
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data Grafik Gangster Berhasil Dipasang!")),
      );
    }
  },
  child: Container(
    // Tampilan tombol Grafik Gangster (HD) kamu
  ),
)