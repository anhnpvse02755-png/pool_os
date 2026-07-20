import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/coach/domain/brain/coach_brain.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/brain/knowledge_registry.dart';
import 'package:pool_os/features/coach/domain/context/coach_context.dart';
import 'package:pool_os/features/coach/domain/findings/finding.dart';

void main() {
  test('Coach Brain owns the next lesson for a new learner', () {
    final context = CoachContext.fromFindings(const [
      Finding(
        metricId: 'mastery.entry.fundamental.stance.basic',
        source: FindingSource.mastery,
        value: 0,
        data: {
          'entryId': 'fundamental.stance.basic',
          'pathId': 'path.beginner.fundamentals',
          'pathIndex': 0,
          'stepIndex': 0,
          'current': true,
          'confidence': 0.0,
        },
      ),
      Finding(
        metricId: 'coverage.mastery',
        source: FindingSource.coverage,
        data: {'coveredSource': 'mastery'},
      ),
    ]);

    final output = CoachBrain().decide(context);
    expect(output.feed.single.topic, CoachTopic.mastery);
    expect(
      KnowledgeRegistry.articleFor(output.primaryAction!.knowledgeId),
      'fundamental.stance.basic',
    );
  });

  test('repeated memory raises a measured weakness to critical', () {
    final context = CoachContext.fromFindings(const [
      Finding(
        metricId: 'performance.execution',
        source: FindingSource.performance,
        value: 45,
        sampleSize: 20,
        data: {
          'dimension': 'execution',
          'coachReady': true,
          'methodologyId': 'performance.execution.outcome.v1',
        },
      ),
      Finding(
        metricId: 'performance.execution',
        source: FindingSource.memory,
        value: 45,
        sampleSize: 20,
        data: {'kind': 'weakness', 'occurrences': 2},
      ),
    ]);

    final insight = CoachBrain()
        .decide(context)
        .feed
        .singleWhere((item) => item.topic == CoachTopic.performance);
    expect(insight.priority, CoachPriority.critical);
    expect(insight.evidenceData['occurrences'], 2);
  });
}
