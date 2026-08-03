// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breathing_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreathingSessionAdapter extends TypeAdapter<BreathingSession> {
  @override
  final int typeId = 0;

  @override
  BreathingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreathingSession(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
      durationMinutes: fields[2] as int,
      completedCycles: fields[3] as int,
      completed: fields[4] as bool,
      moodBefore: fields[5] as String?,
      moodAfter: fields[6] as String?,
      techniqueId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BreathingSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.durationMinutes)
      ..writeByte(3)
      ..write(obj.completedCycles)
      ..writeByte(4)
      ..write(obj.completed)
      ..writeByte(5)
      ..write(obj.moodBefore)
      ..writeByte(6)
      ..write(obj.moodAfter)
      ..writeByte(7)
      ..write(obj.techniqueId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathingSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
