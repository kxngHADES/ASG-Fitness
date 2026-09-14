import '../db/database_helper.dart';
import '../models/workout_plan.dart';

class PlanRepository {
  Future<List<WorkoutPlan>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('workout_plans', orderBy: 'created_at DESC');
    return rows.map(WorkoutPlan.fromMap).toList();
  }

  Future<WorkoutPlan?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('workout_plans', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return WorkoutPlan.fromMap(rows.first);
  }

  Future<int> create(WorkoutPlan plan) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('workout_plans', plan.toMap());
  }

  Future<void> update(WorkoutPlan plan) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('workout_plans', plan.toMap(), where: 'id = ?', whereArgs: [plan.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('workout_plans', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PlanExercise>> getExercises(int planId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT pe.*, ex.name AS exercise_name, ex.tracking_type
      FROM plan_exercises pe
      JOIN exercises ex ON ex.id = pe.exercise_id
      WHERE pe.plan_id = ?
      ORDER BY pe.sort_order
    ''', [planId]);
    return rows.map(PlanExercise.fromMap).toList();
  }

  Future<int> addExercise(PlanExercise pe) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('plan_exercises', pe.toMap());
  }

  Future<void> updateExercise(PlanExercise pe) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('plan_exercises', pe.toMap(), where: 'id = ?', whereArgs: [pe.id]);
  }

  Future<void> removeExercise(int planExerciseId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('plan_exercises', where: 'id = ?', whereArgs: [planExerciseId]);
  }

  Future<void> reorderExercises(List<int> planExerciseIdsInOrder) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    for (var i = 0; i < planExerciseIdsInOrder.length; i++) {
      batch.update(
        'plan_exercises',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [planExerciseIdsInOrder[i]],
      );
    }
    await batch.commit(noResult: true);
  }
}
