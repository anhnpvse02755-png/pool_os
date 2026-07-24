class Cue {
  final int? id;
  final int? playerId;
  final String name;
  final String shaftMaterial;
  final double shaftDiameter;
  final String tipBrand;
  final String tipHardness;
  final double? tipSize;
  final String cueType;
  final double weight;
  final String balance;
  final String joint;
  final bool isActive;
  final bool isBreakCue;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cue({
    this.id,
    this.playerId,
    required this.name,
    required this.shaftMaterial,
    required this.shaftDiameter,
    required this.tipBrand,
    required this.tipHardness,
    this.tipSize,
    this.cueType = 'playing',
    required this.weight,
    required this.balance,
    required this.joint,
    this.isActive = true,
    this.isBreakCue = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Cue copyWith({
    int? id,
    int? playerId,
    String? name,
    String? shaftMaterial,
    double? shaftDiameter,
    String? tipBrand,
    String? tipHardness,
    double? tipSize,
    String? cueType,
    double? weight,
    String? balance,
    String? joint,
    bool? isActive,
    bool? isBreakCue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cue(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      name: name ?? this.name,
      shaftMaterial: shaftMaterial ?? this.shaftMaterial,
      shaftDiameter: shaftDiameter ?? this.shaftDiameter,
      tipBrand: tipBrand ?? this.tipBrand,
      tipHardness: tipHardness ?? this.tipHardness,
      tipSize: tipSize ?? this.tipSize,
      cueType: cueType ?? this.cueType,
      weight: weight ?? this.weight,
      balance: balance ?? this.balance,
      joint: joint ?? this.joint,
      isActive: isActive ?? this.isActive,
      isBreakCue: isBreakCue ?? this.isBreakCue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get shaft => '$shaftMaterial ${shaftDiameter}mm';
  String get tip => '$tipBrand $tipHardness';

  static Cue fromLegacy({
    required String name,
    required String shaft,
    required String tip,
    required double weight,
    required String balance,
    required String joint,
    bool isActive = true,
    bool isBreakCue = false,
    int? id,
    int? playerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final shaftParts = shaft.split(' ');
    final shaftMaterial = shaftParts.isNotEmpty ? shaftParts[0] : CueBrands.defaultShaftMaterial;
    double shaftDiameter = CueBrands.defaultShaftDiameter;
    if (shaftParts.length > 1) {
      final diameterStr = shaftParts[1].replaceAll('mm', '');
      shaftDiameter = double.tryParse(diameterStr) ?? CueBrands.defaultShaftDiameter;
    }

    final tipParts = tip.split(' ');
    final tipBrand = tipParts.isNotEmpty ? tipParts[0] : CueBrands.defaultTipBrand;
    final tipHardness = tipParts.length > 1 ? tipParts.sublist(1).join(' ') : CueBrands.defaultTipHardness;

    return Cue(
      id: id,
      playerId: playerId,
      name: name,
      shaftMaterial: shaftMaterial,
      shaftDiameter: shaftDiameter,
      tipBrand: tipBrand,
      tipHardness: tipHardness,
      weight: weight,
      balance: balance,
      joint: joint,
      isActive: isActive,
      isBreakCue: isBreakCue,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class CueBrands {
  static const String defaultShaftMaterial = 'Carbon Fiber';
  static const double defaultShaftDiameter = 12.75;
  static const String defaultTipBrand = 'Kamui';
  static const String defaultTipHardness = 'Medium';
  static const double defaultTipSize = 12.75;

  // Butt Brands
  static const List<String> cueBrands = [
    'Predator',
    'Mezz',
    'Cuetec',
    'Jacoby',
    'McDermott',
    'Meucci',
    'Schon',
    'Pechauer',
    'Viking',
    'Fury',
    'Poison',
    'Lucasi',
    'Rhino',
    'Becue',
    'Players',
    'OB',
    'Fury',
    'Valley',
    'Imperial',
    'Mizerak',
    'Duffy',
    'Schmelke',
    'J. Flowers',
    'Custom',
    'Other',
  ];

  // Shaft brands/models
  static const List<String> shaftMaterials = [
    'Revo',
    'Ignite',
    'Cynergy',
    'WX Sigma',
    'WX Alpha',
    'EX Pro',
    'Z3',
    '314-3',
    'Vantage',
    'Maple',
    'Ash',
    'Oak',
    'Ebony',
    'Birdseye Maple',
    'Carbon Fiber',
    'Fiberglass',
    'Graphite',
  ];

  static const List<double> shaftDiameters = [
    11.75,
    12.0,
    12.25,
    12.5,
    12.75,
    13.0,
  ];

  // Tip manufacturers only
  static const List<String> tipBrands = [
    'Kamui',
    'Zan',
    'HOW',
    'Navigator',
    'Taom',
    'Moori',
    'Triangle',
    'Tiger',
    'Elk Master',
    'Master',
    'Tempest',
    'Le Pro',
    'Everest',
    'Ultraskin',
    'Thoroughbred',
    'Other',
  ];

  // Task 04: exactly 4 cue types — 'support' dropped. A 'break_jump' cue fills
  // both the Break and Jump roles (see EquipmentRepository.getActiveCueByType).
  static const List<String> cueTypes = [
    'playing',
    'break',
    'jump',
    'break_jump',
  ];

  static const List<String> cueTypesDisplay = [
    'playing',
    'break',
    'jump',
    'break_jump',
  ];

  static const Map<String, String> cueTypeLabels = {
    'playing': 'Playing Cue',
    'break': 'Break Cue',
    'jump': 'Jump Cue',
    'break_jump': 'Break + Jump',
  };

  static const List<double> tipSizes = [
    11.5,
    11.75,
    12.0,
    12.25,
    12.5,
    12.75,
    13.0,
    13.2,
    13.5,
    13.75,
    13.9,
    14.0,
  ];

  static const List<String> tipHardnesses = [
    'Soft',
    'Medium Soft',
    'Medium',
    'Medium Hard',
    'Hard',
    'Extra Hard',
  ];

  static const List<String> balances = [
    'Center',
    'Forward',
    'Rear',
  ];

  static const List<String> joints = [
    '5/16x18',
    '3/8x10',
    'Uni-Loc',
    'Sino',
    'CueTec',
    'Radial',
    'Meier',
    'Custom',
  ];
}
