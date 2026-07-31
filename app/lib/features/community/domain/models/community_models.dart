// EPIC 07 — Community data models (Community owns these per §5).

class Friend {
  final String id;
  final String playerId;
  final String friendPlayerId;
  final FriendStatus status;
  final DateTime createdAt;

  const Friend({
    required this.id,
    required this.playerId,
    required this.friendPlayerId,
    required this.status,
    required this.createdAt,
  });
}

enum FriendStatus { pending, accepted, rejected }

class FriendRequest {
  final String id;
  final String fromPlayerId;
  final String toPlayerId;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.fromPlayerId,
    required this.toPlayerId,
    required this.createdAt,
  });
}

class Share {
  final String id;
  final String playerId;
  final ShareTarget target;
  final String targetId;
  final ShareVisibility visibility;
  final DateTime createdAt;

  const Share({
    required this.id,
    required this.playerId,
    required this.target,
    required this.targetId,
    required this.visibility,
    required this.createdAt,
  });
}

enum ShareTarget { match, trainingSession, achievement, pattern, lesson }

enum ShareVisibility { public_, friendsOnly, private_ }

class ActivityEntry {
  final String id;
  final String playerId;
  final ActivityType type;
  final String referenceId;
  final DateTime timestamp;
  final Map<String, Object?> metadata;

  const ActivityEntry({
    required this.id,
    required this.playerId,
    required this.type,
    required this.referenceId,
    required this.timestamp,
    this.metadata = const <String, Object?>{},
  });
}

enum ActivityType {
  matchCompleted,
  goalAchieved,
  trainingCompleted,
  newAchievement,
  sharedLesson,
  sharedPattern,
}

class Challenge {
  final String id;
  final String challengerId;
  final String challengedId;
  final ChallengeType type;
  final ChallengeStatus status;
  final DateTime createdAt;

  const Challenge({
    required this.id,
    required this.challengerId,
    required this.challengedId,
    required this.type,
    required this.status,
    required this.createdAt,
  });
}

enum ChallengeType { raceToNine, practice, drill }

enum ChallengeStatus { pending, accepted, declined, completed, cancelled }

class Achievement {
  final String id;
  final String playerId;
  final String type;
  final String description;
  final DateTime achievedAt;

  const Achievement({
    required this.id,
    required this.playerId,
    required this.type,
    required this.description,
    required this.achievedAt,
  });
}

class Comment {
  final String id;
  final String playerId;
  final CommentTarget target;
  final String targetId;
  final String body;
  final String? parentCommentId;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.playerId,
    required this.target,
    required this.targetId,
    required this.body,
    this.parentCommentId,
    required this.createdAt,
  });
}

enum CommentTarget { sharedMatch, sharedLesson, sharedArticle, sharedPattern }

class NotificationEntry {
  final String id;
  final String playerId;
  final NotificationType type;
  final String message;
  final String referenceId;
  final bool read;
  final DateTime createdAt;

  const NotificationEntry({
    required this.id,
    required this.playerId,
    required this.type,
    required this.message,
    required this.referenceId,
    this.read = false,
    required this.createdAt,
  });
}

enum NotificationType {
  friendRequest,
  challenge,
  comment,
  achievement,
  shareInteraction,
}