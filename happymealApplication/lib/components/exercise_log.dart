import 'package:flutter/material.dart';


class ExerciseLogEntry {
  final String time;           
  final String type;           
  final String intensity;      
  final int durationMinutes;
  final int caloriesBurned;
  final IconData icon;

  const ExerciseLogEntry({
    required this.time,
    required this.type,
    required this.intensity,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.icon,
  });
}

