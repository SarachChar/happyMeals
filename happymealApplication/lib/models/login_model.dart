import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {

  String _username = '';
  String _userId = '';
  
  get username => this._username;
  set username(String value) {
    this._username = value;
    notifyListeners();
  }

  get userId => this._userId;
  set userId(String value) {
    this._userId = value;
    notifyListeners();
  }

  void reset() {
    _username = '';
    _userId = '';
    notifyListeners();
  }
}