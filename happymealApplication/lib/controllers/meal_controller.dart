import 'dart:async';
import 'package:happymeal_application/models/meal_data_model.dart';
import 'package:happymeal_application/services/meal_service.dart';

class MealController {
  final MealService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  MealController(this.service);

  Future<void> addMeal(Meal meal) async {
    onSyncController.add(true);
    await service.addMeal(meal);
    onSyncController.add(false);
  }

  Future<List<Meal>> fetchMeals(String userId) async {
    onSyncController.add(true);
    final meals = await service.getMeals(userId);
    onSyncController.add(false);
    return meals;
  }

  Future<List<Meal>> fetchMealsByDate(DateTime date, String userId) async {
    onSyncController.add(true);
    final meals = await service.getMealsByDate(date, userId);
    onSyncController.add(false);
    return meals;
  }

  Future<void> updateMeal(Meal meal) async {
    onSyncController.add(true);
    await service.updateMeal(meal);
    onSyncController.add(false);
  }
}
