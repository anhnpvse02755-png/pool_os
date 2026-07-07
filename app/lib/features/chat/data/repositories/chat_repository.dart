import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/chat/domain/models/conversation.dart';
import 'package:pool_os/features/chat/domain/models/message.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(databaseProvider));
});

class ChatRepository {
  final db.AppDatabase _db;

  ChatRepository(this._db);

  Future<List<Conversation>> getConversations() async {
    final results = await _db.select(_db.conversations).get();
    return results.map(_mapToConversation).toList();
  }

  Future<Conversation?> getConversation(int id) async {
    final result = await (_db.select(_db.conversations)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return result != null ? _mapToConversation(result) : null;
  }

  Future<int> createConversation(Conversation conversation) async {
    return _db.into(_db.conversations).insert(
      db.ConversationsCompanion.insert(
        title: conversation.title,
        lastMessage: Value(conversation.lastMessage),
        lastMessageAt: Value(conversation.lastMessageAt),
        unreadCount: Value(conversation.unreadCount),
        createdAt: Value(conversation.createdAt),
        updatedAt: Value(conversation.updatedAt),
      ),
    );
  }

  Future<bool> updateConversation(Conversation conversation) async {
    return _db.update(_db.conversations).replace(
      db.ConversationsCompanion(
        id: Value(conversation.id!),
        title: Value(conversation.title),
        lastMessage: Value(conversation.lastMessage),
        lastMessageAt: Value(conversation.lastMessageAt),
        unreadCount: Value(conversation.unreadCount),
        createdAt: Value(conversation.createdAt),
        updatedAt: Value(conversation.updatedAt),
      ),
    );
  }

  Future<int> deleteConversation(int id) async {
    await (_db.delete(_db.messages)
          ..where((t) => t.conversationId.equals(id)))
        .go();
    return (_db.delete(_db.conversations)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Message>> getMessages(int conversationId) async {
    final results = await (_db.select(_db.messages)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return results.map(_mapToMessage).toList();
  }

  Future<int> createMessage(Message message) async {
    final id = await _db.into(_db.messages).insert(
      db.MessagesCompanion.insert(
        conversationId: message.conversationId,
        content: message.content,
        isFromUser: message.isFromUser,
        createdAt: Value(message.createdAt),
      ),
    );

    await (_db.update(_db.conversations)
          ..where((t) => t.id.equals(message.conversationId)))
        .write(db.ConversationsCompanion(
      lastMessage: Value(message.content),
      lastMessageAt: Value(message.createdAt),
      updatedAt: Value(DateTime.now()),
    ));

    return id;
  }

  Future<int> deleteMessage(int id) async {
    return (_db.delete(_db.messages)..where((t) => t.id.equals(id))).go();
  }

  Future<int> markConversationAsRead(int conversationId) async {
    return (_db.update(_db.conversations)
          ..where((t) => t.id.equals(conversationId)))
        .write(const db.ConversationsCompanion(unreadCount: Value(0)));
  }

  Conversation _mapToConversation(db.Conversation result) {
    return Conversation(
      id: result.id,
      title: result.title,
      lastMessage: result.lastMessage,
      lastMessageAt: result.lastMessageAt,
      unreadCount: result.unreadCount,
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
    );
  }

  Message _mapToMessage(db.Message result) {
    return Message(
      id: result.id,
      conversationId: result.conversationId,
      content: result.content,
      isFromUser: result.isFromUser,
      createdAt: result.createdAt,
    );
  }
}
