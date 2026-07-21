import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';
import 'package:pool_os/features/coach/presentation/stop_shot_providers.dart';
import 'package:pool_os/features/coach/presentation/decision_reason_presenter.dart';

class StopShotSliceScreen extends ConsumerStatefulWidget {
  const StopShotSliceScreen({
    super.key,
    this.knowledgeId = stopShotKnowledgeId,
  });

  final String knowledgeId;

  @override
  ConsumerState<StopShotSliceScreen> createState() =>
      _StopShotSliceScreenState();
}

class _StopShotSliceScreenState extends ConsumerState<StopShotSliceScreen> {
  int _attempts = 0;
  int _successes = 0;

  @override
  Widget build(BuildContext context) {
    final controller = techniqueControllerProvider(widget.knowledgeId);
    final snapshot = ref.watch(controller);
    return Scaffold(
      appBar: AppBar(title: const Text('Technique Practice')),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(controller),
        ),
        data: (data) => _content(context, data),
      ),
    );
  }

  Widget _content(BuildContext context, StopShotSnapshot snapshot) {
    final entry = snapshot.entry;
    final technique = snapshot.technique;
    final complete = _attempts == technique.measurement.attempts;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(entry.summary, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(entry.body, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        Text('Kết quả cần đạt', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(technique.outcome.description),
        Text(
          '${technique.outcome.requiredSuccesses}/'
          '${technique.outcome.requiredAttempts} lần thành công',
        ),
        const Divider(height: 32),
        Text(technique.drill.title,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final instruction in technique.drill.instructions)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(instruction)),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Semantics(
          label: 'Tiến độ drill B002',
          value: '$_attempts trên ${technique.measurement.attempts}',
          child: LinearProgressIndicator(
            value: _attempts / technique.measurement.attempts,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$_successes/$_attempts đạt',
          key: const Key('stop-shot-live-score'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('stop-shot-miss'),
                onPressed: complete ? null : () => _record(hit: false),
                icon: const Icon(Icons.close),
                label: const Text('Miss'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                key: const Key('stop-shot-hit'),
                onPressed: complete ? null : () => _record(hit: true),
                icon: const Icon(Icons.check),
                label: const Text('Đạt'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          key: const Key('stop-shot-save'),
          onPressed: complete ? _save : null,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Lưu kết quả 25 lượt'),
        ),
        const Divider(height: 32),
        _DecisionPanel(snapshot: snapshot),
      ],
    );
  }

  void _record({required bool hit}) {
    setState(() {
      _attempts++;
      if (hit) _successes++;
    });
  }

  Future<void> _save() async {
    final controller = techniqueControllerProvider(widget.knowledgeId);
    await ref.read(controller.notifier).completeDrill(_successes);
    if (!mounted || ref.read(controller).hasError) return;
    setState(() {
      _attempts = 0;
      _successes = 0;
    });
  }
}

class _DecisionPanel extends StatelessWidget {
  const _DecisionPanel({required this.snapshot});

  final StopShotSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final mastery = snapshot.mastery;
    final decision = snapshot.decision;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coach', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          decision.recommendations.selected.title,
          key: const Key('stop-shot-recommendation'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'Mastery ${mastery.score.round()}% · '
          '${mastery.evidenceCount} kết quả đã đo',
          key: const Key('stop-shot-mastery'),
        ),
        const SizedBox(height: 12),
        Text('Decision Trace', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        for (final reason in decision.trace)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• ${presentDecisionReason(reason)}'),
          ),
        const SizedBox(height: 8),
        Text(
          'Knowledge ${decision.knowledgeVersion} · '
          '${decision.policyVersion}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
}
