import 'dart:io';
import 'package:crop_shield_ai/feedback/feedback_widget.dart';
import 'package:crop_shield_ai/models/scan_result.dart';
import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';



class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (result.confidence * 100).round();
    final formattedDate =
        DateFormat('d MMM yyyy, HH:mm').format(result.scannedAt);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detection Result'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultHero(
                diseaseName: result.diseaseName,
                confidencePercent: confidencePercent,
                inputLabel: result.inputMethod.label,
              ),
              if (result.imagePath != null) ...[
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(
                    File(result.imagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Analysis summary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                result.summary ??
                    'No additional details available for this scan.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _MetaRow(
                icon: Icons.schedule_rounded,
                label: 'Scanned',
                value: formattedDate,
              ),
              const SizedBox(height: 10),
              _MetaRow(
                icon: Icons.input_rounded,
                label: 'Input method',
                value: result.inputMethod.label,
              ),

              // Feedback asks if the diagnosis looked correct.
              const SizedBox(height: 12),
              FeedbackWidget(
                scanId: result.scannedAt.millisecondsSinceEpoch.toString(),
                predictedDisease: result.diseaseName,
                confidence: result.confidence,
                inputMethod: result.inputMethod.label,
                allDiseaseNames: const [
                  'Cotton Army Worm',
                  'Cotton Bacterial Blight',
                  'Cotton Curl Virus',
                  'Cotton Healthy',
                  'Cotton Powdery Mildew',
                  'Cotton Target Spot',
                  'Rice Bacterial Blight',
                  'Rice Blast',
                  'Rice Brown Spot',
                  'Rice Healthy',
                  'Rice Leaf Smut',
                  'Rice Tungro',
                ],
              ),

              const SizedBox(height: 20),
              PrimaryButton(
                label: 'View Advisory',
                icon: Icons.medical_services_outlined,
                onPressed: () =>
                    context.push(AppRoutes.advisory, extra: result),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Fertilizer Guide',
                icon: Icons.grass_rounded,
                backgroundColor: AppColors.leaf,
                foregroundColor: AppColors.forest,
                onPressed: () => context.push(
                  AppRoutes.fertilizer,
                  extra: result.diseaseName,
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Back to Home',
                icon: Icons.home_rounded,
                backgroundColor: AppColors.parchment,
                foregroundColor: AppColors.moss,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({
    required this.diseaseName,
    required this.confidencePercent,
    required this.inputLabel,
  });

  final String diseaseName;
  final int confidencePercent;
  final String inputLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.parchment),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detected condition',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.moss,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            diseaseName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _StatChip(
                label: '$confidencePercent% confidence',
                icon: Icons.verified_outlined,
              ),
              _StatChip(
                label: inputLabel,
                icon: Icons.layers_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.moss),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.stone),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}