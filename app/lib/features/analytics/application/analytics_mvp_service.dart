import '../../../application/foundation/application_context.dart';
import '../../../application/foundation/application_handlers.dart';
import '../../../capabilities/analytics/analytics_capability_contracts.dart';
import '../../../framework/query/query_executor.dart';
import '../../../runtime/analytics/analytics_capability_runtime.dart';
import '../../../shared/foundation/identifier.dart';
import '../../../shared/foundation/result.dart';
import '../../../shared/foundation/value_object.dart';

final class MatchAnalyticsSource extends ValueObject {
  MatchAnalyticsSource({
    required this.matchCount,
    required this.rackCount,
    required this.wins,
    required this.losses,
    required this.duration,
    required List<MatchAnalyticsActivity> recent,
  }) : recent = List.unmodifiable(recent);

  final int matchCount;
  final int rackCount;
  final int wins;
  final int losses;
  final Duration duration;
  final List<MatchAnalyticsActivity> recent;

  @override
  List<Object?> get components => [
        matchCount,
        rackCount,
        wins,
        losses,
        duration.inMicroseconds,
        recent.length,
        ...recent,
      ];
}

final class MatchAnalyticsActivity extends ValueObject {
  const MatchAnalyticsActivity({
    required this.id,
    required this.occurredAt,
    required this.winRate,
    required this.duration,
  });

  final int id;
  final DateTime occurredAt;
  final double winRate;
  final Duration duration;

  @override
  List<Object?> get components => [
        id,
        occurredAt.microsecondsSinceEpoch,
        winRate,
        duration.inMicroseconds,
      ];
}

final class TrainingAnalyticsSource extends ValueObject {
  TrainingAnalyticsSource({
    required this.sessionCount,
    required this.exerciseCount,
    required this.attempts,
    required this.successes,
    required this.duration,
    required List<TrainingAnalyticsActivity> recent,
  }) : recent = List.unmodifiable(recent);

  final int sessionCount;
  final int exerciseCount;
  final int attempts;
  final int successes;
  final Duration duration;
  final List<TrainingAnalyticsActivity> recent;

  @override
  List<Object?> get components => [
        sessionCount,
        exerciseCount,
        attempts,
        successes,
        duration.inMicroseconds,
        recent.length,
        ...recent,
      ];
}

final class TrainingAnalyticsActivity extends ValueObject {
  const TrainingAnalyticsActivity({
    required this.id,
    required this.occurredAt,
    required this.successRate,
    required this.duration,
  });

  final int id;
  final DateTime occurredAt;
  final double successRate;
  final Duration duration;

  @override
  List<Object?> get components => [
        id,
        occurredAt.microsecondsSinceEpoch,
        successRate,
        duration.inMicroseconds,
      ];
}

enum AnalyticsActivityKind { match, training }

final class AnalyticsActivity extends ValueObject {
  const AnalyticsActivity({
    required this.kind,
    required this.id,
    required this.occurredAt,
    required this.rate,
    required this.duration,
  });

  final AnalyticsActivityKind kind;
  final int id;
  final DateTime occurredAt;
  final double rate;
  final Duration duration;

  @override
  List<Object?> get components => [
        kind,
        id,
        occurredAt.microsecondsSinceEpoch,
        rate,
        duration.inMicroseconds,
      ];
}

final class AnalyticsDashboardView extends ValueObject {
  AnalyticsDashboardView({
    required this.matches,
    required this.training,
    required List<AnalyticsActivity> recentActivity,
  }) : recentActivity = List.unmodifiable(recentActivity);

  final MatchAnalyticsSource matches;
  final TrainingAnalyticsSource training;
  final List<AnalyticsActivity> recentActivity;

  double get matchWinRate {
    final racks = matches.wins + matches.losses;
    return racks == 0 ? 0 : matches.wins / racks;
  }

  double get trainingSuccessRate =>
      training.attempts == 0 ? 0 : training.successes / training.attempts;

  @override
  List<Object?> get components => [
        matches,
        training,
        recentActivity.length,
        ...recentActivity,
      ];
}

typedef MatchAnalyticsLoader = Future<MatchAnalyticsSource> Function();
typedef TrainingAnalyticsLoader = Future<TrainingAnalyticsSource> Function();

final class AnalyticsMvpService {
  AnalyticsMvpService({
    required MatchAnalyticsLoader loadMatches,
    required TrainingAnalyticsLoader loadTraining,
  })  : _loadMatches = loadMatches,
        _loadTraining = loadTraining {
    final capability = _AnalyticsMvpCapability();
    const AnalyticsCapabilityBootstrap().initialize(
      registry: AnalyticsCapabilityRegistry([capability]),
      identity: capability.metadata.identity,
      compatibility: AnalyticsCapabilityCompatibility(
        requiredVersion: capability.metadata.version,
      ),
    );
  }

  final MatchAnalyticsLoader _loadMatches;
  final TrainingAnalyticsLoader _loadTraining;
  var _requestSequence = 0;

  Future<AnalyticsDashboardView> load() async {
    _requestSequence += 1;
    final requestId = RuntimeIdentifier(
      namespace: 'product.analytics-mvp.request',
      value: 'dashboard-$_requestSequence',
    );
    final execution =
        await QueryExecutor<_AnalyticsDashboardQuery, AnalyticsDashboardView>(
      handler: _AnalyticsDashboardHandler(_loadMatches, _loadTraining),
      handlerId: RuntimeIdentifier(
        namespace: 'product.analytics-mvp.handler',
        value: 'load-dashboard',
      ),
    ).execute(
      query: const _AnalyticsDashboardQuery(),
      context: ApplicationExecutionContext(
        request: ApplicationRequestContext(
          requestId: requestId,
          correlationId: requestId,
          requestedAtUtc: DateTime.now().toUtc(),
        ),
        cancellationToken: const _NeverCancelled(),
      ),
    );
    return execution.result.fold(
      onSuccess: (view) => view,
      onFailure: (failure) => throw StateError(failure.code),
    );
  }
}

final class _AnalyticsMvpCapability
    implements
        AnalyticsLifecycleCapability,
        StatisticsCollectionCapability,
        ReportingCapability {
  _AnalyticsMvpCapability()
      : metadata = AnalyticsCapabilityMetadata(
          identity: AnalyticsCapabilityIdentity(_id('capability', 'dashboard')),
          version: AnalyticsCapabilityVersion(_id('version', 'v1')),
          kinds: const [
            AnalyticsCapabilityKind.lifecycle,
            AnalyticsCapabilityKind.statisticsCollection,
            AnalyticsCapabilityKind.reporting,
          ],
        );

  @override
  final AnalyticsCapabilityMetadata metadata;
}

final class _AnalyticsDashboardQuery extends ValueObject {
  const _AnalyticsDashboardQuery();

  @override
  List<Object?> get components => const [];
}

final class _AnalyticsDashboardHandler
    implements QueryHandler<_AnalyticsDashboardQuery, AnalyticsDashboardView> {
  const _AnalyticsDashboardHandler(this.loadMatches, this.loadTraining);

  final MatchAnalyticsLoader loadMatches;
  final TrainingAnalyticsLoader loadTraining;

  @override
  Future<Result<AnalyticsDashboardView>> handle(
    _AnalyticsDashboardQuery query,
    ApplicationExecutionContext context,
  ) async {
    final matches = await loadMatches();
    final training = await loadTraining();
    final activity = <AnalyticsActivity>[
      for (final item in matches.recent)
        AnalyticsActivity(
          kind: AnalyticsActivityKind.match,
          id: item.id,
          occurredAt: item.occurredAt,
          rate: item.winRate,
          duration: item.duration,
        ),
      for (final item in training.recent)
        AnalyticsActivity(
          kind: AnalyticsActivityKind.training,
          id: item.id,
          occurredAt: item.occurredAt,
          rate: item.successRate,
          duration: item.duration,
        ),
    ]..sort((left, right) {
        final time = right.occurredAt.compareTo(left.occurredAt);
        if (time != 0) return time;
        final kind = left.kind.index.compareTo(right.kind.index);
        return kind != 0 ? kind : right.id.compareTo(left.id);
      });
    return Success(AnalyticsDashboardView(
      matches: matches,
      training: training,
      recentActivity: activity.take(8).toList(),
    ));
  }
}

final class _NeverCancelled implements CancellationToken {
  const _NeverCancelled();

  @override
  bool get isCancellationRequested => false;
}

RuntimeIdentifier _id(String segment, String value) => RuntimeIdentifier(
      namespace: 'product.analytics-mvp.$segment',
      value: value,
    );
