enum SongStatus {
  analyzing,
  downloaded,
  streamable,
  missing,
  failed;

  static SongStatus fromName(String name) =>
      SongStatus.values.firstWhere((s) => s.name == name,
          orElse: () => SongStatus.streamable);
}
