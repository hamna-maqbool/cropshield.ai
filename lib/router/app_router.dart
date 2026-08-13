import 'package:crop_shield_ai/models/scan_result.dart';
import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/screens/advisory/advisory_screen.dart';
import 'package:crop_shield_ai/screens/camera/camera_screen.dart';
import 'package:crop_shield_ai/screens/fertilizer/fertilizer_screen.dart';
import 'package:crop_shield_ai/screens/forum_screen.dart';
import 'package:crop_shield_ai/screens/history/history_screen.dart';
import 'package:crop_shield_ai/screens/home/home_screen.dart';
import 'package:crop_shield_ai/screens/image_upload/image_upload_screen.dart';
import 'package:crop_shield_ai/screens/pesticide/pesticide_screen.dart';
import 'package:crop_shield_ai/screens/placeholder/placeholder_screen.dart';
import 'package:crop_shield_ai/screens/play/play_hub_screen.dart';
import 'package:crop_shield_ai/screens/result/result_screen.dart';
import 'package:crop_shield_ai/screens/shell/app_shell.dart';
import 'package:crop_shield_ai/screens/text_input/text_input_screen.dart';
import 'package:crop_shield_ai/screens/tools/tools_hub_screen.dart';
import 'package:crop_shield_ai/screens/voice_input/voice_input_screen.dart';
import 'package:crop_shield_ai/screens/yield_predictor_screen/yield_predictor_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.tools,
              builder: (context, state) => const ToolsHubScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.community,
              builder: (context, state) => const ForumScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.play,
              builder: (context, state) => const PlayHubScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.camera,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CameraScreen(),
    ),
    GoRoute(
      path: AppRoutes.imageUpload,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ImageUploadScreen(),
    ),
    GoRoute(
      path: AppRoutes.textInput,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const TextInputScreen(),
    ),
    GoRoute(
      path: AppRoutes.voiceInput,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const VoiceInputScreen(),
    ),
    GoRoute(
      path: AppRoutes.result,
      parentNavigatorKey: rootNavigatorKey,
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
      parentNavigatorKey: rootNavigatorKey,
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
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.fertilizer,
      parentNavigatorKey: rootNavigatorKey,
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
      parentNavigatorKey: rootNavigatorKey,
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
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const YieldPredictorScreen(),
    ),
  ],
);
