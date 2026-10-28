import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
import 'theme/spotless_colors.dart';
import 'widgets/song_tile.dart';

enum SearchMode { local, youtube }

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _query =
      TextEditingController(text: widget.initialQuery ?? '');
  SearchMode _mode = SearchMode.local;
  List<SongRow> _localResults = [];
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;
  bool _searched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if ((widget.initialQuery ?? '').isNotEmpty) {
      _runSearch();
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    final q = _query.text.trim();
    if (q.isEmpty) return;
    unawaited(context.read<MusicRepository>().addSearchHistory(q));
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final repo = context.read<MusicRepository>();
      if (_mode == SearchMode.local) {
        final offline = await repo.offlineOnly();
        final songs = await repo.searchSongs(q, offlineOnly: offline);
        if (!mounted) return;
        setState(() {
          _localResults = songs;
          _results = [];
          _searched = true;
        });
      } else {
        final results = await repo.searchYoutube(q);
        if (!mounted) return;
        setState(() {
          _results = results;
          _localResults = [];
          _searched = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _searched = true;
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _switchMode(SearchMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _searched = false;
      _error = null;
      _localResults = [];
      _results = [];
    });
    if (_query.text.trim().isNotEmpty) {
      _runSearch();
    }
  }

  SongRow _toSong(Map<String, dynamic> r) {
    return SongRow(
      id: 'yt:${r['id']}',
      title: (r['title'] as String?) ?? 'Unknown',
      artist: (r['channel'] as String?) ?? '',
      youtubeId: r['id'] as String?,
      status: 'streamable',
      durationMs: (r['duration'] as num?)?.toInt() != null
          ? (r['duration'] as num).toInt() * 1000
          : null,
      albumArtUrl: (r['thumbnail'] as String?)?.isNotEmpty == true
          ? r['thumbnail'] as String
          : null,
      artEmbedded: false,
      explicit: false,
      playCount: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---- Rounded search bar ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: SpotlessColors.surface,
                  borderRadius:
                      BorderRadius.circular(SpotlessColors.radiusFull),
                  border: Border.all(
                    color: SpotlessColors.outline,
                    width: 0.5,
                  ),
                ),
                child: TextField(
                  controller: _query,
                  autofocus: widget.initialQuery == null,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists or lyrics',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: SpotlessColors.onSurfaceDim,
                    ),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: SpotlessColors.onSurfaceMedium),
                    suffixIcon: _query.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              _query.clear();
                              setState(() {
                                _searched = false;
                                _localResults = [];
                                _results = [];
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (_) => _runSearch(),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),

            // ---- Mode toggle ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _ModePill(
                    label: 'Local',
                    icon: Icons.music_note_rounded,
                    selected: _mode == SearchMode.local,
                    onTap: () => _switchMode(SearchMode.local),
                  ),
                  const SizedBox(width: 8),
                  _ModePill(
                    label: 'YouTube',
                    icon: Icons.download_outlined,
                    selected: _mode == SearchMode.youtube,
                    onTap: () => _switchMode(SearchMode.youtube),
                  ),
                ],
              ),
            ),

            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _runSearch, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (!_searched) {
      return _SearchIdle(
        mode: _mode,
        onHistoryTap: (q) {
          _query.text = q;
          _runSearch();
        },
      );
    }
    if (_mode == SearchMode.local) {
      if (_localResults.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 40,
                    color: SpotlessColors.onSurfaceDim),
                const SizedBox(height: 12),
                Text(
                  'No local songs found for "${_query.text.trim()}".',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _switchMode(SearchMode.youtube),
                  child: const Text('Search YouTube instead'),
                ),
              ],
            ),
          ),
        );
      }
      final player = context.watch<PlayerController>();
      return ListView.builder(
        itemCount: _localResults.length,
        itemBuilder: (context, index) {
          final song = _localResults[index];
          return SongTile(
            song: song,
            isCurrent: player.currentSong?.id == song.id,
            showStatus: true,
            onTap: () async {
              await player.playQueue([song]);
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NowPlayingPage()),
                );
              }
            },
          );
        },
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 40,
                  color: SpotlessColors.onSurfaceDim),
              const SizedBox(height: 12),
              Text(
                'No results for "${_query.text.trim()}". '
                'YouTube may be throttling — retry or try a different query.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _runSearch, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final player = context.watch<PlayerController>();
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final r = _results[index];
        final song = _toSong(r);
        return _YTResultTile(
          result: r,
          song: song,
          onTap: () async {
            await player.playQueue([song]);
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NowPlayingPage()),
              );
            }
          },
          onDownload: () async {
            try {
              await player.downloadSong(song);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download finished')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Download failed: $e')),
                );
              }
            }
          },
        );
      },
    );
  }
}

// ====================================================================
// Mode toggle pill
// ====================================================================

class _ModePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.18)
              : SpotlessColors.surface,
          borderRadius: BorderRadius.circular(SpotlessColors.radiusFull),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.4)
                : SpotlessColors.outline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? scheme.primary : SpotlessColors.onSurfaceDim,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected
                        ? scheme.primary
                        : SpotlessColors.onSurfaceMedium,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// YouTube result tile
// ====================================================================

class _YTResultTile extends StatelessWidget {
  final Map<String, dynamic> result;
  final SongRow song;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  const _YTResultTile({
    required this.result,
    required this.song,
    required this.onTap,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumb = result['thumbnail'] as String?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: SpotlessColors.surface,
        borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(SpotlessColors.radiusSm),
                child: thumb != null && thumb.isNotEmpty
                    ? Image.network(
                        thumb,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const _PlaceholderThumb(),
                      )
                    : const _PlaceholderThumb(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (result['title'] as String?) ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${result['channel'] ?? ''} · ${_fmt((result['duration'] as num?)?.toInt())}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SpotlessColors.onSurfaceMedium,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_outlined, size: 22),
                tooltip: 'Download',
                color: SpotlessColors.onSurfaceMedium,
                onPressed: onDownload,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(int? secs) {
    if (secs == null) return '';
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _PlaceholderThumb extends StatelessWidget {
  const _PlaceholderThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      color: SpotlessColors.surfaceTop,
      child: Icon(Icons.music_note, color: SpotlessColors.onSurfaceDim),
    );
  }
}

// ====================================================================
// Search idle state with recent history
// ====================================================================

class _SearchIdle extends StatefulWidget {
  final SearchMode mode;
  final ValueChanged<String> onHistoryTap;

  const _SearchIdle({required this.mode, required this.onHistoryTap});

  @override
  State<_SearchIdle> createState() => _SearchIdleState();
}

class _SearchIdleState extends State<_SearchIdle> {
  late Future<List<String>> _history;

  @override
  void initState() {
    super.initState();
    _history = context.read<MusicRepository>().searchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _history,
      builder: (context, snap) {
        final history = snap.data ?? const [];
        if (history.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_rounded, size: 48,
                      color: SpotlessColors.onSurfaceDim),
                  const SizedBox(height: 12),
                  Text(
                    widget.mode == SearchMode.local
                        ? 'Search your library — songs, artists or lyrics.'
                        : 'Search YouTube — tap to stream, download icon to save.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SpotlessColors.onSurfaceMedium,
                        ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text(
                  'Recent searches',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await context
                        .read<MusicRepository>()
                        .clearSearchHistory();
                    if (mounted) {
                      setState(() => _history = context
                          .read<MusicRepository>()
                          .searchHistory());
                    }
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (final q in history)
              ListTile(
                dense: true,
                leading: Icon(Icons.history, size: 20,
                    color: SpotlessColors.onSurfaceDim),
                title: Text(q, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => widget.onHistoryTap(q),
              ),
          ],
        );
      },
    );
  }
}
