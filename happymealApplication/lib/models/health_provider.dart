import 'package:flutter/material.dart';

class HealthProvider extends ChangeNotifier {
  String _height = '';
  String _weight = '';
  String _wrist = '';

  String _todayHeight = '';
  String _todayWeight = '';
  String _todayWrist = '';
  double _todayBMI = 0.0;

  DateTime _selectedDate = DateTime.now();

  String get height => _height;
  set height(String value) {
    _height = value;
    notifyListeners();
  }

  String get weight => _weight;
  set weight(String value) {
    _weight = value;
    notifyListeners();
  }

  String get wrist => _wrist;
  set wrist(String value) {
    _wrist = value;
    notifyListeners();
  }

  String get todayHeight => _todayHeight;
  set todayHeight(String value) {
    _todayHeight = value;
    notifyListeners();
  }

  String get todayWeight => _todayWeight;
  set todayWeight(String value) {
    _todayWeight = value;
    notifyListeners();
  }

  String get todayWrist => _todayWrist;
  set todayWrist(String value) {
    _todayWrist = value;
    notifyListeners();
  }

  double get todayBMI => _todayBMI;
  set todayBMI(double value) {
    _todayBMI = value;
    notifyListeners();
  }

  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  void clear() {
    _height = '';
    _weight = '';
    _wrist = '';
    notifyListeners();
  }

  void reset() {
    _height = '';
    _weight = '';
    _wrist = '';
    _todayHeight = '';
    _todayWeight = '';
    _todayWrist = '';
    _todayBMI = 0.0;
    _selectedDate = DateTime.now();
    notifyListeners();
  }
}