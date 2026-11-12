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
              padding: EdgeInsets.fromLTRB(pad, 8, pad, 28),
              children: [
                _HomeHeader(
                  onHistoryTap: () => context.push(AppRoutes.history),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan options',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick one method to check your crop.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 8),
                InputOptionCard(
                  title: 'Camera',
                  subtitle: 'Take a clear photo of the leaf',
                  icon: CupertinoIcons.camera,
                  accentColor: AppColors.moss,
                  onTap: () => context.push(AppRoutes.camera),
                ),
                InputOptionCard(
                  title: 'Gallery',
                  subtitle: 'Upload a photo you already have',
                  icon: CupertinoIcons.photo,
                  accentColor: AppColors.soil,
                  onTap: () => context.push(AppRoutes.imageUpload),
                ),
                InputOptionCard(
                  title: 'Text',
                  subtitle: 'Describe the symptoms in words',
                  icon: CupertinoIcons.pencil,
                  accentColor: AppColors.stone,
                  onTap: () => context.push(AppRoutes.textInput),
                ),
                InputOptionCard(
                  title: 'Voice',
                  subtitle: 'Speak the symptoms hands free',
                  icon: CupertinoIcons.mic,
                  accentColor: AppColors.clay,
                  onTap: () => context.push(AppRoutes.voiceInput),
                ),
                const SizedBox(height: 20),
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crop Shield AI',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
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
        const SizedBox(height: 18),
        Text(
          'Crop disease detection',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                height: 1.25,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Use camera, gallery, text, or voice to get a diagnosis.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
      ],
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          CupertinoIcons.info,
          color: AppColors.stone,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Use clear and well lit leaf photos for better results.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
          ),
        ),
      ],
    );
  }
}
