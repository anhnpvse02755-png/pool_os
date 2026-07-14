// Task 14 — Club & Community domain models.
//
// Pure Dart, no persistence annotations (mirrors tournament/ and
// training_center/). A Club groups players into a small community and lets a
// Match / Training / Tournament optionally *belong* to it. Crucially, Task 14
// does NOT modify the LOCKED RFC-301/302 recording pipeline, the Statistics
// engine, or the Task 13 tournament tables: every "belongs to a club" link is a
// separate row in a join table storing only soft-ref ids. Nothing here reads or
// writes Racks/Shots/Events. No AI, no chat, no online sync, no social feed
// (doc "Không làm").

/// A member's role inside a club (Phần 2 — phân quyền). Kept minimal: an owner
/// manages everything, an admin manages members and events, a member just
/// participates.
enum ClubRole {
  owner,
  admin,
  member;

  String get code => name;

  static ClubRole fromCode(String code) => ClubRole.values
      .firstWhere((r) => r.code == code, orElse: () => ClubRole.member);

  String get labelKey => 'club_role_$name';

  /// Whether this role can add/remove/permission other members.
  bool get canManageMembers => this == owner || this == admin;
}

/// Phần 1 — a club. [managerName] is denormalised free text (the doc lists
/// "Người quản lý" as club info), independent of the member list so it always
/// renders even before members are added. [logoPath] is a local image path
/// (nullable) — no upload/sync.
class Club {
  final int? id;
  final String name;
  final String? logoPath;
  final String? location;
  final String? description;
  final String? managerName;
  final DateTime createdAt;

  const Club({
    this.id,
    required this.name,
    this.logoPath,
    this.location,
    this.description,
    this.managerName,
    required this.createdAt,
  });

  Club copyWith({
    int? id,
    String? name,
    String? logoPath,
    String? location,
    String? description,
    String? managerName,
    DateTime? createdAt,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      location: location ?? this.location,
      description: description ?? this.description,
      managerName: managerName ?? this.managerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Phần 2 — a club member. Either a real Player ([playerId] set) or an invited
/// guest ([playerId] null). [name] is always stored so a member survives even
/// if the linked Player is deleted. [invited] marks a member added via invite
/// who has not been confirmed active yet (the doc lists "Mời" as an action).
class ClubMember {
  final int? id;
  final int clubId;
  final int? playerId; // soft ref, null for a guest / external invite
  final String name;
  final ClubRole role;
  final bool invited;
  final DateTime joinedAt;

  const ClubMember({
    this.id,
    required this.clubId,
    this.playerId,
    required this.name,
    this.role = ClubRole.member,
    this.invited = false,
    required this.joinedAt,
  });

  bool get isGuest => playerId == null;

  ClubMember copyWith({
    int? id,
    int? clubId,
    int? playerId,
    String? name,
    ClubRole? role,
    bool? invited,
    DateTime? joinedAt,
  }) {
    return ClubMember(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      playerId: playerId ?? this.playerId,
      name: name ?? this.name,
      role: role ?? this.role,
      invited: invited ?? this.invited,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

/// The kind of entity a [ClubLink] attaches to the club (Phần 4/5/6). One join
/// table with a discriminator keeps the schema small and additive.
enum ClubLinkKind {
  match,
  training,
  tournament;

  String get code => name;

  static ClubLinkKind fromCode(String code) => ClubLinkKind.values
      .firstWhere((k) => k.code == code, orElse: () => ClubLinkKind.match);
}

/// Phần 4/5/6 — a soft-ref link saying "this Match / Training session /
/// Tournament belongs to this Club". This is the ONLY coupling between Task 14
/// and the recording pipeline / Task 09 training / Task 13 tournaments:
/// [refId] points at the source row (a recorded Match id, a
/// TrainingCenterSession id, or a Tournament id) with no FK, so deleting the
/// source never cascades the club link, and none of those tables are modified.
class ClubLink {
  final int? id;
  final int clubId;
  final ClubLinkKind kind;
  final int refId; // soft ref to Match / TrainingCenterSession / Tournament
  final DateTime createdAt;

  const ClubLink({
    this.id,
    required this.clubId,
    required this.kind,
    required this.refId,
    required this.createdAt,
  });

  ClubLink copyWith({
    int? id,
    int? clubId,
    ClubLinkKind? kind,
    int? refId,
    DateTime? createdAt,
  }) {
    return ClubLink(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      kind: kind ?? this.kind,
      refId: refId ?? this.refId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Phần 3 — one row of the internal ranking / leaderboard. Pure display data
/// computed on demand from the member's linked club matches; never persisted.
/// All counts are derived only from Matches that belong to the club (via
/// [ClubLink]), so the club ranking is a filtered view — it never recomputes or
/// touches the Statistics engine.
class ClubRankingRow {
  final int memberId;
  final String memberName;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int currentStreak; // positive = win streak, negative = loss streak

  const ClubRankingRow({
    required this.memberId,
    required this.memberName,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.currentStreak = 0,
  });

  double get winRate => matchesPlayed == 0 ? 0.0 : wins / matchesPlayed;

  /// Club points: 3 per win, 1 per loss for showing up (simple, non-AI).
  int get clubPoints => wins * 3 + losses;
}

/// Phần 7 — club-wide aggregate statistics. Pure counts, computed on demand.
/// "Chỉ tổng hợp. Không AI."
class ClubStatistics {
  final int totalMatches;
  final int totalRacks;
  final Duration totalTrainingTime;
  final String? mostActiveMemberName; // luyện nhiều nhất
  final String? mostWinsMemberName; // thắng nhiều nhất
  final String? mostImprovedMemberName; // tiến bộ nhiều nhất (may be null)

  const ClubStatistics({
    this.totalMatches = 0,
    this.totalRacks = 0,
    this.totalTrainingTime = Duration.zero,
    this.mostActiveMemberName,
    this.mostWinsMemberName,
    this.mostImprovedMemberName,
  });
}

/// Leaderboard period (Phần 8).
enum LeaderboardPeriod {
  week,
  month,
  year;

  String get labelKey => 'club_period_$name';

  /// Inclusive lower bound for [now] in this period.
  DateTime since(DateTime now) {
    switch (this) {
      case LeaderboardPeriod.week:
        return now.subtract(const Duration(days: 7));
      case LeaderboardPeriod.month:
        return DateTime(now.year, now.month - 1, now.day);
      case LeaderboardPeriod.year:
        return DateTime(now.year - 1, now.month, now.day);
    }
  }
}
