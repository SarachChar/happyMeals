import 'package:flutter/material.dart';
import 'package:happymeal_application/models/meal_data_model.dart';

class MealsModel extends ChangeNotifier {
  final List<Meal> _meals = [];

  List<Meal> get meals => List.unmodifiable(_meals);

  void addMeal(Meal meal) {
    _meals.add(meal);
    notifyListeners();
  }

  void setMeals(List<Meal> meals) {
    _meals
      ..clear()
      ..addAll(meals);
    notifyListeners();
  }
}
