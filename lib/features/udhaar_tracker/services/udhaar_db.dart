// udhaar_db.dart
//
// Local SQLite storage for dealers, credit purchases, and repayments.
// Three tables, linked by dealerId. Outstanding balance is always
// computed at read time from credit_entries minus repayments — never
// stored — so it can't drift out of sync if an entry is edited or
// deleted later.

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/udhaar_models.dart';

class UdhaarDb {
  UdhaarDb._internal();
  static final UdhaarDb instance = UdhaarDb._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'udhaar_tracker.db');

    return openDatabase(
      path,
      version: 1,
      // sqflite does not enforce foreign keys by default — without this,
      // ON DELETE CASCADE above is silently ignored and deleting a
      // dealer would leave orphaned credit_entries/repayments behind.
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE dealers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            contact TEXT,
            note TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE credit_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dealerId INTEGER NOT NULL,
            itemName TEXT NOT NULL,
            category TEXT NOT NULL,
            quantity REAL NOT NULL,
            unit TEXT NOT NULL,
            totalAmount REAL NOT NULL,
            date TEXT NOT NULL,
            fieldName TEXT,
            dueDate TEXT,
            note TEXT,
            FOREIGN KEY (dealerId) REFERENCES dealers (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE repayments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            dealerId INTEGER NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            note TEXT,
            FOREIGN KEY (dealerId) REFERENCES dealers (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ---------------------------------------------------------------------
  // Dealers
  // ---------------------------------------------------------------------

  Future<int> insertDealer(Dealer dealer) async {
    final db = await database;
    return db.insert('dealers', dealer.toMap()..remove('id'));
  }

  Future<List<Dealer>> getAllDealers() async {
    final db = await database;
    final rows = await db.query('dealers', orderBy: 'name ASC');
    return rows.map(Dealer.fromMap).toList();
  }

  Future<Dealer?> getDealer(int id) async {
    final db = await database;
    final rows = await db.query('dealers', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Dealer.fromMap(rows.first);
  }

  Future<int> deleteDealer(int id) async {
    final db = await database;
    // Cascades to credit_entries and repayments via FOREIGN KEY.
    return db.delete('dealers', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------
  // Credit entries (purchases)
  // ---------------------------------------------------------------------

  Future<int> insertCreditEntry(CreditEntry entry) async {
    final db = await database;
    return db.insert('credit_entries', entry.toMap()..remove('id'));
  }

  Future<int> deleteCreditEntry(int id) async {
    final db = await database;
    return db.delete('credit_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<CreditEntry>> getEntriesForDealer(int dealerId) async {
    final db = await database;
    final rows = await db.query(
      'credit_entries',
      where: 'dealerId = ?',
      whereArgs: [dealerId],
      orderBy: 'date DESC',
    );
    return rows.map(CreditEntry.fromMap).toList();
  }

  // ---------------------------------------------------------------------
  // Repayments
  // ---------------------------------------------------------------------

  Future<int> insertRepayment(Repayment repayment) async {
    final db = await database;
    return db.insert('repayments', repayment.toMap()..remove('id'));
  }

  Future<int> deleteRepayment(int id) async {
    final db = await database;
    return db.delete('repayments', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Repayment>> getRepaymentsForDealer(int dealerId) async {
    final db = await database;
    final rows = await db.query(
      'repayments',
      where: 'dealerId = ?',
      whereArgs: [dealerId],
      orderBy: 'date DESC',
    );
    return rows.map(Repayment.fromMap).toList();
  }

  // ---------------------------------------------------------------------
  // Summaries / ledger
  // ---------------------------------------------------------------------

  /// One summary per dealer — this powers the main screen's dealer list.
  Future<List<DealerSummary>> getAllDealerSummaries() async {
    final dealers = await getAllDealers();
    final summaries = <DealerSummary>[];

    for (final dealer in dealers) {
      final entries = await getEntriesForDealer(dealer.id!);
      final repayments = await getRepaymentsForDealer(dealer.id!);

      final totalCredit =
          entries.fold<double>(0, (sum, e) => sum + e.totalAmount);
      final totalRepaid =
          repayments.fold<double>(0, (sum, r) => sum + r.amount);

      final upcomingDueDates = entries
          .map((e) => e.dueDate)
          .whereType<DateTime>()
          .where((d) => d.isAfter(DateTime.now()))
          .toList()
        ..sort();

      summaries.add(DealerSummary(
        dealer: dealer,
        totalCredit: totalCredit,
        totalRepaid: totalRepaid,
        entryCount: entries.length,
        nearestDueDate:
            upcomingDueDates.isNotEmpty ? upcomingDueDates.first : null,
      ));
    }

    return summaries;
  }

  /// Combined, chronological purchase + repayment history for one
  /// dealer — a bank-statement-style ledger with a running balance.
  Future<List<LedgerRow>> getLedgerForDealer(int dealerId) async {
    final entries = await getEntriesForDealer(dealerId);
    final repayments = await getRepaymentsForDealer(dealerId);

    final rows = <LedgerRow>[
      ...entries.map(LedgerRow.credit),
      ...repayments.map(LedgerRow.repayment),
    ];

    rows.sort((a, b) => b.date.compareTo(a.date)); // newest first
    return rows;
  }
}
