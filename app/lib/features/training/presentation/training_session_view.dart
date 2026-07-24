import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/application/training_session_execution_service.dart';

class TrainingSessionView extends ConsumerStatefulWidget {
  const TrainingSessionView({
    super.key,
    required this.sessionId,
    required this.onFinished,
  });

  final int sessionId;
  final Future<void> Function() onFinished;

  @override
  ConsumerState<TrainingSessionView> createState() =>
      _TrainingSessionViewState();
}

class _ExerciseDraft {
  _ExerciseDraft({
    required this.matchId,
    required this.rackId,
    required this.code,
    required this.name,
    this.attempts = 0,
    this.successes = 0,
    this.completed = false,
  });

  final int matchId;
  final int rackId;
  final String code;
  final String name;
  int attempts;
  int successes;
  bool completed;
}

class _TrainingSessionViewState extends ConsumerState<TrainingSessionView> {
  static const _target = 10;
  final _exercises = <_ExerciseDraft>[];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final persisted = await ref
        .read(trainingSessionExecutionServiceProvider)
        .loadExercises(widget.sessionId);
    if (!mounted) return;
    setState(() {
      _exercises
        ..clear()
        ..addAll(persisted.map(
          (item) => _ExerciseDraft(
            matchId: item.matchId,
            rackId: item.rackId,
            code: item.code,
            name: item.name,
            attempts: item.attempts,
            successes: item.successes,
            completed: item.completed,
          ),
        ));
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Training session',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Finish session',
              onPressed: _saving ? null : _finishSession,
              icon: const Icon(Icons.stop_circle_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_exercises.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No exercises yet')),
          ),
        ..._exercises.map(_buildExercise),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _saving ? null : _addExercise,
          icon: const Icon(Icons.add),
          label: const Text('Add exercise'),
        ),
      ],
    );
  }

  Widget _buildExercise(_ExerciseDraft exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (exercise.completed)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            Text(exercise.code),
            const SizedBox(height: 12),
            Text('${exercise.successes}/${exercise.attempts} successful'),
            if (!exercise.completed) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => exercise.attempts += 1),
                      child: const Text('Miss'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() {
                                exercise.attempts += 1;
                                exercise.successes += 1;
                              }),
                      child: const Text('Success'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: exercise.attempts == 0 || _saving
                      ? null
                      : () => _completeExercise(exercise),
                  child: const Text('Complete exercise'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addExercise() async {
    final name = await _exerciseNameDialog();
    if (name == null || !mounted) return;
    setState(() => _saving = true);
    try {
      final ids =
          await ref.read(trainingSessionExecutionServiceProvider).addExercise(
                sessionId: widget.sessionId,
                exerciseCode: _code(name),
                exerciseName: name,
              );
      if (!mounted) return;
      setState(() {
        _exercises.add(
          _ExerciseDraft(
            matchId: ids.matchId,
            rackId: ids.rackId,
            code: _code(name),
            name: name,
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _completeExercise(_ExerciseDraft exercise) async {
    setState(() => _saving = true);
    try {
      await ref.read(trainingSessionExecutionServiceProvider).completeExercise(
            matchId: exercise.matchId,
            rackId: exercise.rackId,
            attempts: exercise.attempts,
            successes: exercise.successes,
            target: _target,
          );
      if (mounted) setState(() => exercise.completed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _finishSession() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(trainingSessionExecutionServiceProvider)
          .finishSession(widget.sessionId);
      await widget.onFinished();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<String?> _exerciseNameDialog() async {
    var name = '';
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add exercise'),
        content: TextField(
          autofocus: true,
          onChanged: (value) => name = value.trim(),
          decoration: const InputDecoration(labelText: 'Exercise name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (name.isNotEmpty) Navigator.pop(dialogContext, name);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _code(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
