import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happymeal_application/models/drink_model.dart';

abstract class DrinkService {
  Future<List<Drink>> getDrinks(String userId);
  Future<Drink> addDrink(Drink drink, String userId);
  Future<void> deleteDrink(Drink drink);
}

class DrinkFirebaseService implements DrinkService {
  final CollectionReference _drinkCollection = FirebaseFirestore.instance
      .collection('drink');

  @override
  Future<List<Drink>> getDrinks(String userId) async {
    QuerySnapshot qs = await _drinkCollection
        .where('userId', isEqualTo: userId)
        .get();
    AllDrinks all = AllDrinks.fromSnapshot(qs);
    return all.drinks;
  }

  @override
  Future<Drink> addDrink(Drink drink, String userId) async {
    final docId = _generateDateTimeId();
    await _drinkCollection.doc(docId).set({
      ...drink.toMap(),
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    drink.dbId = docId;
    return drink;
  }
 
  String _generateDateTimeId() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    String three(int n) => n.toString().padLeft(3, '0');
    return '${now.year}${two(now.month)}${two(now.day)}'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}'
        '${three(now.millisecond)}';
  }
 
  @override
  Future<void> deleteDrink(Drink drink) async {
    await _drinkCollection.doc(drink.dbId).delete();
  }
}
