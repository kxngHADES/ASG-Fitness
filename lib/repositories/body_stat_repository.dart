import 'package:sqflite/sqflite.dart';

import '../db/database_helper.dart';
import '../models/body_stat.dart';

class BodyStatRepository {
  Future<List<BodyStat>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('body_stats', orderBy: 'date ASC');
    return rows.map(BodyStat.fromMap).toList();
  }

  Future<BodyStat?> getLatest() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('body_stats', orderBy: 'date DESC', limit: 1);
    if (rows.isEmpty) return null;
    return BodyStat.fromMap(rows.first);
  }

  /// Inserts, or overwrites the existing entry for that date.
  Future<void> upsert(BodyStat stat) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'body_stats',
      stat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('body_stats', where: 'id = ?', whereArgs: [id]);
  }
}
