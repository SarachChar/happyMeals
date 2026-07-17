import 'package:flutter/material.dart';
import 'package:happymeal_application/controllers/health_controller.dart';
import 'package:happymeal_application/models/health_model.dart';
import 'package:happymeal_application/services/health_service.dart';

class HealthProvider extends ChangeNotifier {
  final HealthController _controller = HealthController(HealthFirebaseService());

  String _height = '';
  String _weight = '';
  String _wrist = '';
  double _selectedBMI = 0.0;

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  String _todayHeight = '';
  String _todayWeight = '';
  String _todayWrist = '';
  double _todayBMI = 0.0;

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

  double get selectedBMI => _selectedBMI;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  String get todayHeight => _todayHeight;
  String get todayWeight => _todayWeight;
  String get todayWrist => _todayWrist;
  double get todayBMI => _todayBMI;

  HealthProvider() {
    _controller.onSync.listen((loading) {
      _isLoading = loading;
      notifyListeners();
    });
    fetchTodayData();
    fetchHealthData();
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String formatPrettyDate(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    notifyListeners();
    await fetchHealthData();
  }

  Future<void> fetchTodayData() async {
    List<Health> results = await _controller.fetchHealthsByDate(DateTime.now());
    if (results.isNotEmpty) {
      final latest = results.last;
      _todayHeight = latest.height;
      _todayWeight = latest.weight;
      _todayWrist = latest.wrist;
      _todayBMI = latest.bmi;
    } else {
      _todayHeight = '';
      _todayWeight = '';
      _todayWrist = '';
      _todayBMI = 0.0;
    }
    notifyListeners();
  }

  Future<void> fetchHealthData() async {
    List<Health> results = await _controller.fetchHealthsByDate(_selectedDate);
    if (results.isNotEmpty) {
      final latest = results.last;
      _height = latest.height;
      _weight = latest.weight;
      _wrist = latest.wrist;
      _selectedBMI = latest.bmi;
    } else {
      _height = '';
      _weight = '';
      _wrist = '';
      _selectedBMI = 0.0;
    }
    notifyListeners();
  }

  Future<void> saveAllHealthData() async {
    if (_height.isEmpty || _weight.isEmpty) {
      throw Exception('กรุณากรอกส่วนสูงและน้ำหนักก่อนทำการบันทึกข้อมูล');
    }

    double bmiVal = 0.0;
    try {
      double h = double.parse(_height) / 100;
      double w = double.parse(_weight);
      bmiVal = w / (h * h);
    } catch (_) {
      bmiVal = 0.0;
    }

    List<Health> existingEntries = await _controller.fetchHealthsByDate(_selectedDate);
    if (existingEntries.isNotEmpty) {
      for (var entry in existingEntries) {
        await _controller.updateHealth(entry);
      }
    }

    Health newHealth = Health(
      createdAt: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
      ),
      height: _height,
      weight: _weight,
      wrist: _wrist,
      bmi: bmiVal,
    );

    await _controller.addHealth(newHealth);
    await fetchHealthData();

    if (formatDate(_selectedDate) == formatDate(DateTime.now())) {
      await fetchTodayData();
    }
  }
}