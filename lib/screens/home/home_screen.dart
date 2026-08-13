import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/theme/app_spacing.dart';
import 'package:crop_shield_ai/widgets/input_option_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// NOTE: Risk Forecast feature (weather-based disease risk) is not built
// yet. Its import and widget call have been removed for now so the app
// compiles. When that feature is ready, re-add:
//   import 'package:crop_shield_ai/risk_forecast/risk_alert_card.dart';
// and the crop toggle + RiskAlertCard block that used to sit here.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gridExtent = width > 400 ? 168.0 : 156.0;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                onHistoryTap: () => context.push(AppRoutes.history),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                8,
                AppSpacing.pageH,
                16,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: gridExtent + 40,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.92,
                ),
                delegate: SliverChildListDelegate([
                  InputOptionCard(
                    title: 'Camera',
                    subtitle: 'Snap a leaf photo for instant analysis',
                    icon: Icons.photo_camera_rounded,
                    accentColor: AppColors.moss,
                    onTap: () => context.push(AppRoutes.camera),
                  ),
                  InputOptionCard(
                    title: 'Image Upload',
                    subtitle: 'Pick from gallery if you already have a photo',
                    icon: Icons.photo_library_rounded,
                    accentColor: AppColors.soil,
                    onTap: () => context.push(AppRoutes.imageUpload),
                  ),
                  InputOptionCard(
                    title: 'Text Input',
                    subtitle: 'Describe symptoms in your own words',
                    icon: Icons.edit_note_rounded,
                    accentColor: AppColors.stone,
                    onTap: () => context.push(AppRoutes.textInput),
                  ),
                  InputOptionCard(
                    title: 'Voice Input',
                    subtitle: 'Speak symptoms hands-free in the field',
                    icon: Icons.mic_rounded,
                    accentColor: AppColors.clay,
                    onTap: () => context.push(AppRoutes.voiceInput),
                  ),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: _HomeFooter()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onHistoryTap});

  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        12,
        AppSpacing.pageH,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.moss,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crop Shield AI',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Final Year Project',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onHistoryTap,
                icon: const Icon(Icons.history_rounded, size: 22),
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.moss,
                ),
                tooltip: 'Scan history',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI-Powered Detection',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.leaf,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Protect your harvest with smart diagnosis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        height: 1.25,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose how you want to scan — camera, gallery, text, or voice.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'How would you like to scan?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'All methods lead to disease detection and advisory guidance.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.stone,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'For best results, capture clear, well-lit photos of affected leaves.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
