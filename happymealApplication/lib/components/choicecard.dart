import 'package:flutter/material.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.choiceData,
  });

  final ChoiceData choiceData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (choiceData.title.isNotEmpty) Text(choiceData.title),
          ...List.generate(choiceData.choices.length, (index) {
            return ChoiceRadio(
              label: choiceData.choices[index],
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              value: index + 1,
              groupValue: choiceData.groupValue,
              onChanged: (int? value) {
                if (value != null) {
                  choiceData.onChanged(value);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

class ChoiceRadio extends StatelessWidget {
  const ChoiceRadio({
    super.key,
    required this.label,
    required this.padding,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final int groupValue;
  final int value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          onChanged(value);
        }
      },
      child: Row(
        children: [
          Radio<int>(
            groupValue: groupValue,
            value: value,
            onChanged: (int? value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
          Text(label),
        ],
      ),
    );
  }
}

class ChoiceData {
  const ChoiceData({
    required this.title,
    required this.choices,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final List<String> choices;
  final int groupValue;
  final ValueChanged<int> onChanged;
}