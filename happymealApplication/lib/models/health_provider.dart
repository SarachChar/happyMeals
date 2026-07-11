import 'package:flutter/material.dart';

class HealthProvider extends ChangeNotifier {
  String _height = '';
  String _weight = '';
  String _wrist = '';

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
}