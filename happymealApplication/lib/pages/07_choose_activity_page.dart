import 'package:flutter/material.dart';


class ExerciseTypePage extends StatelessWidget {
  const ExerciseTypePage({
    super.key,
    required this.typeList,
  });


  final List<dynamic> typeList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Choose Your Activity'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: typeList.length,
        itemBuilder: (context, index) {
          return ExerciseTypeCard(
            data: ExerciseTypeData(
              name: typeList[index][0],
              icon: typeList[index][1],
            ),
          );
        },
      ),
    );
  }
}

class ExerciseTypeCard extends StatelessWidget {
  const ExerciseTypeCard({
    super.key,
    required this.data,
  });

  final ExerciseTypeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(data.icon, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            child: const Text('Choose'),
            onPressed: () {
              Navigator.pop(context, data.name);
            },
          ),
        ],
      ),
    );
  }
}


class ExerciseTypeData {
  const ExerciseTypeData({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}