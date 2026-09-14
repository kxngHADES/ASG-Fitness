class Equipment {
  final int? id;
  final String name;
  final String category;
  final bool owned;

  const Equipment({
    this.id,
    required this.name,
    required this.category,
    this.owned = false,
  });

  Equipment copyWith({int? id, String? name, String? category, bool? owned}) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      owned: owned ?? this.owned,
    );
  }

  factory Equipment.fromMap(Map<String, Object?> map) {
    return Equipment(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      owned: (map['owned'] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
    };
  }
}
