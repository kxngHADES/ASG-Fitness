class WorkoutSession {
  final int? id;
  final int? planId;
  final String name;
  final String date; // yyyy-MM-dd
  final String startedAt;
  final String? completedAt;
  final String? notes;

  // Populated via join.
  final String? planName;

  const WorkoutSession({
    this.id,
    this.planId,
    required this.name,
    required this.date,
    required this.startedAt,
    this.completedAt,
    this.notes,
    this.planName,
  });

  factory WorkoutSession.fromMap(Map<String, Object?> map) {
    return WorkoutSession(
      id: map['id'] as int?,
      planId: map['plan_id'] as int?,
      name: map['name'] as String,
      date: map['date'] as String,
      startedAt: map['started_at'] as String,
      completedAt: map['completed_at'] as String?,
      notes: map['notes'] as String?,
      planName: map['plan_name'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'plan_id': planId,
      'name': name,
      'date': date,
      'started_at': startedAt,
      'completed_at': completedAt,
      'notes': notes,
    };
  }
}

class SessionExercise {
  final int? id;
  final int sessionId;
  final int exerciseId;
  final int sortOrder;

  // Populated via join.
  final String? exerciseName;
  final String? trackingType;

  const SessionExercise({
    this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.sortOrder,
    this.exerciseName,
    this.trackingType,
  });

  factory SessionExercise.fromMap(Map<String, Object?> map) {
    return SessionExercise(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      exerciseId: map['exercise_id'] as int,
      sortOrder: map['sort_order'] as int,
      exerciseName: map['exercise_name'] as String?,
      trackingType: map['tracking_type'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'sort_order': sortOrder,
    };
  }
}

class SetLog {
  final int? id;
  final int sessionExerciseId;
  final int setNumber;
  final double? weightKg;
  final int? reps;
  final int? durationSeconds;
  final double? distanceKm;
  final bool completed;

  const SetLog({
    this.id,
    required this.sessionExerciseId,
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.durationSeconds,
    this.distanceKm,
    this.completed = false,
  });

  SetLog copyWith({
    double? weightKg,
    int? reps,
    int? durationSeconds,
    double? distanceKm,
    bool? completed,
  }) {
    return SetLog(
      id: id,
      sessionExerciseId: sessionExerciseId,
      setNumber: setNumber,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceKm: distanceKm ?? this.distanceKm,
      completed: completed ?? this.completed,
    );
  }

  factory SetLog.fromMap(Map<String, Object?> map) {
    return SetLog(
      id: map['id'] as int?,
      sessionExerciseId: map['session_exercise_id'] as int,
      setNumber: map['set_number'] as int,
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      reps: map['reps'] as int?,
      durationSeconds: map['duration_seconds'] as int?,
      distanceKm: (map['distance_km'] as num?)?.toDouble(),
      completed: (map['completed'] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'session_exercise_id': sessionExerciseId,
      'set_number': setNumber,
      'weight_kg': weightKg,
      'reps': reps,
      'duration_seconds': durationSeconds,
      'distance_km': distanceKm,
      'completed': completed ? 1 : 0,
    };
  }
}
