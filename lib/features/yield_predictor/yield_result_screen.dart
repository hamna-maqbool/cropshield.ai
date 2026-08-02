import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'yield_predictor_engine.dart';

class YieldResultScreen extends StatefulWidget {
  const YieldResultScreen({super.key, required this.result});

  final YieldPredictionResult result;

  @override
  State<YieldResultScreen> createState() => _YieldResultScreenState();
}

class _YieldResultScreenState extends State<YieldResultScreen> {
  bool _showBreakdown = false;

  String _money(double v) {
    final isNegative = v < 0;
    final abs = v.abs();
    final s = abs.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
        );
    return '${isNegative ? '-' : ''}Rs $s';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final profitable = r.profit >= 0;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Your Forecast',
          style: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.forest,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.forest),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _HeroCard(
            cropLabel: r.cropLabel,
            areaInAcres: r.areaInAcres,
            totalYieldMaunds: r.totalYieldMaunds,
            profit: r.profit,
            profitable: profitable,
            moneyFormatter: _money,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Revenue',
                  value: _money(r.revenue),
                  icon: Icons.trending_up_rounded,
                  color: AppColors.moss,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'Total Cost',
                  value: _money(r.totalCost),
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.clay,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Profit / Acre',
                  value: _money(r.profitPerAcre),
                  icon: Icons.landscape_rounded,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'Return on Cost',
                  value: '${r.roiPercent.toStringAsFixed(0)}%',
                  icon: Icons.percent_rounded,
                  color: AppColors.soil,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _BreakdownCard(
            result: r,
            expanded: _showBreakdown,
            onToggle: () => setState(() => _showBreakdown = !_showBreakdown),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.sourceNote,
                    style: GoogleFonts.manrope(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'This is an estimate based on regional averages and your inputs. '
              'Actual results depend on weather, pest pressure, and field '
              'conditions during the season.',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: AppColors.textMuted,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.cropLabel,
    required this.areaInAcres,
    required this.totalYieldMaunds,
    required this.profit,
    required this.profitable,
    required this.moneyFormatter,
  });

  final String cropLabel;
  final double areaInAcres;
  final double totalYieldMaunds;
  final double profit;
  final bool profitable;
  final String Function(double) moneyFormatter;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.forest, AppColors.moss],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cropLabel · ${areaInAcres.toStringAsFixed(1)} acres',
                  style: GoogleFonts.manrope(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Estimated Yield',
                  style: GoogleFonts.manrope(
                    color: Colors.white60,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${totalYieldMaunds.toStringAsFixed(1)} maunds',
                  style: GoogleFonts.fraunces(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
                const SizedBox(height: 18),
                Text(
                  profitable ? 'Estimated Profit' : 'Estimated Loss',
                  style: GoogleFonts.manrope(
                    color: Colors.white60,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      profitable
                          ? Icons.arrow_circle_up_rounded
                          : Icons.arrow_circle_down_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      moneyFormatter(profit),
                      style: GoogleFonts.fraunces(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.fraunces(
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2921),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.manrope(fontSize: 11.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// The trust-building piece: shows exactly how the baseline yield was
/// adjusted step by step to reach the final number.
class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.result,
    required this.expanded,
    required this.onToggle,
  });

  final YieldPredictionResult result;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.insights_rounded, size: 18, color: AppColors.forest),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'How we calculated this',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2921),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  for (final step in result.steps)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: step.multiplier >= 1.0
                                  ? AppColors.moss
                                  : AppColors.clay,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      step.label,
                                      style: GoogleFonts.manrope(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF3A4A3D),
                                      ),
                                    ),
                                    Text(
                                      '×${step.multiplier.toStringAsFixed(2)}',
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: step.multiplier >= 1.0
                                            ? AppColors.moss
                                            : AppColors.clay,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  step.note,
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Divider(color: AppColors.parchment, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Final yield per acre',
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest,
                        ),
                      ),
                      Text(
                        '${result.adjustedYieldPerAcre.toStringAsFixed(1)} maunds',
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}
