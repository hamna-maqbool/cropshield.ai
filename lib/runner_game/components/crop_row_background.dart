// crop_row_background.dart
//
// Procedural parallax background: three layers of "crop rows" scrolling
// toward the camera at different speeds, giving depth without needing
// any image/sprite assets. Each layer is one component so the parallax
// ratio is trivial to tune per layer.

import 'dart:ui';
import 'package:flame/components.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';

class CropRowLayer extends PositionComponent with HasGameRef {
  CropRowLayer({
    required this.rowSpacing,
    required this.parallaxFactor,
    required this.rowColor,
    required this.rowThickness,
    this.opacity = 1.0,
  }) : super(priority: -10);

  /// Vertical distance between successive rows, in game units.
  final double rowSpacing;

  /// Multiplier applied to the game's base scroll speed. Layers further
  /// "back" should use a smaller factor so they appear to move slower.
  final double parallaxFactor;

  final Color rowColor;
  final double rowThickness;
  final double opacity;

  double _scrollOffset = 0;

  /// Set externally each frame by the parent game based on current speed.
  double scrollSpeed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _scrollOffset += scrollSpeed * parallaxFactor * dt;
    _scrollOffset %= rowSpacing;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = rowColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final width = gameRef.size.x;
    final height = gameRef.size.y;

    // Draw rows from just above the top down past the bottom so the
    // scroll wrap never shows a gap.
    var y = -rowSpacing + _scrollOffset;
    while (y < height + rowSpacing) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, width, rowThickness),
        paint,
      );
      y += rowSpacing;
    }
  }
}

/// Convenience wrapper that owns three [CropRowLayer]s (far / mid / near)
/// so the game only has to manage a single background component.
class CropFieldParallax extends PositionComponent with HasGameRef {
  CropFieldParallax() : super(priority: -10);

  late final CropRowLayer far;
  late final CropRowLayer mid;
  late final CropRowLayer near;

  @override
  Future<void> onLoad() async {
    far = CropRowLayer(
      rowSpacing: 140,
      parallaxFactor: 0.35,
      rowColor: AppColors.forest,
      rowThickness: 10,
      opacity: 0.35,
    );
    mid = CropRowLayer(
      rowSpacing: 90,
      parallaxFactor: 0.65,
      rowColor: AppColors.moss,
      rowThickness: 14,
      opacity: 0.45,
    );
    near = CropRowLayer(
      rowSpacing: 60,
      parallaxFactor: 1.0,
      rowColor: AppColors.leaf,
      rowThickness: 8,
      opacity: 0.30,
    );
    await addAll([far, mid, near]);
  }

  /// Called every frame by [FieldRunnerGame] with the current scroll
  /// speed in game-units/second.
  void setScrollSpeed(double speed) {
    far.scrollSpeed = speed;
    mid.scrollSpeed = speed;
    near.scrollSpeed = speed;
  }
}
