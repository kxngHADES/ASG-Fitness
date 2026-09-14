import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/body_stat_provider.dart';
import 'providers/equipment_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/session_provider.dart';
import 'screens/app_root.dart';

void main() {
  runApp(const AsgFitnessApp());
}

class AsgFitnessApp extends StatelessWidget {
  const AsgFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EquipmentProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => BodyStatProvider()),
      ],
      child: MaterialApp(
        title: 'ASG Fitness',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF5A1F),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF5A1F),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const AppRoot(),
      ),
    );
  }
}
