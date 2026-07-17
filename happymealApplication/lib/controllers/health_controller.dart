import 'dart:async';
import 'package:happymeal_application/models/health_model.dart';
import 'package:happymeal_application/services/health_service.dart';

class HealthController {
  List<Health> entries = List.empty();
  final HealthService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  HealthController(this.service);

  Future<List<Health>> fetchHealths() async {
    onSyncController.add(true);
    entries = await service.getHealths();
    onSyncController.add(false);
    return entries;
  }

  Future<List<Health>> fetchHealthsByDate(DateTime date) async {
    onSyncController.add(true);
    entries = await service.getHealthsByDate(date);
    onSyncController.add(false);
    return entries;
  }

  Future<Health> addHealth(Health health) async {
    onSyncController.add(true);
    Health newHealth = await service.addHealth(health);
    onSyncController.add(false);
    return newHealth;
  }

  Future<void> updateHealth(Health health) async {
    onSyncController.add(true);
    await service.updateHealth(health);
    onSyncController.add(false);
  }
}