import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/player_state/domain/form_curve_analyzer.dart';

final formIntelligenceServiceProvider = Provider<FormIntelligenceService>((ref) {
  return FormIntelligenceService(
    ref.watch(sessionRepositoryProvider),
    ref.watch(matchRepositoryProvider),
    ref.watch(rackRepositoryProvider),
    ref.watch(shotRepositoryProvider),
  );
});

/// Task 07: the thin data-layer that fans out over the recording repos, feeds
/// real racks + shots into [FormCurveAnalyzer], and returns the curve. No
/// interpretation lives here — the analyzer is pure; this just assembles data.
class FormIntelligenceService {
  final SessionRepository _sessionRepo;
  final MatchRepository _matchRepo;
  final RackRepository _rackRepo;
  final ShotRepository _shotRepo;

  const FormIntelligenceService(
    this._sessionRepo,
    this._matchRepo,
    this._rackRepo,
    this._shotRepo,
  );

  final FormCurveAnalyzer _analyzer = const FormCurveAnalyzer();

  /// Build the form curve for a single match from real recorded data.
  Future<FormCurve> curveForMatch(int matchId) async {
    final match = await _matchRepo.getMatchById(matchId);
    final racks = await _rackRepo.getRacksByMatchId(matchId);
    final shotsByRackId = <int, List<Shot>>{};
    for (final rack in racks) {
      if (rack.id == null) continue;
      shotsByRackId[rack.id!] = await _shotRepo.getShotsByRackId(rack.id!);
    }
    return _analyzer.buildCurve(
      racks: racks,
      shotsByRackId: shotsByRackId,
      matchStart: match?.startTime,
    );
  }

  /// Build the form curve for the most recent match that has any racks, so the
  /// UI can show "today's" curve without the caller knowing match ids. Returns
  /// FormCurve.insufficient(0) when there is no match data at all.
  Future<FormCurve> latestMatchCurve() async {
    final sessions = await _sessionRepo.getAllSessions();
    // Newest sessions first.
    final ordered = sessions.where((s) => s.id != null).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    for (final session in ordered) {
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      matches.sort((a, b) => b.matchNumber.compareTo(a.matchNumber));
      for (final match in matches) {
        if (match.id == null) continue;
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        if (racks.isEmpty) continue;
        return curveForMatch(match.id!);
      }
    }
    return FormCurve.insufficient(0);
  }
}
