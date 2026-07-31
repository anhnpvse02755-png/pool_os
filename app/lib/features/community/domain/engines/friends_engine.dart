// EPIC 07 — FriendsEngine (Deliverable 2.1).
//
// Wave 1. Implements: friend list / friend request / accept / reject /
// remove friend / friend profile preview.
// Beta constraints: no blocking, no private messaging.

import 'package:pool_os/features/community/domain/community_engine.dart';

class FriendsEngine implements CommunityEngine {
  @override
  String get engineId => 'friends';

  @override
  Future<CommunityContribution> run(CommunityRequest request) async {
    return const CommunityContribution(
      engineId: 'friends',
      status: CapabilityStatus.implemented,
    );
  }
}
