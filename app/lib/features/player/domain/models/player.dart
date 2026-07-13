import 'dart:convert';

class Player {
  final int? id;
  final String name;
  final String dominantHand;
  final String language;
  final String measurementSystem;
  final String theme;
  final bool isActive;
  // Task 05 Player Profile: career-profile fields. All optional so a bare
  // player (name only) is still valid.
  final String? avatarPath;
  final int? age;
  final String? gender;
  final String? clubRegion;
  final String? rank; // H, G, F...
  final String? mainGame; // 9ball / 10ball / 8ball
  final String? goal;
  final List<String> playStyles; // safe/attack/fast/steady/control/power-break
  final List<String> trainingGoals;
  final DateTime? startedPlayingAt;
  final bool hasCompeted;
  final int? hoursPerWeek;
  final DateTime createdAt;
  final DateTime updatedAt;

  Player({
    this.id,
    required this.name,
    required this.dominantHand,
    required this.language,
    required this.measurementSystem,
    required this.theme,
    this.isActive = true,
    this.avatarPath,
    this.age,
    this.gender,
    this.clubRegion,
    this.rank,
    this.mainGame,
    this.goal,
    this.playStyles = const [],
    this.trainingGoals = const [],
    this.startedPlayingAt,
    this.hasCompeted = false,
    this.hoursPerWeek,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Player copyWith({
    int? id,
    String? name,
    String? dominantHand,
    String? language,
    String? measurementSystem,
    String? theme,
    bool? isActive,
    String? avatarPath,
    int? age,
    String? gender,
    String? clubRegion,
    String? rank,
    String? mainGame,
    String? goal,
    List<String>? playStyles,
    List<String>? trainingGoals,
    DateTime? startedPlayingAt,
    bool? hasCompeted,
    int? hoursPerWeek,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      dominantHand: dominantHand ?? this.dominantHand,
      language: language ?? this.language,
      measurementSystem: measurementSystem ?? this.measurementSystem,
      theme: theme ?? this.theme,
      isActive: isActive ?? this.isActive,
      avatarPath: avatarPath ?? this.avatarPath,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      clubRegion: clubRegion ?? this.clubRegion,
      rank: rank ?? this.rank,
      mainGame: mainGame ?? this.mainGame,
      goal: goal ?? this.goal,
      playStyles: playStyles ?? this.playStyles,
      trainingGoals: trainingGoals ?? this.trainingGoals,
      startedPlayingAt: startedPlayingAt ?? this.startedPlayingAt,
      hasCompeted: hasCompeted ?? this.hasCompeted,
      hoursPerWeek: hoursPerWeek ?? this.hoursPerWeek,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get initials {
    if (name.isEmpty) return 'P';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Months since the player started (for the "you've played N months" line).
  int? get monthsPlaying {
    if (startedPlayingAt == null) return null;
    final now = DateTime.now();
    return (now.year - startedPlayingAt!.year) * 12 +
        (now.month - startedPlayingAt!.month);
  }

  // JSON helpers for the multi-select list columns.
  static List<String> decodeList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {}
    return const [];
  }

  static String encodeList(List<String> list) => jsonEncode(list);
}

/// Task 05: selectable play styles (multi-select). Stored as string codes.
class PlayStyles {
  static const String safe = 'safe';
  static const String attack = 'attack';
  static const String fast = 'fast';
  static const String steady = 'steady';
  static const String control = 'control';
  static const String powerBreak = 'power_break';

  static const List<String> all = [safe, attack, fast, steady, control, powerBreak];

  static String label(String code, String locale) {
    final vi = locale == 'vi';
    switch (code) {
      case safe:
        return vi ? 'An toàn' : 'Safe';
      case attack:
        return vi ? 'Tấn công' : 'Attack';
      case fast:
        return vi ? 'Đánh nhanh' : 'Fast';
      case steady:
        return vi ? 'Đánh chắc' : 'Steady';
      case control:
        return vi ? 'Kiểm soát' : 'Control';
      case powerBreak:
        return vi ? 'Phá mạnh' : 'Power break';
      default:
        return code;
    }
  }
}

/// Task 05: common training goals (multi-select). Stored as string codes.
class TrainingGoals {
  static const String rankUp = 'rank_up';
  static const String breakPower = 'break_power';
  static const String position = 'position';
  static const String jump = 'jump';
  static const String safety = 'safety';
  static const String tournament = 'tournament';

  static const List<String> all = [rankUp, breakPower, position, jump, safety, tournament];

  static String label(String code, String locale) {
    final vi = locale == 'vi';
    switch (code) {
      case rankUp:
        return vi ? 'Lên hạng' : 'Rank up';
      case breakPower:
        return vi ? 'Ổn định lực phá' : 'Break power';
      case position:
        return vi ? 'Điều bi' : 'Position';
      case jump:
        return vi ? 'Jump' : 'Jump';
      case safety:
        return vi ? 'Safety' : 'Safety';
      case tournament:
        return vi ? 'Thi đấu giải' : 'Tournament';
      default:
        return code;
    }
  }
}

enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert,
  professional;

  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
      case SkillLevel.professional:
        return 'Professional';
    }
  }
}
