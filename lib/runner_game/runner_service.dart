// runner_service.dart
//
// Stores the player's best score locally (same pattern as your other
// local-storage services). No backend needed.

import 'package:shared_preferences/shared_preferences.dart';

class RunnerService {
  static const String _bestScoreKey = 'runner_best_score';

  Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0;
  }

  Future<void> saveScoreIfBest(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_bestScoreKey) ?? 0;
    if (score > current) {
      await prefs.setInt(_bestScoreKey, score);
    }
  }
}
