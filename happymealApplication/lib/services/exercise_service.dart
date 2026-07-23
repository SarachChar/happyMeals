import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happymeal_application/components/exercise_log.dart';

abstract class ExerciseService {
  Future<List<ExerciseLogEntry>> getExercises(String userId);
  Future<List<ExerciseLogEntry>> getExercisesByDate(String userId, DateTime date);
  Future<ExerciseLogEntry> addExercise(ExerciseLogEntry entry);
  Future<void> deleteExercise(ExerciseLogEntry entry);
}

String exerciseDocId(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  String three(int n) => n.toString().padLeft(3, '0');
  return '${dt.year}${two(dt.month)}${two(dt.day)}'
      '${two(dt.hour)}${two(dt.minute)}${two(dt.second)}'
      '${three(dt.millisecond)}';
}

class ExerciseFirebaseService implements ExerciseService {
  @override
  Future<List<ExerciseLogEntry>> getExercises(String userId) async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('exercises')
        .where('userId', isEqualTo: userId)
        .where('isDelete', isEqualTo: false)
        .get();
    AllExercises all = AllExercises.fromSnapshot(qs);
    return all.exercises;
  }

  @override
  Future<List<ExerciseLogEntry>> getExercisesByDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('exercises')
        .where('userId', isEqualTo: userId)
        .where('isDelete', isEqualTo: false)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .get();
    AllExercises all = AllExercises.fromSnapshot(qs);
    return all.exercises;
  }

  @override
  Future<ExerciseLogEntry> addExercise(ExerciseLogEntry entry) async {
    final docId = exerciseDocId(DateTime.now());
    await FirebaseFirestore.instance.collection('exercises').doc(docId).set({
      ...entry.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    entry.dbId = docId;
    return entry;
  }

  @override
  Future<void> deleteExercise(ExerciseLogEntry entry) async {
    await FirebaseFirestore.instance
        .collection('exercises')
        .doc(entry.dbId)
        .update({'isDelete': true});
  }
}
