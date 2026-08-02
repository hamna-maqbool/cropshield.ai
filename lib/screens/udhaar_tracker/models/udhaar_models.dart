// udhaar_models.dart
//
// Models for the Input Credit (Udhaar) Tracker.
//
// A Dealer has many CreditEntry (purchases made on credit) and many
// Repayment (money paid back). The outstanding balance owed to a
// dealer is never stored directly — it is always computed as
// (sum of CreditEntry.totalAmount) - (sum of Repayment.amount) so the
// number can never drift out of sync with the underlying transactions.

class Dealer {
  Dealer({
    this.id,
    required this.name,
    this.contact,
    this.note,
  });

  final int? id;
  final String name;
  final String? contact;
  final String? note;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'contact': contact,
        'note': note,
      };

  factory Dealer.fromMap(Map<String, dynamic> map) => Dealer(
        id: map['id'] as int?,
        name: map['name'] as String,
        contact: map['contact'] as String?,
        note: map['note'] as String?,
      );
}

enum CreditCategory { seed, fertilizer, pesticide, diesel, other }

extension CreditCategoryLabel on CreditCategory {
  String get label {
    switch (this) {
      case CreditCategory.seed:
        return 'Seed';
      case CreditCategory.fertilizer:
        return 'Fertilizer';
      case CreditCategory.pesticide:
        return 'Pesticide';
      case CreditCategory.diesel:
        return 'Diesel';
      case CreditCategory.other:
        return 'Other';
    }
  }
}

class CreditEntry {
  CreditEntry({
    this.id,
    required this.dealerId,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.totalAmount,
    required this.date,
    this.fieldName,
    this.dueDate,
    this.note,
  });

  final int? id;
  final int dealerId;
  final String itemName;
  final CreditCategory category;
  final double quantity;
  final String unit; // e.g. "kg", "bags", "liters"
  final double totalAmount;
  final DateTime date;
  final String? fieldName;
  final DateTime? dueDate;
  final String? note;

  Map<String, dynamic> toMap() => {
        'id': id,
        'dealerId': dealerId,
        'itemName': itemName,
        'category': category.name,
        'quantity': quantity,
        'unit': unit,
        'totalAmount': totalAmount,
        'date': date.toIso8601String(),
        'fieldName': fieldName,
        'dueDate': dueDate?.toIso8601String(),
        'note': note,
      };

  factory CreditEntry.fromMap(Map<String, dynamic> map) => CreditEntry(
        id: map['id'] as int?,
        dealerId: map['dealerId'] as int,
        itemName: map['itemName'] as String,
        category: CreditCategory.values
            .firstWhere((c) => c.name == map['category']),
        quantity: (map['quantity'] as num).toDouble(),
        unit: map['unit'] as String,
        totalAmount: (map['totalAmount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        fieldName: map['fieldName'] as String?,
        dueDate: map['dueDate'] != null
            ? DateTime.parse(map['dueDate'] as String)
            : null,
        note: map['note'] as String?,
      );
}

class Repayment {
  Repayment({
    this.id,
    required this.dealerId,
    required this.amount,
    required this.date,
    this.note,
  });

  final int? id;
  final int dealerId;
  final double amount;
  final DateTime date;
  final String? note;

  Map<String, dynamic> toMap() => {
        'id': id,
        'dealerId': dealerId,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Repayment.fromMap(Map<String, dynamic> map) => Repayment(
        id: map['id'] as int?,
        dealerId: map['dealerId'] as int,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        note: map['note'] as String?,
      );
}

/// Computed rollup for one dealer — never stored, always derived from
/// the dealer's credit entries and repayments.
class DealerSummary {
  DealerSummary({
    required this.dealer,
    required this.totalCredit,
    required this.totalRepaid,
    required this.entryCount,
    required this.nearestDueDate,
  });

  final Dealer dealer;
  final double totalCredit;
  final double totalRepaid;
  final int entryCount;
  final DateTime? nearestDueDate;

  double get outstandingBalance => totalCredit - totalRepaid;
}

/// One row in a dealer's combined ledger — either a purchase or a
/// repayment, normalized so the UI can render both in one timeline
/// with a running balance.
class LedgerRow {
  LedgerRow.credit(CreditEntry e)
      : date = e.date,
        isCredit = true,
        amount = e.totalAmount,
        title = e.itemName,
        subtitle =
            '${e.quantity} ${e.unit} · ${e.category.label}${e.fieldName != null ? ' · ${e.fieldName}' : ''}',
        note = e.note,
        sourceId = e.id;

  LedgerRow.repayment(Repayment r)
      : date = r.date,
        isCredit = false,
        amount = r.amount,
        title = 'Repayment',
        subtitle = 'Paid to dealer',
        note = r.note,
        sourceId = r.id;

  final DateTime date;
  final bool isCredit; // true = purchase (increases balance owed)
  final double amount;
  final String title;
  final String subtitle;
  final String? note;
  final int? sourceId;
}
