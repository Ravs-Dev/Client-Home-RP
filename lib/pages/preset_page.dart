import 'package:flutter/material.dart';
import '../services/download_service.dart';

class PresetPage extends StatefulWidget {
  const PresetPage({Key? key}) : super(key: key);

  @override
  State<PresetPage> createState() => _PresetPageState();
}

class _PresetPageState extends State<PresetPage> {
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  // Fungsi Helper untuk Menjalankan Download & Menampilkan Dialog Progress
  Future<void> _processDownload({
    required String title,
    required String zipUrl,
  }) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    // Tampilkan Dialog Loading Progress
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Mengunduh $title", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _downloadProgress > 0
                        ? "Proses: ${(_downloadProgress * 100).toStringAsFixed(0)}%"
                        : "Menghubungkan ke server...",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    try {
      await DownloadService.downloadAndInstallData(
        zipUrl: zipUrl,
        targetPackageName: "com.rockstargames.gtasa",
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
            });
          }
        },
      );

      if (mounted) Navigator.of(context).pop(); // Tutup Dialog

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berhasil! $title siap dimainkan."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Tutup Dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preset Grafik & Data Game"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Pilih paket data yang ingin dipasang ke dalam game:",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // TOMBOL 1: GRAFIK BIASA (data_samp.zip)
              // ==========================================
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isDownloading
                      ? null
                      : () => _processDownload(
                            title: "Data SA-MP Original",
                            zipUrl: "https://github.com/Ravs-Dev/Client-Home-RP/releases/download/v1.0.0/data_samp.zip",
                          ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_android, size: 36, color: Colors.green),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Grafik Biasa (Default)",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Mengunduh data_samp.zip\n(Ringan, Stabil & Hemat Penyimpanan)",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.download, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // TOMBOL 2: GRAFIK GANGSTER (data_gangster.zip)
              // ==========================================
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isDownloading
                      ? null
                      : () => _processDownload(
                            title: "Grafik Gangster HD",
                            zipUrl: "https://github.com/Ravs-Dev/Client-Home-RP/releases/download/v1.0.0/data_gangster.zip",
                          ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, size: 36, color: Colors.amber),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Grafik Gangster (HD Mod)",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Mengunduh data_gangster.zip\n(Tekstur HD, Tampilan Menarik & ENB)",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.download, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}