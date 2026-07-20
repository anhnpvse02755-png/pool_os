import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/knowledge_compiler_v0.dart' as compiler;

void main() {
  late List<String> sources;
  late File generated;
  late Map<String, dynamic> masteryPolicies;

  setUp(() {
    final files = Directory('corpus/articles')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.md'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    sources = files.map((file) => file.readAsStringSync()).toList();
    generated = File('assets/executable_pack_v0_6.json');
    masteryPolicies = compiler.parseYamlObject(
      File('corpus/mastery_policies.yaml').readAsStringSync(),
    );
  });

  test('compiler emits a deterministic discriminated union pack', () {
    final compiled = compiler.compileKnowledgeCorpus(
      sources,
      masteryPolicyDocument: masteryPolicies,
    );
    expect(compiled, _normalizeNewlines(generated.readAsStringSync()));
    final pack = ExecutableKnowledgePack.fromJsonString(compiled);
    expect(pack.entries, hasLength(4));
    expect(
      pack.entries.map((entry) => entry.kind),
      containsAll(ExecutableKnowledgeKind.values),
    );
    expect(pack.byId('control.stop_shot')!.payload, isA<TechniquePayload>());
    expect(
      pack.byId('mistake.poor_speed_control')!.payload,
      isA<MistakePayload>(),
    );
    expect(pack.byId('aiming.ghost_ball')!.payload, isA<ConceptPayload>());
    expect(pack.byId('control.follow_shot')!.payload, isA<TechniquePayload>());
    expect(
      pack.masteryPolicy(MasteryCategory.foundation).requiredSuccessesFor(25),
      23,
    );
  });

  test('compiler rejects duplicate IDs', () {
    expect(
      () => compiler.compileKnowledgeCorpus(
        [...sources, sources.first],
        masteryPolicyDocument: masteryPolicies,
      ),
      throwsA(isA<ExecutableKnowledgeException>()),
    );
  });

  test('compiler rejects dangling relations', () {
    final invalid = [...sources];
    invalid[0] = invalid[0].replaceFirst(
      'control.stop_shot',
      'missing.knowledge',
    );
    expect(
      () => compiler.compileKnowledgeCorpus(
        invalid,
        masteryPolicyDocument: masteryPolicies,
      ),
      throwsA(isA<ExecutableKnowledgeException>()),
    );
  });

  test('compiler rejects knowledge that is not verified', () {
    final draft = [...sources];
    draft[0] = draft[0].replaceFirst(
      'reviewState: verified',
      'reviewState: reviewed',
    );
    expect(
      () => compiler.compileKnowledgeCorpus(
        draft,
        masteryPolicyDocument: masteryPolicies,
      ),
      throwsA(isA<ExecutableKnowledgeException>()),
    );
  });

  test('runtime rejects a modified generated pack', () {
    final tampered = generated
        .readAsStringSync()
        .replaceFirst('Ghost Ball', 'Ghost Ball Modified');
    expect(
      () => ExecutableKnowledgePack.fromJsonString(tampered),
      throwsA(isA<ExecutableKnowledgeException>()),
    );
  });
}

String _normalizeNewlines(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
