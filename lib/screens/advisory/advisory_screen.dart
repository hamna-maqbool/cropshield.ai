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

  // Static advisory text for now. Can swap in real data later.
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
      'recovery': '2 to 4 weeks with proper treatment and care.',
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Advisory'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                    'Advisory for',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.moss,
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.diseaseName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 14, color: AppColors.moss),
                          const SizedBox(width: 4),
                          Text(
                            'Recovery: $recovery',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(
                  AppRoutes.fertilizer,
                  extra: getCropFromDiseaseClass(result.diseaseName),
                ),
                child: const Text('Fertilizer Guide'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(
                  AppRoutes.pesticide,
                  extra: getCropFromDiseaseClass(result.diseaseName),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.clay,
                ),
                child: const Text('Pesticide Calculator'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forest,
                ),
                child: const Text('Back to Home'),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          SizedBox(
            width: 24,
            child: Text(
              '$number.',
              style: const TextStyle(
                color: AppColors.forest,
                fontSize: 13,
                fontWeight: FontWeight.w700,
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