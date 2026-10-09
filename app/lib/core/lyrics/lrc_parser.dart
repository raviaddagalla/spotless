import '../models/lyrics.dart';

class LrcParser {
  static final _timeTag = RegExp(r'\[(\d{1,3}):(\d{1,2})(?:[.:](\d{1,3}))?\]');
  static final _metaTag = RegExp(r'^\[(ti|ar|al|by|offset|re|ve|length):.*\]$');

  static Lyrics parse(String raw) {
    final lines = <LyricLine>[];
    final textParts = <String>[];

    for (final rawLine in raw.split('\n')) {
      final line = rawLine.trimRight();
      if (line.trim().isEmpty) continue;

      final matches = _timeTag.allMatches(line).toList();
      if (matches.isEmpty) {
        if (!_metaTag.hasMatch(line.trim())) {
          textParts.add(line);
        }
        continue;
      }

      final content = line.substring(matches.last.end).trim();
      if (content.isEmpty) continue;

      for (final m in matches) {
        final minutes = int.tryParse(m.group(1)!) ?? 0;
        final seconds = int.tryParse(m.group(2)!) ?? 0;
        var millis = 0;
        final frac = m.group(3);
        if (frac != null && frac.isNotEmpty) {
          if (frac.length == 1) {
            millis = int.parse(frac) * 100;
          } else if (frac.length == 2) {
            millis = int.parse(frac) * 10;
          } else {
            millis = int.parse(frac);
          }
        }
        lines.add(LyricLine(
          time: Duration(minutes: minutes, seconds: seconds, milliseconds: millis),
          text: content,
        ));
      }
    }

    lines.sort((a, b) => a.time.compareTo(b.time));
    final plain = textParts.join('\n').trim();
    if (lines.isNotEmpty) {
      return Lyrics(synced: true, lines: lines, plainText: plain);
    }
    return Lyrics(synced: false, lines: const [], plainText: plain);
  }
}
