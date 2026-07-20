import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/knowledge_publication.dart';

void main() {
  late Directory temporary;
  late Directory store;
  late String compiled;

  setUp(() {
    temporary = Directory.systemTemp.createTempSync(
      'pool_os_knowledge_publication_',
    );
    store = Directory('${temporary.path}${Platform.pathSeparator}store');
    compiled = compileCurrentCorpus(Directory.current);
  });

  tearDown(() {
    if (temporary.existsSync()) temporary.deleteSync(recursive: true);
  });

  group('KnowledgePublicationPipeline', () {
    test('compiler input matches the frozen generated asset', () {
      expect(
        compiled,
        _normalizeNewlines(
          File('assets/executable_pack_v0_6.json').readAsStringSync(),
        ),
      );
    });

    test('publishes one deterministic immutable artifact idempotently', () {
      final pipeline = KnowledgePublicationPipeline(store);

      final first = pipeline.publish(compiled);
      final second = pipeline.publish(compiled);

      expect(second.digest, first.digest);
      expect(pipeline.current().contentDigest, first.contentDigest);
      final artifacts =
          Directory('${store.path}${Platform.pathSeparator}objects')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('package.json'));
      expect(artifacts, hasLength(1));
    });

    test('serializes concurrent publishers into one current artifact',
        () async {
      final storePath = store.path;
      final publications = await Future.wait([
        for (var index = 0; index < 3; index++)
          Isolate.run(
            () => KnowledgePublicationPipeline(Directory(storePath))
                .publish(compiled)
                .contentDigest,
          ),
      ]);

      expect(publications.toSet(), hasLength(1));
      expect(
        KnowledgePublicationPipeline(store).current().contentDigest,
        publications.first,
      );
    });

    test('validation failure cannot replace the current publication', () {
      final pipeline = KnowledgePublicationPipeline(store);
      final current = pipeline.publish(compiled);
      final tampered = compiled.replaceFirst('Ghost Ball', 'Tampered Ball');

      expect(
        () => pipeline.publish(tampered),
        throwsA(isA<ExecutableKnowledgeException>()),
      );
      expect(pipeline.current().contentDigest, current.contentDigest);
    });

    test('recovers when publication stops after backing up current', () {
      final stable = KnowledgePublicationPipeline(store).publish(compiled);
      final next = _variant(compiled, knowledgeVersion: '0.6.0-failure-test');
      final failing = KnowledgePublicationPipeline(
        store,
        faultInjector: (checkpoint) {
          if (checkpoint == PublicationCheckpoint.currentBackedUp) {
            throw StateError('simulated process termination');
          }
        },
      );

      expect(() => failing.publish(next), throwsStateError);

      final recovered = KnowledgePublicationPipeline(store).current();
      expect(recovered.contentDigest, stable.contentDigest);
    });

    test('rollback atomically selects the previous immutable publication', () {
      final pipeline = KnowledgePublicationPipeline(store);
      final first = pipeline.publish(compiled);
      final second = pipeline.publish(
        _variant(compiled, knowledgeVersion: '0.6.0-next'),
      );
      expect(second.contentDigest, isNot(first.contentDigest));

      final rolledBack = pipeline.rollback();

      expect(rolledBack.contentDigest, first.contentDigest);
      expect(pipeline.current().contentDigest, first.contentDigest);
    });

    test('corrupted current pointer falls back to the previous publication',
        () {
      final pipeline = KnowledgePublicationPipeline(store);
      final first = pipeline.publish(compiled);
      pipeline.publish(_variant(compiled, knowledgeVersion: '0.6.0-next'));
      File('${store.path}${Platform.pathSeparator}current.json')
          .writeAsStringSync('{"truncated":', flush: true);

      final recovered = pipeline.current();

      expect(recovered.contentDigest, first.contentDigest);
      expect(
        jsonDecode(
          File('${store.path}${Platform.pathSeparator}current.json')
              .readAsStringSync(),
        ),
        isA<Map<String, dynamic>>(),
      );
    });

    test('rejects a modified immutable artifact', () {
      final pipeline = KnowledgePublicationPipeline(store);
      final publication = pipeline.publish(compiled);
      final artifact = File(
        '${store.path}${Platform.pathSeparator}'
        '${publication.artifactPath.replaceAll('/', Platform.pathSeparator)}',
      );
      artifact.writeAsStringSync(
        '${artifact.readAsStringSync()}\n',
        flush: true,
      );

      expect(
        pipeline.current,
        throwsA(isA<KnowledgePublicationException>()),
      );
    });

    test('verifyCurrent detects compiler/publication drift', () {
      final pipeline = KnowledgePublicationPipeline(store);
      pipeline.publish(compiled);

      expect(
        () => pipeline.verifyCurrent(
          _variant(compiled, knowledgeVersion: '0.6.0-drift'),
        ),
        throwsA(isA<KnowledgePublicationException>()),
      );
    });
  });
}

String _variant(String compiled, {required String knowledgeVersion}) {
  final payload = Map<String, dynamic>.from(
    jsonDecode(compiled) as Map,
  )
    ..remove('contentDigest')
    ..['knowledgeVersion'] = knowledgeVersion;
  final digest = sha256.convert(utf8.encode(jsonEncode(payload))).toString();
  return '${const JsonEncoder.withIndent(' ').convert({
        ...payload,
        'contentDigest': digest,
      })}\n';
}

String _normalizeNewlines(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
