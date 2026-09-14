import '../db/database_helper.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  static const _selectBase = '''
    SELECT ex.*, eq.name AS equipment_name
    FROM exercises ex
    LEFT JOIN equipment eq ON eq.id = ex.equipment_id
  ''';

  Future<List<Exercise>> getAll({bool onlyAvailable = false}) async {
    final db = await DatabaseHelper.instance.database;
    final where = onlyAvailable
        ? '''
      WHERE ex.equipment_id IS NULL OR ex.equipment_id IN (SELECT equipment_id FROM owned_equipment)
      '''
        : '';
    final rows = await db.rawQuery('$_selectBase $where ORDER BY ex.primary_muscle, ex.name');
    return rows.map(Exercise.fromMap).toList();
  }

  Future<Exercise?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('$_selectBase WHERE ex.id = ?', [id]);
    if (rows.isEmpty) return null;
    return Exercise.fromMap(rows.first);
  }

  Future<bool> isAvailable(int exerciseId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT 1 FROM exercises ex
      WHERE ex.id = ?
        AND (ex.equipment_id IS NULL OR ex.equipment_id IN (SELECT equipment_id FROM owned_equipment))
    ''', [exerciseId]);
    return rows.isNotEmpty;
  }

  Future<int> createCustom(Exercise exercise) async {
    final db = await DatabaseHelper.instance.database;
    final map = exercise.toMap();
    map['is_custom'] = 1;
    return db.insert('exercises', map);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('exercises', where: 'id = ? AND is_custom = 1', whereArgs: [id]);
  }
}
