import 'dart:io';

import 'package:crop_shield_ai/models/input_method.dart';
import 'package:crop_shield_ai/models/scan_result.dart';
import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/services/image_picker_service.dart';
import 'package:crop_shield_ai/services/prediction_service.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImageInputScreen extends StatefulWidget {
  const ImageInputScreen({
    super.key,
    required this.title,
    required this.headline,
    required this.description,
    required this.emptyIcon,
    required this.pickLabel,
    required this.pickIcon,
    required this.inputMethod,
    required this.accentColor,
    required this.pickImage,
  });

  final String title;
  final String headline;
  final String description;
  final IconData emptyIcon;
  final String pickLabel;
  final IconData pickIcon;
  final InputMethod inputMethod;
  final Color accentColor;
  final Future<String?> Function(ImagePickerService service) pickImage;

  @override
  State<ImageInputScreen> createState() => _ImageInputScreenState();
}

class _ImageInputScreenState extends State<ImageInputScreen> {
  final _pickerService = ImagePickerService();

  String? _imagePath;
  bool _isPicking = false;
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _handlePick() async {
    setState(() {
      _isPicking = true;
      _errorMessage = null;
    });

    try {
      final path = await widget.pickImage(_pickerService);
      if (!mounted) return;
      setState(() => _imagePath = path);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not access the ${widget.inputMethod == InputMethod.camera ? 'camera' : 'gallery'}. '
            'Check permissions and try again.';
      });
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _handleAnalyze() async {
    final path = _imagePath;
    if (path == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final prediction = await PredictionService.analyzeImage(path);
      if (!mounted) return;

      final result = ScanResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inputMethod: widget.inputMethod,
        diseaseName: prediction.diseaseName,
        confidence: prediction.confidence,
        scannedAt: DateTime.now(),
        imagePath: path,
        summary: prediction.summary,
      );

      context.push(AppRoutes.result, extra: result);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Analysis failed. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _clearImage() => setState(() => _imagePath = null);

  @override
  Widget build(BuildContext context) {
    final hasImage = _imagePath != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isAnalyzing ? null : () => context.pop(),
        ),
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.headline,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _ImagePreviewFrame(
                  imagePath: _imagePath,
                  emptyIcon: widget.emptyIcon,
                  accentColor: widget.accentColor,
                  emptyLabel: hasImage ? null : 'No image selected',
                  emptySubtitle: hasImage
                      ? null
                      : 'Use the button below to ${widget.inputMethod == InputMethod.camera ? 'capture' : 'choose'} a photo',
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: _errorMessage!),
              ],
              const SizedBox(height: 20),
              if (hasImage) ...[
                PrimaryButton(
                  label: 'Analyze Crop',
                  icon: Icons.biotech_rounded,
                  isLoading: _isAnalyzing,
                  onPressed: _handleAnalyze,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: widget.inputMethod == InputMethod.camera
                      ? 'Retake Photo'
                      : 'Choose Different Image',
                  icon: widget.pickIcon,
                  backgroundColor: AppColors.parchment,
                  foregroundColor: AppColors.moss,
                  isLoading: _isPicking,
                  onPressed: _isAnalyzing ? null : _handlePick,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isAnalyzing ? null : _clearImage,
                  child: const Text('Clear selection'),
                ),
              ] else
                PrimaryButton(
                  label: widget.pickLabel,
                  icon: widget.pickIcon,
                  isLoading: _isPicking,
                  backgroundColor: widget.accentColor,
                  onPressed: _handlePick,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreviewFrame extends StatelessWidget {
  const _ImagePreviewFrame({
    required this.imagePath,
    required this.emptyIcon,
    required this.accentColor,
    this.emptyLabel,
    this.emptySubtitle,
  });

  final String? imagePath;
  final IconData emptyIcon;
  final Color accentColor;
  final String? emptyLabel;
  final String? emptySubtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.parchment),
      ),
      clipBehavior: Clip.antiAlias,
      child: imagePath != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(emptyIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Preview',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(emptyIcon, size: 38, color: accentColor),
                ),
                if (emptyLabel != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    emptyLabel!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
                if (emptySubtitle != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      emptySubtitle!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.danger,
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
