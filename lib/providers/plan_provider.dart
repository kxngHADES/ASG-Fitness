import 'package:flutter/foundation.dart';

import '../models/workout_plan.dart';
import '../repositories/plan_repository.dart';

class PlanProvider extends ChangeNotifier {
  final PlanRepository _repo = PlanRepository();

  List<WorkoutPlan> _plans = [];
  bool _loading = true;

  List<WorkoutPlan> get plans => _plans;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _plans = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<int> createPlan(String name, String? description) async {
    final id = await _repo.create(WorkoutPlan(
      name: name,
      description: description,
      createdAt: DateTime.now().toIso8601String(),
    ));
    await load();
    return id;
  }

  Future<void> deletePlan(int id) async {
    await _repo.delete(id);
    _plans = _plans.where((p) => p.id != id).toList();
    notifyListeners();
  }

  Future<List<PlanExercise>> getExercises(int planId) => _repo.getExercises(planId);

  Future<void> addExercise({
    required int planId,
    required int exerciseId,
    required int sortOrder,
    required int targetSets,
    required String targetReps,
    double? targetWeight,
    int? restSeconds,
    String? notes,
  }) async {
    await _repo.addExercise(PlanExercise(
      planId: planId,
      exerciseId: exerciseId,
      sortOrder: sortOrder,
      targetSets: targetSets,
      targetReps: targetReps,
      targetWeight: targetWeight,
      restSeconds: restSeconds,
      notes: notes,
    ));
  }

  Future<void> updatePlanExercise(PlanExercise pe) => _repo.updateExercise(pe);

  Future<void> removeExercise(int planExerciseId) => _repo.removeExercise(planExerciseId);

  Future<void> reorder(List<int> ids) => _repo.reorderExercises(ids);
}
