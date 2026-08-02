// fuel_log_db.dart
//
// Local SQLite storage for fuel entries. Works fully offline — no
// network needed to log a fill-up. If you later add a backend, this
// is the single place to add a sync queue (mark rows unsynced, push
// them when connectivity returns).

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/fuel_entry.dart';

class FuelLogDb {
  FuelLogDb._internal();
  static final FuelLogDb instance = FuelLogDb._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fuel_log.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE fuel_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fieldName TEXT NOT NULL,
            tractorName TEXT NOT NULL,
            liters REAL NOT NULL,
            pricePerLiter REAL NOT NULL,
            date TEXT NOT NULL,
            workerName TEXT,
            stationName TEXT,
            note TEXT,
            receiptPhotoPath TEXT
          )
        ''');
      },
    );
  }

  // ---------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------

  Future<int> insertEntry(FuelEntry entry) async {
    final db = await database;
    final map = entry.toMap()..remove('id');
    return db.insert('fuel_entries', map);
  }

  Future<int> updateEntry(FuelEntry entry) async {
    final db = await database;
    return db.update(
      'fuel_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return db.delete('fuel_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FuelEntry>> getAllEntries() async {
    final db = await database;
    final rows = await db.query('fuel_entries', orderBy: 'date DESC');
    return rows.map(FuelEntry.fromMap).toList();
  }

  Future<List<FuelEntry>> getEntriesForField(String fieldName) async {
    final db = await database;
    final rows = await db.query(
      'fuel_entries',
      where: 'fieldName = ?',
      whereArgs: [fieldName],
      orderBy: 'date DESC',
    );
    return rows.map(FuelEntry.fromMap).toList();
  }

  Future<List<FuelEntry>> getEntriesForTractor(String tractorName) async {
    final db = await database;
    final rows = await db.query(
      'fuel_entries',
      where: 'tractorName = ?',
      whereArgs: [tractorName],
      orderBy: 'date DESC',
    );
    return rows.map(FuelEntry.fromMap).toList();
  }

  /// Distinct field names that have at least one entry — used to build
  /// the summary list without hardcoding field names anywhere.
  Future<List<String>> getDistinctFieldNames() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT fieldName FROM fuel_entries ORDER BY fieldName ASC',
    );
    return rows.map((r) => r['fieldName'] as String).toList();
  }

  /// Rolled-up totals per field — this is what powers the "history" view.
  Future<List<FieldFuelSummary>> getFieldSummaries() async {
    final fieldNames = await getDistinctFieldNames();
    final summaries = <FieldFuelSummary>[];

    for (final field in fieldNames) {
      final entries = await getEntriesForField(field);
      if (entries.isEmpty) continue;

      final totalLiters =
          entries.fold<double>(0, (sum, e) => sum + e.liters);
      final totalCost =
          entries.fold<double>(0, (sum, e) => sum + e.totalCost);
      final dates = entries.map((e) => e.date).toList()..sort();

      summaries.add(FieldFuelSummary(
        fieldName: field,
        totalLiters: totalLiters,
        totalCost: totalCost,
        entryCount: entries.length,
        firstFillDate: dates.first,
        lastFillDate: dates.last,
      ));
    }

    return summaries;
  }
}
