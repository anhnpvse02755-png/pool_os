import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/chat/domain/models/conversation.dart';
import 'package:pool_os/features/chat/domain/models/message.dart';
import 'package:pool_os/features/chat/data/repositories/chat_repository.dart';

class ConversationListState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  const ConversationListState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationListState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final conversationListNotifierProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>((ref) {
  return ConversationListNotifier(ref.watch(chatRepositoryProvider));
});

class ConversationListNotifier extends StateNotifier<ConversationListState> {
  final ChatRepository _repository;

  ConversationListNotifier(this._repository)
      : super(const ConversationListState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final conversations = await _repository.getConversations();
      conversations.sort((a, b) {
        if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
        if (a.lastMessageAt == null) return 1;
        if (b.lastMessageAt == null) return -1;
        return b.lastMessageAt!.compareTo(a.lastMessageAt!);
      });
      state = state.copyWith(conversations: conversations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createConversation(String title) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final conversation = Conversation(title: title);
      await _repository.createConversation(conversation);
      await loadConversations();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteConversation(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteConversation(id);
      await loadConversations();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class ChatRoomState {
  final Conversation? conversation;
  final List<Message> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatRoomState({
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ChatRoomState copyWith({
    Conversation? conversation,
    List<Message>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return ChatRoomState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

final chatRoomNotifierProvider =
    StateNotifierProvider.family<ChatRoomNotifier, ChatRoomState, int>(
        (ref, conversationId) {
  return ChatRoomNotifier(ref.watch(chatRepositoryProvider), conversationId);
});

class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  final ChatRepository _repository;
  final int conversationId;

  ChatRoomNotifier(this._repository, this.conversationId)
      : super(const ChatRoomState());

  Future<void> loadChat() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final conversation = await _repository.getConversation(conversationId);
      final messages = await _repository.getMessages(conversationId);
      await _repository.markConversationAsRead(conversationId);
      state = state.copyWith(
        conversation: conversation,
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    state = state.copyWith(isSending: true, error: null);
    try {
      final message = Message(
        conversationId: conversationId,
        content: content.trim(),
        isFromUser: true,
      );
      await _repository.createMessage(message);

      final messages = await _repository.getMessages(conversationId);
      final conversation = await _repository.getConversation(conversationId);
      state = state.copyWith(
        conversation: conversation,
        messages: messages,
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await _repository.deleteMessage(messageId);
      final messages = await _repository.getMessages(conversationId);
      state = state.copyWith(messages: messages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
