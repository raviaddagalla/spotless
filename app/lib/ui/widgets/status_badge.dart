import 'package:flutter/material.dart';

import '../../core/models/song_status.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final songStatus = SongStatus.fromName(status);
    final (label, color) = switch (songStatus) {
      SongStatus.downloaded => ('Downloaded', const Color(0xFF1DB954)),
      SongStatus.streamable => ('Streamable', const Color(0xFF4FC3F7)),
      SongStatus.missing => ('Missing', const Color(0xFF9E9E9E)),
      SongStatus.failed => ('Failed', const Color(0xFFE53935)),
      SongStatus.analyzing => ('Analyzing…', const Color(0xFFFFB300)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
