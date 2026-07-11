import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '09_choosedrinkpage.dart';
import '../models/drink_provider.dart';

class DrinkPage extends StatefulWidget {
  const DrinkPage({super.key});

  @override
  State<DrinkPage> createState() => _DrinkPageState();
}

class _DrinkPageState extends State<DrinkPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  Future<void> pickDate() async {
    final provider = context.read<DrinkProvider>();

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      provider.setDate(date);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DrinkProvider>();

    // ตั้งวันที่เริ่มต้นเป็นวันนี้ ถ้ายังไม่มีการเลือกวันที่ (ครั้งแรกที่เปิดหน้า)
    if (provider.selectedDate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.setDate(DateTime.now());
      });
    }

    final DateTime selectedDate = provider.selectedDate ?? DateTime.now();
    final String currentDate = provider.formatDate(selectedDate);

    _dateController.text = currentDate;

    final List<Map<String, dynamic>> todayHistory = provider.historyForDate(
      currentDate,
    );
    final int totalCup = provider.totalCupFor(currentDate);
    final int totalMl = provider.totalMlFor(currentDate);
    final int totalcalories = provider.totalCaloriesFor(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Drink Update & History"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Select Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: pickDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select date";
                  }
                  return null;
                },
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          "Today Summary",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            "Date : $currentDate",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            "Drinks : $totalCup Cups",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Total : $totalMl ml",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Total Calories : $totalcalories kcal",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Drink History",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              Expanded(
                child: todayHistory.isEmpty
                    ? const Center(
                        child: Text(
                          "No drinks yet",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: todayHistory.length,
                        itemBuilder: (context, index) {
                          final drink = todayHistory[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      drink['image'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          child: Text(
                                            drink['drinkName'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            "Date : ${drink['date']}",
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            "Size : ${drink['size']}",
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            "Sugar : ${drink['sugar']}%",
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            "Volume : ${drink['ml']} ml",
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            'Calories: ${drink['calories'] ?? 0} kcal',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          if (!_formKey.currentState!.validate()) {
            return;
          }

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChooseDrinkPage()),
          );

          if (result != null) {
            result['date'] = currentDate;

            provider.addDrink(result);

            final int totalCal = provider.totalCaloriesFor(currentDate);

            if (totalCal > 500) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("วันนี้คุณดื่มน้ำหวาน/แคลอรี่เยอะแล้วจ้า"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
