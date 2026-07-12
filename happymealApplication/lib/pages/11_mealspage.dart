import 'package:flutter/material.dart';
import 'package:happymeal_application/controllers/meal_controller.dart';
import 'package:happymeal_application/models/meal_data_model.dart';
import 'package:happymeal_application/models/meals_model.dart';
import 'package:happymeal_application/models/meals_summary_model.dart';
import 'package:happymeal_application/services/meal_service.dart';
import 'package:provider/provider.dart';

class MealsPage extends StatelessWidget {
  const MealsPage({super.key});
  final int _recommendedCalories = 2200;

  @override
  Widget build(BuildContext context) {
    final mealsModel = context.watch<MealsModel>();
    final summary = context.watch<MealsSummaryModel>();
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Meals Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddMealPage(),
                ),
              );
            }
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(28.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TODAY · ${summary.totalMeals} MEALS · ${summary.totalFoodItems} ITEMS',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 101, 101, 101),
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        summary.totalCalories.toString(),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 101, 101, 101),
                          fontSize: 48.0,
                          fontWeight: FontWeight.w400,
                          height: 1.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '/ ${_recommendedCalories.toString()} kcal',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 101, 101, 101),
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      NutritionBox(label: 'CARBS', value: '${summary.totalCarb}g'),
                      NutritionBox(label: 'PROTEIN', value: '${summary.totalProtein}g'),
                      NutritionBox(label: 'FAT', value: '${summary.totalFat}g'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Today Meals List',
              style: const TextStyle(
                color: Color.fromARGB(255, 101, 101, 101),
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (mealsModel.meals.isNotEmpty) 
            Expanded(
              child: ListView.builder(
                itemCount: mealsModel.meals.length,
                itemBuilder: (context, index) {
                  final meal = mealsModel.meals[index];
                  return MealsCard(data: meal);
                },
              ),
            ),
          if (mealsModel.meals.isEmpty) 
            Center(
              child: Text('No meals yet. Add your first meal!')
            )
        ],
      ),
    );
  }
}

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final _mealFormKey = GlobalKey<FormState>();
  final _foodFormKey = GlobalKey<FormState>();

  final MealController _mealController = MealController(MealFirebaseService());

  String? _mealName;

  String? _foodName;
  String? _foodImageUrl;
  int? _foodKcal;
  int? _foodProtein;
  int? _foodCarb;
  int? _foodFat;

  final _foodNameController = TextEditingController();
  final _foodImageUrlController = TextEditingController();
  final _foodKcalController = TextEditingController();
  final _foodProteinController = TextEditingController();
  final _foodCarbController = TextEditingController();
  final _foodFatController = TextEditingController();

  @override
  void dispose() {
    _foodNameController.dispose();
    _foodImageUrlController.dispose();
    _foodKcalController.dispose();
    _foodProteinController.dispose();
    _foodCarbController.dispose();
    _foodFatController.dispose();
    super.dispose();
  }

  final List<dynamic> foodList = const [
    ['Burger', 550, 30, 40, 35,'https://pub-aaa82e9851064d22b954c3ebbafc9ae6.r2.dev/legacy/thumbnails/burger-with-melted-cheese-m-Y1i3jpYYJZYfOEfX5dX.webp'],
    ['Fried Chicken', 350, 25, 10, 20, 'https://pub-aaa82e9851064d22b954c3ebbafc9ae6.r2.dev/generated/thumbnails/crispy-fried-chicken-with-french-fries-SyM0c9HqKU2MrTD1ocea3.webp'],
    ['Ice Cream', 200, 5, 25, 10, 'https://pub-aaa82e9851064d22b954c3ebbafc9ae6.r2.dev/legacy/thumbnails/bowl-of-ice-cream-with-chocolate-labZgS7rWlAKNphP8l9jI.webp'],
    ['Wrap', 300, 5, 40, 15, 'https://pub-aaa82e9851064d22b954c3ebbafc9ae6.r2.dev/legacy/thumbnails/grilled-meat-wrap-with-fresh-vegetables-bsf-WCWE_0Aoeu9qf5Jqa.webp'],
    ['Pad Thai', 400, 15, 50, 20, 'https://media.istockphoto.com/id/2259673809/photo/pad-thai-with-large-prawns-served-on-a-white-plate.jpg?b=1&s=612x612&w=0&k=20&c=6tLnwvQBDtNir7vzVNEhWoYRg-CddZSqvCWVJk42src='],
    ['Tom Yum Soup', 150, 10, 20, 5, 'https://media.istockphoto.com/id/164464068/photo/spicy-thai-tom-yam-seafood-soup.jpg?b=1&s=612x612&w=0&k=20&c=Pqv5UcOYJfbzWuAlUb8ZAhui-3hrlWBUR9HL7Q3Sf5Q=']
  ];

  final List<Food> _foods = [];

  String? _validateTextField(String fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName must not be empty';
    }
    return null;
  }

  String? _validateNumberField(String fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName must not be empty';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }

  void _addFood() {
    if (!_foodFormKey.currentState!.validate()) {
      return;
    }
    _foodFormKey.currentState!.save();

    setState(() {
      _foods.add(Food(
        name: _foodName!,
        kcal: _foodKcal!,
        protein: _foodProtein!,
        carb: _foodCarb!,
        fat: _foodFat!,
        imageUrl: _foodImageUrl!,
      ));
    });

    _foodFormKey.currentState!.reset();
    _foodNameController.clear();
    _foodImageUrlController.clear();
    _foodKcalController.clear();
    _foodProteinController.clear();
    _foodCarbController.clear();
    _foodFatController.clear();
  }

  void _saveMeal() async {
    if (!_mealFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Input is invalid')),
      );
      return;
    }
    if (_foods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one food')),
      );
      return;
    }
    _mealFormKey.currentState!.save();

    final meal = Meal(
      mealName: _mealName!,
      createdAt: DateTime.now(),
      foods: List<Food>.from(_foods),
    );

    final mealsModel = context.read<MealsModel>();
    mealsModel.addMeal(meal);

    try {
      await _mealController.addMeal(meal);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload meal: $e')),
      );
    }

    int items = 0;
    int cal = 0;
    int carb = 0;
    int protein = 0;
    int fat = 0;
    for (final m in mealsModel.meals) {
      items += m.foods.length;
      for (final f in m.foods) {
        cal += f.kcal;
        carb += f.carb;
        protein += f.protein;
        fat += f.fat;
      }
    }

    if (!mounted) return;
    final summary = context.read<MealsSummaryModel>();
    summary.totalMeals = mealsModel.meals.length;
    summary.totalFoodItems = items;
    summary.totalCalories = cal;
    summary.totalCarb = carb;
    summary.totalProtein = protein;
    summary.totalFat = fat;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('AddMeal Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _mealFormKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.restaurant),
                    labelText: 'Meal Name',
                    hintText: 'e.g. Breakfast',
                  ),
                  onSaved: (value) {
                    _mealName = value;
                  },
                  validator: (value) {
                    return _validateTextField('Meal Name', value);
                  },
                ),
              ),
            ),

            Text(
              'Add Food',
              style: Theme.of(context).textTheme.titleMedium
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  child: Text('Choose food'),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<Food>(
                      MaterialPageRoute(
                        builder: (context) => FoodListPage (
                          foodList: foodList
                        ),
                      ),
                    );
                    if (result == null) return;
                    setState(() {
                      _foodNameController.text = result.name;
                      _foodImageUrlController.text = result.imageUrl;
                      _foodKcalController.text = result.kcal.toString();
                      _foodProteinController.text = result.protein.toString();
                      _foodCarbController.text = result.carb.toString();
                      _foodFatController.text = result.fat.toString();
                    });
                    _addFood();
                  },
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  '----- Add Food Manually -----',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 101, 101, 101),
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),

            Form(
              key: _foodFormKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _foodNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Food Name',
                      ),
                      onSaved: (value) {
                        _foodName = value;
                      },
                      validator: (value) {
                        return _validateTextField('Food Name', value);
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _foodImageUrlController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Image URL',
                      ),
                      onSaved: (value) {
                        _foodImageUrl = value;
                      },
                      validator: (value) {
                        return _validateTextField('Image URL', value);
                      },
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _foodKcalController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Kcal',
                            ),
                            onSaved: (value) {
                              _foodKcal = int.parse(value!);
                            },
                            validator: (value) {
                              return _validateNumberField('Kcal', value);
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _foodProteinController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Protein (g)',
                            ),
                            onSaved: (value) {
                              _foodProtein = int.parse(value!);
                            },
                            validator: (value) {
                              return _validateNumberField('Protein', value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _foodCarbController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Carb (g)',
                            ),
                            onSaved: (value) {
                              _foodCarb = int.parse(value!);
                            },
                            validator: (value) {
                              return _validateNumberField('Carb', value);
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _foodFatController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Fat (g)',
                            ),
                            onSaved: (value) {
                              _foodFat = int.parse(value!);
                            },
                            validator: (value) {
                              return _validateNumberField('Fat', value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: .center,
              children: [
                ElevatedButton(
                  onPressed: _addFood,
                  child: Text('Add Food'),
                ),
              ],
            ),

            const Divider(),

            Text(
              'Foods in this meal (${_foods.length})',
              style: Theme.of(context).textTheme.titleMedium
            ),

            ..._foods.map((food) => FoodCard(data: food)),

            Row(
              mainAxisAlignment: .center,
              children: [
                ElevatedButton(
                  onPressed: _saveMeal,
                  child: Text('Save Meal'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FoodListPage extends StatelessWidget {
  const FoodListPage({
    super.key, 
    required this.foodList
  });

  final List<dynamic> foodList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Choose Food Page'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: foodList.length,
        itemBuilder: (context, index) {
          return SelectFoodCard(
            data: Food(
              name: foodList[index][0],
              kcal: foodList[index][1],
              protein: foodList[index][2],
              carb: foodList[index][3],
              fat: foodList[index][4],
              imageUrl: foodList[index][5],
            ),
          );
        },
      ),
    );
  }
}

class SelectFoodCard extends StatelessWidget {
  const SelectFoodCard({
    super.key,
    required this.data
  });

  final Food data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            data.imageUrl,
            width: 140.0,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 101, 101, 101),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Kcal: ${data.kcal}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 101, 101, 101),
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                  
                  Text(
                    'Protein: ${data.protein}g',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 101, 101, 101),
                    ),
                  ),
                  Text(
                    'Carb: ${data.carb}g',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 101, 101, 101),
                    ),
                  ),
                  Text(
                    'Fat: ${data.fat}g',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 101, 101, 101),
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Choose'),
                    onPressed: () {
                      Navigator.pop(context, data);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MealsCard extends StatelessWidget {
  const MealsCard({
    super.key,
    required this.data
  });

  final Meal data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 199, 199, 199),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                data.mealName,
                style: const TextStyle(
                  color: Color.fromARGB(255, 101, 101, 101),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(' · '),
              Text(
                '${data.createdAt.hour.toString().padLeft(2, '0')}:'
                '${data.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 101, 101, 101),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ],
          ),
          ...data.foods.map(
            (food) => FoodCard(data: food),
          ),
        ],
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.data
  });

  final Food data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            data.imageUrl,
            width: 140.0,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 101, 101, 101),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Kcal: ${data.kcal}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 101, 101, 101),
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                  
                  Text(
                    'Protein: ${data.protein}g',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 101, 101, 101),
                    ),
                  ),
                  Text(
                    'Carb: ${data.carb}g',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 101, 101, 101),
                    ),
                  ),
                  Text(
                    'Fat: ${data.fat}g',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 101, 101, 101),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NutritionBox extends StatelessWidget {
  const NutritionBox({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color.fromARGB(255, 101, 101, 101),
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                value,
                style: const TextStyle(
                  color: Color.fromARGB(255, 101, 101, 101),
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
