import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;

/// Task 04: the three equipment roles a cue can fill.
class CueRole {
  static const String playing = 'playing';
  static const String breakRole = 'break';
  static const String jump = 'jump';

  static const List<String> all = [playing, breakRole, jump];

  static String label(String role, String locale) {
    final vi = locale == 'vi';
    switch (role) {
      case breakRole:
        return vi ? 'Phá' : 'Break';
      case jump:
        return vi ? 'Nhảy' : 'Jump';
      case playing:
      default:
        return vi ? 'Đánh' : 'Playing';
    }
  }
}

/// Pure role/cue resolution for Task 04. A Shot has no cueId (the RFC-301
/// recording pipeline is LOCKED); instead the cue used for a shot is derived
/// read-side from its [ShotTypes] value and the match's equipment snapshot.
///
///   Break        -> Break cue
///   Jump         -> Jump cue
///   everything else (normal / opening / bank / safety / masse) -> Playing cue
///
/// Business decision: if the resolved role has no cue in the snapshot, fall
/// back to the Playing cue — a shot is always attributed to the cue actually
/// in hand. Resolution reads ONLY the match's snapshot row, never the live
/// active cues, so historical matches stay stable when defaults change later.
class CueRoleResolver {
  /// The equipment role a shot of [shotType] belongs to.
  static String roleForShotType(String shotType) {
    switch (shotType) {
      case ShotTypes.breakShot:
        return CueRole.breakRole;
      case ShotTypes.jumpShot:
        return CueRole.jump;
      // opening/normal/safety/bank/masse are all played with the Playing cue.
      default:
        return CueRole.playing;
    }
  }

  /// Resolve the cue id for a shot from a match snapshot, applying the Playing
  /// fallback when the shot's role has no configured cue. Returns null only
  /// when the snapshot has no cue at all (e.g. player recorded no equipment).
  static int? resolveCueId(db.MatchEquipmentSnapshot? snapshot, String shotType) {
    if (snapshot == null) return null;
    final role = roleForShotType(shotType);
    switch (role) {
      case CueRole.breakRole:
        return snapshot.breakCueId ?? snapshot.playingCueId;
      case CueRole.jump:
        return snapshot.jumpCueId ?? snapshot.playingCueId;
      case CueRole.playing:
      default:
        return snapshot.playingCueId;
    }
  }
}
