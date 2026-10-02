import 'package:flutter_test/flutter_test.dart';
import 'package:mindful_breathing/data/models/ambience_track.dart';

void main() {
  test('ambienceById finds an existing track', () {
    final track = ambienceById('ocean');

    expect(track.id, 'ocean');
    expect(track.label, 'Ocean');
    expect(track.assetPath, 'sounds/ocean.mp3');
  });

  test('ambienceById falls back to the first track for an unknown id', () {
    final track = ambienceById('does-not-exist');

    expect(track, kAmbienceTracks.first);
  });

  test('kAmbienceTracks has no duplicate ids and every asset path is under sounds/', () {
    final ids = kAmbienceTracks.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);

    for (final track in kAmbienceTracks) {
      expect(track.assetPath, startsWith('sounds/'));
    }
  });
}
