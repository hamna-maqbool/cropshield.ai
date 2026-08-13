import 'package:crop_shield_ai/models/input_method.dart';
import 'package:crop_shield_ai/models/scan_result.dart';
import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/services/symptom_matcher_service.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/theme/app_spacing.dart';
import 'package:crop_shield_ai/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isAnalyzing = false;
  bool _speechAvailable = false;
  String _recognizedText = '';
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.stop();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speechToText.initialize(
      onError: (error) {
        setState(() => _isListening = false);
        _animController.stop();
        _animController.reset();
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _animController.stop();
      _animController.reset();
      setState(() => _isListening = false);
    } else {
      if (!_speechAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available on this device.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      setState(() {
        _isListening = true;
        _recognizedText = '';
      });
      _animController.repeat(reverse: true);
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        localeId: 'en_US',
      );
    }
  }

  Future<void> _analyzeSymptoms() async {
    if (_recognizedText.isEmpty) return;

    setState(() => _isAnalyzing = true);

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final prediction = SymptomMatcherService.analyzeSymptoms(
        _recognizedText,
      );

      if (!mounted) return;

      final result = ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inputMethod: InputMethod.voice,
        diseaseName: prediction['disease'] as String,
        confidence: prediction['confidence'] as double,
        scannedAt: DateTime.now(),
        queryText: _recognizedText,
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

  void _clearText() {
    setState(() => _recognizedText = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Voice Input'),
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
            children: [
              Text(
                'Speak your crop symptoms',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the microphone and describe what you observe on your crop.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _isListening
                    ? _scaleAnim
                    : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: _isListening ? AppColors.danger : AppColors.forest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isListening
                    ? 'Listening... tap to stop'
                    : _speechAvailable
                        ? 'Tap to speak'
                        : 'Speech not available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _isListening
                          ? AppColors.danger
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 28),
              if (_recognizedText.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.parchment),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recognized text',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                          ),
                          GestureDetector(
                            onTap: _clearText,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _recognizedText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Spacer(),
              PrimaryButton(
                label: 'Analyze Symptoms',
                icon: Icons.biotech_rounded,
                isLoading: _isAnalyzing,
                onPressed: (_recognizedText.isNotEmpty && !_isAnalyzing)
                    ? _analyzeSymptoms
                    : null,
                backgroundColor: AppColors.forest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
