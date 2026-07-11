import 'package:flutter/material.dart';

class DrinkProvider extends ChangeNotifier {
  DateTime? _selectedDate;
  final List<Map<String, dynamic>> _drinkHistory = [];

  DateTime? get selectedDate => _selectedDate;
  List<Map<String, dynamic>> get drinkHistory =>
      List.unmodifiable(_drinkHistory);


  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void addDrink(Map<String, dynamic> drink) {
    _drinkHistory.add(drink);
    notifyListeners();
  }


  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }


  List<Map<String, dynamic>> historyForDate(String dateStr) {
    return _drinkHistory.where((d) => d['date'] == dateStr).toList();
  }

  int totalCupFor(String dateStr) => historyForDate(dateStr).length;

  int totalMlFor(String dateStr) => historyForDate(
    dateStr,
  ).fold(0, (sum, d) => sum + ((d['ml'] ?? 0) as num).toInt());

  int totalCaloriesFor(String dateStr) => historyForDate(
    dateStr,
  ).fold(0, (sum, d) => sum + ((d['calories'] ?? 0) as num).toInt());
}
