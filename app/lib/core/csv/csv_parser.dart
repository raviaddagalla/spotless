/// RFC 4180 CSV parser that handles quoted fields, embedded quotes,
/// commas inside quotes and BOM. Spotify playlist exports rely on this.
class CsvParser {
  final List<List<String>> rows;

  CsvParser(this.rows);

  factory CsvParser.parse(String input) {
    String text = input;
    if (text.startsWith('\uFEFF')) {
      text = text.substring(1);
    }
    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final rows = <List<String>>[];
    final row = <String>[];
    final cell = StringBuffer();
    var inQuotes = false;
    var started = false;

    void endCell() {
      row.add(cell.toString());
      cell.clear();
      started = false;
    }

    void endRow() {
      endCell();
      rows.add(List.of(row));
      row.clear();
    }

    for (var i = 0; i < text.length; i++) {
      final c = text[i];
      if (inQuotes) {
        if (c == '"') {
          if (i + 1 < text.length && text[i + 1] == '"') {
            cell.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          cell.write(c);
        }
      } else {
        switch (c) {
          case '"':
            inQuotes = true;
            started = true;
          case ',':
            endCell();
          case '\n':
            endRow();
          default:
            cell.write(c);
            started = true;
        }
      }
    }
    if (started || cell.isNotEmpty || row.isNotEmpty) {
      endRow();
    }
    return CsvParser(rows);
  }

  List<Map<String, String>> toMaps() {
    if (rows.isEmpty) return const [];
    final header = rows.first.map((h) => h.trim()).toList();
    final result = <Map<String, String>>[];
    for (final row in rows.skip(1)) {
      final map = <String, String>{};
      for (var i = 0; i < header.length; i++) {
        map[header[i]] = i < row.length ? row[i] : '';
      }
      result.add(map);
    }
    return result;
  }
}
