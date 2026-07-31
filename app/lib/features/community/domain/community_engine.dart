// EPIC 07 — CommunityEngine abstract base.
// Barrel: engines import this file to get CommunityEngine, CommunityRequest,
// CommunityContribution, and CapabilityStatus.

import 'package:pool_os/features/community/domain/community_request.dart';
import 'package:pool_os/features/community/domain/community_response.dart';
import 'package:pool_os/features/community/domain/capability.dart';

export 'community_request.dart';
export 'community_response.dart';
export 'capability.dart';

abstract class CommunityEngine {
  String get engineId;
  Future<CommunityContribution> run(CommunityRequest request);
}
