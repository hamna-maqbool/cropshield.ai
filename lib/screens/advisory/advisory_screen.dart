import 'package:crop_shield_ai/models/scan_result.dart';
import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

String getCropFromDiseaseClass(String diseaseClass) {
  final lower = diseaseClass.toLowerCase();
  if (lower.startsWith('cotton')) return 'Cotton';
  if (lower.startsWith('rice')) return 'Rice';
  return 'Cotton';
}

class AdvisoryScreen extends StatelessWidget {
  const AdvisoryScreen({super.key, required this.result});

  final ScanResult result;

  // Static advisory data per disease — replace with real data later
  static const Map<String, Map<String, dynamic>> _advisoryData = {
    'default': {
      'severity': 'Moderate',
      'severityColor': 0xFFE9C46A,
      'cause': 'Fungal or bacterial infection detected on the crop.',
      'treatment': [
        'Remove and destroy all infected plant parts immediately.',
        'Apply appropriate fungicide or bactericide as recommended.',
        'Avoid overhead irrigation to reduce moisture on leaves.',
        'Ensure proper spacing between plants for air circulation.',
      ],
      'prevention': [
        'Use disease-resistant seed varieties when available.',
        'Practice crop rotation every season.',
        'Monitor crops regularly for early signs of disease.',
        'Maintain proper soil drainage and avoid waterlogging.',
      ],
      'recovery': '2–4 weeks with proper treatment and care.',
    },
  };

  Map<String, dynamic> get _advisory {
    final key = result.diseaseName.toLowerCase();
    return _advisoryData[key] ?? _advisoryData['default']!;
  }

  @override
  Widget build(BuildContext context) {
    final advisory = _advisory;
    final severity = advisory['severity'] as String;
    final severityColor = Color(advisory['severityColor'] as int);
    final cause = advisory['cause'] as String;
    final treatment = advisory['treatment'] as List<String>;
    final prevention = advisory['prevention'] as List<String>;
    final recovery = advisory['recovery'] as String;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Advisory',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.forest, AppColors.moss],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advisory for',
                    style: TextStyle(
                      color: AppColors.leaf,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.diseaseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 14, color: severityColor),
                            const SizedBox(width: 4),
                            Text(
                              '$severity severity',
                              style: TextStyle(
                                color: severityColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_rounded,
                                size: 14, color: AppColors.leaf),
                            const SizedBox(width: 4),
                            Text(
                              'Recovery: $recovery',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cause
            _SectionCard(
              icon: Icons.science_outlined,
              title: 'Probable Cause',
              color: AppColors.clay,
              child: Text(
                cause,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Treatment
            _SectionCard(
              icon: Icons.medical_services_outlined,
              title: 'Treatment Steps',
              color: AppColors.danger,
              child: Column(
                children: treatment
                    .asMap()
                    .entries
                    .map((e) => _StepRow(
                          number: e.key + 1,
                          text: e.value,
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Prevention
            _SectionCard(
              icon: Icons.shield_outlined,
              title: 'Prevention Tips',
              color: AppColors.success,
              child: Column(
                children: prevention
                    .map((tip) => _BulletRow(text: tip))
                    .toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Fertilizer guide button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push(
                  AppRoutes.fertilizer,
                  extra: getCropFromDiseaseClass(result.diseaseName),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.moss,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Fertilizer Guide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Pesticide calculator button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push(
                  AppRoutes.pesticide,
                  extra: getCropFromDiseaseClass(result.diseaseName),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.clay,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Pesticide Calculator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Back to home button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.parchment, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}