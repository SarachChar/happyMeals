import 'package:flutter/material.dart';

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Happy Meal'),
      ),
      body:  GridView.count (
        crossAxisCount: 2,
        children: List.generate(4, (index){
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/${index + 1}');
            },
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
                borderRadius: BorderRadius.circular(20.0)
              ),
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  Icon(getPageIcon(index)),
                  Text(getPageTitle(index))
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Meals';
      case 1:
        return 'Health';
      case 2:
        return 'Exercise';
      case 3:
        return 'Drinks';
      default:
        return 'title not found';
    }
  }

  IconData getPageIcon(int index) {
    switch (index) {
      case 0:
        return Icons.restaurant;
      case 1:
        return Icons.monitor_heart;
      case 2:
        return Icons.fitness_center;
      case 3:
        return Icons.water_drop;
      default:
        return Icons.error;
    }
  }

}
