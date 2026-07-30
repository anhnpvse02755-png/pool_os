// EPIC 03 — Coach Notes screen.
//
// Manual notes only. Categories: mistake, improve, observation,
// coach_comment. No AI generation. Player can add / delete notes.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/training_system/domain/models/training_system_models.dart';
import 'package:pool_os/features/training_system/presentation/providers/training_system_providers.dart';

class CoachNotesScreen extends ConsumerWidget {
  const CoachNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(coachNotesProvider((sessionId: null, playerId: null)));
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNote(context, ref),
        child: const Icon(Icons.add),
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => data.isEmpty
            ? const Center(child: Text('No coach notes yet.'))
            : ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, i) {
                  final n = data[i];
                  return ListTile(
                    leading: _categoryIcon(n.category),
                    title: Text(n.category.code),
                    subtitle: Text(n.body),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(coachNoteControllerProvider.notifier)
                          .delete(n.id!),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _categoryIcon(CoachNoteCategory c) {
    return switch (c) {
      CoachNoteCategory.mistake => const Icon(Icons.error_outline, color: Colors.red),
      CoachNoteCategory.improve => const Icon(Icons.trending_up, color: Colors.blue),
      CoachNoteCategory.observation => const Icon(Icons.visibility, color: Colors.grey),
      CoachNoteCategory.coachComment => const Icon(Icons.school, color: Colors.green),
    };
  }

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final category = await showDialog<CoachNoteCategory>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Category'),
        children: [
          for (final c in CoachNoteCategory.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(c),
              child: Text(c.code),
            ),
        ],
      ),
    );
    if (category == null || !context.mounted) return;
    final controller = TextEditingController();
    final body = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Note (${category.code})'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Type your note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (body == null || body.trim().isEmpty) return;
    await ref.read(coachNoteControllerProvider.notifier).add(
          CoachNote(
            category: category,
            body: body.trim(),
            createdAt: DateTime.now(),
          ),
        );
  }
}
