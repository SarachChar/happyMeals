import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ExerciseLogEntry {
  final String time;
  final String type;
  final String intensity;
  final int durationMinutes;
  final int caloriesBurned;
  final IconData icon;
  String dbId;

  ExerciseLogEntry({
    required this.time,
    required this.type,
    required this.intensity,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.icon,
    this.dbId = '',
  });

  factory ExerciseLogEntry.fromSnapshot(Map<String, dynamic> snapshot) {
    return ExerciseLogEntry(
      time: snapshot['time'] as String,
      type: snapshot['type'] as String,
      intensity: snapshot['intensity'] as String,
      durationMinutes: snapshot['durationMinutes'] as int? ?? 0,
      caloriesBurned: snapshot['caloriesBurned'] as int? ?? 0,
      icon: IconData(
        snapshot['iconCodePoint'] as int? ?? Icons.fitness_center.codePoint,
        fontFamily: 'MaterialIcons',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'type': type,
      'intensity': intensity,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'iconCodePoint': icon.codePoint,
    };
  }
}

class AllExercises {
  final List<ExerciseLogEntry> exercises;
  AllExercises(this.exercises);

  factory AllExercises.fromSnapshot(QuerySnapshot qs) {
    List<ExerciseLogEntry> exercises;

    exercises = qs.docs.map((DocumentSnapshot ds) {
      ExerciseLogEntry entry =
          ExerciseLogEntry.fromSnapshot(ds.data() as Map<String, dynamic>);
      entry.dbId = ds.id;
      return entry;
    }).toList();

    return AllExercises(exercises);
  }
}

