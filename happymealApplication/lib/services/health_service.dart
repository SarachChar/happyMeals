import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happymeal_application/models/health_model.dart';

abstract class HealthService {
  Future<Health> addHealth(Health health);
  Future<List<Health>> getHealths(String userId);
  Future<List<Health>> getHealthsByDate(DateTime date, String userId);
  Future<void> updateHealth(Health health);
}

String healthDocId(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  String three(int n) => n.toString().padLeft(3, '0');
  return '${dt.year}${two(dt.month)}${two(dt.day)}'
      '${two(dt.hour)}${two(dt.minute)}${two(dt.second)}'
      '${three(dt.millisecond)}';
}

class HealthFirebaseService implements HealthService {
  
  @override
  Future<Health> addHealth(Health health) async {
    await FirebaseFirestore.instance
        .collection('health')
        .doc(healthDocId(health.createdAt))
        .set({
          ...health.toMap(),
          'timestamp': FieldValue.serverTimestamp(),
        });
    return health;
  }

  @override
  Future<List<Health>> getHealths(String userId) async {
    final qs = await FirebaseFirestore.instance
        .collection('health')
        .where('userId', isEqualTo: userId)
        .get();
    return qs.docs
        .map((doc) => Health.fromSnapshot(doc.data() as Map<String, dynamic>))
        .where((health) => !health.isDelete)
        .toList();
  }

  @override
  Future<List<Health>> getHealthsByDate(DateTime date, String userId) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    
    final qs = await FirebaseFirestore.instance
        .collection('health')
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('createdAt', isLessThan: end.toIso8601String())
        .get();
        
    return qs.docs
        .map((doc) => Health.fromSnapshot(doc.data() as Map<String, dynamic>))
        .where((health) => !health.isDelete)
        .toList();
  }

  @override
  Future<void> updateHealth(Health health) async {
    await FirebaseFirestore.instance
        .collection('health')
        .doc(healthDocId(health.createdAt))
        .update({
          'isDelete': true,
        });
  }
}