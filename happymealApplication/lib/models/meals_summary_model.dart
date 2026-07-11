import 'package:flutter/material.dart';

class MealsSummaryModel extends ChangeNotifier {
  int _totalMeals = 0;
  int _totalFoodItems = 0;
  int _totalCalories = 0;
  int _totalCarb = 0;
  int _totalProtein = 0;
  int _totalFat = 0;

  get totalMeals => this._totalMeals;
  set totalMeals( value) {
    this._totalMeals = value;
    notifyListeners();
  }

  get totalFoodItems => this._totalFoodItems;
  set totalFoodItems( value) {
    this._totalFoodItems = value;
    notifyListeners();
  }

  get totalCalories => this._totalCalories;
  set totalCalories( value) {
    this._totalCalories = value;
    notifyListeners();
  }

  get totalCarb => this._totalCarb;
  set totalCarb( value) {
    this._totalCarb = value;
    notifyListeners();
  }

  get totalProtein => this._totalProtein;
  set totalProtein( value) {
    this._totalProtein = value;
    notifyListeners();
  }

  get totalFat => this._totalFat;
  set totalFat( value) {
    this._totalFat = value;
    notifyListeners();
  }

}