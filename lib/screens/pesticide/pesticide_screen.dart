import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PesticideScreen extends StatefulWidget {
  const PesticideScreen({super.key, this.initialCrop, this.initialPest});

  final String? initialCrop;
  final String? initialPest;

  @override
  State<PesticideScreen> createState() => _PesticideScreenState();
}

class _PesticideScreenState extends State<PesticideScreen> {
  String? _selectedCrop;
  String? _selectedPest;

  String _areaUnit = 'Acres'; // 'Acres' or 'Kanals'
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _tankController =
      TextEditingController(text: '16');
  DateTime _sprayDate = DateTime.now();

  final List<String> _crops = ['Cotton', 'Rice'];

  @override
  void initState() {
    super.initState();
    if (widget.initialCrop != null) _selectedCrop = widget.initialCrop;
    if (widget.initialPest != null) _selectedPest = widget.initialPest;
  }

  @override
  void dispose() {
    _areaController.dispose();
    _tankController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Pesticide recommendation data
  // doseValue is per ACRE. waterPerAcreL is spray volume per acre (L).
  // costPerAcreRs is an approximate market estimate for the product only.
  // ---------------------------------------------------------------------
  static const Map<String, Map<String, Map<String, dynamic>>> _pesticideData = {
    'Cotton': {
      'Army Worm': {
        'urdu': 'فوجی سنڈی',
        'type': 'Insecticide',
        'activeIngredient': 'Emamectin Benzoate 1.9% EC',
        'brands': 'Proclaim, Ustad, Match 5EC (alt: Coragen)',
        'moaGroup': 'IRAC Group 6 (avoid repeated use — rotate group)',
        'doseValue': 200.0,
        'doseUnit': 'ml',
        'waterPerAcreL': 100.0,
        'phiDays': 7,
        'costPerAcreRs': 1200.0,
        'precautions':
            'Spray in the evening when bees are inactive. Ensure full leaf coverage including undersides where larvae hide. Do not exceed 2 applications per season with the same mode-of-action group.',
      },
      'Bacterial Blight': {
        'urdu': 'بیکٹیریل بلائٹ',
        'type': 'Bactericide',
        'activeIngredient': 'Copper Oxychloride 50% WP',
        'brands': 'Cuprofix, Copper King, Kocide',
        'moaGroup': 'Copper-based — low resistance risk',
        'doseValue': 400.0,
        'doseUnit': 'g',
        'waterPerAcreL': 150.0,
        'phiDays': 3,
        'costPerAcreRs': 800.0,
        'precautions':
            'Apply preventively before rain or dew-heavy mornings. Do not tank-mix with other chemicals unless label-approved. Remove and burn severely infected plant debris after harvest.',
      },
      'Curl Virus': {
        'urdu': 'پتہ مروڑ وائرس',
        'type': 'Insecticide (whitefly vector control)',
        'activeIngredient': 'Imidacloprid 200 SL',
        'brands': 'Confidor, Admire, Tatafen',
        'moaGroup': 'IRAC Group 4A — rotate with Group 9 or 23 to prevent resistance',
        'doseValue': 100.0,
        'doseUnit': 'ml',
        'waterPerAcreL': 150.0,
        'phiDays': 15,
        'costPerAcreRs': 1000.0,
        'precautions':
            'This controls the whitefly vector, not the virus itself — infected plants cannot be cured. Remove and destroy infected plants early. Clear weed hosts around field borders.',
      },
      'Powdery Mildew': {
        'urdu': 'سفید پھپھوندی',
        'type': 'Fungicide',
        'activeIngredient': 'Sulphur 80% WP',
        'brands': 'Thiovit, Kumulus, Cosavet',
        'moaGroup': 'FRAC Group M2 (multi-site) — low resistance risk',
        'doseValue': 250.0,
        'doseUnit': 'g',
        'waterPerAcreL': 150.0,
        'phiDays': 5,
        'costPerAcreRs': 700.0,
        'precautions':
            'Never apply sulphur when temperature exceeds 32°C — it will scorch leaves. Apply in cooler morning or evening hours. Ensure good air circulation between plants.',
      },
      'Target Spot': {
        'urdu': 'ٹارگٹ سپاٹ',
        'type': 'Fungicide',
        'activeIngredient': 'Mancozeb 80% WP',
        'brands': 'Dithane M-45, Indofil M-45, Manzeb',
        'moaGroup': 'FRAC Group M3 (multi-site protectant)',
        'doseValue': 400.0,
        'doseUnit': 'g',
        'waterPerAcreL': 150.0,
        'phiDays': 7,
        'costPerAcreRs': 900.0,
        'precautions':
            'Apply preventively at first symptom appearance — mancozeb is a protectant, not curative. Reapply after heavy rainfall as it washes off leaves.',
      },
    },
    'Rice': {
      'Bacterial Blight': {
        'urdu': 'بیکٹیریل بلائٹ',
        'type': 'Bactericide',
        'activeIngredient': 'Copper Oxychloride 50% WP',
        'brands': 'Cuprofix, Copper King, Kocide',
        'moaGroup': 'Copper-based — low resistance risk',
        'doseValue': 400.0,
        'doseUnit': 'g',
        'waterPerAcreL': 150.0,
        'phiDays': 3,
        'costPerAcreRs': 800.0,
        'precautions':
            'Avoid excess nitrogen fertilizer — it increases bacterial blight severity. Drain field briefly to reduce leaf wetness. Use clean irrigation water where possible.',
      },
      'Blast': {
        'urdu': 'رائس بلاسٹ',
        'type': 'Fungicide',
        'activeIngredient': 'Tricyclazole 75% WP',
        'brands': 'Beam, Kylas, Trooper',
        'moaGroup': 'FRAC Group 1 — rotate with a different group each season',
        'doseValue': 120.0,
        'doseUnit': 'g',
        'waterPerAcreL': 150.0,
        'phiDays': 14,
        'costPerAcreRs': 1100.0,
        'precautions':
            'Apply preventively at the boot-leaf stage before symptoms peak — this is the most critical timing for rice blast control. Avoid excess nitrogen, which increases susceptibility.',
      },
      'Brown Spot': {
        'urdu': 'براؤن اسپاٹ',
        'type': 'Fungicide',
        'activeIngredient': 'Mancozeb 80% WP',
        'brands': 'Dithane M-45, Indofil M-45',
        'moaGroup': 'FRAC Group M3 (multi-site protectant)',
        'doseValue': 400.0,
        'doseUnit': 'g',
        'waterPerAcreL': 150.0,
        'phiDays': 7,
        'costPerAcreRs': 850.0,
        'precautions':
            'Brown spot is often linked to potassium deficiency in the soil — correct soil fertility alongside spraying for best results. Reapply after heavy rain.',
      },
      'Leaf Smut': {
        'urdu': 'لیف سمٹ',
        'type': 'Fungicide',
        'activeIngredient': 'Propiconazole 25% EC',
        'brands': 'Tilt, Bumper',
        'moaGroup': 'FRAC Group 3 — do not exceed 2 sprays per season',
        'doseValue': 200.0,
        'doseUnit': 'ml',
        'waterPerAcreL': 150.0,
        'phiDays': 14,
        'costPerAcreRs': 950.0,
        'precautions':
            'Spray at early tillering as soon as symptoms appear. Ensure thorough leaf coverage — leaf smut spreads fast in dense canopy with high humidity.',
      },
      'Tungro': {
        'urdu': 'ٹنگرو وائرس',
        'type': 'Insecticide (leafhopper vector control)',
        'activeIngredient': 'Imidacloprid 200 SL',
        'brands': 'Confidor, Applaud, Tatafen',
        'moaGroup': 'IRAC Group 4A — rotate to avoid resistance',
        'doseValue': 100.0,
        'doseUnit': 'ml',
        'waterPerAcreL': 150.0,
        'phiDays': 15,
        'costPerAcreRs': 1000.0,
        'precautions':
            'Targets the green leafhopper vector — infected plants themselves cannot be cured. Remove and destroy infected clumps early. Use tungro-tolerant varieties in future seasons.',
      },
    },
  };

  List<String> get _currentPests {
    if (_selectedCrop == null) return [];
    return _pesticideData[_selectedCrop]!.keys.toList();
  }

  Map<String, dynamic>? get _currentPesticide {
    if (_selectedCrop == null || _selectedPest == null) return null;
    return _pesticideData[_selectedCrop]?[_selectedPest];
  }

  double get _enteredArea => double.tryParse(_areaController.text) ?? 0;
  double get _tankCapacity => double.tryParse(_tankController.text) ?? 16;

  // Converts entered area to acres for calculation (1 acre = 8 kanals)
  double get _areaInAcres =>
      _areaUnit == 'Kanals' ? _enteredArea / 8 : _enteredArea;

  Map<String, dynamic>? get _calculation {
    final p = _currentPesticide;
    final acres = _areaInAcres;
    if (p == null || acres <= 0 || _tankCapacity <= 0) return null;

    final totalProduct = (p['doseValue'] as double) * acres;
    final totalWater = (p['waterPerAcreL'] as double) * acres;
    final numTanks = (totalWater / _tankCapacity).ceil();
    final productPerTank = numTanks > 0 ? totalProduct / numTanks : 0.0;
    final totalCost = (p['costPerAcreRs'] as double) * acres;
    final safeHarvestDate =
        _sprayDate.add(Duration(days: p['phiDays'] as int));

    return {
      'totalProduct': totalProduct,
      'totalWater': totalWater,
      'numTanks': numTanks,
      'productPerTank': productPerTank,
      'totalCost': totalCost,
      'safeHarvestDate': safeHarvestDate,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pesticide = _currentPesticide;
    final calc = _calculation;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Pesticide Calculator',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.forest, AppColors.moss],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🧪 کیڑے مار دوا کیلکولیٹر',
                    style: TextStyle(
                      color: AppColors.leaf,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pesticide Calculator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Get the exact pesticide dose, tank-mix, and safe harvest date for your field size.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionLabel('Select Crop'),
            const SizedBox(height: 10),
            Row(
              children: _crops.map((crop) {
                final isSelected = _selectedCrop == crop;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedCrop = crop;
                      _selectedPest = null;
                    }),
                    child: Container(
                      margin:
                          EdgeInsets.only(right: crop == 'Cotton' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.forest : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.forest : AppColors.parchment,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(crop == 'Cotton' ? '🌿' : '🌾',
                              style: const TextStyle(fontSize: 28)),
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
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            _sectionLabel('Select Pest / Disease'),
            const SizedBox(height: 10),
            if (_selectedCrop == null)
              _placeholderBox('Select a crop first to see pest options')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentPests.map((pest) {
                  final isSelected = _selectedPest == pest;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPest = pest),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.moss : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.moss : AppColors.parchment,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        pest,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            if (pesticide != null) ...[
              const SizedBox(height: 24),
              _RecommendationCard(pesticide: pesticide),

              const SizedBox(height: 24),
              _sectionLabel('Field Size'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _areaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'e.g. 5',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.parchment),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _areaUnit,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.parchment),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Acres', child: Text('Acres')),
                        DropdownMenuItem(
                            value: 'Kanals', child: Text('Kanals')),
                      ],
                      onChanged: (v) => setState(() => _areaUnit = v!),
                    ),
                  ),
                ],
              ),
              if (_areaUnit == 'Kanals' && _enteredArea > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '= ${_areaInAcres.toStringAsFixed(2)} acres',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ),

              const SizedBox(height: 16),
              _sectionLabel('Sprayer Tank Capacity (Liters)'),
              const SizedBox(height: 10),
              TextField(
                controller: _tankController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Standard knapsack sprayer = 16 L',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.parchment),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _sectionLabel('Spray Date'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _sprayDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setState(() => _sprayDate = picked);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.parchment),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 18, color: AppColors.moss),
                      const SizedBox(width: 10),
                      Text(
                        '${_sprayDate.day}/${_sprayDate.month}/${_sprayDate.year}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (calc != null) ...[
                const SizedBox(height: 24),
                _ResultCard(pesticide: pesticide, calc: calc),
              ] else if (_enteredArea > 0) ...[
                const SizedBox(height: 16),
                _placeholderBox(
                    'Enter a valid field size and tank capacity to calculate'),
              ],
            ],

            if (_selectedCrop == null)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: [
                      const Text('🧪', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text(
                        'Select crop and pest to calculate exact pesticide quantity for your field',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppColors.textMuted, fontSize: 14),
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

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      );

  Widget _placeholderBox(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.pesticide});

  final Map<String, dynamic> pesticide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.parchment, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.moss.withOpacity(0.08),
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
                    color: AppColors.moss.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.science_rounded,
                      color: AppColors.moss, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pesticide['activeIngredient'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${pesticide['urdu']} • ${pesticide['type']}',
                        style: const TextStyle(
                          fontSize: 12,
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
                _infoRow(Icons.store_rounded, 'Pakistani Brands',
                    pesticide['brands'] as String, AppColors.clay),
                const SizedBox(height: 10),
                _infoRow(
                    Icons.rotate_right_rounded,
                    'Resistance Group',
                    pesticide['moaGroup'] as String,
                    AppColors.forest),
                const SizedBox(height: 10),
                _infoRow(
                    Icons.timer_off_rounded,
                    'Pre-Harvest Interval',
                    '${pesticide['phiDays']} days before harvest',
                    AppColors.danger),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.success.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.health_and_safety_rounded,
                              size: 16, color: AppColors.success),
                          SizedBox(width: 6),
                          Text(
                            'Safety Precautions',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pesticide['precautions'] as String,
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

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.pesticide, required this.calc});

  final Map<String, dynamic> pesticide;
  final Map<String, dynamic> calc;

  @override
  Widget build(BuildContext context) {
    final safeDate = calc['safeHarvestDate'] as DateTime;
    final unit = pesticide['doseUnit'] as String;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.moss],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Your Spray Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _resultRow(
              'Total product needed',
              '${(calc['totalProduct'] as double).toStringAsFixed(0)} $unit'),
          _resultRow('Total water needed',
              '${(calc['totalWater'] as double).toStringAsFixed(0)} L'),
          _resultRow(
              'Sprayer tank loads', '${calc['numTanks']} tank(s)'),
          _resultRow('Product per tank',
              '${(calc['productPerTank'] as double).toStringAsFixed(1)} $unit'),
          _resultRow('Estimated cost',
              'PKR ${(calc['totalCost'] as double).toStringAsFixed(0)}'),
          const Divider(color: Colors.white30, height: 24),
          Row(
            children: [
              const Icon(Icons.event_available_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Safe to harvest on or after ${safeDate.day}/${safeDate.month}/${safeDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}