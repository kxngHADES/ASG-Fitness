import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/equipment_provider.dart';
import '../providers/exercise_provider.dart';
import 'equipment/equipment_onboarding_screen.dart';
import 'main_shell.dart';

/// Decides whether to show the first-run equipment onboarding flow or the
/// main app shell, based on whether the user has picked any equipment yet.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late Future<bool> _needsOnboarding;

  @override
  void initState() {
    super.initState();
    // Defer to after the first frame: EquipmentProvider.load() calls
    // notifyListeners() synchronously before its first await, which would
    // otherwise trigger "setState called during build" since this runs
    // from initState.
    _needsOnboarding = Future(_bootstrap);
  }

  Future<bool> _bootstrap() async {
    final equipmentProvider = context.read<EquipmentProvider>();
    final exerciseProvider = context.read<ExerciseProvider>();
    await equipmentProvider.load();
    final ownedIds = equipmentProvider.owned.map((e) => e.id!).toSet();
    await exerciseProvider.load(ownedIds);
    // Bodyweight is auto-owned; onboarding is "needed" if nothing else is picked.
    final ownedBeyondBodyweight = equipmentProvider.owned.where((e) => e.name != 'Bodyweight');
    return ownedBeyondBodyweight.isEmpty;
  }

  void _finishOnboarding() {
    final ownedIds = context.read<EquipmentProvider>().owned.map((e) => e.id!).toSet();
    context.read<ExerciseProvider>().updateOwnedEquipment(ownedIds);
    setState(() {
      _needsOnboarding = Future.value(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _needsOnboarding,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == true) {
          return EquipmentOnboardingScreen(onDone: _finishOnboarding);
        }
        return const MainShell();
      },
    );
  }
}
