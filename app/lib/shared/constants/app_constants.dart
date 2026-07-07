class AppConstants {
  // App
  static const String appName = 'Pool OS';
  static const String appNameVi = 'Pool OS';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'pool_os.db';

  // Default player
  static const String defaultPlayerName = 'Player';
  static const DominantHand defaultDominantHand = DominantHand.right;
  static const Language defaultLanguage = Language.vietnamese;
  static const MeasurementSystem defaultMeasurementSystem = MeasurementSystem.cm;

  // Session types
  static const String sessionTypePractice = 'practice';
  static const String sessionTypeMatch = 'match';
  static const String sessionTypeTournament = 'tournament';
  static const String sessionTypeTraining = 'training';

  // Game types (for Match)
  static const String gameTypeWarmUp = 'warm_up';
  static const String gameTypeRaceTo5 = 'race_to_5';
  static const String gameTypeRaceTo7 = 'race_to_7';
  static const String gameTypeGhostChallenge = 'ghost_challenge';
  static const String gameTypeChallengeMatch = 'challenge_match';
  static const String gameTypeLeagueMatch = 'league_match';
  static const String gameTypeTournamentMatch = 'tournament_match';
  static const String gameTypePracticeMatch = 'practice_match';
  static const String gameTypeDrill = 'drill';

  // Rack result
  static const bool rackWin = true;
  static const bool rackLoss = false;

  // Position quality
  static const String positionQualityPerfect = 'perfect';
  static const String positionQualityGood = 'good';
  static const String positionQualityPlayable = 'playable';
  static const String positionQualityRecovery = 'recovery';
  static const String positionQualityBad = 'bad';

  // Shot difficulty
  static const String shotDifficultyEasy = 'easy';
  static const String shotDifficultyMedium = 'medium';
  static const String shotDifficultyHard = 'hard';
  static const String shotDifficultyExtreme = 'extreme';

  // Event categories
  static const String eventCategoryStroke = 'stroke';
  static const String eventCategoryPosition = 'position';
  static const String eventCategoryDecision = 'decision';
  static const String eventCategoryPattern = 'pattern';
  static const String eventCategoryBreak = 'break';
  static const String eventCategoryMental = 'mental';
  static const String eventCategoryEquipment = 'equipment';
  static const String eventCategoryTraining = 'training';
  static const String eventCategoryEnvironment = 'environment';
  static const String eventCategorySpecial = 'special';

  // Event severity
  static const String eventSeverityLow = 'low';
  static const String eventSeverityMedium = 'medium';
  static const String eventSeverityHigh = 'high';
  static const String eventSeverityCritical = 'critical';

  // Theme
  static const String themeDark = 'dark';
  static const String themeLight = 'light';
}

enum DominantHand { left, right }

enum Language { english, vietnamese }

enum MeasurementSystem { cm, inch }
