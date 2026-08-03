import '../../core/utils/unsplash.dart';

/// A guided breathing pattern the user can pick from the Library.
class BreathingTechnique {
  final String id;
  final String name;
  final String pattern; // e.g. "4-7-8"
  final String description;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final String imageUrl;
  final String imageCredit;
  final bool advanced;

  const BreathingTechnique({
    required this.id,
    required this.name,
    required this.pattern,
    required this.description,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.imageUrl,
    required this.imageCredit,
    this.advanced = false,
  });
}

const List<BreathingTechnique> kBreathingTechniques = [
  BreathingTechnique(
    id: '4-7-8',
    name: '4-7-8 Relax',
    pattern: '4-7-8',
    description: "Settles the nervous system before sleep",
    inhaleSeconds: 4,
    holdSeconds: 7,
    exhaleSeconds: 8,
    imageUrl: UnsplashPhotos.nightForest,
    imageCredit: 'Photo by Dmitry Spravko on Unsplash',
  ),
  BreathingTechnique(
    id: '5-5',
    name: 'Coherent 5-5',
    pattern: '5-5',
    description: 'Even, steady breathing to build focus',
    inhaleSeconds: 5,
    holdSeconds: 0,
    exhaleSeconds: 5,
    imageUrl: UnsplashPhotos.darkWater,
    imageCredit: 'Photo by Illia Horokhovsky on Unsplash',
  ),
  BreathingTechnique(
    id: 'box-4x4',
    name: 'Box 4×4',
    pattern: '4-4-4-4',
    description: 'Steady nerves with an even box count',
    inhaleSeconds: 4,
    holdSeconds: 4,
    exhaleSeconds: 4,
    imageUrl: UnsplashPhotos.neonArchitecture,
    imageCredit: 'Photo by Julia Taubitz on Unsplash',
  ),
  BreathingTechnique(
    id: 'wim-hof',
    name: 'Wim Hof rounds',
    pattern: '30 + hold',
    description: '30 fast breaths, then a long hold',
    inhaleSeconds: 2,
    holdSeconds: 0,
    exhaleSeconds: 2,
    imageUrl: UnsplashPhotos.sunlitLeaves,
    imageCredit: 'Photo by Nick Augustat on Unsplash',
    advanced: true,
  ),
];

BreathingTechnique techniqueById(String id) => kBreathingTechniques.firstWhere(
      (t) => t.id == id,
      orElse: () => kBreathingTechniques.first,
    );
