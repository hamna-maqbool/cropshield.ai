import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'yield_predictor_data.dart';
import 'yield_predictor_engine.dart';
import 'yield_result_screen.dart';

/// Yield & Profit Predictor — input form.
///
/// Designed for real farmer use: almost everything is tap-to-select
/// (chips/steppers), not typed. If [lastScanCrop] / [lastScanSeverity] are
/// provided (from the app's own disease-detection history), the crop and
/// health fields are pre-filled automatically — the disease model feeds
/// straight into the yield model.
class YieldPredictorScreen extends StatefulWidget {
  const YieldPredictorScreen({
    super.key,
    this.lastScanCrop,
    this.lastScanSeverity,
  });

  final CropType? lastScanCrop;
  final DiseaseSeverity? lastScanSeverity;

  @override
  State<YieldPredictorScreen> createState() => _YieldPredictorScreenState();
}

class _YieldPredictorScreenState extends State<YieldPredictorScreen> {
  late CropType _crop = widget.lastScanCrop ?? CropType.cotton;
  bool _useKanal = false;
  double _area = 5; // in the currently selected unit
  SoilType _soil = SoilType.loamy;
  IrrigationType _irrigation = IrrigationType.canal;
  FertilizerLevel _fertilizer = FertilizerLevel.medium;
  SowingTime _sowing = SowingTime.onTime;
  late DiseaseSeverity _disease = widget.lastScanSeverity ?? DiseaseSeverity.healthy;
  late bool _diseaseAutoDetected = widget.lastScanSeverity != null;

  late double _price = cropBaselines[_crop]!.defaultPricePerMaund;
  bool _costsExpanded = false;
  late double _seedCost = cropBaselines[_crop]!.defaultSeedCostPerAcre;
  late double _fertilizerCost = cropBaselines[_crop]!.defaultFertilizerCostPerAcre;
  late double _pesticideCost = cropBaselines[_crop]!.defaultPesticideCostPerAcre;
  late double _laborCost = cropBaselines[_crop]!.defaultLaborCostPerAcre;
  late double _otherCost = cropBaselines[_crop]!.defaultOtherCostPerAcre;

  double get _areaInAcres => _useKanal ? _area / kanalPerAcre : _area;

  void _applyCropDefaults(CropType crop) {
    final b = cropBaselines[crop]!;
    setState(() {
      _crop = crop;
      _price = b.defaultPricePerMaund;
      _seedCost = b.defaultSeedCostPerAcre;
      _fertilizerCost = b.defaultFertilizerCostPerAcre;
      _pesticideCost = b.defaultPesticideCostPerAcre;
      _laborCost = b.defaultLaborCostPerAcre;
      _otherCost = b.defaultOtherCostPerAcre;
    });
  }

  void _calculate() {
    HapticFeedback.mediumImpact();
    final input = YieldPredictionInput(
      crop: _crop,
      areaInAcres: _areaInAcres,
      soil: _soil,
      irrigation: _irrigation,
      fertilizer: _fertilizer,
      sowing: _sowing,
      disease: _disease,
      diseaseAutoDetected: _diseaseAutoDetected,
      pricePerMaund: _price,
      seedCostPerAcre: _seedCost,
      fertilizerCostPerAcre: _fertilizerCost,
      pesticideCostPerAcre: _pesticideCost,
      laborCostPerAcre: _laborCost,
      otherCostPerAcre: _otherCost,
    );
    final result = YieldPredictorEngine.predict(input);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => YieldResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        backgroundColor: AppColors.parchment,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Yield & Profit Predictor',
          style: GoogleFonts.fraunces(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.forest,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.forest),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
        children: [
          _SectionCard(
            title: 'Crop',
            child: _ChipRow<CropType>(
              value: _crop,
              options: const [
                CropType.cotton,
                CropType.riceBasmati,
                CropType.riceCoarse,
              ],
              labelBuilder: (c) => cropBaselines[c]!.label,
              onChanged: _applyCropDefaults,
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Land Area',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _UnitToggle(
                        useKanal: _useKanal,
                        onChanged: (v) => setState(() {
                          _area = v
                              ? _area * kanalPerAcre
                              : _area / kanalPerAcre;
                          _useKanal = v;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _Stepper(
                  value: _area,
                  min: _useKanal ? 1 : 0.5,
                  max: _useKanal ? 80 : 100,
                  step: _useKanal ? 1 : 0.5,
                  suffix: _useKanal ? 'kanal' : 'acre',
                  onChanged: (v) => setState(() => _area = v),
                ),
                if (_useKanal)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '≈ ${_areaInAcres.toStringAsFixed(2)} acres',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Soil Type',
            child: _ChipRow<SoilType>(
              value: _soil,
              options: SoilType.values,
              labelBuilder: soilLabel,
              onChanged: (v) => setState(() => _soil = v),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Irrigation Source',
            child: _ChipRow<IrrigationType>(
              value: _irrigation,
              options: IrrigationType.values,
              labelBuilder: irrigationLabel,
              onChanged: (v) => setState(() => _irrigation = v),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Fertilizer Level',
            child: _ChipRow<FertilizerLevel>(
              value: _fertilizer,
              options: FertilizerLevel.values,
              labelBuilder: fertilizerLabel,
              onChanged: (v) => setState(() => _fertilizer = v),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Sowing Time',
            child: _ChipRow<SowingTime>(
              value: _sowing,
              options: SowingTime.values,
              labelBuilder: sowingLabel,
              onChanged: (v) => setState(() => _sowing = v),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Crop Health',
            subtitle: _diseaseAutoDetected
                ? 'Auto-filled from your latest scan — you can override it'
                : 'No recent scan found — set manually or scan a leaf first',
            child: _ChipRow<DiseaseSeverity>(
              value: _disease,
              options: DiseaseSeverity.values,
              labelBuilder: diseaseLabel,
              onChanged: (v) => setState(() {
                _disease = v;
                _diseaseAutoDetected = false;
              }),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Market Price',
            subtitle: 'Prices move often — check today\'s mandi rate',
            child: _MoneyField(
              label: 'Price per maund (Rs)',
              value: _price,
              onChanged: (v) => setState(() => _price = v),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Input Costs (per acre)',
            trailing: TextButton(
              onPressed: () => setState(() => _costsExpanded = !_costsExpanded),
              child: Text(
                _costsExpanded ? 'Hide' : 'Edit',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  color: AppColors.moss,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated total',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      'Rs ${(_seedCost + _fertilizerCost + _pesticideCost + _laborCost + _otherCost).toStringAsFixed(0)} / acre',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.forest,
                      ),
                    ),
                  ],
                ),
                if (_costsExpanded) ...[
                  const SizedBox(height: 14),
                  _MoneyField(
                    label: 'Seed',
                    value: _seedCost,
                    onChanged: (v) => setState(() => _seedCost = v),
                  ),
                  const SizedBox(height: 10),
                  _MoneyField(
                    label: 'Fertilizer',
                    value: _fertilizerCost,
                    onChanged: (v) => setState(() => _fertilizerCost = v),
                  ),
                  const SizedBox(height: 10),
                  _MoneyField(
                    label: 'Pesticide',
                    value: _pesticideCost,
                    onChanged: (v) => setState(() => _pesticideCost = v),
                  ),
                  const SizedBox(height: 10),
                  _MoneyField(
                    label: 'Labor',
                    value: _laborCost,
                    onChanged: (v) => setState(() => _laborCost = v),
                  ),
                  const SizedBox(height: 10),
                  _MoneyField(
                    label: 'Other (land prep, transport, etc.)',
                    value: _otherCost,
                    onChanged: (v) => setState(() => _otherCost = v),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cropBaselines[_crop]!.sourceNote,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Calculate Yield & Profit',
                style: GoogleFonts.manrope(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable form primitives
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2921),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ChipRow<T> extends StatelessWidget {
  const _ChipRow({
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final selected = opt == value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(opt);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.forest : AppColors.parchment,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.forest : Colors.transparent,
              ),
            ),
            child: Text(
              labelBuilder(opt),
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF3A4A3D),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.useKanal, required this.onChanged});

  final bool useKanal;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _segment('Acre', !useKanal, () => onChanged(false))),
          Expanded(child: _segment('Kanal', useKanal, () => onChanged(true))),
        ],
      ),
    );
  }

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.forest : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.suffix,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final double step;
  final String suffix;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _roundButton(Icons.remove_rounded, () {
          final next = (value - step).clamp(min, max);
          HapticFeedback.selectionClick();
          onChanged(next);
        }),
        Expanded(
          child: Column(
            children: [
              Text(
                '${value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} $suffix',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  activeColor: AppColors.moss,
                  inactiveColor: AppColors.parchment,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        _roundButton(Icons.add_rounded, () {
          final next = (value + step).clamp(min, max);
          HapticFeedback.selectionClick();
          onChanged(next);
        }),
      ],
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: AppColors.forest),
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value.toStringAsFixed(0));
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF3A4A3D)),
          ),
        ),
        SizedBox(
          width: 120,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.right,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.forest,
            ),
            decoration: InputDecoration(
              prefixText: 'Rs ',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.parchment),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.moss),
              ),
            ),
            onSubmitted: (v) => onChanged(double.tryParse(v) ?? value),
            onEditingComplete: () {},
          ),
        ),
      ],
    );
  }
}
