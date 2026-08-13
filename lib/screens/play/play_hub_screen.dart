import 'package:crop_shield_ai/game/field_game_screen.dart';
import 'package:crop_shield_ai/runner_game/runner_game_screen.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/theme/app_spacing.dart';
import 'package:crop_shield_ai/widgets/feature_row.dart';
import 'package:flutter/material.dart';

class PlayHubScreen extends StatelessWidget {
  const PlayHubScreen({super.key});

  void _pushRoot(BuildContext context, Widget screen) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            12,
            AppSpacing.pageH,
            24,
          ),
          children: [
            Text(
              'Play & Learn',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Fun mini-games that teach real farming decisions.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 20),
            FeatureRow(
              title: 'Play: My Field',
              subtitle:
                  'Manage a virtual field for 8 weeks — grow, spray, survive!',
              icon: Icons.videogame_asset_rounded,
              color: AppColors.moss,
              onTap: () => _pushRoot(context, const FieldGameScreen()),
            ),
            const SizedBox(height: 10),
            FeatureRow(
              title: 'Play: Field Runner',
              subtitle: 'Dodge pests, collect leaves — how far can you run?',
              icon: Icons.directions_run_rounded,
              color: AppColors.clay,
              onTap: () => _pushRoot(context, const RunnerGameScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
