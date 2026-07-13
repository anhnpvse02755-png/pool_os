import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player_state/data/form_intelligence_service.dart';
import 'package:pool_os/features/player_state/domain/form_curve_analyzer.dart';

/// Task 07: the latest match's form curve, computed on demand from real data.
final latestFormCurveProvider = FutureProvider<FormCurve>((ref) async {
  final service = ref.watch(formIntelligenceServiceProvider);
  return service.latestMatchCurve();
});

/// A specific match's form curve (family-keyed by matchId).
final matchFormCurveProvider =
    FutureProvider.family<FormCurve, int>((ref, matchId) async {
  final service = ref.watch(formIntelligenceServiceProvider);
  return service.curveForMatch(matchId);
});
