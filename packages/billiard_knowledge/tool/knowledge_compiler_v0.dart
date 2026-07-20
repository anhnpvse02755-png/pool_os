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
  final entry = <String, dynamic>{
    'id': id,
    'kind': front['kind'],
    'reviewState': front['reviewState'],
    'title': front['title'],
    'summary': front['summary'],
    'body': parsed.body,
    'capabilities': front['capabilities'] ?? <dynamic>[],
    'relations': front['relations'] ?? <dynamic>[],
    'payload': front['payload'],
  };
  ExecutableKnowledgeEntry.fromJson(entry);
  return CompiledKnowledgeEntrySource(
    id: id,
    knowledgeVersion: _requiredString(front, 'knowledgeVersion'),
    publishedAt: _requiredString(front, 'publishedAt'),
    entry: entry,
  );
}

class CompiledKnowledgeEntrySource {
  const CompiledKnowledgeEntrySource({
    required this.id,
    required this.knowledgeVersion,
    required this.publishedAt,
    required this.entry,
  });

  final String id;
  final String knowledgeVersion;
  final String publishedAt;
  final Map<String, dynamic> entry;
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
