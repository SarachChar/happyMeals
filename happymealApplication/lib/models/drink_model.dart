import 'package:cloud_firestore/cloud_firestore.dart';

class Drink {
  String drinkName;
  String image;
  String size;
  int sugar;
  int ml;
  int calories;
  String date;
  String dbId;

  Drink({
    required this.drinkName,
    required this.image,
    required this.size,
    required this.sugar,
    required this.ml,
    required this.calories,
    required this.date,
    this.dbId = '',
  });

  factory Drink.fromSnapshot(Map<String, dynamic> snapshot) {
    return Drink(
      drinkName: snapshot['drinkName'] as String? ?? '',
      image: snapshot['image'] as String? ?? '',
      size: snapshot['size'] as String? ?? '',
      sugar: (snapshot['sugar'] as num?)?.toInt() ?? 0,
      ml: (snapshot['ml'] as num?)?.toInt() ?? 0,
      calories: (snapshot['calories'] as num?)?.toInt() ?? 0,
      date: snapshot['date'] as String? ?? '',
    );
  }

  factory Drink.fromMap(Map<String, dynamic> map) {
    return Drink(
      drinkName: map['drinkName'] as String,
      image: map['image'] as String,
      size: map['size'] as String,
      sugar: (map['sugar'] as num).toInt(),
      ml: (map['ml'] as num).toInt(),
      calories: (map['calories'] as num).toInt(),
      date: map['date'] as String,
      dbId: map['dbId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'drinkName': drinkName,
      'image': image,
      'size': size,
      'sugar': sugar,
      'ml': ml,
      'calories': calories,
      'date': date,
    };
  }

  Map<String, dynamic> toDisplayMap() {
    return {
      ...toMap(),
      'dbId': dbId,
    };
  }
}

class AllDrinks {
  final List<Drink> drinks;
  AllDrinks(this.drinks);

  factory AllDrinks.fromSnapshot(QuerySnapshot qs) {
    List<Drink> drinks = qs.docs.map((DocumentSnapshot ds) {
      Drink drink = Drink.fromSnapshot(ds.data() as Map<String, dynamic>);
      drink.dbId = ds.id;
      return drink;
    }).toList();

    return AllDrinks(drinks);
  }
}
