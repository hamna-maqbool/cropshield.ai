import 'package:crop_shield_ai/models/input_method.dart';
import 'package:crop_shield_ai/models/scan_result.dart';
import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/services/symptom_matcher_service.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/theme/app_spacing.dart';
import 'package:crop_shield_ai/widgets/primary_button.dart';
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Text Input'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            8,
            AppSpacing.pageH,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Describe your crop symptoms',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Type what you observe — yellowing, spots, wilting, or any other visible signs.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 16),
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
                ].map((hint) {
                  return ActionChip(
                    label: Text('+ $hint'),
                    onPressed: () {
                      final current = _controller.text;
                      _controller.text = current.isEmpty ? hint : '$current, $hint';
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                  decoration: const InputDecoration(
                    hintText:
                        'e.g. Leaves have brown spots with yellow edges, plant looks wilted...',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_controller.text.trim().split(' ').where((w) => w.isNotEmpty).length} words',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Analyze Symptoms',
                icon: Icons.biotech_rounded,
                isLoading: _isAnalyzing,
                onPressed: (_hasText && !_isAnalyzing) ? _analyzeSymptoms : null,
                backgroundColor: AppColors.forest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
