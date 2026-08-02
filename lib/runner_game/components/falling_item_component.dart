// falling_item_component.dart
//
// Base class shared by obstacles, collectibles, and power-ups: all three
// are just circles carrying an emoji that scroll from the top of the
// screen toward the player's row, so the shared movement/removal logic
// lives here once instead of being copy-pasted three times.

import 'package:flutter/painting.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../field_runner_game.dart';
import 'player_component.dart';

abstract class FallingItemComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef<FieldRunnerGame> {
  FallingItemComponent({
    required this.lane,
    required double laneX,
    required this.emoji,
    required this.fillColor,
    double radius = 24,
  }) : super(
          position: Vector2(laneX, -radius * 2),
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
          priority: 5,
        );

  final int lane;
  final String emoji;
  final Color fillColor;

  bool consumed = false;

  /// Set by the game every frame; units are game-y per second.
  double fallSpeed = 0;

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox(radius: size.x / 2 - 2)..anchor = Anchor.center);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += fallSpeed * dt;

    // Once well past the player's row, remove — cleanup happens here so
    // the game loop never has to scan a growing list by hand.
    if (position.y > gameRef.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      gameRef.resolveHit(this);
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2 - 2;

    final shadowPaint = Paint()..color = const Color(0x22000000);
    canvas.drawCircle(center + const Offset(0, 3), radius, shadowPaint);

    final bodyPaint = Paint()..color = fillColor;
    canvas.drawCircle(center, radius, bodyPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, borderPaint);

    final tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 22)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}
