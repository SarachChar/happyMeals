import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:happymeal_application/firebase_options.dart';
import 'package:happymeal_application/models/drink_provider.dart';
import 'package:happymeal_application/models/exercise_model.dart';
import 'package:happymeal_application/models/health_provider.dart';
import 'package:happymeal_application/models/login_model.dart';
import 'package:happymeal_application/models/meals_model.dart';
import 'package:happymeal_application/models/meals_summary_model.dart';
import 'package:happymeal_application/pages/00_gridpage.dart';
import 'package:happymeal_application/pages/01_health.dart';
import 'package:happymeal_application/pages/05_exercisepage.dart';
import 'package:happymeal_application/pages/06_add_exercise_page.dart';
import 'package:happymeal_application/pages/08_drinkpage.dart';
import 'package:happymeal_application/pages/11_mealspage.dart';
import 'package:happymeal_application/pages/88_example_postpage.dart';
import 'package:happymeal_application/pages/homePage.dart';
import 'package:happymeal_application/pages/loginPage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginModel()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseModel ()),
        ChangeNotifierProvider(create: (_) => MealsSummaryModel()),
        ChangeNotifierProvider(create: (_) => MealsModel()),
        ChangeNotifierProvider(create: (_) => DrinkProvider()),
      ],
      child: AuthGate(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6E8B5A)),
      ),
      initialRoute: '/home',
      routes: {
        '/0': (context) => GridPage(),
        '/1': (context) => MealsPage(),
        '/2': (context) => HealthPage(),
        '/3': (context) => ExercisePage(),
        '/4': (context) => DrinkPage(),
        '/addexercise': (context) => AddExercisePage(),
        '/home':(context) => HomePage(),
        '/postexample':(context) => PostPage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) {
          print('Signed out');
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: .fromSeed(seedColor:  const Color(0xFF6E8B5A))
            ),
            home: LoginPage(),
          );
        }
        print('Signed in as ${snapshot.data?.email}.');
        return MyApp();
      },
    );
  }
}
