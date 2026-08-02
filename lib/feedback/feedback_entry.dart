// feedback_entry.dart
// Data model for one piece of farmer feedback on a scan result.

class FeedbackEntry {
  final String scanId;             // links feedback to the specific scan
  final String predictedDisease;   // what the model predicted
  final double confidence;         // model's confidence (0.0 - 1.0)
  final String inputMethod;        // e.g. "Camera", "Gallery"
  final bool wasCorrect;           // true = farmer tapped 👍, false = 👎
  final String? correctedDisease;  // farmer's picked correct disease, if wrong
  final DateTime timestamp;

  FeedbackEntry({
    required this.scanId,
    required this.predictedDisease,
    required this.confidence,
    required this.inputMethod,
    required this.wasCorrect,
    this.correctedDisease,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'scanId': scanId,
        'predictedDisease': predictedDisease,
        'confidence': confidence,
        'inputMethod': inputMethod,
        'wasCorrect': wasCorrect,
        'correctedDisease': correctedDisease,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      scanId: json['scanId'] as String,
      predictedDisease: json['predictedDisease'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      inputMethod: json['inputMethod'] as String,
      wasCorrect: json['wasCorrect'] as bool,
      correctedDisease: json['correctedDisease'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}