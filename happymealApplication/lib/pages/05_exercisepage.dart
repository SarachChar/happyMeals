import 'package:flutter/material.dart';
import 'package:happymeal_application/components/exercise_log.dart';
import 'package:happymeal_application/controllers/exercise_controller.dart';
import 'package:happymeal_application/models/exercise_model.dart';
import 'package:happymeal_application/services/exercise_service.dart';
import 'package:provider/provider.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final ExerciseController controller =
      ExerciseController(ExerciseFirebaseService());
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
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    final entries = await controller.fetchExercises();
    if (!mounted) return;
    context.read<ExerciseModel>().setEntries(entries);
  }

  Future<void> _goToAddExercisePage() async {
    final result = await Navigator.pushNamed(context, '/addexercise');
    if (result is ExerciseLogEntry) {
      final savedEntry = await controller.addExercise(result);
      if (!mounted) return;
      context.read<ExerciseModel>().addEntry(savedEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _goToAddExercisePage,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ExerciseModel>(
              builder: (context, model, child) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildSummaryCard(
                        context,
                        model.getTotalCalories(),
                        model.getTotalDuration(),
                      ),
                    ),
                    Expanded(
                      child: _buildExerciseLog(context, model.entries),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int totalCalories, int totalDuration) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryStat(
              icon: Icons.local_fire_department,
              accentColor: primary,
              label: 'Calories Burned',
              value: '$totalCalories',
              unit: 'kcal/day',
            ),
          ),
          Container(
            width: 1,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildSummaryStat(
              icon: Icons.timer,
              accentColor: primary,
              label: 'Duration',
              value: '$totalDuration',
              unit: 'min/day',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat({
    required IconData icon,
    required Color accentColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        const SizedBox(height: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseLog(BuildContext context, List<ExerciseLogEntry> entries) {
  if (entries.isEmpty) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exercise Log',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text(
                'No exercise logged yet',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exercise Log',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildLogCard(context, entries[index]);
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLogCard(BuildContext context, ExerciseLogEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            child: Icon(
              entry.icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.type,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.time}  •  ${entry.intensity}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.durationMinutes} min',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                '${entry.caloriesBurned} kcal',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}