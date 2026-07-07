import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/chat/presentation/chat_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(conversationListNotifierProvider.notifier)
          .loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(conversationListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('conversations')),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.conversations.isEmpty
              ? _buildEmptyState(context, l10n)
              : _buildConversationList(context, state, l10n),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateConversationDialog(context, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.get('empty_state'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.get('tap_to_add'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(
      BuildContext context, ConversationListState state, AppLocalizations l10n) {
    return ListView.builder(
      itemCount: state.conversations.length,
      itemBuilder: (context, index) {
        final conversation = state.conversations[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(conversation.title.isNotEmpty
                ? conversation.title[0].toUpperCase()
                : '?'),
          ),
          title: Text(conversation.title),
          subtitle: conversation.lastMessage != null
              ? Text(
                  conversation.lastMessage!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: conversation.unreadCount > 0
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    conversation.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                )
              : _formatTime(conversation.lastMessageAt),
          onTap: () {
            context.push('/chat/${conversation.id}');
          },
          onLongPress: () {
            _showDeleteDialog(context, l10n, conversation.id!);
          },
        );
      },
    );
  }

  Widget? _formatTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return Text('${difference.inDays}d');
    } else if (difference.inHours > 0) {
      return Text('${difference.inHours}h');
    } else if (difference.inMinutes > 0) {
      return Text('${difference.inMinutes}m');
    }
    return const Text('now');
  }

  void _showCreateConversationDialog(
      BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('new_conversation')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.get('conversation_title_hint'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(conversationListNotifierProvider.notifier)
                    .createConversation(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text(l10n.get('create')),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, AppLocalizations l10n, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('delete_conversation')),
        content: Text(l10n.get('are_you_sure')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(conversationListNotifierProvider.notifier)
                  .deleteConversation(id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );
  }
}
