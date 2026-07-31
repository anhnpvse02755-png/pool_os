// EPIC 07 — canonical request shapes for CommunityService.

class CommunityRequest {
  final String playerId;
  final DateTime asOf;

  const CommunityRequest({
    required this.playerId,
    required this.asOf,
  });
}

class ShareRequest extends CommunityRequest {
  final String targetId;
  final String target;
  final String visibility;

  const ShareRequest({
    required super.playerId,
    required super.asOf,
    required this.targetId,
    required this.target,
    required this.visibility,
  });
}

class CommentRequest extends CommunityRequest {
  final String targetId;
  final String target;
  final String body;
  final String? parentCommentId;

  const CommentRequest({
    required super.playerId,
    required super.asOf,
    required this.targetId,
    required this.target,
    required this.body,
    this.parentCommentId,
  });
}
