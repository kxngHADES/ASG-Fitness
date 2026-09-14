class BodyStat {
  final int? id;
  final String date; // yyyy-MM-dd, unique
  final double? weightKg;
  final double? bodyFatPct;
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;
  final double? armCm;
  final double? thighCm;
  final String? notes;

  const BodyStat({
    this.id,
    required this.date,
    this.weightKg,
    this.bodyFatPct,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.armCm,
    this.thighCm,
    this.notes,
  });

  factory BodyStat.fromMap(Map<String, Object?> map) {
    return BodyStat(
      id: map['id'] as int?,
      date: map['date'] as String,
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      bodyFatPct: (map['body_fat_pct'] as num?)?.toDouble(),
      chestCm: (map['chest_cm'] as num?)?.toDouble(),
      waistCm: (map['waist_cm'] as num?)?.toDouble(),
      hipsCm: (map['hips_cm'] as num?)?.toDouble(),
      armCm: (map['arm_cm'] as num?)?.toDouble(),
      thighCm: (map['thigh_cm'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'weight_kg': weightKg,
      'body_fat_pct': bodyFatPct,
      'chest_cm': chestCm,
      'waist_cm': waistCm,
      'hips_cm': hipsCm,
      'arm_cm': armCm,
      'thigh_cm': thighCm,
      'notes': notes,
    };
  }
}
