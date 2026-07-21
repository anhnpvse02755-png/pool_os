import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

const compilerVersion = '0.6.1';

void main(List<String> args) {
  final root = Directory.current.absolute;
  final sourceRoot = Directory(
    '${root.path}${Platform.pathSeparator}corpus${Platform.pathSeparator}articles',
  );
  final output = File(
    '${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}'
    'executable_pack_v0_6.json',
  );
  final write = !args.contains('--check');

  try {
    final files = sourceRoot
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.md'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    final compiled = compileKnowledgeCorpus(
      files.map((file) => file.readAsStringSync()).toList(),
      masteryPolicyDocument: parseYamlObject(
        File(
          '${root.path}${Platform.pathSeparator}corpus'
          '${Platform.pathSeparator}mastery_policies.yaml',
        ).readAsStringSync(),
      ),
    );
    if (write) {
      output.writeAsStringSync(compiled);
      stdout.writeln('Compiled ${files.length} entries -> ${output.path}');
    } else if (!output.existsSync() ||
        _normalizeNewlines(output.readAsStringSync()) != compiled) {
      throw const ExecutableKnowledgeException(
        'Generated pack drift. Run the compiler without --check.',
      );
    } else {
      stdout.writeln('Executable corpus and generated pack are in sync.');
    }
  } catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

String compileKnowledgeCorpus(
  List<String> markdownSources, {
  required Map<String, dynamic> masteryPolicyDocument,
}) {
  if (markdownSources.isEmpty) {
    throw const ExecutableKnowledgeException('Corpus must not be empty.');
  }
  final compiledSources =
      markdownSources.map(compileKnowledgeEntrySource).toList(growable: false);
  final ids = <String>{};
  for (final source in compiledSources) {
    if (!ids.add(source.id)) {
      throw ExecutableKnowledgeException(
        'Duplicate knowledge ID: ${source.id}.',
      );
    }
  }
  final dependencyIssues = validateKnowledgeDependencies(
    compiledSources.map(
      (source) => KnowledgeDependencyNode(
        entryId: source.id,
        dependencies: source.dependencies,
      ),
    ),
  );
  if (dependencyIssues.isNotEmpty) {
    final issue = dependencyIssues.first;
    throw ExecutableKnowledgeException(
      'Dependency validation failed [${issue.code.name}] for '
      '${issue.entryId}: ${issue.details.join(', ')}.',
    );
  }

  final versions =
      compiledSources.map((source) => source.knowledgeVersion).toSet();
  if (versions.length != 1) {
    throw const ExecutableKnowledgeException(
      'All entries in a release must use one knowledgeVersion.',
    );
  }
  final timestamps =
      compiledSources.map((source) => source.publishedAt).toList()..sort();
  final entries = compiledSources.map((source) => source.entry).toList()
    ..sort((a, b) => '${a['id']}'.compareTo('${b['id']}'));

  final payload = <String, dynamic>{
    'schemaVersion': 1,
    'compilerVersion': compilerVersion,
    'knowledgeVersion': versions.single,
    'generatedAt': timestamps.last,
    'masteryPolicyVersion': masteryPolicyDocument['policyVersion'],
    'masteryPolicies': masteryPolicyDocument['policies'],
    'entries': entries,
  };
  final digest = sha256.convert(utf8.encode(jsonEncode(payload))).toString();
  final pack = <String, dynamic>{...payload, 'contentDigest': digest};
  ExecutableKnowledgePack.fromJson(pack);
  return '${const JsonEncoder.withIndent('  ').convert(pack)}\n';
}

CompiledKnowledgeEntrySource compileKnowledgeEntrySource(String markdown) {
  final parsed = _parseMarkdown(_normalizeNewlines(markdown));
  final front = parsed.frontMatter;
  final id = _requiredString(front, 'id');
  if (front['schemaVersion'] != 1) {
    throw ExecutableKnowledgeException('$id has unsupported schemaVersion.');
  }
  final relations = _compileRelations(front['relations'], entryId: id);
  final entry = <String, dynamic>{
    'id': id,
    'kind': front['kind'],
    'reviewState': front['reviewState'],
    'title': front['title'],
    'summary': front['summary'],
    'body': parsed.body,
    'capabilities': front['capabilities'] ?? <dynamic>[],
    'relations': relations.runtimeTargets,
    if (relations.dependencies.isNotEmpty)
      'dependencies': relations.dependencies,
    'payload': front['payload'],
  };
  ExecutableKnowledgeEntry.fromJson(entry);
  return CompiledKnowledgeEntrySource(
    id: id,
    knowledgeVersion: _requiredString(front, 'knowledgeVersion'),
    publishedAt: _requiredString(front, 'publishedAt'),
    dependencies: relations.dependencies,
    entry: entry,
  );
}

class CompiledKnowledgeEntrySource {
  const CompiledKnowledgeEntrySource({
    required this.id,
    required this.knowledgeVersion,
    required this.publishedAt,
    required this.dependencies,
    required this.entry,
  });

  final String id;
  final String knowledgeVersion;
  final String publishedAt;
  final List<String> dependencies;
  final Map<String, dynamic> entry;
}

enum KnowledgeDependencyValidationCode {
  duplicateDependency,
  selfDependency,
  danglingDependency,
  dependencyCycle,
}

class KnowledgeDependencyNode {
  KnowledgeDependencyNode({
    required this.entryId,
    required List<String> dependencies,
  }) : dependencies = List.unmodifiable(dependencies);

  final String entryId;
  final List<String> dependencies;
}

class KnowledgeDependencyValidationIssue {
  KnowledgeDependencyValidationIssue({
    required this.code,
    required this.entryId,
    required List<String> details,
  }) : details = List.unmodifiable(details);

  final KnowledgeDependencyValidationCode code;
  final String entryId;
  final List<String> details;
}

List<KnowledgeDependencyValidationIssue> validateKnowledgeDependencies(
  Iterable<KnowledgeDependencyNode> nodes,
) {
  final ordered = [...nodes]
    ..sort((left, right) => left.entryId.compareTo(right.entryId));
  final byId = {for (final node in ordered) node.entryId: node};
  final issues = <KnowledgeDependencyValidationIssue>[];
  for (final node in ordered) {
    final seen = <String>{};
    for (final dependencyId in node.dependencies) {
      if (!seen.add(dependencyId)) {
        issues.add(
          KnowledgeDependencyValidationIssue(
            code: KnowledgeDependencyValidationCode.duplicateDependency,
            entryId: node.entryId,
            details: [dependencyId],
          ),
        );
      } else if (dependencyId == node.entryId) {
        issues.add(
          KnowledgeDependencyValidationIssue(
            code: KnowledgeDependencyValidationCode.selfDependency,
            entryId: node.entryId,
            details: [dependencyId],
          ),
        );
      } else if (!byId.containsKey(dependencyId)) {
        issues.add(
          KnowledgeDependencyValidationIssue(
            code: KnowledgeDependencyValidationCode.danglingDependency,
            entryId: node.entryId,
            details: [dependencyId],
          ),
        );
      }
    }
  }

  final cycleComponents = _dependencyCycles(ordered, byId);
  for (final component in cycleComponents) {
    for (final entryId in component) {
      issues.add(
        KnowledgeDependencyValidationIssue(
          code: KnowledgeDependencyValidationCode.dependencyCycle,
          entryId: entryId,
          details: component,
        ),
      );
    }
  }
  issues.sort((left, right) {
    final byEntry = left.entryId.compareTo(right.entryId);
    if (byEntry != 0) return byEntry;
    return left.code.index.compareTo(right.code.index);
  });
  return List.unmodifiable(issues);
}

List<List<String>> _dependencyCycles(
  List<KnowledgeDependencyNode> nodes,
  Map<String, KnowledgeDependencyNode> byId,
) {
  var nextIndex = 0;
  final indices = <String, int>{};
  final lowLinks = <String, int>{};
  final stack = <String>[];
  final onStack = <String>{};
  final cycles = <List<String>>[];

  void connect(String entryId) {
    indices[entryId] = nextIndex;
    lowLinks[entryId] = nextIndex;
    nextIndex++;
    stack.add(entryId);
    onStack.add(entryId);

    final dependencies = byId[entryId]!.dependencies.toSet().toList()..sort();
    for (final dependencyId in dependencies) {
      if (dependencyId == entryId || !byId.containsKey(dependencyId)) continue;
      if (!indices.containsKey(dependencyId)) {
        connect(dependencyId);
        lowLinks[entryId] = _minimum(
          lowLinks[entryId]!,
          lowLinks[dependencyId]!,
        );
      } else if (onStack.contains(dependencyId)) {
        lowLinks[entryId] = _minimum(
          lowLinks[entryId]!,
          indices[dependencyId]!,
        );
      }
    }

    if (lowLinks[entryId] != indices[entryId]) return;
    final component = <String>[];
    while (stack.isNotEmpty) {
      final member = stack.removeLast();
      onStack.remove(member);
      component.add(member);
      if (member == entryId) break;
    }
    if (component.length > 1) {
      component.sort();
      cycles.add(List.unmodifiable(component));
    }
  }

  for (final node in nodes) {
    if (!indices.containsKey(node.entryId)) connect(node.entryId);
  }
  cycles.sort((left, right) => left.first.compareTo(right.first));
  return cycles;
}

int _minimum(int left, int right) => left < right ? left : right;

class _CompiledRelations {
  const _CompiledRelations({
    required this.runtimeTargets,
    required this.dependencies,
  });

  final List<String> runtimeTargets;
  final List<String> dependencies;
}

_CompiledRelations _compileRelations(dynamic value, {required String entryId}) {
  if (value == null) {
    return const _CompiledRelations(runtimeTargets: [], dependencies: []);
  }
  if (value is! List) {
    throw ExecutableKnowledgeException('$entryId.relations must be a list.');
  }
  final legacyTargets = <String>[];
  final dependencies = <String>[];
  for (final relation in value) {
    if (relation is String && relation.trim().isNotEmpty) {
      legacyTargets.add(relation);
      continue;
    }
    if (relation is! Map<String, dynamic> ||
        relation['type'] != 'requires' ||
        relation['targetId'] is! String ||
        (relation['targetId'] as String).trim().isEmpty) {
      throw ExecutableKnowledgeException(
        '$entryId.relations contains an invalid typed dependency.',
      );
    }
    dependencies.add(relation['targetId'] as String);
  }
  final canonicalDependencies = [...dependencies]..sort();
  return _CompiledRelations(
    runtimeTargets: List.unmodifiable([
      ...legacyTargets,
      ...canonicalDependencies,
    ]),
    dependencies: List.unmodifiable(canonicalDependencies),
  );
}

String _normalizeNewlines(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

Map<String, dynamic> parseYamlObject(String source) {
  final parsed = _plain(loadYaml(source));
  if (parsed is! Map<String, dynamic>) {
    throw const ExecutableKnowledgeException('YAML root must be an object.');
  }
  if (parsed['schemaVersion'] != 1) {
    throw const ExecutableKnowledgeException(
      'Unsupported mastery policy schema version.',
    );
  }
  return parsed;
}

_ParsedMarkdown _parseMarkdown(String markdown) {
  final match = RegExp(r'^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]+)$')
      .firstMatch(markdown.trim());
  if (match == null) {
    throw const ExecutableKnowledgeException(
      'Source requires YAML front matter and a Markdown body.',
    );
  }
  final frontMatter = _plain(loadYaml(match.group(1)!));
  if (frontMatter is! Map<String, dynamic>) {
    throw const ExecutableKnowledgeException('Front matter must be an object.');
  }
  return _ParsedMarkdown(frontMatter, match.group(2)!.trim());
}

class _ParsedMarkdown {
  const _ParsedMarkdown(this.frontMatter, this.body);

  final Map<String, dynamic> frontMatter;
  final String body;
}

dynamic _plain(dynamic value) {
  if (value is YamlMap) {
    return <String, dynamic>{
      for (final entry in value.entries)
        entry.key.toString(): _plain(entry.value),
    };
  }
  if (value is YamlList) return value.map(_plain).toList();
  return value;
}

String _requiredString(Map<String, dynamic> object, String field) {
  final value = object[field];
  if (value is! String || value.trim().isEmpty) {
    throw ExecutableKnowledgeException('$field must be a non-empty string.');
  }
  return value;
}
