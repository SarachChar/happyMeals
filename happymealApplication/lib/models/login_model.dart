import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {

  String _username = '';
  
  get username => this._username;
  set username(String value) {
    this._username = value;
    notifyListeners();
  }

  void reset() {
    _username = '';
    notifyListeners();
  }
}