import 'dart:async';
import 'package:happymeal_application/components/exercise_log.dart';
import 'package:happymeal_application/services/exercise_service.dart';

class ExerciseController {
  List<ExerciseLogEntry> entries = List.empty();
  final ExerciseService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  ExerciseController(this.service);

  Future<List<ExerciseLogEntry>> fetchExercises(String userId) async {
    onSyncController.add(true);
    entries = await service.getExercises(userId);
    onSyncController.add(false);
    return entries;
  }

  Future<ExerciseLogEntry> addExercise(ExerciseLogEntry entry) async {
    onSyncController.add(true);
    ExerciseLogEntry newEntry = await service.addExercise(entry);
    onSyncController.add(false);
    return newEntry;
  }

  Future<void> deleteExercise(ExerciseLogEntry entry) async {
    onSyncController.add(true);
    await service.deleteExercise(entry);
    onSyncController.add(false);
  }
}
