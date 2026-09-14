class WorkoutPlan {
  final int? id;
  final String name;
  final String? description;
  final String createdAt;

  const WorkoutPlan({
    this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory WorkoutPlan.fromMap(Map<String, Object?> map) {
    return WorkoutPlan(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
    };
  }
}

class PlanExercise {
  final int? id;
  final int planId;
  final int exerciseId;
  final int sortOrder;
  final int targetSets;
  final String targetReps; // free text e.g. "8-12" or "30s" or "400m"
  final double? targetWeight;
  final int? restSeconds;
  final String? notes;

  // Populated via join.
  final String? exerciseName;
  final String? trackingType;

  const PlanExercise({
    this.id,
    required this.planId,
    required this.exerciseId,
    required this.sortOrder,
    required this.targetSets,
    required this.targetReps,
    this.targetWeight,
    this.restSeconds,
    this.notes,
    this.exerciseName,
    this.trackingType,
  });

  factory PlanExercise.fromMap(Map<String, Object?> map) {
    return PlanExercise(
      id: map['id'] as int?,
      planId: map['plan_id'] as int,
      exerciseId: map['exercise_id'] as int,
      sortOrder: map['sort_order'] as int,
      targetSets: map['target_sets'] as int,
      targetReps: map['target_reps'] as String,
      targetWeight: (map['target_weight'] as num?)?.toDouble(),
      restSeconds: map['rest_seconds'] as int?,
      notes: map['notes'] as String?,
      exerciseName: map['exercise_name'] as String?,
      trackingType: map['tracking_type'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'plan_id': planId,
      'exercise_id': exerciseId,
      'sort_order': sortOrder,
      'target_sets': targetSets,
      'target_reps': targetReps,
      'target_weight': targetWeight,
      'rest_seconds': restSeconds,
      'notes': notes,
    };
  }
}
