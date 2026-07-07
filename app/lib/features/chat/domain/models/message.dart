class Message {
  final int? id;
  final int conversationId;
  final String content;
  final bool isFromUser;
  final DateTime createdAt;

  Message({
    this.id,
    required this.conversationId,
    required this.content,
    required this.isFromUser,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Message copyWith({
    int? id,
    int? conversationId,
    String? content,
    bool? isFromUser,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      isFromUser: isFromUser ?? this.isFromUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
