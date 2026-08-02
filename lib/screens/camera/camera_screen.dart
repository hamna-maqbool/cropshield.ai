import 'package:crop_shield_ai/models/input_method.dart';
import 'package:crop_shield_ai/screens/shared/image_input_screen.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ImageInputScreen(
      title: 'Camera Scan',
      headline: 'Capture affected leaves',
      description:
          'Hold the camera steady, fill the frame with the leaf, and ensure even lighting for accurate detection.',
      emptyIcon: Icons.photo_camera_rounded,
      pickLabel: 'Open Camera',
      pickIcon: Icons.photo_camera_rounded,
      inputMethod: InputMethod.camera,
      accentColor: AppColors.moss,
      pickImage: (service) => service.captureFromCamera(),
    );
  }
}
