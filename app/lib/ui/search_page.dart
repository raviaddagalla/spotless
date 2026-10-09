import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/db/app_database.dart';
import '../core/services/music_repository.dart';
import '../core/state/player_controller.dart';
import 'now_playing_page.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: widget.initialQuery == null,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search songs, artists or lyrics',
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _runSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _runSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<SearchMode>(
              segments: const [
                ButtonSegment(
                  value: SearchMode.local,
                  label: Text('Local'),
                  icon: Icon(Icons.music_note),
                ),
                ButtonSegment(
                  value: SearchMode.youtube,
                  label: Text('YouTube'),
                  icon: Icon(Icons.download_outlined),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => _switchMode(s.first),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
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
                const Icon(Icons.search_off, size: 40),
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
              const Icon(Icons.search_off, size: 40),
              const SizedBox(height: 12),
              Text(
                'No results for "${_query.text.trim()}". '
                'YouTube may be throttling this device/network — '
                'retry in a bit or try a different query.',
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
        return ListTile(
          leading: _thumb(r['thumbnail'] as String?),
          title: Text(
            (r['title'] as String?) ?? 'Unknown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${r['channel'] ?? ''} · ${_fmt((r['duration'] as num?)?.toInt())}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.download_outlined),
                tooltip: 'Download',
                onPressed: () async {
                  try {
                    await player.downloadSong(song);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Download finished')),
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
              ),
            ],
          ),
          onTap: () async {
            // Stream the not-yet-downloaded song straight from YouTube;
            // the download button remains the way to save it offline.
            final player = context.read<PlayerController>();
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

  Widget _thumb(String? url) {
    if (url == null || url.isEmpty) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Icon(Icons.music_note),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.music_note),
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

/// Idle state before a search: recent query chips (F6).
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
            child: Text(
              widget.mode == SearchMode.local
                  ? 'Search your library — songs, artists or lyrics.'
                  : 'Search YouTube — tap a result to stream it, '
                      'or use the download icon to save it offline.',
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
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
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
                leading: const Icon(Icons.history, size: 20),
                title: Text(q, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => widget.onHistoryTap(q),
              ),
          ],
        );
      },
    );
  }
}
