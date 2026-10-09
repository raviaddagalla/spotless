class LyricLine {
  final Duration time;
  final String text;

  const LyricLine({required this.time, required this.text});
}

class Lyrics {
  final bool synced;
  final List<LyricLine> lines;
  final String plainText;

  const Lyrics({required this.synced, required this.lines, required this.plainText});

  bool get isEmpty => plainText.trim().isEmpty && lines.isEmpty;
}
