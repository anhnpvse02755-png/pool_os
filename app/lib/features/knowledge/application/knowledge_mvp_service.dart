import 'package:billiard_knowledge/billiard_knowledge.dart';

import '../../../application/foundation/application_context.dart';
import '../../../application/foundation/application_handlers.dart';
import '../../../capabilities/knowledge/knowledge_capability_contracts.dart';
import '../../../framework/query/query_executor.dart';
import '../../../runtime/knowledge/knowledge_capability_runtime.dart';
import '../../../shared/foundation/identifier.dart';
import '../../../shared/foundation/result.dart';
import '../../../shared/foundation/value_object.dart';

typedef KnowledgeCatalogLoader = Future<KnowledgeCatalog> Function();

final class KnowledgeCategorySummary extends ValueObject {
  const KnowledgeCategorySummary({required this.kind, required this.count});

  final KnowledgeKind kind;
  final int count;

  @override
  List<Object?> get components => [kind, count];
}

final class KnowledgeBrowseView extends ValueObject {
  KnowledgeBrowseView({
    required this.catalog,
    required List<KnowledgeSearchResult> results,
    required List<KnowledgeCategorySummary> categories,
  })  : results = List.unmodifiable(results),
        categories = List.unmodifiable(categories);

  final KnowledgeCatalog catalog;
  final List<KnowledgeSearchResult> results;
  final List<KnowledgeCategorySummary> categories;

  @override
  List<Object?> get components => [
        catalog.packVersion,
        results.length,
        for (final result in results) ...[result.entry.id, result.score],
        categories.length,
        ...categories,
      ];
}

final class KnowledgeBrowseRequest extends ValueObject {
  const KnowledgeBrowseRequest({
    this.text = '',
    this.kind,
    this.level,
    this.locale = 'en',
  });

  final String text;
  final KnowledgeKind? kind;
  final AudienceLevel? level;
  final String locale;

  @override
  List<Object?> get components => [text, kind, level, locale];
}

final class KnowledgeMvpService {
  KnowledgeMvpService(this._loadCatalog) {
    final capability = _KnowledgeMvpCapability();
    const KnowledgeCapabilityBootstrap().initialize(
      registry: KnowledgeCapabilityRegistry([capability]),
      identity: capability.metadata.identity,
      compatibility: KnowledgeCapabilityCompatibility(
        requiredVersion: capability.metadata.version,
      ),
    );
  }

  final KnowledgeCatalogLoader _loadCatalog;
  var _requestSequence = 0;

  Future<KnowledgeBrowseView> browse(KnowledgeBrowseRequest request) async {
    _requestSequence += 1;
    final requestId = RuntimeIdentifier(
      namespace: 'product.knowledge-mvp.request',
      value: 'browse-$_requestSequence',
    );
    final execution =
        await QueryExecutor<KnowledgeBrowseRequest, KnowledgeBrowseView>(
      handler: _BrowseKnowledgeHandler(_loadCatalog),
      handlerId: RuntimeIdentifier(
        namespace: 'product.knowledge-mvp.handler',
        value: 'browse-catalog',
      ),
    ).execute(
      query: request,
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

final class _KnowledgeMvpCapability
    implements
        KnowledgeLifecycleCapability,
        KnowledgeSearchCapability,
        KnowledgeRetrievalCapability,
        KnowledgeClassificationCapability {
  _KnowledgeMvpCapability()
      : metadata = KnowledgeCapabilityMetadata(
          identity: KnowledgeCapabilityIdentity(_id('capability', 'library')),
          version: KnowledgeCapabilityVersion(_id('version', 'v1')),
          kinds: const [
            KnowledgeCapabilityKind.lifecycle,
            KnowledgeCapabilityKind.search,
            KnowledgeCapabilityKind.retrieval,
            KnowledgeCapabilityKind.classification,
          ],
        );

  @override
  final KnowledgeCapabilityMetadata metadata;
}

final class _BrowseKnowledgeHandler
    implements QueryHandler<KnowledgeBrowseRequest, KnowledgeBrowseView> {
  const _BrowseKnowledgeHandler(this.loadCatalog);

  final KnowledgeCatalogLoader loadCatalog;

  @override
  Future<Result<KnowledgeBrowseView>> handle(
    KnowledgeBrowseRequest request,
    ApplicationExecutionContext context,
  ) async {
    final catalog = await loadCatalog();
    final results = catalog.search(KnowledgeQuery(
      text: request.text,
      locale: request.locale,
      kinds: request.kind == null ? const {} : {request.kind!},
      levels: request.level == null ? const {} : {request.level!},
    ));
    final counts = <KnowledgeKind, int>{
      for (final kind in KnowledgeKind.values) kind: 0,
    };
    for (final entry in catalog.entries) {
      counts[entry.kind] = counts[entry.kind]! + 1;
    }
    return Success(KnowledgeBrowseView(
      catalog: catalog,
      results: results,
      categories: [
        for (final kind in KnowledgeKind.values)
          if (counts[kind]! > 0)
            KnowledgeCategorySummary(kind: kind, count: counts[kind]!),
      ],
    ));
  }
}

final class _NeverCancelled implements CancellationToken {
  const _NeverCancelled();

  @override
  bool get isCancellationRequested => false;
}

RuntimeIdentifier _id(String segment, String value) => RuntimeIdentifier(
      namespace: 'product.knowledge-mvp.$segment',
      value: value,
    );
