// field_runner_game.dart
//
// The FlameGame itself. Owns the world (background, player, HUD), the
// spawn/difficulty timers, and reacts to collisions reported by the
// falling-item components. Flutter-side UI (ready/game-over menus,
// swipe gestures) lives in runner_game_screen.dart and talks to this
// class through a small public API (startGame / moveLane / jump / duck).

import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart' show Colors;

import 'components/crop_row_background.dart';
import 'components/falling_item_component.dart';
import 'components/game_items.dart';
import 'components/hud_component.dart';
import 'components/player_component.dart';
import 'models/runner_enums.dart';
import 'runner_service.dart';

class FieldRunnerGame extends FlameGame with HasCollisionDetection {
  FieldRunnerGame({required this.onGameOver});

  /// Fired once per run when the player is finally out — the Flutter
  /// screen uses this to flip its overlay and show the game-over card.
  final void Function(int score, bool isNewBest) onGameOver;

  final RunnerService _service = RunnerService();
  final Random _random = Random();

  RunnerGameState state = RunnerGameState.ready;

  late CropFieldParallax _background;
  late PlayerComponent player;
  late HudComponent hud;

  int score = 0;
  int best = 0;
  int combo = 0;
  double survivalTime = 0;
  double _spawnAccumulator = 0;
  double _powerUpAccumulator = 0;

  bool _boostActive = false;
  double _boostTimer = 0;

  static const double _baseSpeed = 260; // game units / second
  static const double _maxSpeed = 620;
  static const double _speedRamp = 9; // speed gain per second survived
  static const double _powerUpInterval = 9.0;

  List<double> _laneX = [];
  double _playerY = 0;

  Vector2 _worldOffset = Vector2.zero();
  double _shakeTime = 0;
  double _shakeIntensity = 0;

  @override
  Future<void> onLoad() async {
    await _loadBest();
    _recomputeLayout();

    _background = CropFieldParallax();
    await add(_background);

    player = PlayerComponent(laneXPositions: _laneX, playerY: _playerY);
    await add(player);

    hud = HudComponent()..best = best;
    await add(hud);

    pauseEngine();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _recomputeLayout();
    if (isLoaded) {
      player.laneXPositions = _laneX;
    }
  }

  void _recomputeLayout() {
    final w = size.x == 0 ? 400.0 : size.x;
    final laneWidth = w / 3;
    _laneX = [laneWidth * 0.5, laneWidth * 1.5, laneWidth * 2.5];
    _playerY = (size.y == 0 ? 800.0 : size.y) * 0.78;
  }

  Future<void> _loadBest() async {
    best = await _service.getBestScore();
  }

  // ---------------------------------------------------------------------
  // Public API used by the Flutter screen
  // ---------------------------------------------------------------------

  void startGame() {
    score = 0;
    combo = 0;
    survivalTime = 0;
    _spawnAccumulator = 0;
    _powerUpAccumulator = 0;
    _boostActive = false;
    _boostTimer = 0;

    children.whereType<FallingItemComponent>().toList().forEach(
          (c) => c.removeFromParent(),
        );

    player.reset();
    hud
      ..score = 0
      ..combo = 0
      ..best = best;

    state = RunnerGameState.playing;
    resumeEngine();
  }

  void moveLane(int delta) {
    if (state != RunnerGameState.playing) return;
    player.moveToLane(player.lane + delta);
  }

  void jump() {
    if (state != RunnerGameState.playing) return;
    player.jump();
  }

  void duck() {
    if (state != RunnerGameState.playing) return;
    player.duck();
  }

  void togglePause() {
    if (state == RunnerGameState.playing) {
      state = RunnerGameState.paused;
      pauseEngine();
    } else if (state == RunnerGameState.paused) {
      state = RunnerGameState.playing;
      resumeEngine();
    }
  }

  // ---------------------------------------------------------------------
  // Game loop
  // ---------------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);
    if (state != RunnerGameState.playing) return;

    survivalTime += dt;
    final currentSpeed =
        min(_maxSpeed, _baseSpeed + survivalTime * _speedRamp);
    _background.setScrollSpeed(currentSpeed);

    _updateFallSpeeds(currentSpeed);
    _updateSpawning(dt, currentSpeed);
    _updatePowerUps(dt);
    _updateShake(dt);
  }

  void _updateFallSpeeds(double currentSpeed) {
    for (final item in children.whereType<FallingItemComponent>()) {
      item.fallSpeed = currentSpeed;
    }
  }

  void _updateSpawning(double dt, double currentSpeed) {
    _spawnAccumulator += dt;
    final spawnInterval = max(0.5, 1.05 - survivalTime * 0.012);
    if (_spawnAccumulator >= spawnInterval) {
      _spawnAccumulator = 0;
      _spawnItem();
    }

    _powerUpAccumulator += dt;
    if (_powerUpAccumulator >= _powerUpInterval) {
      _powerUpAccumulator = 0;
      _spawnPowerUp();
    }
  }

  void _spawnItem() {
    final lane = _random.nextInt(_laneX.length);
    final roll = _random.nextDouble();

    if (roll < 0.55) {
      final isGround = _random.nextDouble() < 0.7;
      final pestType = isGround ? PestType.ground : PestType.flying;
      final emoji = isGround
          ? (['🐛', '🦗', '🐌'])[_random.nextInt(3)]
          : '🦅';
      add(
        PestObstacleComponent(
          lane: lane,
          laneX: _laneX[lane],
          pestType: pestType,
          emojiOverride: emoji,
        ),
      );
    } else {
      final isGolden = _random.nextDouble() < 0.15;
      add(
        LeafCollectibleComponent(
          lane: lane,
          laneX: _laneX[lane],
          isGolden: isGolden,
        ),
      );
    }
  }

  void _spawnPowerUp() {
    final lane = _random.nextInt(_laneX.length);
    final type =
        _random.nextBool() ? PowerUpType.shield : PowerUpType.boost;
    add(PowerUpComponent(lane: lane, laneX: _laneX[lane], powerUpType: type));
  }

  void _updatePowerUps(double dt) {
    if (_boostActive) {
      _boostTimer -= dt;
      if (_boostTimer <= 0) _boostActive = false;
    }
  }

  // ---------------------------------------------------------------------
  // Collision resolution — called by falling items when they reach the
  // player's row and share a lane with them (see FallingItemComponent /
  // PlayerComponent hitboxes).
  // ---------------------------------------------------------------------

  void resolveHit(FallingItemComponent item) {
    // This is only ever called from a real Flame collision callback
    // (CircleHitbox-on-CircleHitbox overlap between the item and the
    // player), so no manual lane/distance re-checking is needed here.
    if (item.consumed || state != RunnerGameState.playing) return;
    item.consumed = true;

    if (item is PestObstacleComponent) {
      final dodgedByJump =
          item.pestType == PestType.ground && player.isJumping;
      final dodgedByDuck =
          item.pestType == PestType.flying && player.isDucking;

      if (dodgedByJump || dodgedByDuck) {
        item.removeFromParent();
        return;
      }

      if (player.isShielded) {
        player.setShielded(false);
        _burstParticles(item.position, Colors.white);
        item.removeFromParent();
      } else {
        item.removeFromParent();
        _endGame();
      }
    } else if (item is LeafCollectibleComponent) {
      combo += 1;
      final base = item.isGolden ? 50 : 10;
      final multiplier = _boostActive ? 2 : 1;
      score += base * multiplier * (1 + (combo ~/ 5));
      hud
        ..score = score
        ..combo = combo;
      _burstParticles(
        item.position,
        item.isGolden ? Colors.amber : Colors.lightGreen,
      );
      item.removeFromParent();
    } else if (item is PowerUpComponent) {
      if (item.powerUpType == PowerUpType.shield) {
        player.setShielded(true);
      } else {
        _boostActive = true;
        _boostTimer = 5.0;
      }
      _burstParticles(item.position, Colors.cyanAccent);
      item.removeFromParent();
    }
  }

  void _burstParticles(Vector2 origin, Color color) {
    final particleComponent = ParticleSystemComponent(
      position: origin.clone(),
      particle: Particle.generate(
        count: 10,
        lifespan: 0.5,
        generator: (i) {
          final angle = _random.nextDouble() * pi * 2;
          final speed = 60 + _random.nextDouble() * 60;
          return AcceleratedParticle(
            speed: Vector2(cos(angle), sin(angle)) * speed,
            acceleration: Vector2(0, 140),
            child: CircleParticle(
              radius: 3,
              paint: Paint()..color = color,
            ),
          );
        },
      ),
    );
    add(particleComponent);
  }

  void _updateShake(double dt) {
    if (_shakeTime > 0) {
      _shakeTime -= dt;
      // NOTE: num.clamp() returns num, not double — always follow it
      // with .toDouble() when the result feeds a double-typed field.
      // This is the exact bug class that broke the previous attempt.
      final falloff = (_shakeTime / 0.35).clamp(0.0, 1.0).toDouble();
      final dx = (_random.nextDouble() * 2 - 1) * _shakeIntensity * falloff;
      final dy = (_random.nextDouble() * 2 - 1) * _shakeIntensity * falloff;
      _worldOffset = Vector2(dx, dy);
      camera.viewfinder.position = _worldOffset;
    } else if (_worldOffset != Vector2.zero()) {
      _worldOffset = Vector2.zero();
      camera.viewfinder.position = Vector2.zero();
    }
  }

  void _triggerShake() {
    _shakeTime = 0.35;
    _shakeIntensity = 10;
  }

  Future<void> _endGame() async {
    state = RunnerGameState.gameOver;
    _triggerShake();
    final wasNewBest = score > best;
    await _service.saveScoreIfBest(score);
    best = await _service.getBestScore();
    hud.best = best;
    pauseEngine();
    onGameOver(score, wasNewBest);
  }
}
