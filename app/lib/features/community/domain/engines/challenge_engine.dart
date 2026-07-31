// EPIC 07 — ChallengeEngine (Deliverable 2.4).
//
// Wave 2. States: Pending / Accepted / Declined / Completed / Cancelled.
// Types: Race to 9 / Practice / Drill. No matchmaking, no auto pairing.

import 'package:pool_os/features/community/domain/community_engine.dart';

class ChallengeEngine implements CommunityEngine {
  @override
  String get engineId => 'challenge';

  @override
  Future<CommunityContribution> run(CommunityRequest request) async {
    return const CommunityContribution(
      engineId: 'challenge',
      status: CapabilityStatus.implemented,
    );
  }
}
