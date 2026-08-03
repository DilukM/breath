/// Moods offered on the check-in screens before/after a session.
class Mood {
  final String label;
  final String emoji;

  const Mood(this.label, this.emoji);
}

const List<Mood> kMoods = [
  Mood('Restless', '😖'),
  Mood('Heavy', '😔'),
  Mood('Okay', '😐'),
  Mood('Calm', '🙂'),
  Mood('Great', '😌'),
];
