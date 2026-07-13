import 'dart:convert';

/// Task 06: pre-match + post-match state for one Match. Pure data — no Coach /
/// Statistics / AI reads it yet. Both halves are optional and entered at
/// different times (before vs after the match).
class MatchContext {
  final int? id;
  final int matchId;
  // --- Pre-match ---
  final String? purpose;
  final String? opponent;
  final String? tableFamiliarity;
  final String? roomFamiliarity;
  final String? lighting;
  final String? warmupLevel;
  final List<String> matchGoals;
  final DateTime? preRecordedAt;
  // --- Post-match ---
  final String? fatigueLevel;
  final List<String> fatigueAreas;
  final String? mentalState;
  final int? selfRating; // 1..5
  final String? biggestFactor;
  final String? biggestFactorNote;
  final DateTime? postRecordedAt;

  MatchContext({
    this.id,
    required this.matchId,
    this.purpose,
    this.opponent,
    this.tableFamiliarity,
    this.roomFamiliarity,
    this.lighting,
    this.warmupLevel,
    this.matchGoals = const [],
    this.preRecordedAt,
    this.fatigueLevel,
    this.fatigueAreas = const [],
    this.mentalState,
    this.selfRating,
    this.biggestFactor,
    this.biggestFactorNote,
    this.postRecordedAt,
  });

  bool get hasPre => preRecordedAt != null;
  bool get hasPost => postRecordedAt != null;

  MatchContext copyWith({
    int? id,
    int? matchId,
    String? purpose,
    String? opponent,
    String? tableFamiliarity,
    String? roomFamiliarity,
    String? lighting,
    String? warmupLevel,
    List<String>? matchGoals,
    DateTime? preRecordedAt,
    String? fatigueLevel,
    List<String>? fatigueAreas,
    String? mentalState,
    int? selfRating,
    String? biggestFactor,
    String? biggestFactorNote,
    DateTime? postRecordedAt,
  }) {
    return MatchContext(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      purpose: purpose ?? this.purpose,
      opponent: opponent ?? this.opponent,
      tableFamiliarity: tableFamiliarity ?? this.tableFamiliarity,
      roomFamiliarity: roomFamiliarity ?? this.roomFamiliarity,
      lighting: lighting ?? this.lighting,
      warmupLevel: warmupLevel ?? this.warmupLevel,
      matchGoals: matchGoals ?? this.matchGoals,
      preRecordedAt: preRecordedAt ?? this.preRecordedAt,
      fatigueLevel: fatigueLevel ?? this.fatigueLevel,
      fatigueAreas: fatigueAreas ?? this.fatigueAreas,
      mentalState: mentalState ?? this.mentalState,
      selfRating: selfRating ?? this.selfRating,
      biggestFactor: biggestFactor ?? this.biggestFactor,
      biggestFactorNote: biggestFactorNote ?? this.biggestFactorNote,
      postRecordedAt: postRecordedAt ?? this.postRecordedAt,
    );
  }

  static List<String> decodeList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {}
    return const [];
  }

  static String encodeList(List<String> list) => jsonEncode(list);
}

// ---- Task 06 option vocabularies (string codes + bilingual labels) ----

class MatchPurpose {
  static const practice = 'practice';
  static const compete = 'compete';
  static const tournament = 'tournament';
  static const social = 'social';
  static const all = [practice, compete, tournament, social];
  static String label(String c, String l) {
    final vi = l == 'vi';
    switch (c) {
      case practice: return vi ? 'Luyện tập' : 'Practice';
      case compete: return vi ? 'Thi đấu' : 'Compete';
      case tournament: return vi ? 'Giải đấu' : 'Tournament';
      case social: return vi ? 'Giao lưu' : 'Social';
      default: return c;
    }
  }
}

class MatchOpponent {
  static const solo = 'solo';
  static const friend = 'friend';
  static const strong = 'strong';
  static const even = 'even';
  static const weak = 'weak';
  static const all = [solo, friend, strong, even, weak];
  static String label(String c, String l) {
    final vi = l == 'vi';
    switch (c) {
      case solo: return vi ? 'Chơi một mình' : 'Solo';
      case friend: return vi ? 'Bạn bè' : 'Friend';
      case strong: return vi ? 'Đối thủ mạnh' : 'Strong';
      case even: return vi ? 'Ngang trình' : 'Even';
      case weak: return vi ? 'Đối thủ yếu' : 'Weak';
      default: return c;
    }
  }
}

class Familiarity {
  static const familiar = 'familiar';
  static const unfamiliar = 'unfamiliar';
  static const all = [familiar, unfamiliar];
  static String label(String c, String l) {
    final vi = l == 'vi';
    if (c == familiar) return vi ? 'Quen' : 'Familiar';
    if (c == unfamiliar) return vi ? 'Lạ' : 'Unfamiliar';
    return c;
  }
}

class Lighting {
  static const good = 'good';
  static const normal = 'normal';
  static const poor = 'poor';
  static const all = [good, normal, poor];
  static String label(String c, String l) {
    final vi = l == 'vi';
    switch (c) {
      case good: return vi ? 'Tốt' : 'Good';
      case normal: return vi ? 'Bình thường' : 'Normal';
      case poor: return vi ? 'Kém' : 'Poor';
      default: return c;
    }
  }
}

class WarmupLevel {
  static const none = 'none';
  static const light = 'light';
  static const full = 'full';
  static const playedHot = 'played_hot';
  static const all = [none, light, full, playedHot];
  static String label(String c, String l) {
    final vi = l == 'vi';
    switch (c) {
      case none: return vi ? 'Chưa khởi động' : 'None';
      case light: return vi ? 'Khởi động nhẹ' : 'Light';
      case full: return vi ? 'Khởi động đầy đủ' : 'Full';
      case playedHot: return vi ? 'Đã đánh nóng' : 'Played hot';
      default: return c;
    }
  }
}

class MatchGoal {
  static const stopShot = 'stop_shot';
  static const position = 'position';
  static const breakGoal = 'break';
  static const win = 'win';
  static const tournament = 'tournament';
  static const all = [stopShot, position, breakGoal, win, tournament];
  static String label(String c, String l) {
    final vi = l == 'vi';
    switch (c) {
      case stopShot: return vi ? 'Luyện Stop Shot' : 'Stop Shot';
      case position: return vi ? 'Luyện Position' : 'Position';
      case breakGoal: return vi ? 'Luyện Break' : 'Break';
      case win: return vi ? 'Chỉ muốn thắng' : 'Just win';
      case tournament: return vi ? 'Chơi giải' : 'Tournament';
      default: return c;
    }
  }
}

class FatigueLevel {
  static const none = 'none';
  static const light = 'light';
  static const tired = 'tired';
  static const veryTired = 'very_tired';
  static const all = [none, light, tired, veryTired];
  static String label(String c, String l) {
    final vi = l == 'vi';
    switch (c) {
      case none: return vi ? 'Không mệt' : 'None';
      case light: return vi ? 'Mệt nhẹ' : 'Light';
      case tired: return vi ? 'Mệt' : 'Tired';
      case veryTired: return vi ? 'Rất mệt' : 'Very tired';
      default: return c;
    }
  }
}

class FatigueArea {
  static const arm = 'arm';
  static const shoulder = 'shoulder';
  static const wrist = 'wrist';
  static const back = 'back';
  static const eyes = 'eyes';
  static const stamina = 'stamina';
  static const all = [arm, shoulder, wrist, back, eyes, stamina];
  static String label(String c, String l) {
    final vi = l == 'vi';
    switch (c) {
      case arm: return vi ? 'Tay' : 'Arm';
      case shoulder: return vi ? 'Vai' : 'Shoulder';
      case wrist: return vi ? 'Cổ tay' : 'Wrist';
      case back: return vi ? 'Lưng' : 'Back';
      case eyes: return vi ? 'Mắt' : 'Eyes';
      case stamina: return vi ? 'Thể lực' : 'Stamina';
      default: return c;
    }
  }
}

class MentalState {
  static const veryConfident = 'very_confident';
  static const ok = 'ok';
  static const normal = 'normal';
  static const unsure = 'unsure';
  static const pressure = 'pressure';
  static const all = [veryConfident, ok, normal, unsure, pressure];
  static String label(String c, String l) {
    final vi = l == 'vi';
    switch (c) {
      case veryConfident: return vi ? 'Rất tự tin' : 'Very confident';
      case ok: return vi ? 'Ổn' : 'OK';
      case normal: return vi ? 'Bình thường' : 'Normal';
      case unsure: return vi ? 'Thiếu tự tin' : 'Unsure';
      case pressure: return vi ? 'Áp lực' : 'Pressure';
      default: return c;
    }
  }
}

class BiggestFactor {
  static const breakFactor = 'break';
  static const position = 'position';
  static const easyMiss = 'easy_miss';
  static const mental = 'mental';
  static const fatigue = 'fatigue';
  static const opponent = 'opponent';
  static const table = 'table';
  static const other = 'other';
  static const all = [breakFactor, position, easyMiss, mental, fatigue, opponent, table, other];
  static String label(String c, String l) {
    final vi = l == 'vi';
    switch (c) {
      case breakFactor: return vi ? 'Break kém' : 'Weak break';
      case position: return vi ? 'Điều bi' : 'Position';
      case easyMiss: return vi ? 'Miss bi dễ' : 'Easy miss';
      case mental: return vi ? 'Tâm lý' : 'Mental';
      case fatigue: return vi ? 'Mệt' : 'Fatigue';
      case opponent: return vi ? 'Đối thủ quá mạnh' : 'Opponent too strong';
      case table: return vi ? 'Không quen bàn' : 'Unfamiliar table';
      case other: return vi ? 'Khác' : 'Other';
      default: return c;
    }
  }
}
