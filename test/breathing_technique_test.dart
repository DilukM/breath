import 'package:flutter_test/flutter_test.dart';
import 'package:mindful_breathing/data/models/breathing_technique.dart';

void main() {
  test('techniqueById finds an existing technique', () {
    final technique = techniqueById('box-4x4');

    expect(technique.id, 'box-4x4');
    expect(technique.name, 'Box 4×4');
    expect(technique.inhaleSeconds, 4);
    expect(technique.holdSeconds, 4);
    expect(technique.exhaleSeconds, 4);
  });

  test('techniqueById falls back to the first technique for an unknown id', () {
    final technique = techniqueById('does-not-exist');

    expect(technique, kBreathingTechniques.first);
  });

  test('kBreathingTechniques has no duplicate ids', () {
    final ids = kBreathingTechniques.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
  });
}
