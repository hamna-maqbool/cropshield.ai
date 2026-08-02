/// Data layer for the Yield & Profit Predictor.
///
/// Baseline yields are grounded in published figures for Punjab, Pakistan:
/// - Cotton (seed cotton / phutti): Punjab average ~9–11 maunds/acre
///   (Pakistan Cotton Ginners Association / Business Recorder, 2025 season).
/// - Rice — Basmati: Punjab average ~20–22 maunds/acre paddy
///   (Punjab Crop Reporting Service).
/// - Rice — Coarse/Hybrid: Punjab average ~35 maunds/acre, well-managed
///   fields can reach 60–80 (Rice Research Institute, Kala Shah Kaku).
///
/// Prices and per-acre costs are seeded with reasonable, editable defaults —
/// these move weekly/seasonally, so the UI always lets the farmer override
/// them with the current mandi rate before calculating. 1 maund = 40 kg.
library yield_predictor_data;

enum CropType { cotton, riceBasmati, riceCoarse }

enum SoilType { sandy, loamy, clay }

enum IrrigationType { canal, tubeWell }

enum FertilizerLevel { low, medium, high }

enum SowingTime { early, onTime, late }

/// Disease severity — designed to be auto-populated from the app's own
/// disease-detection scan result, tying the yield predictor directly to
/// the CNN model output. Falls back to a manual picker if no scan exists.
enum DiseaseSeverity { healthy, mild, moderate, severe }

class CropBaseline {
  const CropBaseline({
    required this.label,
    required this.baselineMaundsPerAcre,
    required this.defaultPricePerMaund,
    required this.defaultSeedCostPerAcre,
    required this.defaultFertilizerCostPerAcre,
    required this.defaultPesticideCostPerAcre,
    required this.defaultLaborCostPerAcre,
    required this.defaultOtherCostPerAcre,
    required this.sourceNote,
  });

  final String label;
  final double baselineMaundsPerAcre;
  final double defaultPricePerMaund;
  final double defaultSeedCostPerAcre;
  final double defaultFertilizerCostPerAcre;
  final double defaultPesticideCostPerAcre;
  final double defaultLaborCostPerAcre;
  final double defaultOtherCostPerAcre;
  final String sourceNote;

  double get defaultTotalCostPerAcre =>
      defaultSeedCostPerAcre +
      defaultFertilizerCostPerAcre +
      defaultPesticideCostPerAcre +
      defaultLaborCostPerAcre +
      defaultOtherCostPerAcre;
}

const Map<CropType, CropBaseline> cropBaselines = {
  CropType.cotton: CropBaseline(
    label: 'Cotton',
    baselineMaundsPerAcre: 10,
    defaultPricePerMaund: 8500,
    defaultSeedCostPerAcre: 3500,
    defaultFertilizerCostPerAcre: 10000,
    defaultPesticideCostPerAcre: 14000,
    defaultLaborCostPerAcre: 18000,
    defaultOtherCostPerAcre: 6000,
    sourceNote:
        'Punjab average seed-cotton (phutti) yield ~9–11 maunds/acre; '
        '2025 government support price ~Rs 8,500/maund.',
  ),
  CropType.riceBasmati: CropBaseline(
    label: 'Rice — Basmati',
    baselineMaundsPerAcre: 22,
    defaultPricePerMaund: 4200,
    defaultSeedCostPerAcre: 2500,
    defaultFertilizerCostPerAcre: 8000,
    defaultPesticideCostPerAcre: 5000,
    defaultLaborCostPerAcre: 18000,
    defaultOtherCostPerAcre: 6000,
    sourceNote:
        'Punjab Basmati paddy average ~20–22 maunds/acre '
        '(Punjab Crop Reporting Service).',
  ),
  CropType.riceCoarse: CropBaseline(
    label: 'Rice — Coarse / Hybrid',
    baselineMaundsPerAcre: 35,
    defaultPricePerMaund: 3000,
    defaultSeedCostPerAcre: 2500,
    defaultFertilizerCostPerAcre: 8000,
    defaultPesticideCostPerAcre: 5000,
    defaultLaborCostPerAcre: 17000,
    defaultOtherCostPerAcre: 6000,
    sourceNote:
        'Punjab coarse/hybrid paddy average ~35 maunds/acre, well-managed '
        'fields reach 60–80 (Rice Research Institute, Kala Shah Kaku).',
  ),
};

/// One line of the transparent "how we calculated this" breakdown.
class AdjustmentStep {
  const AdjustmentStep(this.label, this.multiplier, this.note);
  final String label;
  final double multiplier;
  final String note;
}

double soilMultiplier(SoilType s) => switch (s) {
      SoilType.loamy => 1.05,
      SoilType.clay => 0.95,
      SoilType.sandy => 0.90,
    };

String soilLabel(SoilType s) => switch (s) {
      SoilType.loamy => 'Loamy',
      SoilType.clay => 'Clay',
      SoilType.sandy => 'Sandy',
    };

double irrigationMultiplier(IrrigationType i) => switch (i) {
      IrrigationType.canal => 1.00,
      IrrigationType.tubeWell => 0.95,
    };

String irrigationLabel(IrrigationType i) => switch (i) {
      IrrigationType.canal => 'Canal',
      IrrigationType.tubeWell => 'Tube well',
    };

double fertilizerMultiplier(FertilizerLevel f) => switch (f) {
      FertilizerLevel.low => 0.80,
      FertilizerLevel.medium => 1.00,
      FertilizerLevel.high => 1.08,
    };

String fertilizerLabel(FertilizerLevel f) => switch (f) {
      FertilizerLevel.low => 'Low',
      FertilizerLevel.medium => 'Recommended',
      FertilizerLevel.high => 'High',
    };

double sowingMultiplier(SowingTime s) => switch (s) {
      SowingTime.early => 1.05,
      SowingTime.onTime => 1.00,
      SowingTime.late => 0.88,
    };

String sowingLabel(SowingTime s) => switch (s) {
      SowingTime.early => 'Early',
      SowingTime.onTime => 'On time',
      SowingTime.late => 'Late',
    };

double diseaseMultiplier(DiseaseSeverity d) => switch (d) {
      DiseaseSeverity.healthy => 1.00,
      DiseaseSeverity.mild => 0.90,
      DiseaseSeverity.moderate => 0.75,
      DiseaseSeverity.severe => 0.55,
    };

String diseaseLabel(DiseaseSeverity d) => switch (d) {
      DiseaseSeverity.healthy => 'Healthy',
      DiseaseSeverity.mild => 'Mild symptoms',
      DiseaseSeverity.moderate => 'Moderate infection',
      DiseaseSeverity.severe => 'Severe infection',
    };

/// 1 acre = 8 kanal (Punjab land measurement convention).
const double kanalPerAcre = 8.0;
