/// How a set of this exercise is logged.
enum TrackingType {
  weightReps, // e.g. bench press: weight + reps
  bodyweightReps, // e.g. push ups: reps only (optional added weight)
  time, // e.g. plank: duration only
  distanceTime, // e.g. treadmill run: distance + duration
}

TrackingType trackingTypeFromString(String value) {
  return TrackingType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => TrackingType.weightReps,
  );
}

class Exercise {
  final int? id;
  final String name;
  final String category; // Strength, Cardio, Mobility
  final String primaryMuscle;
  final String? secondaryMuscles;
  final int? equipmentId; // null = bodyweight / no equipment needed
  final TrackingType trackingType;
  final String? instructions;

  // Populated via joins, not stored directly on this table.
  final String? equipmentName;

  const Exercise({
    this.id,
    required this.name,
    required this.category,
    required this.primaryMuscle,
    this.secondaryMuscles,
    this.equipmentId,
    required this.trackingType,
    this.instructions,
    this.equipmentName,
  });

  factory Exercise.fromMap(Map<String, Object?> map) {
    return Exercise(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      primaryMuscle: map['primary_muscle'] as String,
      secondaryMuscles: map['secondary_muscles'] as String?,
      equipmentId: map['equipment_id'] as int?,
      trackingType: trackingTypeFromString(map['tracking_type'] as String),
      instructions: map['instructions'] as String?,
      equipmentName: map['equipment_name'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'primary_muscle': primaryMuscle,
      'secondary_muscles': secondaryMuscles,
      'equipment_id': equipmentId,
      'tracking_type': trackingType.name,
      'instructions': instructions,
    };
  }
}
