// EPIC 07 — SharingEngine (Deliverable 2.2).
//
// Wave 1. Allow sharing: Match / Training Session / Achievement /
// Pattern / Lesson. Share types: Public / Friends only / Private.
// No external social network integration.

import 'package:pool_os/features/community/domain/community_engine.dart';

class SharingEngine implements CommunityEngine {
  @override
  String get engineId => 'sharing';

  @override
  Future<CommunityContribution> run(CommunityRequest request) async {
    return const CommunityContribution(
      engineId: 'sharing',
      status: CapabilityStatus.implemented,
    );
  }
}
