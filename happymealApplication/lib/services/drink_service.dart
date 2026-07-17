import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happymeal_application/models/drink_model.dart';

abstract class DrinkService {
  Future<List<Drink>> getDrinks();
  Future<Drink> addDrink(Drink drink);
  Future<void> deleteDrink(Drink drink);
}

class DrinkFirebaseService implements DrinkService {
  final CollectionReference _drinkCollection = FirebaseFirestore.instance
      .collection('drink');

  @override
  Future<List<Drink>> getDrinks() async {
    QuerySnapshot qs = await _drinkCollection.get();
    AllDrinks all = AllDrinks.fromSnapshot(qs);
    return all.drinks;
  }

  @override
  Future<Drink> addDrink(Drink drink) async {
    final docRef = await _drinkCollection.add({
      ...drink.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    drink.dbId = docRef.id;
    return drink;
  }

  @override
  Future<void> deleteDrink(Drink drink) async {
    await _drinkCollection.doc(drink.dbId).delete();
  }
}
