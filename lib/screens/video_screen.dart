import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';
import '../services/samp_launcher_service.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  double _loadingProgress = 0.0;
  Timer? _progressTimer;
  String _loadingText = "Menghubungkan ke server kota...";

  // Animasi fade-in untuk UI
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animasi
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _initializeVideo();
    _startLoadingSimulation();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset('assets/intro.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _controller.setLooping(false);
          _controller.setVolume(1.0);
          _controller.play();
        }
      }).catchError((error) {
        debugPrint("Video play error (menggunakan fallback): $error");
        if (mounted) {
          setState(() {
            _isVideoInitialized = true; // Tetap set true agar fallback UI muncul
          });
        }
      });
  }

  void _startLoadingSimulation() {
    // DIPERCEPAT: 0.03 setiap 200ms = ~6.5 detik untuk mencapai 100%
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _loadingProgress += 0.03;

        if (_loadingProgress >= 0.3 && _loadingProgress < 0.6) {
          _loadingText = "Memuat aset & tekstur kota...";
        } else if (_loadingProgress >= 0.6 && _loadingProgress < 0.9) {
          _loadingText = "Menyiapkan karakter ${AppConfig.nickname}...";
        } else if (_loadingProgress >= 1.0) {
          _loadingProgress = 1.0;
          _loadingText = "Selesai! Membuka SA-MP Client...";
          _progressTimer?.cancel();
          _onLoadingComplete();
        }
      });
    });
  }

  void _onLoadingComplete() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    try {
      // 1. Cek apakah SA-MP sudah terinstall
      final isInstalled = await SamPLauncherService.isSampInstalled();

      if (!isInstalled) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                SizedBox(width: 8),
                Text("Client Tidak Ditemukan", style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            content: const Text(
              "Aplikasi SA-MP Client belum terinstall.\n\n"
                  "Silakan install terlebih dahulu:\n"
                  "• SA-MP Launcher by Ravs\n"
                  "• SA-MP Mobile",
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                child: const Text("MENGERTI", style: TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        return;
      }

      // 2. Launch game
      final success = await SamPLauncherService.launchGame(
        ip: AppConfig.serverIp,
        port: AppConfig.serverPort,
        username: AppConfig.nickname,
      );

      if (mounted) {
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gagal membuka SA-MP. Pastikan APK-nya valid!"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // 3. Kembali ke menu utama setelah 1 detik
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint("Critical error during launch: $e");
      if (mounted) {
        Navigator.pop(context); // Force return jika terjadi error fatal
      }
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Pemutar Video Full-Screen Cinematic
          Positioned.fill(
            child: _isVideoInitialized && _controller.value.isInitialized
                ? Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
                : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_esports_rounded, size: 80, color: Colors.white.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      "HOMEROLEPLAY",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Overlay Gelap (agar teks terbaca)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // 3. Logo di Tengah Atas (dengan Animasi Fade)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B4D8).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_esports_rounded, color: const Color(0xFF00B4D8), size: 28),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("HOMEROLEPLAY", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          Text("SA-MP CLIENT", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Status Loading & Progress Bar ala FiveM (dengan Animasi Fade)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Positioned(
              left: 32,
              right: 32,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _loadingText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${(_loadingProgress * 100).toInt()}%",
                        style: const TextStyle(
                          color: Color(0xFF00B4D8),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _loadingProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B4D8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}