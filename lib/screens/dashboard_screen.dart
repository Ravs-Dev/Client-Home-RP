import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../widgets/server_card.dart';
import '../widgets/server_detail_panel.dart';
import '../services/server_query_service.dart';
import '../models/app_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late VideoPlayerController _trailerController;
  bool _isTrailerInitialized = false;

  // Channel komunikasi ke Native Android untuk Launch Game SAMP
  static const MethodChannel _gameChannel = MethodChannel('com.homeroleplay.launcher/game');

  // State Data Dynamic Server
  bool _isFetchingServer = true;
  ServerStatus _serverStatus = ServerStatus(
    isOnline: true,
    players: 0,
    maxPlayers: 50,
    ping: 0,
    hostname: "HomeRoleplay",
    gamemode: "ravs",
    version: "0.3.7-R2",
    isMaintenance: false,
    isStorm: false,
  );

  @override
  void initState() {
    super.initState();
    _fetchServerData();

    // Memuat video trailer server dari assets
    _trailerController = VideoPlayerController.asset('assets/intro.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isTrailerInitialized = true);
          _trailerController.setLooping(true);
          _trailerController.setVolume(0.5);
          _trailerController.play();
        }
      }).catchError((error) {
        debugPrint("Gagal memuat trailer video: $error");
      });
  }

  Future<void> _fetchServerData() async {
    setState(() => _isFetchingServer = true);
    final status = await ServerQueryService.fetchServerStatus();
    if (mounted) {
      setState(() {
        _serverStatus = status;
        _isFetchingServer = false;
      });
    }
  }

  // ALUR BARU: Pindah ke Loading Screen dulu, lalu launch game SAMP
  Future<void> _onConnectServer() async {
    // 1. Pindah ke halaman Loading Screen
    if (Navigator.canPop(context)) {
      Navigator.pushNamed(context, '/loading');
    } else {
      Navigator.pushReplacementNamed(context, '/loading');
    }

    // 2. Menjalankan game SAMP via Native MethodChannel
    try {
      final bool success = await _gameChannel.invokeMethod('launchGame', {
        'ip': AppConfig.serverIp,
        'port': AppConfig.serverPort,
        'nickname': AppConfig.nickname,
      });

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menjalankan game. Pastikan APK SAMP sudah terpasang!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _trailerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isSmallScreen = mediaQuery.size.height < 500 || mediaQuery.size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/bg/home_hood.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0F172A)),
            ),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          // Content (Tanpa Sidebar & Row)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 10.0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER (Title & Refresh)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DASHBOARD",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 16 : 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Selamat datang, ${AppConfig.nickname}!",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isSmallScreen ? 11 : 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        onPressed: _fetchServerData,
                        tooltip: "Refresh Status",
                        padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 16),

                  // BODY LAYOUT
                  Expanded(
                    child: isLandscape
                        ? _buildLandscapeLayout(isSmallScreen)
                        : _buildPortraitLayout(isSmallScreen),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Layout Lanskap
  Widget _buildLandscapeLayout(bool isSmall) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ServerCard(
                  serverName: "HomeRoleplay SA-MP",
                  ip: AppConfig.serverIp,
                  port: AppConfig.serverPort,
                  playerCount: "${_serverStatus.players}/${_serverStatus.maxPlayers}",
                  ping: "${_serverStatus.ping} ms",
                  isOnline: _serverStatus.isOnline,
                  onConnect: _onConnectServer, // Mengarahkan ke alur Loading Screen -> Game
                ),
                SizedBox(height: isSmall ? 10 : 16),
                _buildVideoTrailer(isSmall),
              ],
            ),
          ),
        ),
        SizedBox(width: isSmall ? 10 : 16),
        Expanded(
          flex: 2,
          child: ServerDetailPanel(status: _serverStatus),
        ),
      ],
    );
  }

  // Layout Potret
  Widget _buildPortraitLayout(bool isSmall) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServerCard(
            serverName: "HomeRoleplay",
            ip: AppConfig.serverIp,
            port: AppConfig.serverPort,
            playerCount: "${_serverStatus.players}/${_serverStatus.maxPlayers}",
            ping: "${_serverStatus.ping} ms",
            isOnline: _serverStatus.isOnline,
            onConnect: _onConnectServer, // Mengarahkan ke alur Loading Screen -> Game
          ),
          SizedBox(height: isSmall ? 10 : 16),
          _buildVideoTrailer(isSmall),
          SizedBox(height: isSmall ? 10 : 16),
          SizedBox(
            height: 250,
            child: ServerDetailPanel(status: _serverStatus),
          ),
        ],
      ),
    );
  }

  // Widget Video Trailer
  Widget _buildVideoTrailer(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(isSmall ? 10.0 : 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.movie_creation_rounded, color: const Color(0xFF00B4D8), size: isSmall ? 16 : 20),
                  SizedBox(width: isSmall ? 6 : 8),
                  Text(
                    "TRAILER",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 12 : 14,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _trailerController.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: const Color(0xFF00B4D8),
                  size: isSmall ? 22 : 26,
                ),
                onPressed: () {
                  setState(() {
                    _trailerController.value.isPlaying
                        ? _trailerController.pause()
                        : _trailerController.play();
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 6 : 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: isSmall ? 130 : 180,
              width: double.infinity,
              color: Colors.black,
              child: _isTrailerInitialized
                  ? AspectRatio(
                aspectRatio: _trailerController.value.aspectRatio,
                child: VideoPlayer(_trailerController),
              )
                  : const Center(
                child: CircularProgressIndicator(color: Color(0xFF00B4D8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}