// feedback_widget.dart
//
// Farmer-friendly feedback card for the Result screen.
// - Big thumbs up / thumbs down buttons, no typing required.
// - If "wrong", the farmer taps the correct disease from a list
//   instead of typing (most farmers won't type comfortably).
// - Shows "already submitted" state if they come back to this scan.

import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'feedback_entry.dart';
import 'feedback_service.dart';

class FeedbackWidget extends StatefulWidget {
  final String scanId;
  final String predictedDisease;
  final double confidence;
  final String inputMethod;
  final List<String> allDiseaseNames;

  const FeedbackWidget({
    super.key,
    required this.scanId,
    required this.predictedDisease,
    required this.confidence,
    required this.inputMethod,
    required this.allDiseaseNames,
  });

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  final FeedbackService _service = FeedbackService();

  bool _loading = true;
  bool _alreadySubmitted = false;
  bool _showDiseasePicker = false;

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  Future<void> _checkExisting() async {
    final exists = await _service.hasFeedback(widget.scanId);
    if (!mounted) return;
    setState(() {
      _alreadySubmitted = exists;
      _loading = false;
    });
  }

  Future<void> _submit({required bool wasCorrect, String? correctedDisease}) async {
    final entry = FeedbackEntry(
      scanId: widget.scanId,
      predictedDisease: widget.predictedDisease,
      confidence: widget.confidence,
      inputMethod: widget.inputMethod,
      wasCorrect: wasCorrect,
      correctedDisease: correctedDisease,
    );
    await _service.saveFeedback(entry);
    if (!mounted) return;
    setState(() {
      _alreadySubmitted = true;
      _showDiseasePicker = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _alreadySubmitted ? _buildThankYou(context) : _buildAskingCard(context),
    );
  }

  Widget _buildAskingCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Was this diagnosis correct?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        if (!_showDiseasePicker) ...[
          Row(
            children: [
              Expanded(
                child: _bigChoiceButton(
                  icon: Icons.thumb_up_alt_rounded,
                  label: 'Yes',
                  color: AppColors.success,
                  onTap: () => _submit(wasCorrect: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _bigChoiceButton(
                  icon: Icons.thumb_down_alt_rounded,
                  label: 'No',
                  color: AppColors.danger,
                  onTap: () => setState(() => _showDiseasePicker = true),
                ),
              ),
            ],
          ),
        ] else ...[
          Text(
            'What is the correct disease?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ...widget.allDiseaseNames
                  .where((name) => name != widget.predictedDisease)
                  .map(
                (name) {
                  return ActionChip(
                    label: Text(name),
                    onPressed: () =>
                        _submit(wasCorrect: false, correctedDisease: name),
                  );
                },
              ),
              ActionChip(
                label: const Text('Not sure'),
                onPressed: () => _submit(wasCorrect: false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _showDiseasePicker = false),
            child: const Text('Back'),
          ),
        ],
      ],
    );
  }

  Widget _buildThankYou(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'Thanks! Your feedback is saved.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  Widget _bigChoiceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
