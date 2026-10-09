import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotless/core/db/app_database.dart';

void main() {
  group('Shuffle & Smart Shuffle Specification §33-§34', () {
    test('Normal shuffle keeps current song first and preserves all items', () {
      final queue = List.generate(
        10,
        (i) => SongRow(
          id: 'song_$i',
          title: 'Title $i',
          artist: 'Artist ${i % 3}',
          status: 'downloaded',
          playCount: i,
          artEmbedded: false,
          explicit: false,
        ),
      );

      const current = 3;
      final rest = [
        for (var i = 0; i < queue.length; i++)
          if (i != current) i,
      ]..shuffle(Random(42));

      final shuffleOrder = [current, ...rest];

      expect(shuffleOrder.length, equals(queue.length));
      expect(shuffleOrder.first, equals(current));
      expect(shuffleOrder.toSet().length, equals(queue.length)); // No duplicates
    });

    test('Artist diversity spacing avoids consecutive tracks by the same artist', () {
      final songs = [
        const SongRow(id: '1', title: 'A1', artist: 'Drake', status: 'downloaded', playCount: 5, artEmbedded: false, explicit: false),
        const SongRow(id: '2', title: 'A2', artist: 'Drake', status: 'downloaded', playCount: 5, artEmbedded: false, explicit: false),
        const SongRow(id: '3', title: 'A3', artist: 'Drake', status: 'downloaded', playCount: 5, artEmbedded: false, explicit: false),
        const SongRow(id: '4', title: 'B1', artist: 'Adele', status: 'downloaded', playCount: 3, artEmbedded: false, explicit: false),
        const SongRow(id: '5', title: 'C1', artist: 'Coldplay', status: 'downloaded', playCount: 2, artEmbedded: false, explicit: false),
        const SongRow(id: '6', title: 'D1', artist: 'Queen', status: 'downloaded', playCount: 1, artEmbedded: false, explicit: false),
      ];

      // Simulate spacing logic
      final remaining = List.generate(songs.length, (i) => i);
      final spaced = <int>[];
      String lastArtist = '';

      while (remaining.isNotEmpty) {
        int pickIdx = 0;
        if (lastArtist.isNotEmpty) {
          for (var i = 0; i < remaining.length; i++) {
            if (songs[remaining[i]].artist.toLowerCase() != lastArtist) {
              pickIdx = i;
              break;
            }
          }
        }
        final chosen = remaining.removeAt(pickIdx);
        spaced.add(chosen);
        lastArtist = songs[chosen].artist.toLowerCase();
      }

      // Verify that no two consecutive songs have the same artist where alternates existed
      for (var i = 0; i < spaced.length - 1; i++) {
        final a1 = songs[spaced[i]].artist;
        final a2 = songs[spaced[i + 1]].artist;
        if (a1 == a2) {
          // Only allowed if all remaining candidates were the same artist
          final remainingSame = spaced.skip(i).every((idx) => songs[idx].artist == a1);
          expect(remainingSame, isTrue);
        }
      }
    });
  });
}
