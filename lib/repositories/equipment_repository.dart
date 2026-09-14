import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/equipment.dart';

class EquipmentRepository {
  Future<List<Equipment>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT e.id, e.name, e.category,
        CASE WHEN o.equipment_id IS NULL THEN 0 ELSE 1 END AS owned
      FROM equipment e
      LEFT JOIN owned_equipment o ON o.equipment_id = e.id
      ORDER BY e.category, e.name
    ''');
    return rows.map(Equipment.fromMap).toList();
  }

  Future<Set<int>> getOwnedIds() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('owned_equipment');
    return rows.map((r) => r['equipment_id'] as int).toSet();
  }

  Future<void> setOwned(int equipmentId, bool owned) async {
    final db = await DatabaseHelper.instance.database;
    if (owned) {
      await db.insert(
        'owned_equipment',
        {'equipment_id': equipmentId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      await db.delete(
        'owned_equipment',
        where: 'equipment_id = ?',
        whereArgs: [equipmentId],
      );
    }
  }
}
