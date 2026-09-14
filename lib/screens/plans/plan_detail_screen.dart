import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../models/workout_plan.dart';
import '../../models/workout_session.dart';
import '../../providers/plan_provider.dart';
import '../../providers/session_provider.dart';
import '../exercises/exercise_picker_screen.dart';
import '../workout/active_workout_screen.dart';

class PlanDetailScreen extends StatefulWidget {
  final int planId;
  const PlanDetailScreen({super.key, required this.planId});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  late Future<List<PlanExercise>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<PlanProvider>().getExercises(widget.planId);
  }

  Future<void> _addExercise() async {
    final exercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(builder: (_) => const ExercisePickerScreen()),
    );
    if (exercise == null || !mounted) return;

    final config = await _showPlanExerciseForm(context, exerciseName: exercise.name);
    if (config == null || !mounted) return;

    final planProvider = context.read<PlanProvider>();
    final currentCount = (await planProvider.getExercises(widget.planId)).length;
    await planProvider.addExercise(
          planId: widget.planId,
          exerciseId: exercise.id!,
          sortOrder: currentCount,
          targetSets: config.sets,
          targetReps: config.reps,
          targetWeight: config.weight,
          restSeconds: config.restSeconds,
        );
    setState(_reload);
  }

  Future<void> _editExercise(PlanExercise pe) async {
    final config = await _showPlanExerciseForm(
      context,
      exerciseName: pe.exerciseName ?? '',
      initialSets: pe.targetSets,
      initialReps: pe.targetReps,
      initialWeight: pe.targetWeight,
      initialRest: pe.restSeconds,
      allowDelete: true,
    );
    if (config == null || !mounted) return;
    final planProvider = context.read<PlanProvider>();
    if (config.delete) {
      await planProvider.removeExercise(pe.id!);
    } else {
      await planProvider.updatePlanExercise(PlanExercise(
            id: pe.id,
            planId: pe.planId,
            exerciseId: pe.exerciseId,
            sortOrder: pe.sortOrder,
            targetSets: config.sets,
            targetReps: config.reps,
            targetWeight: config.weight,
            restSeconds: config.restSeconds,
          ));
    }
    setState(_reload);
  }

  Future<void> _startWorkout(WorkoutPlan plan, List<PlanExercise> exercises) async {
    final sessionProvider = context.read<SessionProvider>();
    final sessionId = await sessionProvider.startSession(name: plan.name, planId: plan.id);
    for (var i = 0; i < exercises.length; i++) {
      await sessionProvider.addSessionExercise(SessionExercise(
        sessionId: sessionId,
        exerciseId: exercises[i].exerciseId,
        sortOrder: i,
      ));
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(sessionId: sessionId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanProvider>().plans.cast<WorkoutPlan?>().firstWhere(
          (p) => p?.id == widget.planId,
          orElse: () => null,
        );

    return Scaffold(
      appBar: AppBar(title: Text(plan?.name ?? 'Plan')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<PlanExercise>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final exercises = snapshot.data!;
          return Column(
            children: [
              if (plan?.description != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(alignment: Alignment.centerLeft, child: Text(plan!.description!)),
                ),
              Expanded(
                child: exercises.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No exercises yet. Tap + to add one from your available equipment.', textAlign: TextAlign.center),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: exercises.length,
                        itemBuilder: (context, i) {
                          final pe = exercises[i];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${i + 1}')),
                            title: Text(pe.exerciseName ?? 'Exercise'),
                            subtitle: Text(
                              '${pe.targetSets} sets × ${pe.targetReps}'
                              '${pe.targetWeight != null ? ' @ ${pe.targetWeight} kg' : ''}'
                              '${pe.restSeconds != null ? ' · ${pe.restSeconds}s rest' : ''}',
                            ),
                            onTap: () => _editExercise(pe),
                          );
                        },
                      ),
              ),
              if (exercises.isNotEmpty && plan != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _startWorkout(plan, exercises),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Workout'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlanExerciseFormResult {
  final int sets;
  final String reps;
  final double? weight;
  final int? restSeconds;
  final bool delete;

  _PlanExerciseFormResult({
    required this.sets,
    required this.reps,
    this.weight,
    this.restSeconds,
    this.delete = false,
  });
}

Future<_PlanExerciseFormResult?> _showPlanExerciseForm(
  BuildContext context, {
  required String exerciseName,
  int initialSets = 3,
  String initialReps = '8-12',
  double? initialWeight,
  int? initialRest = 60,
  bool allowDelete = false,
}) {
  final setsController = TextEditingController(text: '$initialSets');
  final repsController = TextEditingController(text: initialReps);
  final weightController = TextEditingController(text: initialWeight?.toString() ?? '');
  final restController = TextEditingController(text: initialRest?.toString() ?? '');

  return showDialog<_PlanExerciseFormResult>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(exerciseName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: setsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Sets'),
          ),
          TextField(
            controller: repsController,
            decoration: const InputDecoration(labelText: 'Reps (e.g. 8-12, 30s, 400m)'),
          ),
          TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Target weight (kg, optional)'),
          ),
          TextField(
            controller: restController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Rest seconds (optional)'),
          ),
        ],
      ),
      actions: [
        if (allowDelete)
          TextButton(
            onPressed: () => Navigator.of(context).pop(_PlanExerciseFormResult(sets: 0, reps: '', delete: true)),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final sets = int.tryParse(setsController.text.trim()) ?? 3;
            final reps = repsController.text.trim().isEmpty ? '8-12' : repsController.text.trim();
            final weight = double.tryParse(weightController.text.trim());
            final rest = int.tryParse(restController.text.trim());
            Navigator.of(context).pop(_PlanExerciseFormResult(sets: sets, reps: reps, weight: weight, restSeconds: rest));
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
