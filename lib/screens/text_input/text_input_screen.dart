import 'package:crop_shield_ai/models/input_method.dart';
import 'package:crop_shield_ai/models/scan_result.dart';
import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/services/symptom_matcher_service.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TextInputScreen extends StatefulWidget {
  const TextInputScreen({super.key});

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyzeSymptoms() async {
    if (!_hasText) return;

    setState(() => _isAnalyzing = true);

    try {
      // Small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 800));

      final prediction = SymptomMatcherService.analyzeSymptoms(
        _controller.text.trim(),
      );

      if (!mounted) return;

      final result = ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inputMethod: InputMethod.text,
        diseaseName: prediction['disease'] as String,
        confidence: prediction['confidence'] as double,
        scannedAt: DateTime.now(),
        queryText: _controller.text.trim(),
        summary: prediction['summary'] as String,
      );

      context.push(AppRoutes.result, extra: result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis failed. Please try again.'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Text Input',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe your crop symptoms',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Type what you observe — yellowing, spots, wilting, or any other visible signs.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            // Hint chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'brown spots',
                'yellow leaves',
                'white powder',
                'curling leaves',
                'black spots',
                'wilting',
              ].map((hint) => GestureDetector(
                onTap: () {
                  final current = _controller.text;
                  _controller.text = current.isEmpty
                      ? hint
                      : '$current, $hint';
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.leaf.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.sage.withOpacity(0.4)),
                  ),
                  child: Text(
                    '+ $hint',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.moss,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.parchment, width: 1.5),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 7,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText:
                      'e.g. Leaves have brown spots with yellow edges, plant looks wilted...',
                  hintStyle:
                      TextStyle(color: AppColors.textMuted, fontSize: 14),
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_controller.text.trim().split(' ').where((w) => w.isNotEmpty).length} words',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_hasText && !_isAnalyzing)
                    ? _analyzeSymptoms
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  disabledBackgroundColor: AppColors.parchment,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isAnalyzing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Analyze Symptoms',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}