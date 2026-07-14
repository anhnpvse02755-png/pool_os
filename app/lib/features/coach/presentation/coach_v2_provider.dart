// Task 15 — Coach Intelligence V2, Layer 4: the coordinator provider.
//
// This provider is a COORDINATOR, not a decision-maker. It only: (1) runs the
// finding producers read-only against the existing repositories, (2) assembles
// the derived CoachContext, and (3) hands it to CoachBrain. It decides nothing
// itself — all priority/grouping/confidence/action logic lives in the Brain.
//
// A NEW provider (rather than surgery on the 1030-line legacy CoachNotifier) so
// the V2 pipeline is cleanly read-only and low-risk. The legacy coach_provider
// is left untouched for now (see plan: old engines reduced to dead code later).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/coach/domain/brain/coach_brain.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/context/coach_context.dart';
import 'package:pool_os/features/coach/domain/findings/finding.dart';
import 'package:pool_os/features/coach/domain/findings/shot_context_producer.dart';
import 'package:pool_os/features/coach/domain/findings/support_producers.dart';
import 'package:pool_os/features/daily_readiness/data/repositories/daily_readiness_repository.dart';
import 'package:pool_os/features/endurance/presentation/endurance_provider.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_service.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/skill/data/skill_repository.dart';
import 'package:pool_os/features/statistics/data/repositories/statistics_repository.dart';
import 'package:pool_os/features/training_center/data/repositories/training_center_repository.dart';

/// Builds the derived [CoachContext] fresh each run from persisted domain data.
/// Read-only; owns no state. Exposed separately so it can be tested and so the
/// output provider can depend on it.
final coachContextProvider = FutureProvider<CoachContext>((ref) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final matchRepo = ref.watch(matchRepositoryProvider);
  final rackRepo = ref.watch(rackRepositoryProvider);
  final shotRepo = ref.watch(shotRepositoryProvider);

  final findings = <Finding>[];

  // 1) Shot success by context (the new derivation) + coverage counts.
  final shotProducer =
      ShotContextProducer(sessionRepo, matchRepo, rackRepo, shotRepo);
  final shotFindings = await shotProducer.produce();
  findings.addAll(shotFindings);

  // 2) Career facts (real counts only). Win rate must be MATCH-level, not
  //    rack-level: CareerStats.totalWins/totalLosses count racks, so use
  //    getWinRateDetail (matches.length + per-match isWin) for the win rate and
  //    keep CareerStats only for shot accuracy.
  final statsRepo = ref.watch(statisticsRepositoryProvider);
  final career = await statsRepo.getCareerStats();
  final winDetail = await statsRepo.getWinRateDetail();
  findings.addAll(produceCareerFindings(CareerFacts(
    totalMatches: winDetail.totalMatches,
    matchesWon: winDetail.wonMatches,
    totalShots: career.totalShots,
    shotsMade: career.totalMade,
  )));

  // 3) Persisted skills.
  final skillRepo = ref.watch(skillRepositoryProvider);
  final skills = await skillRepo.getAllSkills();
  findings.addAll(produceSkillFindings(skills
      .map((s) => SkillFact(
            category: s.category,
            score: s.score,
            confidence: s.confidence,
            trend: s.trend,
          ))
      .toList()));

  // 4) Training drill runs (training context, real successes/attempts).
  final trainingRepo = ref.watch(trainingCenterRepositoryProvider);
  final runs = await trainingRepo.getAllRuns();
  findings.addAll(produceTrainingFindings(runs
      .map((r) => DrillFact(
            drillKey: r.drillKey,
            category: r.category,
            attempts: r.attempts,
            successes: r.successes,
          ))
      .toList()));

  // 5) Today's readiness (present/absent + score).
  final readinessRepo = ref.watch(dailyReadinessRepositoryProvider);
  final now = DateTime.now();
  final todayKey =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final today = await readinessRepo.getByDate(todayKey);
  findings.addAll(produceReadinessFindings(
    loggedToday: today != null,
    overallScore: today?.overallScore,
    observedAt: today != null ? now : null,
  ));

  // 6) Equipment per-(cue,role) real success rates.
  final equipmentService = ref.watch(equipmentPerformanceServiceProvider);
  final roleStats = await equipmentService.computeRoleStats();
  findings.addAll(produceEquipmentFindings(roleStats
      .map((s) => EquipmentFact(
            cueName: s.cueName,
            role: s.role,
            attempts: s.attempts,
            made: s.made,
          ))
      .toList()));

  // 7) Endurance profile (only when the analyzer had enough data).
  final endurance = await ref.watch(enduranceProfileProvider.future);
  if (endurance.hasEnoughData) {
    findings.addAll(produceEnduranceFindings(
      enduranceScore: endurance.enduranceScore,
      averageDeclineRack: endurance.averageDeclineRack,
      sampleMatches: endurance.analyzedMatches,
    ));
  }

  // 8) Coverage: one count per source so Coach Understanding is derivable.
  findings.addAll(produceCoverageFindings({
    FindingSource.shots:
        shotFindings.fold<int>(0, (s, f) => s + f.sampleSize),
    FindingSource.statistics: career.totalWins + career.totalLosses,
    FindingSource.skill: skills.length,
    FindingSource.training: runs.length,
    FindingSource.equipment: roleStats.length,
    FindingSource.readiness: today != null ? 1 : 0,
    FindingSource.endurance: endurance.hasEnoughData ? endurance.analyzedMatches : 0,
  }));

  return CoachContext.fromFindings(findings, now: now);
});

/// The Coach V2 output the screen renders. Runs the Brain over the context.
final coachOutputProvider = FutureProvider<CoachOutput>((ref) async {
  final ctx = await ref.watch(coachContextProvider.future);
  return CoachBrain().decide(ctx);
});
