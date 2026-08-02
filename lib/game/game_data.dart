// game_data.dart
//
// Static game data: maps each disease name to its real leaf photo(s)
// from assets/game_leaves/, grouped by crop. Also defines the simple
// event/decision text shown to the farmer during the game.

class GameData {
  // ---- Cotton ----
  static const Map<String, List<String>> cottonDiseaseImages = {
    'Cotton Army Worm': ['assets/game_leaves/army_worm.jpeg'],
    'Cotton Bacterial Blight': [
      'assets/game_leaves/bacterial_blight1.jpeg',
      'assets/game_leaves/bacterial_blight2.jpeg',
    ],
    'Cotton Curl Virus': [
      'assets/game_leaves/curl_virus.jpeg',
      'assets/game_leaves/curl_virus2.jpeg',
    ],
    'Cotton Powdery Mildew': [
      'assets/game_leaves/powdery_mildew1.jpeg',
      'assets/game_leaves/powdery_mildew2.jpeg',
      'assets/game_leaves/powdery_mildew3.jpeg',
    ],
    'Cotton Target Spot': [
      'assets/game_leaves/target_spot1.jpeg',
      'assets/game_leaves/target_spot2.jpeg',
    ],
  };

  static const List<String> cottonHealthyImages = [
    'assets/game_leaves/healthy_leaf1.jpeg',
    'assets/game_leaves/healthy_leaf2.jpeg',
  ];

  // ---- Rice ----
  static const Map<String, List<String>> riceDiseaseImages = {
    'Rice Bacterial Blight': [
      'assets/game_leaves/rice_bacterialblight1.jpeg',
      'assets/game_leaves/rice_bacterialblight2.jpeg',
    ],
    'Rice Blast': [
      'assets/game_leaves/rice_blast1.jpeg',
      'assets/game_leaves/rice_blast2.jpeg',
    ],
    'Rice Brown Spot': [
      'assets/game_leaves/rice_brownspot1.jpeg',
      'assets/game_leaves/rice_brownspot2.jpeg',
    ],
    'Rice Leaf Smut': [
      'assets/game_leaves/rice_leafsmut1.jpeg',
      'assets/game_leaves/rice_leafsmut2.jpeg',
    ],
    'Rice Tungro': ['assets/game_leaves/rice_tungro.jpeg'],
  };

  static const List<String> riceHealthyImages = [
    'assets/game_leaves/rice_healthy1.jpeg',
    'assets/game_leaves/rice_healthy2.jpeg',
  ];

  // Returns the disease-name -> image-list map for a given crop.
  static Map<String, List<String>> diseaseImagesFor(String crop) {
    return crop == 'Cotton' ? cottonDiseaseImages : riceDiseaseImages;
  }

  static List<String> healthyImagesFor(String crop) {
    return crop == 'Cotton' ? cottonHealthyImages : riceHealthyImages;
  }
}

// One week's random event during the game.
enum GameEventType { calm, disease, weatherGood, weatherBad }

class GameEvent {
  final GameEventType type;
  final String? diseaseName;   // set only when type == disease
  final String? imagePath;     // set only when type == disease
  final String title;
  final String description;

  GameEvent({
    required this.type,
    required this.title,
    required this.description,
    this.diseaseName,
    this.imagePath,
  });
}
