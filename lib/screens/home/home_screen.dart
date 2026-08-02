import 'package:crop_shield_ai/features/fuel_log/screens/fuel_log_screen.dart';
import 'package:crop_shield_ai/features/udhaar_tracker/screens/udhaar_screen.dart';
import 'package:crop_shield_ai/game/field_game_screen.dart';
import 'package:crop_shield_ai/runner_game/runner_game_screen.dart';
import 'package:crop_shield_ai/features/yield_predictor/yield_predictor_screen.dart';
import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/screens/forum_screen.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
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
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: _HomeHeader(
                    onHistoryTap: () =>
                        context.push(AppRoutes.history))),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildListDelegate([
                  InputOptionCard(
                    title: 'Camera',
                    subtitle:
                        'Snap a leaf photo for instant analysis',
                    icon: Icons.photo_camera_rounded,
                    accentColor: AppColors.moss,
                    onTap: () => context.push(AppRoutes.camera),
                  ),
                  InputOptionCard(
                    title: 'Image Upload',
                    subtitle:
                        'Pick from gallery if you already have a photo',
                    icon: Icons.photo_library_rounded,
                    accentColor: AppColors.soil,
                    onTap: () =>
                        context.push(AppRoutes.imageUpload),
                  ),
                  InputOptionCard(
                    title: 'Text Input',
                    subtitle: 'Describe symptoms in your own words',
                    icon: Icons.edit_note_rounded,
                    accentColor: AppColors.stone,
                    onTap: () =>
                        context.push(AppRoutes.textInput),
                  ),
                  InputOptionCard(
                    title: 'Voice Input',
                    subtitle:
                        'Speak symptoms hands-free in the field',
                    icon: Icons.mic_rounded,
                    accentColor: AppColors.clay,
                    onTap: () =>
                        context.push(AppRoutes.voiceInput),
                  ),
                ]),
              ),
            ),

            // Tools Section
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farming Tools',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Guides and calculators for better crop management.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(height: 14),
                    _ToolCard(
                      title: 'Fertilizer & Nutrition Guide',
                      subtitle:
                          'Get کھاد recommendations by crop and growth stage',
                      icon: Icons.grass_rounded,
                      color: AppColors.moss,
                      emoji: '🌱',
                      onTap: () =>
                          context.push(AppRoutes.fertilizer),
                    ),
                    const SizedBox(height: 12),
                    _ToolCard(
                      title: 'Pesticide Calculator',
                      subtitle:
                          'Get کیڑے مار دوا dose, tank-mix, and safe harvest date',
                      icon: Icons.science_rounded,
                      color: AppColors.clay,
                      emoji: '🧪',
                      onTap: () =>
                          context.push(AppRoutes.pesticide),
                    ),
                    const SizedBox(height: 12),
                    _ToolCard(
                      title: 'Yield & Profit Predictor',
                      subtitle:
                          'Get متوقع پیداوار and profit estimate for your field',
                      icon: Icons.agriculture_rounded,
                      color: AppColors.forest,
                      emoji: '🌾',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const YieldPredictorScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ToolCard(
                      title: 'Tractor Fuel Log',
                      subtitle: 'Track ڈیزل fill-ups and cost per field',
                      icon: Icons.local_gas_station_rounded,
                      color: AppColors.soil,
                      emoji: '⛽',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FuelLogScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ToolCard(
                      title: 'Input Credit (Udhaar) Tracker',
                      subtitle:
                          'Track ادھار from dealers and repayments',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.clay,
                      emoji: '📒',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UdhaarScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------------------------------------------------------
            // NEW: Games section — "My Field" simulation and
            // "Field Runner" endless runner. Both are separate, standalone
            // features living in lib/game/ and lib/runner_game/.
            // ---------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Play & Learn',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fun mini-games that teach real farming decisions.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(height: 14),
                    _ToolCard(
                      title: 'Play: My Field',
                      subtitle:
                          'Manage a virtual field for 8 weeks — grow, spray, survive!',
                      icon: Icons.videogame_asset_rounded,
                      color: AppColors.moss,
                      emoji: '🎮',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FieldGameScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ToolCard(
                      title: 'Play: Field Runner',
                      subtitle:
                          'Dodge pests, collect leaves — how far can you run?',
                      icon: Icons.directions_run_rounded,
                      color: AppColors.clay,
                      emoji: '🏃',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RunnerGameScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------------------------------------------------------
            // NEW: Community Forum — farmers post questions, experts
            // reply. Single entry point; create-post and post-detail
            // are handled inside ForumScreen itself.
            // ---------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ask fellow farmers and verified experts for help.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(height: 14),
                    _ToolCard(
                      title: 'Community Forum',
                      subtitle:
                          'Post a question with a photo — get expert advice',
                      icon: Icons.forum_rounded,
                      color: AppColors.forest,
                      emoji: '👨‍🌾',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForumScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: _HomeFooter()),
            const SliverToBoxAdapter(
                child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.emoji,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: color,
              ),
            ),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.moss, AppColors.forest],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.moss.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crop Shield AI',
                      style:
                          Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Final Year Project',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onHistoryTap,
                icon:
                    const Icon(Icons.history_rounded, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.parchment,
                  foregroundColor: AppColors.moss,
                ),
                tooltip: 'Scan history',
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.forest, AppColors.moss],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color:
                      AppColors.forest.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'AI-Powered Detection',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(
                          color: AppColors.leaf,
                          fontSize: 11,
                        ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Protect your harvest\nwith smart diagnosis',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        color: Colors.white,
                        height: 1.2,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Choose how you want to scan — camera, gallery, text, or voice.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color:
                            Colors.white.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'How would you like to scan?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'All methods lead to disease detection and advisory guidance.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.parchment.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.parchment),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: AppColors.stone, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'For best results, capture clear, well-lit photos of affected leaves.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}