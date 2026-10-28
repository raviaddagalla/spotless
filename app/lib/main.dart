import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/audio/audio_engine.dart';
import 'core/db/app_database.dart';
import 'core/services/music_repository.dart';
import 'core/state/player_controller.dart';
import 'core/youtube/yt_bridge.dart';
import 'ui/home_shell.dart';
import 'ui/now_playing_page.dart';
import 'ui/settings_page.dart';
import 'ui/theme/dynamic_theme_provider.dart';
import 'ui/theme/spotless_colors.dart';
import 'ui/theme/spotless_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() async {
    try {
      final db = AppDatabase();
      final repo = MusicRepository(db: db, yt: YtBridge());
      await repo.init();

      final engine = AudioEngine();
      await AudioService.init(
        builder: () => engine,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.nandhu.spotless.channel.audio',
          androidNotificationChannelName: 'Spotless playback',
          androidNotificationOngoing: true,
        ),
      );

      final controller = PlayerController(repo: repo, engine: engine);
      engine.setCrossfade(
        await repo.crossfadeEnabled()
            ? const Duration(seconds: 4)
            : Duration.zero,
      );

      final dynamicTheme = DynamicThemeProvider(
        repo: repo,
        player: controller,
      );

      runApp(
        MultiProvider(
          providers: [
            Provider<MusicRepository>.value(value: repo),
            ChangeNotifierProvider<PlayerController>.value(value: controller),
            ChangeNotifierProvider<DynamicThemeProvider>.value(
                value: dynamicTheme),
          ],
          child: const SpotlessApp(),
        ),
      );
    } catch (e, s) {
      debugPrint('FATAL STARTUP ERROR: $e\n$s');
      runApp(StartupError(error: '$e'));
    }
  }, (error, stack) {
    debugPrint('FATAL STARTUP ERROR: $error\n$stack');
  });
}

class StartupError extends StatelessWidget {
  final String error;

  const StartupError({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: SpotlessTheme.of(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: SpotlessColors.error, size: 48),
                const SizedBox(height: 16),
                const Text('Spotless failed to start',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SpotlessApp extends StatelessWidget {
  const SpotlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamicTheme = context.watch<DynamicThemeProvider>();

    return MaterialApp(
      title: 'Spotless',
      debugShowCheckedModeBanner: false,
      theme: SpotlessTheme.of(colorScheme: dynamicTheme.scheme),
      home: const HomeShell(),
      routes: {
        SettingsPage.route: (_) => const SettingsPage(),
        'now_playing': (_) => const NowPlayingPage(),
      },
    );
  }
}

