import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionResult {
  final String diseaseName;
  final double confidence;
  final String summary;
  final String rawLabel;

  const PredictionResult({
    required this.diseaseName,
    required this.confidence,
    required this.summary,
    required this.rawLabel,
  });
}

class PredictionService {
  static const String _modelPath = 'assets/cropshield_mobilenetv3.tflite';
  static const String _labelsPath = 'assets/class_labels.json';
  static const int _inputSize = 224;
  static const int _numClasses = 12;

  static Interpreter? _interpreter;
  static Map<String, String>? _labels;
  static bool _isInitialized = false;

  static Future<void> _initialize() async {
    if (_isInitialized) return;
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      final labelsJson = await rootBundle.loadString(_labelsPath);
      _labels = Map<String, String>.from(json.decode(labelsJson));
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize model: $e');
    }
  }

  static Future<PredictionResult> analyzeImage(String imagePath) async {
    await _initialize();

    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) throw Exception('Could not decode image');

    final resized = img.copyResize(
      decodedImage,
      width: _inputSize,
      height: _inputSize,
    );

    // MobileNetV3 preprocess_input: scale to [-1, 1]
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              (pixel.r / 127.5) - 1.0,
              (pixel.g / 127.5) - 1.0,
              (pixel.b / 127.5) - 1.0,
            ];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(_numClasses, 0.0));
    _interpreter!.run(input, output);

    final probabilities = output[0];
    int maxIndex = 0;
    double maxProb = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    final rawLabel = _labels?['$maxIndex'] ?? 'unknown';
    final displayLabel = _formatLabel(rawLabel);
    final summary = _generateSummary(rawLabel, maxProb);

    return PredictionResult(
      diseaseName: displayLabel,
      confidence: maxProb,
      summary: summary,
      rawLabel: rawLabel,
    );
  }

  static String _formatLabel(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static String _generateSummary(String rawLabel, double confidence) {
    final percent = (confidence * 100).round();
    final Map<String, String> summaries = {
      'cotton_army_worm':
          'Army worm infestation detected on cotton crop with $percent% confidence. Larvae feeding patterns visible on leaves.',
      'cotton_bacterial_blight':
          'Bacterial blight detected on cotton with $percent% confidence. Angular water-soaked lesions indicate bacterial infection.',
      'cotton_curl_virus':
          'Cotton leaf curl virus detected with $percent% confidence. Upward curling and thickening of leaves are key indicators.',
      'cotton_healthy_leaf':
          'Crop appears healthy with $percent% confidence. No signs of disease or pest damage detected.',
      'cotton_powdery_mildew':
          'Powdery mildew detected on cotton with $percent% confidence. White powdery fungal growth visible on leaf surface.',
      'cotton_target_spot':
          'Target spot disease detected with $percent% confidence. Circular lesions with concentric rings are characteristic symptoms.',
      'rice_bacterialblight':
          'Bacterial blight detected on rice with $percent% confidence. Yellow to white lesions along leaf margins observed.',
      'rice_blast':
          'Rice blast disease detected with $percent% confidence. Diamond-shaped lesions with grey centers indicate blast infection.',
      'rice_brownspot':
          'Brown spot disease detected on rice with $percent% confidence. Oval brown lesions with yellow halos are present.',
      'rice_healthy':
          'Rice crop appears healthy with $percent% confidence. No signs of disease or stress detected.',
      'rice_leafsmut':
          'Leaf smut detected on rice with $percent% confidence. Black powdery masses on leaf surface indicate fungal infection.',
      'rice_tungro':
          'Rice tungro disease detected with $percent% confidence. Yellow-orange discoloration of leaves indicates viral infection.',
    };

    return summaries[rawLabel] ??
        'Disease detected with $percent% confidence. Please consult an agricultural expert for detailed analysis.';
  }
}