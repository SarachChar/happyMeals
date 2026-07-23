import 'dart:async';
import 'package:happymeal_application/models/drink_model.dart';
import 'package:happymeal_application/services/drink_service.dart';

class DrinkController {
  List<Drink> drinks = [];
  final DrinkService service;

  final StreamController<bool> _onSyncController =
      StreamController<bool>.broadcast();
  Stream<bool> get onSync => _onSyncController.stream;

  DrinkController(this.service);

  Future<List<Drink>> fetchDrinks(String userId) async {
    _onSyncController.add(true);
    drinks = await service.getDrinks(userId);
    _onSyncController.add(false);
    return drinks;
  }

  Future<Drink> addDrink(Drink drink, String userId) async {
    _onSyncController.add(true);
    Drink newDrink = await service.addDrink(drink, userId);
    _onSyncController.add(false);
    return newDrink;
  }

  Future<void> deleteDrink(Drink drink) async {
    _onSyncController.add(true);
    await service.deleteDrink(drink);
    _onSyncController.add(false);
  }

  void dispose() {
    _onSyncController.close();
  }
}
