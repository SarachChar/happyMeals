import 'package:flutter/material.dart';
import 'package:happymeal_application/models/drink_model.dart';

/// Pure data/state holder for drinks — mirrors ExerciseModel's role.
/// Fetching/adding/deleting now happens via DrinkController directly in
/// DrinkPage; this class no longer owns a controller.
class DrinkProvider extends ChangeNotifier {
  DateTime? _selectedDate;
  List<Drink> _drinks = [];

  DateTime? get selectedDate => _selectedDate;
  List<Drink> get drinks => List.unmodifiable(_drinks);

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setDrinks(List<Drink> drinks) {
    _drinks = drinks;
    notifyListeners();
  }

  void reset() {
    _selectedDate = null;
    _drinks = [];
    notifyListeners();
  }

  void addDrink(Drink drink) {
    _drinks.add(drink);
    notifyListeners();
  }

  void removeDrink(Drink drink) {
    _drinks.removeWhere((d) => d.dbId == drink.dbId);
    notifyListeners();
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<Drink> historyForDate(String dateStr) {
    return _drinks.where((d) => d.date == dateStr).toList();
  }

  int totalCupFor(String dateStr) => historyForDate(dateStr).length;

  int totalMlFor(String dateStr) =>
      historyForDate(dateStr).fold(0, (sum, d) => sum + d.ml);

  int totalCaloriesFor(String dateStr) =>
      historyForDate(dateStr).fold(0, (sum, d) => sum + d.calories);
}
