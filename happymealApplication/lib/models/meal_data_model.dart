// --------------------- data models
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
}
