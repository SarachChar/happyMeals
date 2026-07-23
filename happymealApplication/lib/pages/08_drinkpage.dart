import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:happymeal_application/controllers/drink_controller.dart';
import 'package:happymeal_application/models/drink_model.dart';
import 'package:happymeal_application/models/drink_provider.dart';
import 'package:happymeal_application/services/drink_service.dart';
import 'package:happymeal_application/models/login_model.dart';
import '09_choosedrinkpage.dart';

class DrinkPage extends StatefulWidget {
  const DrinkPage({super.key});

  @override
  State<DrinkPage> createState() => _DrinkPageState();
}

class _DrinkPageState extends State<DrinkPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  final DrinkController controller = DrinkController(DrinkFirebaseService());
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller.onSync.listen((bool syncState) {
      if (!mounted) return;
      setState(() {
        isLoading = syncState;
      });
    });
    _fetchDrinks();
  }

  Future<void> _fetchDrinks() async {
    final userId = context.read<LoginModel>().userId as String;
    final drinks = await controller.fetchDrinks(userId);
    if (!mounted) return;
    context.read<DrinkProvider>().setDrinks(drinks);
  }

  Future<void> pickDate() async {
    final model = context.read<DrinkProvider>();

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: model.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      model.setDate(date);
    }
  }

  Future<void> _addDrink(String currentDate) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChooseDrinkPage()),
    );

    if (result == null) return;

    final newDrink = Drink(
      drinkName: result['drinkName'] as String,
      image: result['image'] as String,
      size: result['size'] as String,
      sugar: (result['sugar'] as num).toInt(),
      ml: (result['ml'] as num).toInt(),
      calories: (result['calories'] as num).toInt(),
      date: currentDate,
    );

    final userId = context.read<LoginModel>().userId as String;
    final savedDrink = await controller.addDrink(newDrink, userId);
    if (!mounted) return;
    context.read<DrinkProvider>().addDrink(savedDrink);

    final int totalCal = context.read<DrinkProvider>().totalCaloriesFor(
      currentDate,
    );

    if (totalCal > 500) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("วันนี้คุณดื่มน้ำหวาน/แคลอรี่เยอะแล้วจ้า"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteDrink(Drink drink) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ลบเครื่องดื่ม"),
        content: Text('ต้องการลบ "${drink.drinkName}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ลบ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await controller.deleteDrink(drink);
    if (!mounted) return;
    await _fetchDrinks();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DrinkProvider>();

    if (model.selectedDate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        model.setDate(DateTime.now());
      });
    }

    final DateTime selectedDate = model.selectedDate ?? DateTime.now();
    final String currentDate = model.formatDate(selectedDate);

    _dateController.text = currentDate;

    final List<Drink> todayHistory = model.historyForDate(currentDate);
    final int totalCup = model.totalCupFor(currentDate);
    final int totalMl = model.totalMlFor(currentDate);
    final int totalcalories = model.totalCaloriesFor(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Drink Update & History"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                                      drink.image,
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
                                            drink.drinkName,
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
                                          child: Text("Date : ${drink.date}"),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text("Size : ${drink.size}"),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            "Sugar : ${drink.sugar}%",
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text("Volume : ${drink.ml} ml"),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            'Calories: ${drink.calories} kcal',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteDrink(drink),
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
        onPressed: isLoading
            ? null
            : () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                await _addDrink(currentDate);
              },
      ),
    );
  }
}
