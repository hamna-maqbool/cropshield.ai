// fuel_entry.dart
//
// A single diesel fill-up record. One tractor + one field + one fill-up
// event. History and cost rollups are computed FROM a list of these,
// not stored separately — keeps the source of truth in one place.

class FuelEntry {
  FuelEntry({
    this.id,
    required this.fieldName,
    required this.tractorName,
    required this.liters,
    required this.pricePerLiter,
    required this.date,
    this.workerName,
    this.stationName,
    this.note,
    this.receiptPhotoPath,
  });

  final int? id; // null until saved (sqlite assigns it)
  final String fieldName;
  final String tractorName;
  final double liters;
  final double pricePerLiter;
  final DateTime date;
  final String? workerName;
  final String? stationName;
  final String? note;
  final String? receiptPhotoPath; // local file path, optional

  double get totalCost => liters * pricePerLiter;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fieldName': fieldName,
      'tractorName': tractorName,
      'liters': liters,
      'pricePerLiter': pricePerLiter,
      'date': date.toIso8601String(),
      'workerName': workerName,
      'stationName': stationName,
      'note': note,
      'receiptPhotoPath': receiptPhotoPath,
    };
  }

  factory FuelEntry.fromMap(Map<String, dynamic> map) {
    return FuelEntry(
      id: map['id'] as int?,
      fieldName: map['fieldName'] as String,
      tractorName: map['tractorName'] as String,
      liters: (map['liters'] as num).toDouble(),
      pricePerLiter: (map['pricePerLiter'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      workerName: map['workerName'] as String?,
      stationName: map['stationName'] as String?,
      note: map['note'] as String?,
      receiptPhotoPath: map['receiptPhotoPath'] as String?,
    );
  }

  FuelEntry copyWith({
    int? id,
    String? fieldName,
    String? tractorName,
    double? liters,
    double? pricePerLiter,
    DateTime? date,
    String? workerName,
    String? stationName,
    String? note,
    String? receiptPhotoPath,
  }) {
    return FuelEntry(
      id: id ?? this.id,
      fieldName: fieldName ?? this.fieldName,
      tractorName: tractorName ?? this.tractorName,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      date: date ?? this.date,
      workerName: workerName ?? this.workerName,
      stationName: stationName ?? this.stationName,
      note: note ?? this.note,
      receiptPhotoPath: receiptPhotoPath ?? this.receiptPhotoPath,
    );
  }
}

/// Rolled-up totals for one field across all its fuel entries.
/// Computed on the fly by FuelLogDb.getFieldSummaries() — not stored.
class FieldFuelSummary {
  FieldFuelSummary({
    required this.fieldName,
    required this.totalLiters,
    required this.totalCost,
    required this.entryCount,
    required this.firstFillDate,
    required this.lastFillDate,
  });

  final String fieldName;
  final double totalLiters;
  final double totalCost;
  final int entryCount;
  final DateTime firstFillDate;
  final DateTime lastFillDate;

  double get averagePricePerLiter =>
      totalLiters == 0 ? 0 : totalCost / totalLiters;
}
