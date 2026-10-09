import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';

import 'debug_page.dart';

class SettingsPage extends StatelessWidget {
  static const route = '/settings';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _LibrarySection(),
          const Divider(height: 32),
          const _ImportSection(),
          const Divider(height: 32),
          const _PlaybackSection(),
          const Divider(height: 32),
          const _CoversSection(),
          const Divider(height: 32),
          const _ProvidersSection(),
          const Divider(height: 32),
          const _DiagnosticsSection(),
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
    setState(() => _busy = true);

    final progress = ValueNotifier<(int, int, String)>((0, 0, 'Starting…'));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProgressDialog(
        title: 'Importing playlists',
        progress: progress,
      ),
    );

    try {
      final result = await repo.importPlaylistCsvs(paths, onProgress: (d, t, m) {
        progress.value = (d, t, m);
      });
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${result.imported} songs'
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Import from Spotify',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          'Pick your Spotify playlist exports (.csv, one file per playlist). '
          'Every song is found on YouTube, downloaded, tagged and given '
          'lyrics + cover art automatically. No local music folder needed — '
          're-run any time to continue where it left off.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _busy ? null : _import,
          icon: const Icon(Icons.file_download_outlined),
          label: Text(_busy ? 'Importing…' : 'Import playlist CSVs…'),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Playback',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Crossfade between songs'),
          subtitle: const Text(
            'Overlaps the next song with the last ~4 seconds of the current one.',
          ),
          value: crossfade,
          onChanged: (v) async {
            setState(() => _crossfade = v);
            final player = context.read<PlayerController>();
            await context.read<MusicRepository>().setCrossfadeEnabled(v);
            player.setCrossfade(
                v ? const Duration(seconds: 4) : Duration.zero);
          },
        ),
      ],
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

  Future<void> _browse() async {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Library',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          'Folder containing songs.csv, sleep.csv, music/ and lyrics/. '
          'The app needs All files access for this path.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _root,
          decoration: const InputDecoration(
            labelText: 'Library folder path',
            hintText: '/storage/emulated/0/Music/SpotlessLibrary',
            border: OutlineInputBorder(),
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
                icon: const Icon(Icons.sync),
                label: Text(_scanning ? 'Scanning…' : 'Save & Rescan'),
              ),
            ),
          ],
        ),
      ],
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
  final ValueNotifier<(int, int, String)> _progress = ValueNotifier((0, 0, ''));

  Future<void> _embedAll() async {
    final repo = context.read<MusicRepository>();
    setState(() => _busy = true);
    _progress.value = (0, 0, 'Starting…');
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ProgressDialog(
        title: 'Embedding covers into MP3s',
        progress: _progress,
      ),
    );
    await repo.embedAllCovers(onProgress: (done, total, current) {
      _progress.value = (done, total, current);
    });
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
            'Removes cached cover images (they will be re-fetched next time).'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Covers',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _busy ? null : _embedAll,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Embed all covers into MP3s'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _busy ? null : _clearCache,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear cover cache'),
        ),
      ],
    );
  }
}

class _ProgressDialog extends StatelessWidget {
  final String title;
  final ValueNotifier<(int, int, String)> progress;

  const _ProgressDialog({required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          );
        },
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
  final _qlooController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final repo = context.read<MusicRepository>();
    final lastFm = await repo.getLastFmApiKey();
    final qloo = await repo.getQlooApiKey();
    if (mounted) {
      _lastFmController.text = lastFm ?? '';
      _qlooController.text = qloo ?? '';
    }
  }

  @override
  void dispose() {
    _lastFmController.dispose();
    _qlooController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendation Providers (Spec §17, §48)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure external recommendation APIs for enhanced music discovery. '
          'Local offline feature similarity is always active as a baseline.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white60,
              ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _lastFmController,
          decoration: InputDecoration(
            labelText: 'Last.fm API Key',
            hintText: 'Enter API Key',
            border: const OutlineInputBorder(),
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
        const SizedBox(height: 12),
        TextField(
          controller: _qlooController,
          decoration: InputDecoration(
            labelText: 'Qloo API Key',
            hintText: 'Enter API Key',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.save_rounded),
              tooltip: 'Save Qloo Key',
              onPressed: () async {
                await repo.setQlooApiKey(_qlooController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Qloo API key saved')),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DiagnosticsSection extends StatelessWidget {
  const _DiagnosticsSection();

  @override
  Widget build(BuildContext context) {
    final repo = context.read<MusicRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diagnostics & Maintenance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.bug_report_outlined, color: Color(0xFF1DB954)),
          title: const Text('Open Diagnostics Screen'),
          subtitle: const Text('View live session, playback, lyrics & ranking metrics'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DebugPage()),
            );
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.cleaning_services_outlined, color: Colors.amber),
          title: const Text('Clean Discovery Cache'),
          subtitle: const Text('Purge stale unplayed recommendation candidates (Spec §24)'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final cleaned = await repo.discoveryService.cleanupStaleCandidates();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleaned up $cleaned stale discovery candidates')),
              );
            }
          },
        ),
      ],
    );
  }
}
