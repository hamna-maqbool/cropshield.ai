// game_items.dart
//
// Concrete falling items: pests (obstacles), leaves (collectibles), and
// power-ups. Each only needs to define appearance + which category it
// belongs to — the shared fall/cleanup/render logic lives in
// FallingItemComponent.

import 'package:crop_shield_ai/theme/app_colors.dart';
import '../models/runner_enums.dart';
import 'falling_item_component.dart';

class PestObstacleComponent extends FallingItemComponent {
  PestObstacleComponent({
    required super.lane,
    required double laneX,
    required this.pestType,
    String? emojiOverride,
  }) : super(
          laneX: laneX,
          emoji: emojiOverride ?? (pestType == PestType.ground ? '🐛' : '🦅'),
          fillColor: AppColors.clay,
        );

  final PestType pestType;
}

class LeafCollectibleComponent extends FallingItemComponent {
  LeafCollectibleComponent({
    required super.lane,
    required double laneX,
    this.isGolden = false,
  }) : super(
          laneX: laneX,
          emoji: isGolden ? '🍀' : '🌿',
          fillColor: isGolden ? AppColors.parchment : AppColors.leaf,
          radius: isGolden ? 22 : 20,
        );

  final bool isGolden;
}

class PowerUpComponent extends FallingItemComponent {
  PowerUpComponent({
    required super.lane,
    required double laneX,
    required this.powerUpType,
  }) : super(
          laneX: laneX,
          emoji: powerUpType == PowerUpType.shield ? '🛡️' : '🧪',
          fillColor: powerUpType == PowerUpType.shield
              ? AppColors.stone
              : AppColors.forest,
          radius: 22,
        );

  final PowerUpType powerUpType;
}
