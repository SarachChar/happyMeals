import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happymeal_application/models/meal_data_model.dart';

abstract class MealService {
  Future<void> addMeal(Meal meal);
}

class MealFirebaseService implements MealService {
  @override
  Future<void> addMeal(Meal meal) async {
    await FirebaseFirestore.instance.collection('meals').add({
      ...meal.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
