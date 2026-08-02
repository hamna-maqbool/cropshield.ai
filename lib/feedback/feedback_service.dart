// feedback_service.dart
//
// Saves feedback locally on the phone using SharedPreferences.
// Works fully offline — important for farmers in low-signal areas.
// If you later add a backend/Firebase, only this file needs to change.
//
// Add this to pubspec.yaml if not already there:
//   dependencies:
//     shared_preferences: ^2.2.2

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'feedback_entry.dart';

class FeedbackService {
  static const String _storageKey = 'diagnosis_feedback_list';

  // Save one feedback entry (appends to the existing list).
  Future<void> saveFeedback(FeedbackEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_storageKey) ?? [];
    existing.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_storageKey, existing);
  }

  // Check if this scan already has feedback (prevents asking twice
  // if the farmer navigates back to the same result screen).
  Future<bool> hasFeedback(String scanId) async {
    final all = await getAllFeedback();
    return all.any((e) => e.scanId == scanId);
  }

  // Get all saved feedback — useful for a "Feedback History" screen
  // or for your FYP demo/evaluation showing collected data.
  Future<List<FeedbackEntry>> getAllFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw
        .map((s) =>
            FeedbackEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  // Quick stats, e.g. "85% of diagnoses confirmed correct"
  Future<double> getAccuracyPercent() async {
    final all = await getAllFeedback();
    if (all.isEmpty) return 0;
    final correct = all.where((e) => e.wasCorrect).length;
    return (correct / all.length) * 100;
  }
}