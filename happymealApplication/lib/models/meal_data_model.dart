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
}
