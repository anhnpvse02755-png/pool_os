// EPIC 03 — Progress screen.
//
// Displays the TrainingProgressSnapshot read-only composition.
// Spec §4: Total Practice Time, Total Sessions, Completed Drills,
// Goal Completion, Practice Frequency, Improvement Timeline.
// No prediction. No AI.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/training_system/presentation/providers/training_system_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(progressSnapshotProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: snap.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatTile(
              label: 'Total Practice Time',
              value: _formatDuration(data.totalPracticeTime),
            ),
            _StatTile(
              label: 'Total Sessions',
              value: data.totalSessions.toString(),
            ),
            _StatTile(
              label: 'Completed Drills',
              value: data.completedDrills.toString(),
            ),
            _StatTile(
              label: 'Goals Completed',
              value: '${data.goalsCompleted} / ${data.goalsTotal}',
              subtitle:
                  'Active: ${data.goalsActive} · Archived: ${data.goalsArchived}',
            ),
            _StatTile(
              label: 'Practice Frequency',
              value: '${data.practiceFrequencyPerWeek} days / week',
              subtitle: 'Rolling 4 weeks',
            ),
            const SizedBox(height: 16),
            Text('Improvement Timeline', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (data.improvementTimeline.isEmpty)
              const Text('Chưa đủ dữ liệu để vẽ timeline.')
            else
              SizedBox(
                height: 200,
                child: _Timeline(points: data.improvementTimeline),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  const _StatTile({required this.label, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<dynamic> points;
  const _Timeline({required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TimelinePainter(points: points),
      size: const Size(double.infinity, 200),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final List<dynamic> points;
  _TimelinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = Colors.blue;

    final dy = size.height - 16;
    final stepX = points.length == 1 ? size.width / 2 : size.width / (points.length - 1);
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final x = i * stepX;
      final y = dy - (p.value as double) * (size.height - 32);
      if (i > 0) {
        final prev = points[i - 1];
        final px = (i - 1) * stepX;
        final py = dy - (prev.value as double) * (size.height - 32);
        canvas.drawLine(Offset(px, py), Offset(x, y), paint);
      }
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) =>
      oldDelegate.points != points;
}
