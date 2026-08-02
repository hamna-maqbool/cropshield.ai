class SymptomMatcherService {
  static const Map<String, List<String>> _diseaseKeywords = {
    'cotton_army_worm': [
      'worm', 'caterpillar', 'larvae', 'holes', 'eaten', 'insect',
      'pest', 'chewed', 'defoliation', 'army'
    ],
    'cotton_bacterial_blight': [
      'angular', 'water soaked', 'watersoaked', 'bacterial', 'blight',
      'brown edges', 'lesion', 'cotton', 'dark', 'wet'
    ],
    'cotton_curl_virus': [
      'curl', 'curling', 'twisted', 'virus', 'upward', 'thick',
      'thickening', 'vein', 'cotton', 'wrinkled'
    ],
    'cotton_healthy_leaf': [
      'healthy', 'normal', 'green', 'fine', 'good', 'no problem',
      'no disease', 'looks fine'
    ],
    'cotton_powdery_mildew': [
      'white powder', 'powdery', 'mildew', 'white coating',
      'white spots', 'fungal', 'dusty', 'white growth'
    ],
    'cotton_target_spot': [
      'target', 'circular', 'concentric', 'rings', 'round spots',
      'brown circle', 'bullseye', 'spot'
    ],
    'rice_bacterialblight': [
      'yellow edges', 'white edges', 'leaf margin', 'bacterial',
      'blight', 'rice', 'yellowing edge', 'wilting'
    ],
    'rice_blast': [
      'diamond', 'grey center', 'blast', 'rice', 'spindle',
      'gray lesion', 'neck rot', 'panicle'
    ],
    'rice_brownspot': [
      'brown spot', 'oval', 'brown lesion', 'yellow halo',
      'rice', 'brown oval', 'spots'
    ],
    'rice_healthy': [
      'healthy', 'normal', 'green', 'fine', 'good',
      'no problem', 'no disease', 'looks fine', 'rice'
    ],
    'rice_leafsmut': [
      'black powder', 'smut', 'black spots', 'powdery black',
      'dark powder', 'rice', 'black mass'
    ],
    'rice_tungro': [
      'yellow orange', 'orange', 'tungro', 'discoloration',
      'stunted', 'yellow leaves', 'rice', 'viral'
    ],
  };

  static Map<String, dynamic> analyzeSymptoms(String text) {
    final lowerText = text.toLowerCase();
    final Map<String, int> scores = {};

    _diseaseKeywords.forEach((disease, keywords) {
      int score = 0;
      for (final keyword in keywords) {
        if (lowerText.contains(keyword)) {
          score++;
        }
      }
      if (score > 0) scores[disease] = score;
    });

    if (scores.isEmpty) {
      return {
        'disease': 'Unknown',
        'confidence': 0.0,
        'rawLabel': 'unknown',
        'summary': 'No matching symptoms found. Please describe more specific symptoms like color, shape, or location of affected areas.',
      };
    }

    final bestMatch = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    final totalKeywords = _diseaseKeywords[bestMatch.key]!.length;
    final confidence = (bestMatch.value / totalKeywords).clamp(0.3, 0.95);
    final displayName = _formatLabel(bestMatch.key);

    return {
      'disease': displayName,
      'confidence': confidence,
      'rawLabel': bestMatch.key,
      'summary': _generateSummary(bestMatch.key, confidence),
    };
  }

  static String _formatLabel(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  static String _generateSummary(String rawLabel, double confidence) {
    final percent = (confidence * 100).round();
    final Map<String, String> summaries = {
      'cotton_army_worm':
          'Symptoms suggest army worm infestation with $percent% match. Larval feeding patterns described are consistent with this pest.',
      'cotton_bacterial_blight':
          'Symptoms match cotton bacterial blight with $percent% confidence. Angular water-soaked lesions are characteristic of this disease.',
      'cotton_curl_virus':
          'Symptoms suggest cotton leaf curl virus with $percent% match. Leaf curling and thickening are key indicators.',
      'cotton_healthy_leaf':
          'Described symptoms suggest the crop is healthy with $percent% confidence. Continue regular monitoring.',
      'cotton_powdery_mildew':
          'Symptoms match powdery mildew with $percent% confidence. White powdery growth is a classic sign of fungal infection.',
      'cotton_target_spot':
          'Symptoms suggest target spot disease with $percent% match. Circular concentric ring patterns are characteristic.',
      'rice_bacterialblight':
          'Symptoms match rice bacterial blight with $percent% confidence. Yellowing leaf margins indicate bacterial infection.',
      'rice_blast':
          'Symptoms suggest rice blast with $percent% match. Diamond-shaped grey lesions are hallmarks of this disease.',
      'rice_brownspot':
          'Symptoms match rice brown spot with $percent% confidence. Oval brown lesions with yellow halos are present.',
      'rice_healthy':
          'Described symptoms suggest the rice crop is healthy with $percent% confidence. Continue regular monitoring.',
      'rice_leafsmut':
          'Symptoms suggest rice leaf smut with $percent% match. Black powdery masses indicate fungal smut infection.',
      'rice_tungro':
          'Symptoms match rice tungro virus with $percent% confidence. Yellow-orange discoloration is a key indicator.',
    };

    return summaries[rawLabel] ??
        'Symptoms analyzed with $percent% confidence. Consult an agricultural expert for confirmation.';
  }
}