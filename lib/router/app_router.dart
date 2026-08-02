
import 'package:crop_shield_ai/screens/yield_predictor_screen/yield_predictor_screen.dart';
import 'package:crop_shield_ai/models/scan_result.dart';
import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/screens/advisory/advisory_screen.dart';
import 'package:crop_shield_ai/screens/camera/camera_screen.dart';
import 'package:crop_shield_ai/screens/fertilizer/fertilizer_screen.dart';
import 'package:crop_shield_ai/screens/history/history_screen.dart';
import 'package:crop_shield_ai/screens/home/home_screen.dart';
import 'package:crop_shield_ai/screens/image_upload/image_upload_screen.dart';
import 'package:crop_shield_ai/screens/pesticide/pesticide_screen.dart';
import 'package:crop_shield_ai/screens/placeholder/placeholder_screen.dart';
import 'package:crop_shield_ai/screens/result/result_screen.dart';
import 'package:crop_shield_ai/screens/text_input/text_input_screen.dart';
import 'package:crop_shield_ai/screens/voice_input/voice_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.camera,
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: AppRoutes.imageUpload,
      builder: (context, state) => const ImageUploadScreen(),
    ),
    GoRoute(
      path: AppRoutes.textInput,
      builder: (context, state) => const TextInputScreen(),
    ),
    GoRoute(
      path: AppRoutes.voiceInput,
      builder: (context, state) => const VoiceInputScreen(),
    ),
    GoRoute(
      path: AppRoutes.result,
      builder: (context, state) {
        final result = state.extra;
        if (result is! ScanResult) {
          return const PlaceholderScreen(
            title: 'Detection Result',
            subtitle: 'Run a scan from the home screen to see results here.',
          );
        }
        return ResultScreen(result: result);
      },
    ),
    GoRoute(
      path: AppRoutes.advisory,
      builder: (context, state) {
        final result = state.extra;
        if (result is! ScanResult) {
          return const PlaceholderScreen(
            title: 'Advisory',
            subtitle: 'Treatment and prevention recommendations.',
          );
        }
        return AdvisoryScreen(result: result);
      },
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.fertilizer,
      builder: (context, state) {
        final diseaseName = state.extra;
        String? crop;
        if (diseaseName is String) {
          final lower = diseaseName.toLowerCase();
          if (lower.contains('cotton')) crop = 'Cotton';
          if (lower.contains('rice')) crop = 'Rice';
        }
        return FertilizerScreen(initialCrop: crop);
      },
    ),
    GoRoute(
      path: AppRoutes.pesticide,
      builder: (context, state) {
        final diseaseName = state.extra;
        String? crop;
        if (diseaseName is String) {
          final lower = diseaseName.toLowerCase();
          if (lower.contains('cotton')) crop = 'Cotton';
          if (lower.contains('rice')) crop = 'Rice';
        }
        return PesticideScreen(initialCrop: crop);
      },
    ),
    GoRoute(
  path: AppRoutes.yieldPredictor,
  builder: (context, state) => const YieldPredictorScreen(),
),
  ],
);