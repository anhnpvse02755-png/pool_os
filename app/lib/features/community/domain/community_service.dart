// EPIC 07 — CommunityService. THE sole entry point.
//
// PO 2026-07-31 architecture:
//
//   Community UI → CommunityService → CommunityPipeline → 6 Engines → Repository
//
// Strict rule: UI never reaches engines directly. CommunityService is the
// only public surface of the Community layer.

import 'package:pool_os/features/community/domain/community_pipeline.dart';
import 'package:pool_os/features/community/domain/community_request.dart';
import 'package:pool_os/features/community/domain/community_response.dart';

class CommunityService {
  final CommunityPipeline _pipeline;

  const CommunityService(this._pipeline);

  // Wave 1 — Social Foundation
  Future<CommunityResponse> friends(CommunityRequest request) =>
      _pipeline.friends(request);

  Future<CommunityResponse> feed(CommunityRequest request) =>
      _pipeline.feed(request);

  Future<CommunityResponse> sharing(ShareRequest request) =>
      _pipeline.sharing(request);

  // Wave 2 — Interaction
  Future<CommunityResponse> challenge(CommunityRequest request) =>
      _pipeline.challenge(request);

  Future<CommunityResponse> comment(CommentRequest request) =>
      _pipeline.comment(request);

  Future<CommunityResponse> notification(CommunityRequest request) =>
      _pipeline.notification(request);

  // Wave 3 — Recognition
  Future<CommunityResponse> achievement(CommunityRequest request) =>
      _pipeline.achievement(request);

  // Aggregated
  Future<CommunityResponse> dashboard(CommunityRequest request) =>
      _pipeline.dashboard(request);
}
