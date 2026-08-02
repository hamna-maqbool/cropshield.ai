// hud_component.dart
//
// Score / best / combo readout drawn directly by Flame (as opposed to a
// Flutter overlay), so it updates every frame with zero widget rebuild
// cost. Positioned with a HudMarginComponent-style manual offset so it
// stays pinned to the top of the screen regardless of camera movement.

import 'package:flutter/painting.dart';
import 'package:flame/components.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';

class HudComponent extends PositionComponent with HasGameRef {
  HudComponent() : super(priority: 100);

  int score = 0;
  int best = 0;
  int combo = 0;

  @override
  void render(Canvas canvas) {
    _drawChip(canvas, offsetX: 16, label: 'Score', value: '$score');
    _drawChip(
      canvas,
      offsetX: gameRef.size.x - 132,
      label: 'Best',
      value: '$best',
    );
    if (combo >= 2) {
      _drawComboBadge(canvas);
    }
  }

  void _drawChip(
    Canvas canvas, {
    required double offsetX,
    required String label,
    required String value,
  }) {
    const width = 116.0;
    const height = 36.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offsetX, 12, width, height),
      const Radius.circular(18),
    );
    final bgPaint = Paint()..color = const Color(0x4D000000);
    canvas.drawRRect(rect, bgPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: '$label: $value',
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 12);
    tp.paint(canvas, Offset(offsetX + 12, 12 + (height - tp.height) / 2));
  }

  void _drawComboBadge(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'Combo x$combo',
        style: const TextStyle(
          color: AppColors.leaf,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (gameRef.size.x - tp.width) / 2;
    tp.paint(canvas, Offset(x, 58));
  }
}
