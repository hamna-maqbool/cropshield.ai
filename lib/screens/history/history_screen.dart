import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Sample history data — replace with real local storage later
  static const List<Map<String, dynamic>> _sampleHistory = [
    {
      'disease': 'Early Blight',
      'confidence': 92,
      'method': 'Camera',
      'date': '5 Jul 2026',
      'icon': Icons.camera_alt_rounded,
      'color': 0xFFC1121F,
    },
    {
      'disease': 'Leaf Spot',
      'confidence': 87,
      'method': 'Image Upload',
      'date': '4 Jul 2026',
      'icon': Icons.image_rounded,
      'color': 0xFF8B6914,
    },
    {
      'disease': 'Powdery Mildew',
      'confidence': 78,
      'method': 'Text Input',
      'date': '3 Jul 2026',
      'icon': Icons.text_fields_rounded,
      'color': 0xFF2D6A4F,
    },
    {
      'disease': 'Healthy Crop',
      'confidence': 95,
      'method': 'Camera',
      'date': '2 Jul 2026',
      'icon': Icons.camera_alt_rounded,
      'color': 0xFF40916C,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear history — coming soon.'),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Past scans',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${_sampleHistory.length} detections recorded',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _sampleHistory.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _sampleHistory[index];
                  return _HistoryCard(
                    disease: item['disease'] as String,
                    confidence: item['confidence'] as int,
                    method: item['method'] as String,
                    date: item['date'] as String,
                    icon: item['icon'] as IconData,
                    color: Color(item['color'] as int),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.disease,
    required this.confidence,
    required this.method,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String disease;
  final int confidence;
  final String method;
  final String date;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.parchment),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disease,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      method,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '$confidence%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.forest,
                ),
          ),
        ],
      ),
    );
  }
}