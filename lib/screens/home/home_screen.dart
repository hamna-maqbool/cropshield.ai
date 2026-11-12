import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/theme/app_spacing.dart';
import 'package:crop_shield_ai/widgets/input_option_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Risk Forecast is not ready yet, so that block is left out for now.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final pad = AppSpacing.pagePadding(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth(context),
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad, 10, pad, 28),
              children: [
                _HomeHeader(
                  onHistoryTap: () => context.push(AppRoutes.history),
                ),
                const SizedBox(height: 28),
                Text(
                  'Start a scan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose how you want to check your crop health.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 18),
                InputOptionCard(
                  title: 'Camera',
                  subtitle: 'Take a clear photo of the leaf',
                  icon: CupertinoIcons.camera,
                  accentColor: AppColors.moss,
                  emphasized: true,
                  onTap: () => context.push(AppRoutes.camera),
                ),
                const SizedBox(height: 10),
                InputOptionCard(
                  title: 'Gallery',
                  subtitle: 'Upload a photo you already have',
                  icon: CupertinoIcons.photo,
                  accentColor: AppColors.moss,
                  onTap: () => context.push(AppRoutes.imageUpload),
                ),
                const SizedBox(height: 10),
                InputOptionCard(
                  title: 'Text',
                  subtitle: 'Describe the symptoms in words',
                  icon: CupertinoIcons.pencil,
                  accentColor: AppColors.moss,
                  onTap: () => context.push(AppRoutes.textInput),
                ),
                const SizedBox(height: 10),
                InputOptionCard(
                  title: 'Voice',
                  subtitle: 'Speak the symptoms hands free',
                  icon: CupertinoIcons.mic,
                  accentColor: AppColors.moss,
                  onTap: () => context.push(AppRoutes.voiceInput),
                ),
                const SizedBox(height: 28),
                const _HomeFooter(),
              ],
            ),
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.moss,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Icon(
                CupertinoIcons.leaf_arrow_circlepath,
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Final Year Project',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onHistoryTap,
              icon: const Icon(CupertinoIcons.clock, size: 22),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.moss,
              ),
              tooltip: 'Scan history',
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Protect your harvest',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Detect crop disease fast with photo, text, or voice.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textMuted,
                fontSize: 15,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.parchment),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.info,
            color: AppColors.moss,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Clear and well lit leaf photos give the best results.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
