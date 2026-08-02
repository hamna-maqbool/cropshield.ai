// feedback_widget.dart
//
// Farmer-friendly feedback card for the Result screen.
// - Big thumbs up / thumbs down buttons, no typing required.
// - If "wrong", the farmer taps the correct disease from a list
//   instead of typing (most farmers won't type comfortably).
// - Shows "already submitted" state if they come back to this scan.

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

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _alreadySubmitted ? _buildThankYou() : _buildAskingCard(),
      ),
    );
  }

  Widget _buildAskingCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Was this diagnosis correct?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (!_showDiseasePicker) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bigChoiceButton(
                icon: Icons.thumb_up_alt_rounded,
                label: 'Yes',
                color: Colors.green,
                onTap: () => _submit(wasCorrect: true),
              ),
              _bigChoiceButton(
                icon: Icons.thumb_down_alt_rounded,
                label: 'No',
                color: Colors.red,
                onTap: () => setState(() => _showDiseasePicker = true),
              ),
            ],
          ),
        ] else ...[
          const Text(
            'What is the correct disease?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
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
                    label: Text(name, style: const TextStyle(fontSize: 14)),
                    backgroundColor: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.orange.shade200),
                    ),
                    onPressed: () =>
                        _submit(wasCorrect: false, correctedDisease: name),
                  );
                },
              ),
              ActionChip(
                label: const Text('Not sure', style: TextStyle(fontSize: 14)),
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
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

  Widget _buildThankYou() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 26),
        SizedBox(width: 10),
        Flexible(
          child: Text(
            'Thanks! Your feedback is saved.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}