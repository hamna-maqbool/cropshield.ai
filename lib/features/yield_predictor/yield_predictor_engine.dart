import 'yield_predictor_data.dart';

/// Input bundle collected from the form screen.
class YieldPredictionInput {
  const YieldPredictionInput({
    required this.crop,
    required this.areaInAcres,
    required this.soil,
    required this.irrigation,
    required this.fertilizer,
    required this.sowing,
    required this.disease,
    required this.pricePerMaund,
    required this.seedCostPerAcre,
    required this.fertilizerCostPerAcre,
    required this.pesticideCostPerAcre,
    required this.laborCostPerAcre,
    required this.otherCostPerAcre,
    this.diseaseAutoDetected = false,
  });

  final CropType crop;
  final double areaInAcres;
  final SoilType soil;
  final IrrigationType irrigation;
  final FertilizerLevel fertilizer;
  final SowingTime sowing;
  final DiseaseSeverity disease;
  final bool diseaseAutoDetected;

  final double pricePerMaund;
  final double seedCostPerAcre;
  final double fertilizerCostPerAcre;
  final double pesticideCostPerAcre;
  final double laborCostPerAcre;
  final double otherCostPerAcre;

  double get totalCostPerAcre =>
      seedCostPerAcre +
      fertilizerCostPerAcre +
      pesticideCostPerAcre +
      laborCostPerAcre +
      otherCostPerAcre;
}

class YieldPredictionResult {
  const YieldPredictionResult({
    required this.cropLabel,
    required this.areaInAcres,
    required this.baselineYieldPerAcre,
    required this.adjustedYieldPerAcre,
    required this.totalYieldMaunds,
    required this.revenue,
    required this.totalCost,
    required this.profit,
    required this.profitPerAcre,
    required this.steps,
    required this.sourceNote,
  });

  final String cropLabel;
  final double areaInAcres;
  final double baselineYieldPerAcre;
  final double adjustedYieldPerAcre;
  final double totalYieldMaunds;
  final double revenue;
  final double totalCost;
  final double profit;
  final double profitPerAcre;
  final List<AdjustmentStep> steps;
  final String sourceNote;

  double get roiPercent => totalCost == 0 ? 0 : (profit / totalCost) * 100;
}

/// Pure, deterministic, fully-offline calculation — no model file, no
/// network call. Every multiplier traces back to either published Punjab
/// agronomic data or the app's own disease-detection result, and every
/// step is surfaced to the farmer via [YieldPredictionResult.steps].
class YieldPredictorEngine {
  static YieldPredictionResult predict(YieldPredictionInput input) {
    final baseline = cropBaselines[input.crop]!;
    final steps = <AdjustmentStep>[];

    double runningYield = baseline.baselineMaundsPerAcre;
    steps.add(AdjustmentStep(
      'Baseline (${baseline.label})',
      1.0,
      '${runningYield.toStringAsFixed(1)} maunds/acre — regional average',
    ));

    void applyStep(String label, double multiplier, String note) {
      runningYield *= multiplier;
      steps.add(AdjustmentStep(label, multiplier, note));
    }

    applyStep(
      'Soil — ${soilLabel(input.soil)}',
      soilMultiplier(input.soil),
      soilMultiplier(input.soil) >= 1.0
          ? 'Favorable water and nutrient retention'
          : 'Reduced water/nutrient retention',
    );

    applyStep(
      'Irrigation — ${irrigationLabel(input.irrigation)}',
      irrigationMultiplier(input.irrigation),
      input.irrigation == IrrigationType.canal
          ? 'Consistent, silt-rich water supply'
          : 'Reliable but higher-cost water source',
    );

    applyStep(
      'Fertilizer — ${fertilizerLabel(input.fertilizer)}',
      fertilizerMultiplier(input.fertilizer),
      input.fertilizer == FertilizerLevel.high
          ? 'Above recommended dose — diminishing returns beyond this point'
          : input.fertilizer == FertilizerLevel.low
              ? 'Below recommended nutrient dose'
              : 'Matches recommended nutrient dose',
    );

    applyStep(
      'Sowing time — ${sowingLabel(input.sowing)}',
      sowingMultiplier(input.sowing),
      input.sowing == SowingTime.late
          ? 'Delayed sowing shortens the growth window'
          : input.sowing == SowingTime.early
              ? 'Early sowing captures optimal growing conditions'
              : 'Sown within the recommended window',
    );

    applyStep(
      'Crop health — ${diseaseLabel(input.disease)}'
      '${input.diseaseAutoDetected ? ' (from latest scan)' : ''}',
      diseaseMultiplier(input.disease),
      input.disease == DiseaseSeverity.healthy
          ? 'No disease pressure detected'
          : 'Yield loss from detected infection severity',
    );

    final adjustedYieldPerAcre = runningYield;
    final totalYieldMaunds = adjustedYieldPerAcre * input.areaInAcres;
    final revenue = totalYieldMaunds * input.pricePerMaund;
    final totalCost = input.totalCostPerAcre * input.areaInAcres;
    final profit = revenue - totalCost;

    return YieldPredictionResult(
      cropLabel: baseline.label,
      areaInAcres: input.areaInAcres,
      baselineYieldPerAcre: baseline.baselineMaundsPerAcre,
      adjustedYieldPerAcre: adjustedYieldPerAcre,
      totalYieldMaunds: totalYieldMaunds,
      revenue: revenue,
      totalCost: totalCost,
      profit: profit,
      profitPerAcre: input.areaInAcres == 0 ? 0 : profit / input.areaInAcres,
      steps: steps,
      sourceNote: baseline.sourceNote,
    );
  }
}
