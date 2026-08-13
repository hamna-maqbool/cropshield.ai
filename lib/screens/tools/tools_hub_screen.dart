import 'package:crop_shield_ai/features/fuel_log/screens/fuel_log_screen.dart';
import 'package:crop_shield_ai/features/udhaar_tracker/screens/udhaar_screen.dart';
import 'package:crop_shield_ai/features/yield_predictor/yield_predictor_screen.dart';
import 'package:crop_shield_ai/router/app_routes.dart';
import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:crop_shield_ai/theme/app_spacing.dart';
import 'package:crop_shield_ai/widgets/feature_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key});

  void _pushRoot(BuildContext context, Widget screen) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            12,
            AppSpacing.pageH,
            24,
          ),
          children: [
            Text(
              'Farming Tools',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Guides and calculators for better crop management.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 20),
            FeatureRow(
              title: 'Fertilizer & Nutrition Guide',
              subtitle:
                  'Get کھاد recommendations by crop and growth stage',
              icon: Icons.grass_rounded,
              color: AppColors.moss,
              onTap: () => context.push(AppRoutes.fertilizer),
            ),
            const SizedBox(height: 10),
            FeatureRow(
              title: 'Pesticide Calculator',
              subtitle:
                  'Get کیڑے مار دوا dose, tank-mix, and safe harvest date',
              icon: Icons.science_rounded,
              color: AppColors.clay,
              onTap: () => context.push(AppRoutes.pesticide),
            ),
            const SizedBox(height: 10),
            FeatureRow(
              title: 'Yield & Profit Predictor',
              subtitle:
                  'Get متوقع پیداوار and profit estimate for your field',
              icon: Icons.agriculture_rounded,
              color: AppColors.forest,
              onTap: () => _pushRoot(context, const YieldPredictorScreen()),
            ),
            const SizedBox(height: 10),
            FeatureRow(
              title: 'Tractor Fuel Log',
              subtitle: 'Track ڈیزل fill-ups and cost per field',
              icon: Icons.local_gas_station_rounded,
              color: AppColors.soil,
              onTap: () => _pushRoot(context, const FuelLogScreen()),
            ),
            const SizedBox(height: 10),
            FeatureRow(
              title: 'Input Credit (Udhaar) Tracker',
              subtitle: 'Track ادھار from dealers and repayments',
              icon: Icons.receipt_long_rounded,
              color: AppColors.clay,
              onTap: () => _pushRoot(context, const UdhaarScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
