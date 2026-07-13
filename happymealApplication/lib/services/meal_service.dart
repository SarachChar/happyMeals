import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happymeal_application/models/meal_data_model.dart';

abstract class MealService {
  Future<void> addMeal(Meal meal);
  Future<List<Meal>> getMeals();
  Future<List<Meal>> getMealsByDate(DateTime date);
  Future<void> updateMeal(Meal meal);
}

String mealDocId(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  String three(int n) => n.toString().padLeft(3, '0');
  return '${dt.year}${two(dt.month)}${two(dt.day)}'
      '${two(dt.hour)}${two(dt.minute)}${two(dt.second)}'
      '${three(dt.millisecond)}';
}

class MealFirebaseService implements MealService {
  @override
  Future<void> addMeal(Meal meal) async {
    await FirebaseFirestore.instance.collection('meals').doc(mealDocId(meal.createdAt)).set({
      ...meal.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Meal>> getMeals() async {
    final qs = await FirebaseFirestore.instance.collection('meals').get();
    return qs.docs.map((doc) => Meal.fromSnapshot(doc.data()))
        .where((meal) => !meal.isDelete)
        .toList();
  }

  @override
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final qs = await FirebaseFirestore.instance.collection('meals')
        .where('createdAt', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('createdAt', isLessThan: end.toIso8601String())
        .get();
    return qs.docs.map((doc) => Meal.fromSnapshot(doc.data()))
        .where((meal) => !meal.isDelete)
        .toList();
  }

  @override
  Future<void> updateMeal(Meal meal) async {
    await FirebaseFirestore.instance.collection('meals').doc(mealDocId(meal.createdAt))
        .update({
          'isDelete': true
        });
  }
}
