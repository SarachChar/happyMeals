
class Food {
  const Food({
    required this.name,
    required this.kcal,
    required this.protein,
    required this.carb,
    required this.fat,
    required this.imageUrl,
  });

  final String name;
  final int kcal;
  final int protein;
  final int carb;
  final int fat;
  final String imageUrl;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'kcal': kcal,
      'protein': protein,
      'carb': carb,
      'fat': fat,
      'imageUrl': imageUrl,
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      name: map['name'] as String,
      kcal: map['kcal'] as int? ?? 0,
      protein: map['protein'] as int? ?? 0,
      carb: map['carb'] as int? ?? 0,
      fat: map['fat'] as int? ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
    );
  }
}

class Meal {
  const Meal({
    required this.mealName,
    required this.createdAt,
    required this.foods,
  });

  final String mealName;
  final DateTime createdAt;
  final List<Food> foods;

  Map<String, dynamic> toMap() {
    return {
      'mealName': mealName,
      'createdAt': createdAt.toIso8601String(),
      'foods': foods.map((food) => food.toMap()).toList(),
    };
  }

  factory Meal.fromSnapshot(Map<String, dynamic> snapshot) {
    return Meal(
      mealName: snapshot['mealName'] as String? ?? '',
      createdAt: DateTime.parse(snapshot['createdAt'] as String),
      foods: (snapshot['foods'] as List? ?? [])
          .map((food) => Food.fromMap(food as Map<String, dynamic>))
          .toList(),
    );
  }
}
