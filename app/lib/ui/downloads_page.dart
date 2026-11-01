import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/download_manager.dart';
import 'theme/spotless_colors.dart';
import 'widgets/album_art.dart';

/// Visible queue for all yt-dlp downloads. The queue is serialized by
/// [DownloadManager]; this page exposes progress, cancellation and retry
/// instead of leaving a blocked import dialog as the only feedback.
class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<DownloadManager>();
    final tasks = manager.tasks.reversed.toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (tasks.any((t) => t.isFinished))
            TextButton(
              onPressed: manager.clearFinished,
              child: const Text('Clear finished'),
            ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download_for_offline_outlined,
                        size: 56, color: SpotlessColors.onSurfaceDim),
                    const SizedBox(height: 16),
                    Text(
                      'No downloads yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Download a song from the library, search results or the '
                      'player. Queued downloads run one at a time and survive '
                      'screen changes.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SpotlessColors.onSurfaceMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _TaskCard(task: task, manager: manager);
              },
            ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final DownloadTask task;
  final DownloadManager manager;

  const _TaskCard({required this.task, required this.manager});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (label, color) = switch (task.status) {
      DownloadTaskStatus.queued => ('Queued', SpotlessColors.onSurfaceMedium),
      DownloadTaskStatus.running => (
          'Downloading ${(task.progress * 100).round()}%',
          scheme.primary
        ),
      DownloadTaskStatus.completed => ('Saved offline', SpotlessColors.success),
      DownloadTaskStatus.failed => ('Failed', SpotlessColors.error),
      DownloadTaskStatus.cancelled => ('Cancelled', SpotlessColors.warning),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SpotlessColors.surface,
        borderRadius: BorderRadius.circular(SpotlessColors.radiusMd),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(SpotlessColors.radiusSm),
                child: AlbumArt(song: task.song, size: 48),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SpotlessColors.onSurfaceMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.cancelRequested && task.status == DownloadTaskStatus.running
                          ? 'Cancelling…'
                          : label,
                      style: theme.textTheme.labelSmall?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              if (!task.isFinished)
                IconButton(
                  tooltip: 'Cancel download',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => manager.cancel(task),
                )
              else if (task.status == DownloadTaskStatus.failed ||
                  task.status == DownloadTaskStatus.cancelled)
                IconButton(
                  tooltip: 'Retry download',
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  onPressed: () async {
                    try {
                      await manager.retry(task);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Download failed: $e')),
                        );
                      }
                    }
                  },
                )
              else
                IconButton(
                  tooltip: 'Remove from list',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => manager.remove(task),
                ),
            ],
          ),
          if (task.status == DownloadTaskStatus.running ||
              task.status == DownloadTaskStatus.queued) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: task.status == DownloadTaskStatus.queued
                    ? null
                    : task.progress,
                minHeight: 4,
              ),
            ),
          ],
          if (task.error != null &&
              task.status != DownloadTaskStatus.cancelled) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                task.error!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SpotlessColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
