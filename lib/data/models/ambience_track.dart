/// A background sound the user can play during a session.
class AmbienceTrack {
  final String id;
  final String label;

  /// Path passed to `AudioPlayer.play(AssetSource(...))` — relative to
  /// `assets/`, matching the `assets/sounds/` directory declared in
  /// pubspec.yaml.
  final String? assetPath;
  final String? url;

  const AmbienceTrack({
    required this.id,
    required this.label,
    this.assetPath,
    this.url,
  });
}

const List<AmbienceTrack> kAmbienceTracks = [
  AmbienceTrack(id: 'forest', label: 'Forest', url: 'https://github.com/user-attachments/files/32869562/forest.mp3'),
  AmbienceTrack(id: 'rain', label: 'Rain', url: 'https://github.com/user-attachments/files/32870848/rain.mp3'),
  AmbienceTrack(id: 'ocean', label: 'Ocean', url: 'https://github.com/user-attachments/files/32869578/ocean.mp3'),
  AmbienceTrack(id: 'flute', label: 'Flute', url: 'https://github.com/user-attachments/files/32869526/flute.mp3'),
  AmbienceTrack(id: 'chant', label: 'Chant', url: 'https://github.com/user-attachments/files/32869509/chant.mp3'),
  AmbienceTrack(id: 'om', label: 'Om Mantra', url: 'https://github.com/user-attachments/files/32869651/om.mantra.mp3'),
];

AmbienceTrack ambienceById(String id) => kAmbienceTracks.firstWhere(
      (t) => t.id == id,
      orElse: () => kAmbienceTracks.first,
    );
