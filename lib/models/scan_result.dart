import 'package:crop_shield_ai/models/input_method.dart';

class ScanResult {
  const ScanResult({
    required this.id,
    required this.inputMethod,
    required this.diseaseName,
    required this.confidence,
    required this.scannedAt,
    this.imagePath,
    this.queryText,
    this.summary,
  });

  final String id;
  final InputMethod inputMethod;
  final String diseaseName;
  final double confidence;
  final DateTime scannedAt;
  final String? imagePath;
  final String? queryText;
  final String? summary;

  Map<String, dynamic> toJson() => {
        'id': id,
        'inputMethod': inputMethod.name,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'scannedAt': scannedAt.toIso8601String(),
        'imagePath': imagePath,
        'queryText': queryText,
        'summary': summary,
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
        id: json['id'] as String,
        inputMethod: InputMethod.values.byName(json['inputMethod'] as String),
        diseaseName: json['diseaseName'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        scannedAt: DateTime.parse(json['scannedAt'] as String),
        imagePath: json['imagePath'] as String?,
        queryText: json['queryText'] as String?,
        summary: json['summary'] as String?,
      );
}
