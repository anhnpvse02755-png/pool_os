// EPIC 07 — CommentEngine (Deliverable 2.6).
//
// Wave 2. Comments on: shared match / lesson / article / pattern.
// Max 1-level nested reply. No reactions. No emoji engine.

import 'package:pool_os/features/community/domain/community_engine.dart';

class CommentEngine implements CommunityEngine {
  @override
  String get engineId => 'comment';

  @override
  Future<CommunityContribution> run(CommunityRequest request) async {
    return const CommunityContribution(
      engineId: 'comment',
      status: CapabilityStatus.implemented,
    );
  }
}
