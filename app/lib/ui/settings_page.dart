import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../core/services/download_manager.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'debug_page.dart';
import 'downloads_page.dart';
import 'theme/spotless_colors.dart';

/// Redesigned Settings screen with organized Material 3 card containers,
/// clear typography, and complete preservation of all import, playback,
/// covers, discovery, and diagnostic configurations.
class SettingsPage extends StatelessWidget {
  static const route = '/settings';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpotlessColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: const [
          _LibrarySection(),
          SizedBox(height: 16),
          _ImportSection(),
          SizedBox(height: 16),
          _PlaybackSection(),
          SizedBox(height: 16),
          _CoversSection(),
          SizedBox(height: 16),
          _ProvidersSection(),
          SizedBox(height: 16),
          _DiagnosticsSection(),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _SettingsCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SpotlessColors.surfaceContainer,
        borderRadius: BorderRadius.circular(SpotlessColors.radiusLg),
        border: Border.all(
          color: SpotlessColors.surfaceContainerHighest.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(SpotlessColors.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SpotlessColors.onSurfaceMedium,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ImportSection extends StatefulWidget {
  const _ImportSection();

  @override
  State<_ImportSection> createState() => _ImportSectionState();
}

class _ImportSectionState extends State<_ImportSection> {
  bool _busy = false;
  bool _cancelRequested = false;

  Future<void> _import() async {
    final picked = await FilePicker.pickFiles(
      dialogTitle: 'Pick one or more playlist CSV files',
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (picked == null || picked.files.isEmpty || !mounted) return;
    final repo = context.read<MusicRepository>();
    final paths = picked.files.map((f) => f.path!).toList();
    setState(() {
      _busy = true;
      _cancelRequested = false;
    });

    final progress = ValueNotifier<(int, int, String)>((0, 0, 'Starting…'));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProgressDialog(
        title: 'Importing playlists',
        progress: progress,
        onCancel: () {
          _cancelRequested = true;
          progress.value = (progress.value.$1, progress.value.$2,
              'Cancelling after the current download…');
          repo.downloads.cancelAll();
        },
      ),
    );

    try {
      final result = await repo.importPlaylistCsvs(
        paths,
        onProgress: (d, t, m) {
          progress.value = (d, t, m);
        },
        isCancelled: () => _cancelRequested,
      );
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _cancelRequested
                  ? 'Import cancelled after ${result.imported} new download(s). '
                      'Run it again to resume.'
                  : 'Imported ${result.imported} songs'
                      '${result.skipped > 0 ? ', ${result.skipped} already downloaded' : ''}'
                      '${result.failed > 0 ? ', ${result.failed} failed' : ''}.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: Icons.cloud_download_outlined,
      title: 'Import from Spotify',
      subtitle: 'Pick your Spotify playlist exports (.csv, one file per playlist). '
          'Every song is resolved on YouTube, downloaded, tagged, and assigned lyrics.',
      child: FilledButton.icon(
        onPressed: _busy ? null : _import,
        icon: const Icon(Icons.file_download_outlined),
        label: Text(_busy ? 'Importing…' : 'Import playlist CSVs…'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _PlaybackSection extends StatefulWidget {
  const _PlaybackSection();

  @override
  State<_PlaybackSection> createState() => _PlaybackSectionState();
}

class _PlaybackSectionState extends State<_PlaybackSection> {
  bool? _crossfade;

  @override
  void initState() {
    super.initState();
    context.read<MusicRepository>().crossfadeEnabled().then((v) {
      if (mounted) setState(() => _crossfade = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final crossfade = _crossfade ?? true;
    return _SettingsCard(
      icon: Icons.graphic_eq_rounded,
      title: 'Playback',
      subtitle: 'Configure audio transitions and playback behavior',
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Crossfade between songs'),
        subtitle: const Text(
          'Overlaps the next song with the last ~4 seconds of the current one for seamless transitions.',
          style: TextStyle(color: SpotlessColors.onSurfaceMedium, fontSize: 12),
        ),
        value: crossfade,
        onChanged: (v) async {
          setState(() => _crossfade = v);
          final player = context.read<PlayerController>();
          await context.read<MusicRepository>().setCrossfadeEnabled(v);
          player.setCrossfade(
            v ? const Duration(seconds: 4) : Duration.zero,
          );
        },
      ),
    );
  }
}

class _LibrarySection extends StatefulWidget {
  const _LibrarySection();

  @override
  State<_LibrarySection> createState() => _LibrarySectionState();
}

class _LibrarySectionState extends State<_LibrarySection> {
  late final TextEditingController _root =
      TextEditingController(text: context.read<MusicRepository>().libraryRoot ?? '');
  bool _scanning = false;

  @override
  void dispose() {
    _root.dispose();
    super.dispose();
  }

  /// The library lives in shared storage (`/storage/emulated/0/...`). Since
  /// Android 11, raw filesystem access there requires the All Files Access
  /// special permission; declaring it in the manifest alone does nothing.
  Future<bool> _ensureStorageAccess() async {
    if (!Platform.isAndroid) return true;
    final manage = await Permission.manageExternalStorage.status;
    if (manage.isGranted) return true;
    final requested = await Permission.manageExternalStorage.request();
    if (requested.isGranted) return true;
    // Android 10 and below use the legacy storage permission instead.
    final legacy = await Permission.storage.request();
    if (legacy.isGranted) return true;
    if (!mounted) return false;
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Storage access required'),
        content: const Text(
          'Spotless needs access to the folder containing your music and CSV '
          'exports. Grant “All files access” in the system settings, then try '
          'again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open == true) await openAppSettings();
    return false;
  }

  Future<void> _browse() async {
    if (!await _ensureStorageAccess()) return;
    if (!mounted) return;
    final picked = await FilePicker.getDirectoryPath(
      dialogTitle: 'Pick the library folder (music/, lyrics/, songs.csv)',
    );
    if (picked != null && mounted) {
      setState(() => _root.text = picked);
    }
  }

  Future<void> _saveAndScan() async {
    final repo = context.read<MusicRepository>();
    final path = _root.text.trim();
    if (path.isEmpty) return;
    if (!await _ensureStorageAccess()) return;
    if (!mounted) return;
    await repo.setLibraryRoot(path);
    setState(() => _scanning = true);

    if (!mounted) return;
    final progress = ValueNotifier<(int, int, String)>((0, 0, 'Starting…'));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProgressDialog(
        title: 'Scanning library',
        progress: progress,
      ),
    );

    try {
      await repo.scanLibrary(onProgress: (done, total, message) {
        progress.value = (done, total, message);
      });
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Library scanned')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: Icons.folder_copy_outlined,
      title: 'Local Library Storage',
      subtitle: 'Folder containing songs.csv, sleep.csv, music/ and lyrics/. '
          'Requires storage access permissions.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _root,
            decoration: InputDecoration(
              labelText: 'Library folder path',
              hintText: '/storage/emulated/0/Music/SpotlessLibrary',
              filled: true,
              fillColor: SpotlessColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _browse,
                icon: const Icon(Icons.folder_open),
                label: const Text('Browse'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _scanning ? null : _saveAndScan,
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(_scanning ? 'Scanning…' : 'Save & Rescan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoversSection extends StatefulWidget {
  const _CoversSection();

  @override
  State<_CoversSection> createState() => _CoversSectionState();
}

class _CoversSectionState extends State<_CoversSection> {
  bool _busy = false;
  bool _cancelRequested = false;
  final ValueNotifier<(int, int, String)> _progress = ValueNotifier((0, 0, ''));

  Future<void> _embedAll() async {
    final repo = context.read<MusicRepository>();
    setState(() {
      _busy = true;
      _cancelRequested = false;
    });
    _progress.value = (0, 0, 'Starting…');
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProgressDialog(
        title: 'Embedding covers into MP3s',
        progress: _progress,
        onCancel: () => _cancelRequested = true,
      ),
    );
    await repo.embedAllCovers(
      onProgress: (done, total, current) {
        _progress.value = (done, total, current);
      },
      isCancelled: () => _cancelRequested,
    );
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => _busy = false);
    }
  }

  Future<void> _clearCache() async {
    final repo = context.read<MusicRepository>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cover cache?'),
        content: const Text(
          'Removes cached cover images (they will be re-fetched next time).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await repo.clearCoverCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      icon: Icons.photo_library_outlined,
      title: 'Album Art & Covers',
      subtitle: 'Manage local artwork cache and ID3 tag metadata',
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _embedAll,
              icon: const Icon(Icons.save_alt_rounded),
              label: const Text('Embed in MP3s'),
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: _busy ? null : _clearCache,
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Clear cache'),
          ),
        ],
      ),
    );
  }
}

class _ProgressDialog extends StatelessWidget {
  final String title;
  final ValueNotifier<(int, int, String)> progress;
  final VoidCallback? onCancel;

  const _ProgressDialog({
    required this.title,
    required this.progress,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back must not silently dismiss a running import/scan: treat it as a
      // cancel request and keep the dialog until the operation winds down.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) onCancel?.call();
      },
      child: AlertDialog(
        title: Text(title),
        content: ValueListenableBuilder<(int, int, String)>(
          valueListenable: progress,
          builder: (context, value, _) {
            final (done, total, message) = value;
            final pct = total > 0 ? done / total : 0.0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: pct),
                const SizedBox(height: 12),
                Text('$done / $total'),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SpotlessColors.onSurfaceMedium,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
        ],
      ),
    );
  }
}

class _ProvidersSection extends StatefulWidget {
  const _ProvidersSection();

  @override
  State<_ProvidersSection> createState() => _ProvidersSectionState();
}

class _ProvidersSectionState extends State<_ProvidersSection> {
  final _lastFmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final repo = context.read<MusicRepository>();
    final lastFm = await repo.getLastFmApiKey();
    if (mounted) {
      _lastFmController.text = lastFm ?? '';
    }
  }

  @override
  void dispose() {
    _lastFmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();

    return _SettingsCard(
      icon: Icons.auto_awesome_rounded,
      title: 'Recommendation Providers',
      subtitle: 'Optional Last.fm key for external track similarity. Local '
          'offline similarity remains active as the permanent baseline.',
      child: TextField(
        controller: _lastFmController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Last.fm API Key',
          hintText: 'Enter API Key',
          filled: true,
          fillColor: SpotlessColors.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save Last.fm Key',
            onPressed: () async {
              await repo.setLastFmApiKey(_lastFmController.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Last.fm API key saved')),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _DiagnosticsSection extends StatelessWidget {
  const _DiagnosticsSection();

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();
    final theme = Theme.of(context);
    final downloads = context.watch<DownloadManager>();

    return _SettingsCard(
      icon: Icons.analytics_outlined,
      title: 'Diagnostics & Maintenance',
      subtitle: 'System observability, listening metrics, and recommendation maintenance',
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.download_for_offline_outlined,
              color: SpotlessColors.success,
            ),
            title: const Text('Download manager'),
            subtitle: Text(
              downloads.activeCount > 0
                  ? '${downloads.activeCount} active or queued download(s)'
                  : 'View download history, cancel and retry',
              style: const TextStyle(
                color: SpotlessColors.onSurfaceMedium,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: SpotlessColors.onSurfaceDim,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DownloadsPage()),
            ),
          ),
          const Divider(color: Colors.white12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.bug_report_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Open Diagnostics Screen'),
            subtitle: const Text(
              'View live session, playback, lyrics & ranking metrics (Spec §50)',
              style: TextStyle(color: SpotlessColors.onSurfaceMedium, fontSize: 12),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: SpotlessColors.onSurfaceDim,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DebugPage()),
              );
            },
          ),
          const Divider(color: Colors.white12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.cleaning_services_outlined,
              color: SpotlessColors.warning,
            ),
            title: const Text('Clean Discovery Cache'),
            subtitle: const Text(
              'Purge stale unplayed recommendation candidates (Spec §24)',
              style: TextStyle(color: SpotlessColors.onSurfaceMedium, fontSize: 12),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: SpotlessColors.onSurfaceDim,
            ),
            onTap: () async {
              final cleaned = await repo.discoveryService.cleanupStaleCandidates();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cleaned up $cleaned stale discovery candidates',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
