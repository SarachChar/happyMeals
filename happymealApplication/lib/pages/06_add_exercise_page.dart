import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:happymeal_application/components/choicecard.dart';
import 'package:happymeal_application/components/exercise_log.dart';
import 'package:happymeal_application/pages/07_choose_activity_page.dart';


class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, IconData> _exerciseTypes = {
    'Running': Icons.directions_run,
    'Walking': Icons.directions_walk,
    'Cycling': Icons.directions_bike,
    'Swimming': Icons.pool,
    'Weight Training': Icons.fitness_center,
    'Yoga': Icons.self_improvement,
  };

  final Map<String, double> _caloriesPerMinute = {
    'Running': 10,
    'Walking': 4,
    'Cycling': 8,
    'Swimming': 9,
    'Weight Training': 6,
    'Yoga': 3,
  };

  final List<String> _intensityLevels = ['Light', 'Moderate', 'Intense'];

  String _selectedType = 'Running';
  String _selectedIntensity = 'Moderate';

  final TextEditingController _durationController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  int _saveDuration = 0;

  int getIntensityValue() {
  return _intensityLevels.indexOf(_selectedIntensity) + 1;
  }

  int calculateEstimatedCalories() {
      int duration = int.tryParse(_durationController.text) ?? 0;
      double caloriesPerMinute = _caloriesPerMinute[_selectedType] ?? 0;
      int result = (duration * caloriesPerMinute).round();
      return result;
    }

  Future<void> _pickTime() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: _selectedDateTime,
            onDateTimeChanged: (dateTime) {
              setState(() {
                _selectedDateTime = dateTime;
              });
            },
          ),
        );
      },
    );
  }


  Future<void> _goToChooseExerciseType() async {
    final List<dynamic> typeList = [];
    for (final type in _exerciseTypes.keys) {
      typeList.add([type, _exerciseTypes[type]]);
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExerciseTypePage(typeList: typeList),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _selectedType = result;
      });
    }
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    IconData selectedIcon;
    if (_exerciseTypes.containsKey(_selectedType)) {
      selectedIcon = _exerciseTypes[_selectedType]!;
    } else {
      selectedIcon = Icons.fitness_center;
    }

    final newEntry = ExerciseLogEntry(
      time:
          '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
      type: _selectedType,
      intensity: _selectedIntensity,
      durationMinutes: _saveDuration,
      caloriesBurned: calculateEstimatedCalories(),
      icon: selectedIcon,
    );

    Navigator.pop(context, newEntry);
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F1),
      appBar: AppBar(
        backgroundColor: theme,
        title: const Text('Add Exercise'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Exercise Type'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToChooseExerciseType,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 254, 254, 254),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Choose your activity - $_selectedType'),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Duration (minutes)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 254, 254, 254),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter duration';
                  if (int.tryParse(value) == null) return 'Numbers only';
                  if (int.parse(value) <= 0) return 'Must be greater than 0';
                  return null;
                },
                onSaved: (value) {
                  _saveDuration = int.tryParse(value ?? '') ?? 0;
                },
              ),
              const SizedBox(height: 20),

              const Text('Intensity'),
              const SizedBox(height: 8),
              ChoiceCard(
                choiceData: ChoiceData(
                  title: '',
                  choices: _intensityLevels,
                  groupValue: getIntensityValue(),
                  onChanged: (value) {
                    setState(() {
                      _selectedIntensity = _intensityLevels[value - 1];
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              const Text('Time', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 254, 254, 254),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${_selectedDateTime.hour.toString().padLeft(2, '0')}:'
                        '${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.black),
                    const SizedBox(width: 10),
                    Text(
                      'Estimated calories burned: ${calculateEstimatedCalories()} kcal',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Exercise',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}