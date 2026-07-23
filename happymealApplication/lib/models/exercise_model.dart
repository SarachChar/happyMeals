import 'package:flutter/material.dart';
import 'package:happymeal_application/components/exercise_log.dart';

class ExerciseModel extends ChangeNotifier {
  final List<ExerciseLogEntry> _entries = [];

  List<ExerciseLogEntry> get entries => _entries;


  int getTotalCalories() {
    int total = 0;
    for (final entry in _entries) {
      total = total + entry.caloriesBurned;
    }
    return total;
  }

  int getTotalDuration() {
    int total = 0;
    for (final entry in _entries) {
      total = total + entry.durationMinutes;
    }
    return total;
  }

  int getSessionCount() {
    return _entries.length;
  }

  void addEntry(ExerciseLogEntry entry) {
    _entries.insert(0, entry);
    notifyListeners();
  }

  void setEntries(List<ExerciseLogEntry> entries) {
    _entries
      ..clear()
      ..addAll(entries);
    notifyListeners();
  }

  void removeEntry(ExerciseLogEntry entry) {
    _entries.removeWhere((e) => e.dbId == entry.dbId);
    notifyListeners();
  }

  void reset() {
    _entries.clear();
    notifyListeners();
  }
}