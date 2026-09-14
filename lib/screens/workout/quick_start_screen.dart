import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../models/workout_session.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/session_provider.dart';
import '../exercises/exercise_picker_screen.dart';
import 'active_workout_screen.dart';

/// Lets the user build an ad-hoc workout (not tied to a saved plan) by
/// picking exercises from their available equipment, then starts logging.
class QuickStartScreen extends StatefulWidget {
  const QuickStartScreen({super.key});

  @override
  State<QuickStartScreen> createState() => _QuickStartScreenState();
}

class _QuickStartScreenState extends State<QuickStartScreen> {
  final List<int> _selectedIds = [];

  Future<void> _pickExercises() async {
    final ids = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute(builder: (_) => const ExercisePickerScreen(multiSelect: true)),
    );
    if (ids != null) {
      setState(() {
        for (final id in ids) {
          if (!_selectedIds.contains(id)) _selectedIds.add(id);
        }
      });
    }
  }

  Future<void> _start() async {
    final sessionProvider = context.read<SessionProvider>();
    final sessionId = await sessionProvider.startSession(name: 'Quick Workout');
    for (var i = 0; i < _selectedIds.length; i++) {
      await sessionProvider.addSessionExercise(SessionExercise(
        sessionId: sessionId,
        exerciseId: _selectedIds[i],
        sortOrder: i,
      ));
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(sessionId: sessionId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allExercises = context.watch<ExerciseProvider>().exercises;
    final selected = _selectedIds
        .map((id) => allExercises.cast<Exercise?>().firstWhere((e) => e?.id == id, orElse: () => null))
        .whereType<Exercise>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Quick Start')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickExercises,
        icon: const Icon(Icons.add),
        label: const Text('Add Exercises'),
      ),
      body: selected.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Add exercises to build today\'s workout, then start.', textAlign: TextAlign.center),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: selected.length,
              itemBuilder: (context, i) {
                final e = selected[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(e.name),
                  subtitle: Text(e.equipmentName ?? 'Bodyweight'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedIds.remove(e.id)),
                  ),
                );
              },
            ),
      bottomNavigationBar: selected.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Workout'),
                ),
              ),
            ),
    );
  }
}
