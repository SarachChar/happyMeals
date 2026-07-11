import 'package:flutter/material.dart';
import '10_customizedrinkpage.dart';

class ChooseDrinkPage extends StatefulWidget {
  const ChooseDrinkPage({super.key});

  @override
  State<ChooseDrinkPage> createState() => _ChooseDrinkPageState();
}

class DrinkItem {
  final String name;
  final String image;

  DrinkItem({required this.name, required this.image});
}

class _ChooseDrinkPageState extends State<ChooseDrinkPage> {
  String? selectedDrink;

  final List<DrinkItem> drinks = [
    DrinkItem(name: 'Water', image: 'assets/images/water.jpeg'),
    DrinkItem(name: 'Coffee', image: 'assets/images/coffee.jpeg'),
    DrinkItem(name: 'Green Tea', image: 'assets/images/greentea.jpeg'),
    DrinkItem(name: 'Cocoa', image: 'assets/images/cocoa.jpeg'),
    DrinkItem(name: 'Milk Tea', image: 'assets/images/milktea.jpeg'),
    DrinkItem(name: 'Juice', image: 'assets/images/juice.jpeg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Choose Your Drink'),
      ),

      body: ListView.builder(
        itemCount: drinks.length,
        itemBuilder: (context, index) {
          final item = drinks[index];

          return InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomizePage(
                    drinkName: item.name,
                    drinkImage: item.image,
                    drinkType: item.name, // Pass the drink type
                  ),
                ),
              );

              if (result != null) {
                Navigator.pop(context, result);
              }
            },
            child: Container(
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                border: Border.all(
                  color: selectedDrink == item.name
                      ? Colors.green
                      : Colors.grey.shade300,
                  width: selectedDrink == item.name ? 3 : 1,
                ),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      item.image,
                      width: 120,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),

                  if (selectedDrink == item.name)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
