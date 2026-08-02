// player_component.dart
//
// The farmer. Handles lane-change animation, jump/duck states (which
// obstacles actually check against), a running idle bounce, and a
// shield ring drawn when a power-up is active.

import 'dart:math';
import 'package:flutter/painting.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;
import 'package:crop_shield_ai/theme/app_colors.dart';

class PlayerComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef {
  PlayerComponent({required this.laneXPositions, required this.playerY})
      : super(
          size: Vector2(56, 56),
          anchor: Anchor.center,
          priority: 10,
        );

  List<double> laneXPositions;
  final double playerY;

  int lane = 1;
  bool isJumping = false;
  bool isDucking = false;
  bool isShielded = false;

  double _bounceTime = 0;
  double _jumpTimer = 0;
  double _duckTimer = 0;
  static const double _jumpDuration = 0.55;
  static const double _duckDuration = 0.55;

  late final CircleHitbox hitbox;
  late final _ShieldRing _shieldRing;

  @override
  Future<void> onLoad() async {
    position = Vector2(laneXPositions[lane], playerY);

    hitbox = CircleHitbox(radius: 22)..anchor = Anchor.center;
    await add(hitbox);

    _shieldRing = _ShieldRing(
      position: Vector2(size.x / 2, size.y / 2),
    )..opacity = 0;
    await add(_shieldRing);
  }

  void reset() {
    lane = 1;
    isJumping = false;
    isDucking = false;
    isShielded = false;
    _jumpTimer = 0;
    _duckTimer = 0;
    _bounceTime = 0;
    position = Vector2(laneXPositions[lane], playerY);
    scale = Vector2.all(1);
    _shieldRing.opacity = 0;
  }

  void setShielded(bool value) {
    isShielded = value;
    _shieldRing.opacity = value ? 1 : 0;
  }

  void moveToLane(int newLane) {
    // int.clamp() returns num, not int — clamp manually to keep `lane`
    // strictly typed as int (see field_runner_game.dart for the same
    // gotcha with doubles).
    final maxLane = laneXPositions.length - 1;
    lane = newLane < 0 ? 0 : (newLane > maxLane ? maxLane : newLane);
    add(
      MoveToEffect(
        Vector2(laneXPositions[lane], playerY),
        EffectController(duration: 0.16, curve: Curves.easeOut),
      ),
    );
  }

  void jump() {
    if (isDucking || isJumping) return;
    isJumping = true;
    _jumpTimer = _jumpDuration;
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.18),
          EffectController(duration: 0.18, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.28, curve: Curves.easeIn),
        ),
      ]),
    );
  }

  void duck() {
    if (isJumping || isDucking) return;
    isDucking = true;
    _duckTimer = _duckDuration;
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2(1.1, 0.65),
          EffectController(duration: 0.14, curve: Curves.easeOut),
        ),
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: 0.34, curve: Curves.easeIn),
        ),
      ]),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isJumping) {
      _jumpTimer -= dt;
      if (_jumpTimer <= 0) isJumping = false;
    }
    if (isDucking) {
      _duckTimer -= dt;
      if (_duckTimer <= 0) isDucking = false;
    }

    // Subtle running bounce so the character never looks static, even
    // when standing still in a lane.
    _bounceTime += dt * 9;
  }

  @override
  void render(Canvas canvas) {
    final bounceLift = isJumping ? 6.0 : (sin(_bounceTime) * 2);
    final center = Offset(size.x / 2, size.y / 2 - bounceLift);
    final radius = size.x / 2 - 2;

    // Ground shadow, stays fixed while body bounces above it.
    final shadowPaint = Paint()..color = const Color(0x33000000);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 4),
        width: radius * 1.4,
        height: 8,
      ),
      shadowPaint,
    );

    final bodyPaint = Paint()..color = AppColors.leaf;
    canvas.drawCircle(center, radius, bodyPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: '👨\u200d🌾',
        style: TextStyle(fontSize: 26),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}

/// Pulsing ring drawn around the player while a shield power-up is active.
class _ShieldRing extends PositionComponent {
  _ShieldRing({required Vector2 position})
      : super(size: Vector2(70, 70), anchor: Anchor.center, position: position);

  double opacity = 0;
  double _pulse = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 4;
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0) return;
    final wave = (sin(_pulse) + 1) / 2; // 0..1
    final pulseScale = 1.0 + 0.06 * wave;
    final paint = Paint()
      ..color = AppColors.leaf.withValues(alpha: 0.55 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      (size.x / 2) * pulseScale,
      paint,
    );
  }
}
