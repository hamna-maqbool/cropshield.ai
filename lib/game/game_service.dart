// game_service.dart
//
// Saves completed game results locally (same pattern as feedback_service.dart)
// so you can show a "Best Score" / history later without needing a backend.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameResult {
  final String crop;
  final int finalHealth;      // 0-100
  final int finalBudget;      // remaining Rs.
  final int yieldPercent;     // 0-100
  final String badge;         // e.g. "Master Farmer"
  final DateTime timestamp;

  GameResult({
    required this.crop,
    required this.finalHealth,
    required this.finalBudget,
    required this.yieldPercent,
    required this.badge,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'crop': crop,
        'finalHealth': finalHealth,
        'finalBudget': finalBudget,
        'yieldPercent': yieldPercent,
        'badge': badge,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
        crop: json['crop'] as String,
        finalHealth: json['finalHealth'] as int,
        finalBudget: json['finalBudget'] as int,
        yieldPercent: json['yieldPercent'] as int,
        badge: json['badge'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class GameService {
  static const String _storageKey = 'field_game_results';

  Future<void> saveResult(GameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_storageKey) ?? [];
    existing.add(jsonEncode(result.toJson()));
    await prefs.setStringList(_storageKey, existing);
  }

  Future<List<GameResult>> getAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw
        .map((s) => GameResult.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<int> getBestYield() async {
    final all = await getAllResults();
    if (all.isEmpty) return 0;
    return all.map((r) => r.yieldPercent).reduce((a, b) => a > b ? a : b);
  }
}
