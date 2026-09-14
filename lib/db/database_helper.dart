import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../data/seed_data.dart';

/// Central SQLite access point. The whole app is offline-only: every read
/// and write goes through this single on-device database, there is no
/// network layer at all.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const _dbName = 'asg_fitness.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return databaseFactory.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: _onCreate,
        ),
      );
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE equipment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE owned_equipment (
        equipment_id INTEGER PRIMARY KEY REFERENCES equipment(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        primary_muscle TEXT NOT NULL,
        secondary_muscles TEXT,
        equipment_id INTEGER REFERENCES equipment(id) ON DELETE SET NULL,
        tracking_type TEXT NOT NULL,
        instructions TEXT,
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE plan_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
        exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
        sort_order INTEGER NOT NULL,
        target_sets INTEGER NOT NULL,
        target_reps TEXT NOT NULL,
        target_weight REAL,
        rest_seconds INTEGER,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_id INTEGER REFERENCES workout_plans(id) ON DELETE SET NULL,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE session_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
        exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
        sort_order INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE set_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_exercise_id INTEGER NOT NULL REFERENCES session_exercises(id) ON DELETE CASCADE,
        set_number INTEGER NOT NULL,
        weight_kg REAL,
        reps INTEGER,
        duration_seconds INTEGER,
        distance_km REAL,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE body_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        weight_kg REAL,
        body_fat_pct REAL,
        chest_cm REAL,
        waist_cm REAL,
        hips_cm REAL,
        arm_cm REAL,
        thigh_cm REAL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final batch = db.batch();

    final equipmentIds = <String, int>{};
    for (final e in equipmentSeeds) {
      batch.insert('equipment', {'name': e.name, 'category': e.category});
    }
    final equipmentResults = await batch.commit();
    for (var i = 0; i < equipmentSeeds.length; i++) {
      equipmentIds[equipmentSeeds[i].name] = equipmentResults[i] as int;
    }

    // Bodyweight is always "owned" by default since it requires no gear.
    final bodyweightId = equipmentIds['Bodyweight'];
    if (bodyweightId != null) {
      await db.insert('owned_equipment', {'equipment_id': bodyweightId});
    }

    final exerciseBatch = db.batch();
    for (final ex in exerciseSeeds) {
      exerciseBatch.insert('exercises', {
        'name': ex.name,
        'category': ex.category,
        'primary_muscle': ex.primaryMuscle,
        'secondary_muscles': ex.secondaryMuscles,
        'equipment_id': ex.equipment != null ? equipmentIds[ex.equipment] : null,
        'tracking_type': ex.trackingType,
        'instructions': ex.instructions,
        'is_custom': 0,
      });
    }
    await exerciseBatch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
