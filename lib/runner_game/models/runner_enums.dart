// runner_enums.dart
//
// Shared enums for the Field Runner game. Kept in one small file so
// they're easy to reference (and easy to explain in a defense) without
// hunting through component files.

/// Obstacles come in two flavors, each dodged a different way — this is
/// what gives jump/duck a real purpose instead of being decorative.
enum PestType {
  /// Sits on the ground in its lane. Dodge by switching lanes OR jumping.
  ground,

  /// Flies at head height. Dodge by switching lanes OR ducking.
  flying,
}

enum PowerUpType {
  /// Temporary invincibility — one free hit is absorbed, obstacle is
  /// destroyed instead of ending the run. Themed as a pesticide shield.
  shield,

  /// Temporary score multiplier. Themed as a fertilizer growth boost.
  boost,
}

enum RunnerGameState {
  ready,
  playing,
  paused,
  gameOver,
}
