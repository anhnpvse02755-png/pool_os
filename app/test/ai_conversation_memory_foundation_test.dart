import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/ai_conversation_memory_contracts.dart';
import 'package:pool_os/contracts/ai_response_processing_contracts.dart';

void main() {
  test('projects canonical immutable interaction references only', () {
    final memory = const AIConversationMemoryProjector().project([
      _processing('b'),
      _processing('a'),
    ]);

    expect(memory.capabilityId, 'chat_generation');
    expect(memory.entries, hasLength(2));
    expect(memory.entries.map((item) => item.position), [1, 2]);
    expect(
        memory.entries.first.processingDigest
            .compareTo(memory.entries.last.processingDigest),
        lessThan(0));
  });

  test('input order does not change replay JSON or digest', () {
    const projector = AIConversationMemoryProjector();
    final first = projector.project([_processing('a'), _processing('b')]);
    final second = projector.project([_processing('b'), _processing('a')]);

    expect(second.digest, first.digest);
    expect(second.toJson(), first.toJson());
  });

  test('duplicate interaction fails closed', () {
    final item = _processing('same');
    expect(
      () => const AIConversationMemoryProjector().project([item, item]),
      throwsArgumentError,
    );
  });

  test('foreign capability fails closed', () {
    expect(
      () => const AIConversationMemoryProjector().project([
        _processing('chat'),
        _processing('vision', capability: 'shot_analysis'),
      ]),
      throwsArgumentError,
    );
  });

  test('projection and source artifacts remain immutable', () {
    final source = [_processing('a')];
    final before = jsonEncode(source.single.toJson());
    final memory = const AIConversationMemoryProjector().project(source);

    expect(() => memory.entries.add(memory.entries.single),
        throwsUnsupportedError);
    expect(jsonEncode(source.single.toJson()), before);
  });

  test('memory contains no raw content or persistence semantics', () {
    final encoded = jsonEncode(
      const AIConversationMemoryProjector()
          .project([_processing('a')]).toJson(),
    );

    expect(encoded, isNot(contains('prompt')));
    expect(encoded, isNot(contains('completion')));
    expect(encoded, isNot(contains('embedding')));
    expect(encoded, isNot(contains('vector')));
    expect(encoded, isNot(contains('playerState')));
  });
}

AIResponseProcessingContract _processing(
  String suffix, {
  String capability = 'chat_generation',
}) =>
    AIResponseProcessingContract.create(
      providerPayloadDigest: 'payload.$suffix',
      providerRequestDigest: 'request.$suffix',
      providerResultDigest: 'result.$suffix',
      capabilityId: capability,
      processingMetadata: const {
        'providerId': 'stub/deterministic',
        'status': 'stubbed',
      },
    );
