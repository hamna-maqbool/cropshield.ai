import 'package:crop_shield_ai/models/input_method.dart';
import 'package:crop_shield_ai/screens/shared/image_input_screen.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ImageUploadScreen extends StatelessWidget {
  const ImageUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ImageInputScreen(
      title: 'Image Upload',
      headline: 'Select from gallery',
      description:
          'Choose a clear photo of the affected crop. JPG and PNG images work best for disease analysis.',
      emptyIcon: Icons.photo_library_rounded,
      pickLabel: 'Choose Image',
      pickIcon: Icons.photo_library_rounded,
      inputMethod: InputMethod.gallery,
      accentColor: AppColors.soil,
      pickImage: (service) => service.pickFromGallery(),
    );
  }
}
