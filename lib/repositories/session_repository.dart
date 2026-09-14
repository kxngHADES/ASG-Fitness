import '../db/database_helper.dart';
import '../models/workout_session.dart';

class SessionRepository {
  Future<List<WorkoutSession>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT s.*, p.name AS plan_name
      FROM workout_sessions s
      LEFT JOIN workout_plans p ON p.id = s.plan_id
      ORDER BY s.started_at DESC
    ''');
    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<WorkoutSession?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT s.*, p.name AS plan_name
      FROM workout_sessions s
      LEFT JOIN workout_plans p ON p.id = s.plan_id
      WHERE s.id = ?
    ''', [id]);
    if (rows.isEmpty) return null;
    return WorkoutSession.fromMap(rows.first);
  }

  Future<int> create(WorkoutSession session) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('workout_sessions', session.toMap());
  }

  Future<void> update(WorkoutSession session) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('workout_sessions', session.toMap(), where: 'id = ?', whereArgs: [session.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('workout_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> addSessionExercise(SessionExercise se) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('session_exercises', se.toMap());
  }

  Future<List<SessionExercise>> getSessionExercises(int sessionId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT se.*, ex.name AS exercise_name, ex.tracking_type
      FROM session_exercises se
      JOIN exercises ex ON ex.id = se.exercise_id
      WHERE se.session_id = ?
      ORDER BY se.sort_order
    ''', [sessionId]);
    return rows.map(SessionExercise.fromMap).toList();
  }

  Future<int> addSetLog(SetLog log) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('set_logs', log.toMap());
  }

  Future<void> updateSetLog(SetLog log) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('set_logs', log.toMap(), where: 'id = ?', whereArgs: [log.id]);
  }

  Future<void> deleteSetLog(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('set_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SetLog>> getSetLogs(int sessionExerciseId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'set_logs',
      where: 'session_exercise_id = ?',
      whereArgs: [sessionExerciseId],
      orderBy: 'set_number',
    );
    return rows.map(SetLog.fromMap).toList();
  }

  /// History of completed sets for one exercise across all sessions, most
  /// recent first — used to power the progression charts.
  Future<List<Map<String, Object?>>> getExerciseHistory(int exerciseId) async {
    final db = await DatabaseHelper.instance.database;
    return db.rawQuery('''
      SELECT sl.*, s.date
      FROM set_logs sl
      JOIN session_exercises se ON se.id = sl.session_exercise_id
      JOIN workout_sessions s ON s.id = se.session_id
      WHERE se.exercise_id = ? AND sl.completed = 1
      ORDER BY s.date ASC, sl.set_number ASC
    ''', [exerciseId]);
  }
}
