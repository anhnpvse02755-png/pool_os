// EPIC 07 — CommunityPipeline (all 3 waves registered).

import 'package:pool_os/features/community/domain/community_engine.dart';
import 'package:pool_os/features/community/domain/community_request.dart';
import 'package:pool_os/features/community/domain/community_response.dart';
import 'package:pool_os/features/community/domain/capability.dart';
import 'package:pool_os/features/community/domain/engines/friends_engine.dart';
import 'package:pool_os/features/community/domain/engines/feed_engine.dart';
import 'package:pool_os/features/community/domain/engines/sharing_engine.dart';
import 'package:pool_os/features/community/domain/engines/challenge_engine.dart';
import 'package:pool_os/features/community/domain/engines/achievement_engine.dart';
import 'package:pool_os/features/community/domain/engines/comment_engine.dart';
import 'package:pool_os/features/community/domain/engines/notification_engine.dart';

class CommunityPipeline {
  final List<CommunityEngine> _engines;

  const CommunityPipeline(this._engines);

  CommunityEngine? _byId(String id) {
    for (final e in _engines) {
      if (e.engineId == id) return e;
    }
    return null;
  }

  Future<CommunityResponse> _aggregate(
    String playerId,
    DateTime now,
    CommunityRequest request,
    List<String> plannedIds,
  ) async {
    final contributions = <CommunityContribution>[];
    for (final id in plannedIds) {
      final engine = _byId(id);
      if (engine == null) {
        contributions.add(CommunityContribution(
          engineId: id,
          status: CapabilityStatus.planned,
          reason: const CapabilityReason(
            code: 'engine_not_registered',
            message: 'This engine is not yet registered in the pipeline.',
          ),
        ));
        continue;
      }
      final c = await engine.run(request);
      contributions.add(c);
    }
    return CommunityResponse(
      playerId: playerId,
      generatedAt: now,
      contributions: contributions,
    );
  }

  // Wave 1 — Social Foundation
  Future<CommunityResponse> friends(CommunityRequest request) =>
      _aggregate(request.playerId, request.asOf, request, const ['friends']);

  Future<CommunityResponse> feed(CommunityRequest request) =>
      _aggregate(request.playerId, request.asOf, request, const ['feed']);

  Future<CommunityResponse> sharing(ShareRequest request) =>
      _aggregate(request.playerId, request.asOf, request, const ['sharing']);

  // Wave 2 — Interaction
  Future<CommunityResponse> challenge(CommunityRequest request) =>
      _aggregate(request.playerId, request.asOf, request, const ['challenge']);

  Future<CommunityResponse> comment(CommentRequest request) =>
      _aggregate(request.playerId, request.asOf, request, const ['comment']);

  Future<CommunityResponse> notification(CommunityRequest request) =>
      _aggregate(request.playerId, request.asOf, request, const ['notification']);

  // Wave 3 — Recognition
  Future<CommunityResponse> achievement(CommunityRequest request) =>
      _aggregate(request.playerId, request.asOf, request, const ['achievement']);

  // Aggregated dashboard
  Future<CommunityResponse> dashboard(CommunityRequest request) =>
      _aggregate(request.playerId, request.asOf, request, const [
        'friends',
        'feed',
        'sharing',
        'challenge',
        'achievement',
        'comment',
        'notification',
      ]);
}

CommunityPipeline defaultCommunityPipeline() {
  return CommunityPipeline(<CommunityEngine>[
    FriendsEngine(),
    FeedEngine(),
    SharingEngine(),
    ChallengeEngine(),
    AchievementEngine(),
    CommentEngine(),
    NotificationEngine(),
  ]);
}
