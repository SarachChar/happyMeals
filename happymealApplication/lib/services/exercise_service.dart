import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happymeal_application/components/exercise_log.dart';

abstract class ExerciseService {
  Future<List<ExerciseLogEntry>> getExercises();
  Future<ExerciseLogEntry> addExercise(ExerciseLogEntry entry);
  Future<void> deleteExercise(ExerciseLogEntry entry);
}

class ExerciseFirebaseService implements ExerciseService {
  @override
  Future<List<ExerciseLogEntry>> getExercises() async {
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('exercises').get();
    AllExercises all = AllExercises.fromSnapshot(qs);
    return all.exercises;
  }

  @override
  Future<ExerciseLogEntry> addExercise(ExerciseLogEntry entry) async {
    final exerciseRef =
        await FirebaseFirestore.instance.collection('exercises').add({
      ...entry.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    entry.dbId = exerciseRef.id;
    return entry;
  }

  @override
  Future<void> deleteExercise(ExerciseLogEntry entry) async {
    await FirebaseFirestore.instance
        .collection('exercises')
        .doc(entry.dbId)
        .delete();
  }
}
