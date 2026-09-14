import 'package:flutter/foundation.dart';

import '../models/workout_session.dart';
import '../repositories/session_repository.dart';

class SessionProvider extends ChangeNotifier {
  final SessionRepository _repo = SessionRepository();

  List<WorkoutSession> _sessions = [];
  bool _loading = true;

  List<WorkoutSession> get sessions => _sessions;
  List<WorkoutSession> get completed => _sessions.where((s) => s.completedAt != null).toList();
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _sessions = await _repo.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<WorkoutSession?> getById(int id) => _repo.getById(id);

  Future<int> startSession({required String name, int? planId}) async {
    final now = DateTime.now();
    final dateStr = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final id = await _repo.create(WorkoutSession(
      planId: planId,
      name: name,
      date: dateStr,
      startedAt: now.toIso8601String(),
    ));
    return id;
  }

  Future<void> completeSession(int id) async {
    final session = await _repo.getById(id);
    if (session == null) return;
    await _repo.update(WorkoutSession(
      id: session.id,
      planId: session.planId,
      name: session.name,
      date: session.date,
      startedAt: session.startedAt,
      completedAt: DateTime.now().toIso8601String(),
      notes: session.notes,
    ));
    await load();
  }

  Future<void> deleteSession(int id) async {
    await _repo.delete(id);
    _sessions = _sessions.where((s) => s.id != id).toList();
    notifyListeners();
  }

  Future<int> addSessionExercise(SessionExercise se) => _repo.addSessionExercise(se);

  Future<List<SessionExercise>> getSessionExercises(int sessionId) => _repo.getSessionExercises(sessionId);

  Future<int> addSetLog(SetLog log) => _repo.addSetLog(log);

  Future<void> updateSetLog(SetLog log) => _repo.updateSetLog(log);

  Future<void> deleteSetLog(int id) => _repo.deleteSetLog(id);

  Future<List<SetLog>> getSetLogs(int sessionExerciseId) => _repo.getSetLogs(sessionExerciseId);

  Future<List<Map<String, Object?>>> getExerciseHistory(int exerciseId) => _repo.getExerciseHistory(exerciseId);
}
