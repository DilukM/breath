import 'package:hive/hive.dart';

part 'breathing_session.g.dart';

/// Model for a breathing session
@HiveType(typeId: 0)
class BreathingSession {
  @HiveField(0)
  final DateTime startTime;

  @HiveField(1)
  final DateTime endTime;

  @HiveField(2)
  final int durationMinutes;

  @HiveField(3)
  final int completedCycles;

  @HiveField(4)
  final bool completed;

  @HiveField(5)
  final String? moodBefore;

  @HiveField(6)
  final String? moodAfter;

  @HiveField(7)
  final String? techniqueId;

  BreathingSession({
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.completedCycles,
    required this.completed,
    this.moodBefore,
    this.moodAfter,
    this.techniqueId,
  });

  /// Calculate the actual duration of the session
  Duration get actualDuration => endTime.difference(startTime);

  /// Create a copy with updated fields
  BreathingSession copyWith({
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? completedCycles,
    bool? completed,
    String? moodBefore,
    String? moodAfter,
    String? techniqueId,
  }) {
    return BreathingSession(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completedCycles: completedCycles ?? this.completedCycles,
      completed: completed ?? this.completed,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      techniqueId: techniqueId ?? this.techniqueId,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completedCycles': completedCycles,
      'completed': completed,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
      'techniqueId': techniqueId,
    };
  }

  /// Create from map
  factory BreathingSession.fromMap(Map<String, dynamic> map) {
    return BreathingSession(
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      durationMinutes: map['durationMinutes'],
      completedCycles: map['completedCycles'],
      completed: map['completed'],
      moodBefore: map['moodBefore'],
      moodAfter: map['moodAfter'],
      techniqueId: map['techniqueId'],
    );
  }
}
