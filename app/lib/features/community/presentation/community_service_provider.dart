// EPIC 07 — Community Service Riverpod providers.
//
// UI consumers call communityServiceProvider and receive a CommunityService.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/community/domain/community_pipeline.dart';
import 'package:pool_os/features/community/domain/community_service.dart';

final communityPipelineProvider = Provider<CommunityPipeline>(
  (ref) => defaultCommunityPipeline(),
);

final communityServiceProvider = Provider<CommunityService>(
  (ref) => CommunityService(ref.watch(communityPipelineProvider)),
);