import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/equipment/data/repositories/equipment_repository.dart';
import 'package:pool_os/features/equipment/data/repositories/match_equipment_snapshot_repository.dart';
import 'package:pool_os/features/equipment/domain/cue_role_resolver.dart';

final equipmentPerformanceServiceProvider =
    Provider<EquipmentPerformanceService>((ref) {
  return EquipmentPerformanceService(
    ref.watch(sessionRepositoryProvider),
    ref.watch(matchRepositoryProvider),
    ref.watch(rackRepositoryProvider),
    ref.watch(shotRepositoryProvider),
    ref.watch(equipmentRepositoryProvider),
    ref.watch(matchEquipmentSnapshotRepositoryProvider),
  );
});

/// Task 04 §6: per-ROLE equipment statistics computed READ-SIDE from real
/// shots. A cue is never scored by name alone — it is scored per (cue, role),
/// because one physical cue (a break_jump) can own both the Break and Jump
/// roles and those two stat groups are independent.
///
/// Every number here comes from recorded Shots (shotType + result) attributed
/// to a cue via the match's immutable equipment snapshot. It NEVER reads the
/// fabricated EquipmentStats hour/rate constants in StatisticsRepository.
class EquipmentPerformanceService {
  final SessionRepository _sessionRepo;
  final MatchRepository _matchRepo;
  final RackRepository _rackRepo;
  final ShotRepository _shotRepo;
  final EquipmentRepository _equipmentRepo;
  final MatchEquipmentSnapshotRepository _snapshotRepo;

  EquipmentPerformanceService(
    this._sessionRepo,
    this._matchRepo,
    this._rackRepo,
    this._shotRepo,
    this._equipmentRepo,
    this._snapshotRepo,
  );

  /// Aggregate per-(cue, role) performance across every recorded match.
  /// Returns one [CueRoleStats] per (cueId, role) that has at least one shot.
  Future<List<CueRoleStats>> computeRoleStats() async {
    // key = "cueId|role" -> mutable tally
    final tallies = <String, _RoleTally>{};

    final sessions = await _sessionRepo.getAllSessions();
    for (final session in sessions) {
      if (session.id == null) continue;
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      for (final match in matches) {
        if (match.id == null) continue;
        final snapshot = await _snapshotRepo.getByMatchId(match.id!);
        if (snapshot == null) continue; // no equipment recorded for this match
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        for (final rack in racks) {
          if (rack.id == null) continue;
          final shots = await _shotRepo.getShotsByRackId(rack.id!);
          for (final shot in shots) {
            final role = CueRoleResolver.roleForShotType(shot.shotType);
            final cueId = CueRoleResolver.resolveCueId(snapshot, shot.shotType);
            if (cueId == null) continue; // no cue attributable
            final key = '$cueId|$role';
            final t = tallies.putIfAbsent(key, () => _RoleTally(cueId, role));
            t.attempts++;
            switch (shot.result) {
              case ShotResult.made:
                t.made++;
                break;
              case ShotResult.scratch:
                t.scratch++;
                break;
              case ShotResult.foul:
                t.foul++;
                break;
              default:
                t.missed++;
            }
          }
        }
      }
    }

    // Resolve cue names once.
    final cueNames = <int, String>{};
    for (final t in tallies.values) {
      if (!cueNames.containsKey(t.cueId)) {
        final cue = await _equipmentRepo.getCueById(t.cueId);
        cueNames[t.cueId] = cue?.name ?? 'Cue #${t.cueId}';
      }
    }

    return tallies.values
        .map((t) => CueRoleStats(
              cueId: t.cueId,
              cueName: cueNames[t.cueId] ?? 'Cue #${t.cueId}',
              role: t.role,
              attempts: t.attempts,
              made: t.made,
              missed: t.missed,
              scratch: t.scratch,
              foul: t.foul,
            ))
        .toList()
      ..sort((a, b) {
        final r = a.role.compareTo(b.role);
        return r != 0 ? r : b.attempts.compareTo(a.attempts);
      });
  }
}

class _RoleTally {
  final int cueId;
  final String role;
  int attempts = 0;
  int made = 0;
  int missed = 0;
  int scratch = 0;
  int foul = 0;
  _RoleTally(this.cueId, this.role);
}

/// Immutable per-(cue, role) statistics. Success rate is real made/attempts.
class CueRoleStats {
  final int cueId;
  final String cueName;
  final String role; // CueRole.playing | breakRole | jump
  final int attempts;
  final int made;
  final int missed;
  final int scratch;
  final int foul;

  const CueRoleStats({
    required this.cueId,
    required this.cueName,
    required this.role,
    required this.attempts,
    required this.made,
    required this.missed,
    required this.scratch,
    required this.foul,
  });

  double get successRate => attempts > 0 ? made / attempts : 0.0;
  double get scratchRate => attempts > 0 ? scratch / attempts : 0.0;
}

/// Task 04 §7: whether a role's performance problem is EQUIPMENT or SKILL.
enum EquipmentVerdict {
  /// Two+ cues tried in this role perform about the same -> not the cue.
  skillNotEquipment,

  /// A different cue clearly outperforms in this role -> equipment matters.
  equipmentHelps,

  /// Only one cue used but this role lags another role badly -> skill gap.
  skillGap,

  /// Not enough data to judge.
  insufficient,
}

/// A per-role equipment/skill conclusion Coach can surface (spec §7 cases).
class EquipmentInsight {
  final String role;
  final EquipmentVerdict verdict;
  final String message; // localized, plain language
  final String messageVi;

  const EquipmentInsight({
    required this.role,
    required this.verdict,
    required this.message,
    required this.messageVi,
  });
}

extension EquipmentVsSkillAnalysis on EquipmentPerformanceService {
  /// Minimum shots on a (cue, role) before it can be compared (avoid coaching
  /// on tiny samples).
  static const int minRoleSample = 8;

  /// Success-rate gap above which a cue difference is called "equipment matters"
  /// rather than noise.
  static const double equipmentGap = 0.15;

  /// Compare cues within each role to tell equipment problems from skill
  /// problems. READ-SIDE, real data only.
  Future<List<EquipmentInsight>> analyzeEquipmentVsSkill({String locale = 'vi'}) async {
    final stats = await computeRoleStats();
    final byRole = <String, List<CueRoleStats>>{};
    for (final s in stats) {
      if (s.attempts < minRoleSample) continue;
      byRole.putIfAbsent(s.role, () => []).add(s);
    }

    final insights = <EquipmentInsight>[];
    for (final role in [CueRole.breakRole, CueRole.jump]) {
      final cues = byRole[role];
      if (cues == null || cues.isEmpty) continue;

      if (cues.length >= 2) {
        // Multiple cues tried in this role -> compare best vs worst.
        cues.sort((a, b) => b.successRate.compareTo(a.successRate));
        final best = cues.first;
        final worst = cues.last;
        final gap = best.successRate - worst.successRate;
        final roleLabelEn = CueRole.label(role, 'en');
        final roleLabelVi = CueRole.label(role, 'vi');
        if (gap >= equipmentGap) {
          insights.add(EquipmentInsight(
            role: role,
            verdict: EquipmentVerdict.equipmentHelps,
            message:
                '$roleLabelEn: ${best.cueName} (${(best.successRate * 100).round()}%) clearly beats ${worst.cueName} (${(worst.successRate * 100).round()}%). Equipment matters — keep using ${best.cueName}.',
            messageVi:
                '$roleLabelVi: ${best.cueName} (${(best.successRate * 100).round()}%) vượt hẳn ${worst.cueName} (${(worst.successRate * 100).round()}%). Equipment có ảnh hưởng — nên tiếp tục dùng ${best.cueName}.',
          ));
        } else {
          insights.add(EquipmentInsight(
            role: role,
            verdict: EquipmentVerdict.skillNotEquipment,
            message:
                '$roleLabelEn: ${best.cueName} and ${worst.cueName} perform about the same (${(best.successRate * 100).round()}% vs ${(worst.successRate * 100).round()}%). No real difference — train the skill rather than buying more equipment.',
            messageVi:
                '$roleLabelVi: ${best.cueName} và ${worst.cueName} gần như nhau (${(best.successRate * 100).round()}% vs ${(worst.successRate * 100).round()}%). Không khác biệt — nên luyện kỹ thuật thay vì mua thêm cơ.',
          ));
        }
      }
      // Only ONE cue used in this role: we cannot tell equipment from skill
      // (there is nothing to compare the cue against). Deliberately emit NO
      // verdict here — comparing a break/jump made-rate against the playing
      // made-rate would be comparing structurally different, differently-scaled
      // shot populations and would fire false "skill gap" conclusions. The
      // equipment-vs-skill call (spec §7) is only sound across 2+ cues in the
      // SAME role, which is the branch above.
    }
    return insights;
  }
}
