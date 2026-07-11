import 'package:flutter/material.dart';

class CustomizePage extends StatefulWidget {
  final String drinkName;
  final String drinkImage;
  final String drinkType;

  const CustomizePage({
    super.key,
    required this.drinkName,
    required this.drinkImage,
    required this.drinkType,
  });

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  final _formKey = GlobalKey<FormState>();

  String size = 'M';
  double sugar = 0;
  String drinkType = '';

  @override
  void initState() {
    super.initState();

    drinkType = widget.drinkName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.drinkName),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      widget.drinkImage,
                      width: 220,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Text(
                    widget.drinkName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Select Cup Size',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: DropdownButtonFormField<String>(
                  value: size,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'S', child: Text('Small (S) 250 ml')),
                    DropdownMenuItem(value: 'M', child: Text('Medium (M) 350 ml')),
                    DropdownMenuItem(value: 'L', child: Text('Large (L) 450 ml')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a size';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      size = value!;
                    });
                  },
                  onSaved: (value) {
                    size = value!;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    const Text(
                      'Sugar Level',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        children: [0, 25, 50, 75, 100].map((level) {
                          return ChoiceChip(
                            label: Text('$level%'),
                            selected: sugar == level.toDouble(),
                            onSelected: (selected) {
                              setState(() {
                                sugar = level.toDouble();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        int ml;
                        int calories;

                        switch (size) {
                          case 'S':
                            ml = 250;
                            break;
                          case 'M':
                            ml = 350;
                            break;
                          case 'L':
                            ml = 450;
                            break;
                          default:
                            ml = 0;
                        }

                        if (drinkType == 'Water') {
                          calories = 0;
                        } else if (drinkType == 'Coffee') {
                          calories = (ml * 0.3 + sugar).toInt();
                        } else if (drinkType == 'Green Tea') {
                          calories = (ml * 0.35 + sugar * 1.5).toInt();
                        } else {
                          calories = (ml * 0.6 + sugar * 2)
                              .toInt(); // milk tea / cocoa / juice
                        }

                        Navigator.pop(context, {
                          'drinkName': widget.drinkName,
                          'size': size,
                          'sugar': sugar.toInt(),
                          'image': widget.drinkImage,
                          'ml': ml,
                          'calories': calories,
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Save Drink'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
