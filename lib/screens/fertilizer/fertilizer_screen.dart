import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FertilizerScreen extends StatefulWidget {
  const FertilizerScreen({super.key, this.initialCrop});

  final String? initialCrop;

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  String? _selectedCrop;
  String? _selectedStage;

  final List<String> _crops = ['Cotton', 'Rice'];
  final List<String> _stages = [
    'Sowing',
    'Vegetative',
    'Flowering',
    'Harvest'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCrop != null) {
      _selectedCrop = widget.initialCrop;
    }
  }

  static const Map<String, Map<String, List<Map<String, String>>>> _fertilizerData = {
    'Cotton': {
      'Sowing': [
        {
          'name': 'DAP (Di-Ammonium Phosphate)',
          'urdu': 'ڈی اے پی کھاد',
          'brands': 'Engro DAP, Sarsabz DAP, FFC DAP',
          'quantity': '50 kg per acre',
          'timing': 'Apply at the time of sowing',
          'cost': 'PKR 7,500 per acre',
          'benefit': 'Provides phosphorus and nitrogen for root development',
          'deficiency_symptoms': 'Leaves turn dark green to purple/red color. Stunted growth and poor root development. Lower leaves affected first.',
          'application': 'Broadcast evenly and mix into soil before sowing',
        },
        {
          'name': 'Potash (SOP - Sulphate of Potash)',
          'urdu': 'پوٹاش کھاد',
          'brands': 'Engro Zarkhez, Sarsabz SOP, Imported SOP',
          'quantity': '25 kg per acre',
          'timing': 'Mix in soil before sowing',
          'cost': 'PKR 3,000 per acre',
          'benefit': 'Strengthens stem and improves drought resistance',
          'deficiency_symptoms': 'Yellowing and browning of leaf edges (scorching). Weak stems that lodge easily. Poor boll development.',
          'application': 'Mix thoroughly into soil at least 1 week before sowing',
        },
        {
          'name': 'Zinc Sulphate',
          'urdu': 'زنک سلفیٹ',
          'brands': 'Engro Zn, Sarsabz Zinc, Aga Khan Zinc',
          'quantity': '5 kg per acre',
          'timing': 'Apply with DAP at sowing time',
          'cost': 'PKR 1,500 per acre',
          'benefit': 'Prevents zinc deficiency very common in Pakistani soils',
          'deficiency_symptoms': 'Small leaves with bronze or brown spots. New leaves are small and pale yellow. Shortened internodes between leaves.',
          'application': 'Mix with DAP and broadcast before sowing',
        },
      ],
      'Vegetative': [
        {
          'name': 'Urea (46% Nitrogen)',
          'urdu': 'یوریا کھاد',
          'brands': 'Engro Urea, Sona Urea, Fatima Urea, FFC Urea',
          'quantity': '40 kg per acre',
          'timing': 'Apply 3-4 weeks after germination with irrigation',
          'cost': 'PKR 3,200 per acre',
          'benefit': 'Promotes rapid leaf growth and dark green color',
          'deficiency_symptoms': 'Yellowing of older lower leaves first (chlorosis). Slow growth and pale green color throughout plant. Thin weak stems.',
          'application': 'Broadcast near plant base before irrigation. Never apply on wet leaves.',
        },
        {
          'name': 'Boron (Borax)',
          'urdu': 'بوران کھاد',
          'brands': 'Aga Khan Boron, Imported Borax, Solubor',
          'quantity': '2 kg per acre',
          'timing': 'Foliar spray at 4-6 leaf stage',
          'cost': 'PKR 800 per acre',
          'benefit': 'Essential for cell wall formation and water movement',
          'deficiency_symptoms': 'Death of growing tips (terminal bud). Thick, brittle, curled leaves. Hollow stems and cracked fruits.',
          'application': 'Dissolve in water and spray on leaves in early morning or evening',
        },
      ],
      'Flowering': [
        {
          'name': 'Urea (Split Dose)',
          'urdu': 'یوریا کھاد (دوسری قسط)',
          'brands': 'Engro Urea, Sona Urea, Fatima Urea',
          'quantity': '25 kg per acre',
          'timing': 'Apply at flower initiation stage',
          'cost': 'PKR 2,000 per acre',
          'benefit': 'Supports boll formation and fiber development',
          'deficiency_symptoms': 'Premature flower and boll drop. Pale yellow leaves. Reduced boll size and poor fiber quality.',
          'application': 'Apply before irrigation at flower bud stage',
        },
        {
          'name': 'Potash MOP (Muriate of Potash)',
          'urdu': 'پوٹاش ایم او پی',
          'brands': 'Imported MOP, Engro MOP, Sarsabz MOP',
          'quantity': '20 kg per acre',
          'timing': 'Apply at boll development stage',
          'cost': 'PKR 2,400 per acre',
          'benefit': 'Improves fiber quality, boll weight and oil content',
          'deficiency_symptoms': 'Brown scorching of leaf margins. Premature boll opening. Poor fiber strength and reduced yield.',
          'application': 'Broadcast around plants and water immediately',
        },
        {
          'name': 'Calcium Nitrate',
          'urdu': 'کیلشیم نائٹریٹ',
          'brands': 'Haifa Calcium Nitrate, Imported CN',
          'quantity': '10 kg per acre',
          'timing': 'Foliar spray during boll formation',
          'cost': 'PKR 2,000 per acre',
          'benefit': 'Prevents boll rot and improves cell strength',
          'deficiency_symptoms': 'Tip burn on young leaves. Blossom end rot on bolls. Weak cell walls leading to disease susceptibility.',
          'application': 'Dissolve in water and spray on bolls and leaves',
        },
      ],
      'Harvest': [
        {
          'name': 'No Fertilizer Required',
          'urdu': 'کوئی کھاد نہیں',
          'brands': 'N/A',
          'quantity': 'N/A',
          'timing': 'Stop all fertilizer 4 weeks before harvest',
          'cost': 'PKR 0',
          'benefit': 'Allows crop to mature naturally for better fiber quality',
          'deficiency_symptoms': 'N/A — crop is in maturity phase',
          'application': 'Focus on timely harvesting when 60% bolls are open',
        },
      ],
    },
    'Rice': {
      'Sowing': [
        {
          'name': 'DAP (Di-Ammonium Phosphate)',
          'urdu': 'ڈی اے پی کھاد',
          'brands': 'Engro DAP, Sarsabz DAP, FFC DAP',
          'quantity': '40 kg per acre',
          'timing': 'Apply before transplanting into flooded field',
          'cost': 'PKR 6,000 per acre',
          'benefit': 'Establishes strong root system for seedlings',
          'deficiency_symptoms': 'Dark green to purple coloring on leaves. Stunted seedlings with poor tillering. Roots appear brown and underdeveloped.',
          'application': 'Broadcast in flooded field 1-2 days before transplanting',
        },
        {
          'name': 'Zinc Sulphate',
          'urdu': 'زنک سلفیٹ',
          'brands': 'Engro Zn, Sarsabz Zinc, Aga Khan Zinc',
          'quantity': '5 kg per acre',
          'timing': 'Broadcast in flooded field before transplanting',
          'cost': 'PKR 1,500 per acre',
          'benefit': 'Prevents zinc deficiency extremely common in rice paddies',
          'deficiency_symptoms': 'Brown rusty spots on leaves (khaira disease). Mid-rib of leaves turns white or pale. Stunted growth in patches across field.',
          'application': 'Mix with dry sand and broadcast evenly in flooded field',
        },
        {
          'name': 'Single Super Phosphate (SSP)',
          'urdu': 'سنگل سپر فاسفیٹ',
          'brands': 'Sarsabz SSP, Fauji SSP, Local SSP',
          'quantity': '50 kg per acre',
          'timing': 'Apply at land preparation before flooding',
          'cost': 'PKR 2,500 per acre',
          'benefit': 'Provides phosphorus and sulphur for early root growth',
          'deficiency_symptoms': 'Purple coloration on lower leaf surface. Slow establishment after transplanting. Reduced root branching.',
          'application': 'Mix into soil during final land preparation',
        },
      ],
      'Vegetative': [
        {
          'name': 'Urea — First Dose',
          'urdu': 'یوریا کھاد — پہلی قسط',
          'brands': 'Engro Urea, Sona Urea, Fatima Urea, FFC Urea',
          'quantity': '35 kg per acre',
          'timing': 'Apply 2-3 weeks after transplanting',
          'cost': 'PKR 2,800 per acre',
          'benefit': 'Promotes active tillering and leaf area expansion',
          'deficiency_symptoms': 'Yellowing starting from older leaves. Reduced number of tillers. Pale green crop with slow growth.',
          'application': 'Drain field to moist condition, broadcast urea, flood after 2 days',
        },
        {
          'name': 'Urea — Second Dose',
          'urdu': 'یوریا کھاد — دوسری قسط',
          'brands': 'Engro Urea, Sona Urea, Fatima Urea',
          'quantity': '25 kg per acre',
          'timing': 'Apply at maximum tillering stage (35-40 days)',
          'cost': 'PKR 2,000 per acre',
          'benefit': 'Sustains growth and maximizes productive tillers',
          'deficiency_symptoms': 'Early yellowing of flag leaf. Reduced panicle size. Poor grain set at heading stage.',
          'application': 'Same as first dose — drain, apply, re-flood after 2 days',
        },
        {
          'name': 'Potash MOP',
          'urdu': 'پوٹاش کھاد',
          'brands': 'Imported MOP, Engro MOP',
          'quantity': '25 kg per acre',
          'timing': 'Apply at active tillering stage',
          'cost': 'PKR 3,000 per acre',
          'benefit': 'Strengthens stems and reduces lodging risk',
          'deficiency_symptoms': 'Brown scorching of leaf tips and margins. Weak stems prone to falling. Irregular maturity across field.',
          'application': 'Broadcast in drained field and flood after application',
        },
      ],
      'Flowering': [
        {
          'name': 'Urea — Panicle Dose',
          'urdu': 'یوریا کھاد — بالی کی قسط',
          'brands': 'Engro Urea, Sona Urea, FFC Urea',
          'quantity': '20 kg per acre',
          'timing': 'Apply at panicle initiation (50-55 days)',
          'cost': 'PKR 1,600 per acre',
          'benefit': 'Increases grain number per panicle and grain size',
          'deficiency_symptoms': 'Small panicles with few grains. Pale flag leaf color. Poor pollen viability and grain filling.',
          'application': 'Apply before irrigation at panicle initiation stage',
        },
        {
          'name': 'Silica (Silicon)',
          'urdu': 'سیلیکا کھاد',
          'brands': 'Imported Silicon, Aga Khan Silica',
          'quantity': '10 kg per acre',
          'timing': 'Apply before flowering stage',
          'cost': 'PKR 1,200 per acre',
          'benefit': 'Strengthens stem, reduces lodging and improves blast resistance',
          'deficiency_symptoms': 'Soft drooping leaves. High susceptibility to blast disease. Stems break easily near soil level.',
          'application': 'Broadcast in field and incorporate into soil with irrigation',
        },
        {
          'name': 'Sulphur (Gypsum)',
          'urdu': 'گندھک کھاد',
          'brands': 'Local Gypsum, Imported Sulphur, Sarsabz S',
          'quantity': '10 kg per acre',
          'timing': 'Apply at heading stage',
          'cost': 'PKR 600 per acre',
          'benefit': 'Improves grain protein content and aroma in basmati rice',
          'deficiency_symptoms': 'Yellowing of young leaves (unlike nitrogen deficiency which starts from old leaves). Reduced grain aroma.',
          'application': 'Broadcast in field before irrigation',
        },
      ],
      'Harvest': [
        {
          'name': 'No Fertilizer Required',
          'urdu': 'کوئی کھاد نہیں',
          'brands': 'N/A',
          'quantity': 'N/A',
          'timing': 'Stop all fertilizer 3 weeks before harvest',
          'cost': 'PKR 0',
          'benefit': 'Allows grain to mature, dry and fill naturally',
          'deficiency_symptoms': 'N/A — crop is in maturity phase',
          'application': 'Drain field 10-15 days before harvest for easier cutting',
        },
      ],
    },
  };

  List<Map<String, String>> get _currentFertilizers {
    if (_selectedCrop == null || _selectedStage == null) return [];
    return _fertilizerData[_selectedCrop]?[_selectedStage] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Fertilizer Guide'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'کھاد گائیڈ',
                    style: TextStyle(
                      color: AppColors.leaf,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Fertilizer & Nutrition Guide',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedCrop != null
                        ? 'Showing recommendations for $_selectedCrop. Select growth stage below.'
                        : 'Select your crop and growth stage for precise fertilizer recommendations with Pakistani brand names.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Select Crop',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: _crops.map((crop) {
                final isSelected = _selectedCrop == crop;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedCrop = crop;
                      _selectedStage = null;
                    }),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: crop == 'Cotton' ? 8 : 0),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.forest
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.forest
                              : AppColors.parchment,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            crop == 'Cotton'
                                ? Icons.eco_rounded
                                : Icons.grass_rounded,
                            color: isSelected
                                ? Colors.white
                                : AppColors.moss,
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            crop,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (isSelected &&
                              widget.initialCrop != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha:0.2),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Auto-detected',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            const Text(
              'Select Growth Stage',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: _stages.map((stage) {
                final isSelected = _selectedStage == stage;
                final isEnabled = _selectedCrop != null;
                return GestureDetector(
                  onTap: isEnabled
                      ? () =>
                          setState(() => _selectedStage = stage)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.moss
                          : isEnabled
                              ? Colors.white
                              : AppColors.parchment,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.moss
                            : AppColors.parchment,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        stage,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : isEnabled
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            if (_currentFertilizers.isNotEmpty) ...[
              const Text(
                'Recommended Fertilizers',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._currentFertilizers.map((fertilizer) =>
                  _FertilizerCard(fertilizer: fertilizer)),
            ],

            if (_selectedCrop == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.grass_rounded,
                          size: 40, color: AppColors.moss.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'Select your crop and growth stage to see fertilizer recommendations with Pakistani brand names',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FertilizerCard extends StatelessWidget {
  const _FertilizerCard({required this.fertilizer});

  final Map<String, String> fertilizer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.parchment),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.moss.withValues(alpha:0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.moss.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grass_rounded,
                    color: AppColors.moss,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fertilizer['name']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        fertilizer['urdu']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.moss,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pakistani Brands
                _InfoRow(
                  icon: Icons.store_rounded,
                  label: 'Pakistani Brands',
                  value: fertilizer['brands']!,
                  color: AppColors.clay,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.scale_rounded,
                  label: 'Quantity',
                  value: fertilizer['quantity']!,
                  color: AppColors.moss,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  label: 'When to Apply',
                  value: fertilizer['timing']!,
                  color: AppColors.stone,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.agriculture_rounded,
                  label: 'How to Apply',
                  value: fertilizer['application']!,
                  color: AppColors.forest,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Estimated Cost',
                  value: fertilizer['cost']!,
                  color: AppColors.success,
                ),
                const SizedBox(height: 12),

                // Deficiency Symptoms Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha:0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha:0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 16, color: AppColors.danger),
                          SizedBox(width: 6),
                          Text(
                            'Deficiency Symptoms',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fertilizer['deficiency_symptoms']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}