import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:happymeal_application/controllers/drink_controller.dart';
import 'package:happymeal_application/controllers/exercise_controller.dart';
import 'package:happymeal_application/controllers/health_controller.dart';
import 'package:happymeal_application/controllers/meal_controller.dart';
import 'package:happymeal_application/models/drink_provider.dart';
import 'package:happymeal_application/models/exercise_model.dart';
import 'package:happymeal_application/models/health_provider.dart';
import 'package:happymeal_application/models/login_model.dart';
import 'package:happymeal_application/models/meals_model.dart';
import 'package:happymeal_application/models/meals_summary_model.dart';
import 'package:happymeal_application/pages/11_mealspage.dart';
import 'package:happymeal_application/services/drink_service.dart';
import 'package:happymeal_application/services/exercise_service.dart';
import 'package:happymeal_application/services/health_service.dart';
import 'package:happymeal_application/services/meal_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // Daily goals (used for the progress ring / summary card).
  static const int calorieGoal = 2200;
  static const int exerciseGoalMinutes = 60;

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MealController _mealController = MealController(MealFirebaseService());
  final ExerciseController _exerciseController = ExerciseController(ExerciseFirebaseService());
  final DrinkController _drinkController = DrinkController(DrinkFirebaseService());
  final HealthController _healthController = HealthController(HealthFirebaseService());

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _drinkController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadMeals(),
      _loadExercises(),
      _loadDrinks(),
      _loadHealth(),
    ]);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadMeals() async {
    final mealsModel = context.read<MealsModel>();
    if (mealsModel.meals.isNotEmpty) return;
    final userId = context.read<LoginModel>().userId;
    try {
      final meals = await _mealController.fetchMealsByDate(DateTime.now(), userId);
      if (!mounted) return;
      mealsModel.setMeals(meals);
      recalculateSummary(mealsModel, context.read<MealsSummaryModel>());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load meals: $e')),
      );
    }
  }

  Future<void> _loadExercises() async {
    final exerciseModel = context.read<ExerciseModel>();
    if (exerciseModel.entries.isNotEmpty) return;
    final userId = context.read<LoginModel>().userId;
    try {
      final entries =
          await _exerciseController.fetchExercisesByDate(userId, DateTime.now());
      if (!mounted) return;
      exerciseModel.setEntries(entries);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load exercises: $e')),
      );
    }
  }

  Future<void> _loadDrinks() async {
    final drinkProvider = context.read<DrinkProvider>();
    if (drinkProvider.drinks.isNotEmpty) return;
    final userId = context.read<LoginModel>().userId;
    try {
      final drinks = await _drinkController.fetchDrinks(userId);
      if (!mounted) return;
      drinkProvider.setDrinks(drinks);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load drinks: $e')),
      );
    }
  }

  Future<void> _loadHealth() async {
    final healthProvider = context.read<HealthProvider>();
    if (healthProvider.todayHeight.isNotEmpty ||
        healthProvider.todayWeight.isNotEmpty) {
      return;
    }
    final userId = context.read<LoginModel>().userId;
    try {
      final results =
          await _healthController.fetchHealthsByDate(DateTime.now(), userId);
      if (!mounted) return;
      if (results.isNotEmpty) {
        final latest = results.last;
        healthProvider.todayHeight = latest.height;
        healthProvider.todayWeight = latest.weight;
        healthProvider.todayWrist = latest.wrist;
        healthProvider.todayBMI = latest.bmi;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load health: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final mealsData = context.watch<MealsSummaryModel>();
    final exerciseData = context.watch<ExerciseModel>();
    final healthData = context.watch<HealthProvider>();
    final drinkData = context.watch<DrinkProvider>();

    final today = DateTime.now();
    final todayKey = drinkData.formatDate(today);

    final int totalFoodCalories = mealsData.totalCalories;
    final int drinkCalories = drinkData.totalCaloriesFor(todayKey);
    final int totalCalories = totalFoodCalories + drinkCalories;

    final int exerciseDuration = exerciseData.getTotalDuration();
    final int exerciseCaloriesBurned = exerciseData.getTotalCalories();
    final int exerciseSessions = exerciseData.getSessionCount();

    final int totalMl = drinkData.totalMlFor(todayKey);
    final int totalCups = drinkData.totalCupFor(todayKey);

    final String userEmail = context.read<LoginModel>().username;
    final String userId = context.read<LoginModel>().userId;

    final double calorieProgress =
        (totalCalories / HomePage.calorieGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(scheme, today),
              Text(userEmail),
              Text(userId),
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: _buildSummaryCard(
                  scheme,
                  totalCalories: totalCalories,
                  exerciseDuration: exerciseDuration,
                  progress: calorieProgress,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: _buildQuickActions(context, scheme),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _sectionLabel(scheme, 'Exercise'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  spacing: 14,
                  children: [
                    Expanded(
                      child: _statChip(
                        scheme,
                        icon: Icons.local_fire_department_outlined,
                        label: 'Burned',
                        value: '${_formatNumber(exerciseCaloriesBurned)} kcal',
                      ),
                    ),
                    Expanded(
                      child: _statChip(
                        scheme,
                        icon: Icons.fitness_center_outlined,
                        label: 'Sessions',
                        value: '$exerciseSessions',
                      ),
                    ),
                    Expanded(
                      child: _statChip(
                        scheme,
                        icon: Icons.water_drop_outlined,
                        label: 'Drinks',
                        value: '$totalMl ml',
                        hint: '$totalCups cups',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _sectionLabel(scheme, 'Body'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  spacing: 14,
                  children: [
                    Expanded(
                      child: _statChip(
                        scheme,
                        icon: Icons.monitor_weight_outlined,
                        label: 'Weight',
                        value: _valueOrDash(healthData.todayWeight, 'kg'),
                        onTap: () => Navigator.pushNamed(context, '/2'),
                      ),
                    ),
                    Expanded(
                      child: _statChip(
                        scheme,
                        icon: Icons.height_outlined,
                        label: 'Height',
                        value: _valueOrDash(healthData.todayHeight, 'cm'),
                        onTap: () => Navigator.pushNamed(context, '/2'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.logout),
        onPressed: () => _LogOut(),
      )
    );
  }

  Widget _buildHeader(ColorScheme scheme, DateTime today) {
    final dateLabel =
        '${HomePage._weekdays[today.weekday - 1]}, ${HomePage._months[today.month - 1]} ${today.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          dateLabel,
          style: TextStyle(
            color: scheme.primary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          _greetingFor(today.hour),
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 34,
            height: 1.1,
            fontWeight: FontWeight.w700,
            fontFamily: 'serif',
          ),
        ),
      ],
    );
  }

  String _greetingFor(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildSummaryCard(
    ColorScheme scheme, {
    required int totalCalories,
    required int exerciseDuration,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                _buildMetricRow(
                  scheme,
                  dotColor: scheme.primary,
                  label: 'CALORIES',
                  value: _formatNumber(totalCalories),
                  suffix: ' / ${_formatNumber(HomePage.calorieGoal)} kcal',
                ),
                _buildMetricRow(
                  scheme,
                  dotColor: scheme.tertiary,
                  label: 'EXERCISE',
                  value: '$exerciseDuration',
                  suffix: ' / ${HomePage.exerciseGoalMinutes} min',
                ),
              ],
            ),
          ),
          _buildProgressRing(scheme, progress),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    ColorScheme scheme, {
    required Color dotColor,
    required String label,
    required String value,
    required String suffix,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: RichText(
                text: TextSpan(
                  text: value,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(
                      text: suffix,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressRing(ColorScheme scheme, double progress) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: scheme.primary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              color: scheme.primary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ColorScheme scheme) {
    return Row(
      spacing: 14,
      children: [
        Expanded(
          child: _actionCard(
            context,
            route: '/1',
            label: 'Meals',
            icon: Icons.restaurant_outlined,
            background: scheme.primaryContainer,
            iconColor: scheme.onPrimaryContainer,
          ),
        ),
        Expanded(
          child: _actionCard(
            context,
            route: '/4',
            label: 'Drinks',
            icon: Icons.water_drop_outlined,
            background: scheme.tertiaryContainer,
            iconColor: scheme.onTertiaryContainer,
          ),
        ),
        Expanded(
          child: _actionCard(
            context,
            route: '/3',
            label: 'Exercise',
            icon: Icons.monitor_heart_outlined,
            background: scheme.secondaryContainer,
            iconColor: scheme.onSecondaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String route,
    required String label,
    required IconData icon,
    required Color background,
    required Color iconColor,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 36,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 26),
                  const Spacer(),
                  Icon(Icons.add,
                      color: iconColor.withValues(alpha: 0.6), size: 20),
                ],
              ),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(ColorScheme scheme, String text) {
    return Text(
      text,
      style: TextStyle(
        color: scheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _statChip(
    ColorScheme scheme, {
    required IconData icon,
    required String label,
    required String value,
    String? hint,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: 22),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              value,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (hint != null)
            Text(
              hint,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
            ),
        ],
      ),
    );

    return Material(
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: onTap == null
          ? content
          : InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: content,
            ),
    );
  }

  String _valueOrDash(String raw, String unit) {
    if (raw.trim().isEmpty) return '- $unit';
    return '$raw $unit';
  }

  String _formatNumber(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  Future<void> _LogOut() async {
    // Capture provider references before the async gap (dialog await).
    final loginModel = context.read<LoginModel>();
    final healthProvider = context.read<HealthProvider>();
    final exerciseModel = context.read<ExerciseModel>();
    final mealsSummaryModel = context.read<MealsSummaryModel>();
    final mealsModel = context.read<MealsModel>();
    final drinkProvider = context.read<DrinkProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    loginModel.reset();
    healthProvider.reset();
    exerciseModel.reset();
    mealsSummaryModel.reset();
    mealsModel.reset();
    drinkProvider.reset();

    await FirebaseAuth.instance.signOut();
  }
}
