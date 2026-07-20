import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';

const compilerVersion = '1.0.0';

void main(List<String> args) {
  final command = args.isEmpty ? 'check' : args.first;
  final root = _packageRoot(args);
  final compiler = KnowledgeCompiler(root);

  try {
    switch (command) {
      case 'bootstrap':
        compiler.bootstrap();
        break;
      case 'compile':
        compiler.compile(writeOutput: true);
        break;
      case 'check':
        compiler.compile(writeOutput: false);
        break;
      default:
        stderr.writeln(
          'Usage: dart run tool/knowledge_compiler.dart '
          '<bootstrap|compile|check> [--root <package-directory>]',
        );
        exitCode = 64;
    }
  } on KnowledgeCompilerException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

Directory _packageRoot(List<String> args) {
  final rootIndex = args.indexOf('--root');
  if (rootIndex >= 0) {
    if (rootIndex + 1 >= args.length) {
      throw KnowledgeCompilerException('--root requires a directory.');
    }
    return Directory(args[rootIndex + 1]).absolute;
  }
  return Directory.current.absolute;
}

class KnowledgeCompiler {
  KnowledgeCompiler(this.root);

  final Directory root;

  Directory get corpus => Directory(_join(root.path, 'corpus'));
  Directory get entryDirectory => Directory(_join(corpus.path, 'entries'));
  Directory get sourceDirectory => Directory(_join(corpus.path, 'sources'));
  Directory get pathDirectory => Directory(_join(corpus.path, 'paths'));
  File get manifestFile => File(_join(corpus.path, 'manifest.json'));
  File get taxonomyFile => File(_join(corpus.path, 'taxonomy.json'));
  File get registryFile => File(_join(corpus.path, 'id_registry.json'));
  File get packFile => File(_join(root.path, 'assets', 'pack_v1.json'));
  File get reportFile => File(
    _join(_join(root.path, 'build', 'knowledge_compiler'), 'report.json'),
  );

  void bootstrap() {
    if (!packFile.existsSync()) {
      throw KnowledgeCompilerException('Missing seed pack: ${packFile.path}');
    }
    if (corpus.existsSync() && corpus.listSync(recursive: true).isNotEmpty) {
      throw KnowledgeCompilerException(
        'Bootstrap is migration-only and requires an empty corpus directory.',
      );
    }

    final pack = _readObject(packFile);
    final packVersion = _requiredString(pack, 'packVersion', packFile.path);
    final generatedAt = _requiredString(pack, 'generatedAt', packFile.path);
    final sources = _objectList(pack['sources'], 'sources');
    final entries = _objectList(pack['entries'], 'entries');
    final paths = _objectList(pack['paths'], 'paths');

    for (final directory in [entryDirectory, sourceDirectory, pathDirectory]) {
      directory.createSync(recursive: true);
    }

    _writeJson(manifestFile, {
      'schemaVersion': 1,
      'packVersion': packVersion,
      'generatedAt': generatedAt,
      'compilerVersion': compilerVersion,
    });

    final topics = <String>{};
    for (final entry in entries) {
      final id = _requiredString(entry, 'id', 'entry');
      final topic = _requiredString(entry, 'topic', id);
      topics.add(topic);
      entry['discipline'] ??= 'pool';
      entry['categoryPath'] ??= [topic];
      final legacyRelations = entry.remove('relatedEntryIds');
      if (entry['relations'] == null && legacyRelations is List) {
        entry['relations'] = [
          for (final target in legacyRelations)
            {'targetId': target.toString(), 'type': 'related'},
        ];
      }
      _writeJson(File(_join(entryDirectory.path, '$id.json')), entry);
    }
    for (final source in sources) {
      final id = _requiredString(source, 'id', 'source');
      _writeJson(File(_join(sourceDirectory.path, '$id.json')), source);
    }
    for (final path in paths) {
      final id = _requiredString(path, 'id', 'path');
      _writeJson(File(_join(pathDirectory.path, '$id.json')), path);
    }

    _writeJson(taxonomyFile, {
      'schemaVersion': 1,
      'frozenAtPackVersion': packVersion,
      'kinds': KnowledgeKind.values.map((value) => value.name).toList(),
      'disciplines': BilliardDiscipline.values
          .map((value) => value.name)
          .toList(),
      'levels': AudienceLevel.values.map((value) => value.name).toList(),
      'reviewStates': ReviewState.values.map((value) => value.name).toList(),
      'explanationDepths': ExplanationDepth.values
          .map((value) => value.name)
          .toList(),
      'relationTypes': RelationType.values.map((value) => value.name).toList(),
      'topics': topics.toList()..sort(),
    });

    _writeJson(registryFile, {
      'schemaVersion': 1,
      'policy': 'IDs are immutable after registration; rename by deprecation.',
      'entries': [
        for (final entry in entries)
          {
            'id': entry['id'],
            'kind': entry['kind'],
            'status': 'active',
            'firstPublishedIn': packVersion,
          },
      ]..sort((a, b) => '${a['id']}'.compareTo('${b['id']}')),
      'sources': [
        for (final source in sources)
          {
            'id': source['id'],
            'status': 'active',
            'firstPublishedIn': packVersion,
          },
      ]..sort((a, b) => '${a['id']}'.compareTo('${b['id']}')),
      'paths': [
        for (final path in paths)
          {
            'id': path['id'],
            'status': 'active',
            'firstPublishedIn': packVersion,
          },
      ]..sort((a, b) => '${a['id']}'.compareTo('${b['id']}')),
    });

    stdout.writeln(
      'Bootstrapped ${entries.length} entries, ${sources.length} sources, '
      'and ${paths.length} paths into ${corpus.path}.',
    );
  }

  void compile({required bool writeOutput}) {
    final issues = <CompilerIssue>[];
    final manifest = _readObject(manifestFile);
    final taxonomy = _readObject(taxonomyFile);
    final registry = _readObject(registryFile);
    final sources = _readObjects(sourceDirectory, issues);
    final entries = _readObjects(entryDirectory, issues);
    final paths = _readObjects(pathDirectory, issues);

    final allowed = <String, Set<String>>{
      'kind': _stringSet(taxonomy['kinds']),
      'discipline': _stringSet(taxonomy['disciplines']),
      'level': _stringSet(taxonomy['levels']),
      'reviewState': _stringSet(taxonomy['reviewStates']),
      'topic': _stringSet(taxonomy['topics']),
      'depth': _stringSet(taxonomy['explanationDepths']),
      'relation': _stringSet(taxonomy['relationTypes']),
    };

    _validateRegistry(
      records: entries,
      registered: _objectList(registry['entries'], 'registry.entries'),
      entity: 'entry',
      issues: issues,
      kindIsFrozen: true,
    );
    _validateRegistry(
      records: sources,
      registered: _objectList(registry['sources'], 'registry.sources'),
      entity: 'source',
      issues: issues,
    );
    _validateRegistry(
      records: paths,
      registered: _objectList(registry['paths'], 'registry.paths'),
      entity: 'path',
      issues: issues,
    );

    for (final entry in entries) {
      final id = '${entry['id'] ?? ''}';
      _validateId(id, 'entry', issues);
      _allowed(entry, 'kind', allowed['kind']!, id, issues);
      _allowed(entry, 'discipline', allowed['discipline']!, id, issues);
      _allowed(entry, 'level', allowed['level']!, id, issues);
      _allowed(entry, 'reviewState', allowed['reviewState']!, id, issues);
      _allowed(entry, 'topic', allowed['topic']!, id, issues);
      for (final layer in _objectList(entry['layers'], '$id.layers')) {
        _allowed(layer, 'depth', allowed['depth']!, id, issues);
      }
      for (final relation in _objectList(
        entry['relations'],
        '$id.relations',
        optional: true,
      )) {
        final type = '${relation['type'] ?? ''}';
        if (!allowed['relation']!.contains(type)) {
          issues.add(CompilerIssue('unknown_relation', id, type));
        }
      }
    }
    for (final source in sources) {
      _validateId('${source['id'] ?? ''}', 'source', issues);
    }
    for (final path in paths) {
      _validateId('${path['id'] ?? ''}', 'path', issues);
    }

    entries.sort(_byId);
    sources.sort(_byId);
    paths.sort(_byId);
    final pack = <String, dynamic>{
      'packVersion': _requiredString(manifest, 'packVersion', 'manifest'),
      'generatedAt': _requiredString(manifest, 'generatedAt', 'manifest'),
      'sources': sources,
      'entries': entries,
      'paths': paths,
    };

    if (issues.isEmpty) {
      try {
        final catalog = KnowledgeCatalog.fromJson(pack);
        issues.addAll(
          catalog.validate().map(
            (issue) => CompilerIssue(issue.code, issue.entryId, issue.message),
          ),
        );
      } catch (error) {
        issues.add(CompilerIssue('schema_parse_error', null, '$error'));
      }
    }

    final compiled = _prettyJson(pack);
    if (!writeOutput && issues.isEmpty) {
      if (!packFile.existsSync() || packFile.readAsStringSync() != compiled) {
        issues.add(
          CompilerIssue(
            'generated_pack_drift',
            null,
            'Run: dart run tool/knowledge_compiler.dart compile',
          ),
        );
      }
    }

    _writeReport(
      manifest: manifest,
      entries: entries.length,
      sources: sources.length,
      paths: paths.length,
      issues: issues,
    );
    if (issues.isNotEmpty) {
      final summary = issues
          .take(20)
          .map(
            (issue) =>
                '${issue.code}${issue.id == null ? '' : ' [${issue.id}]'}: ${issue.message}',
          )
          .join('\n');
      throw KnowledgeCompilerException(
        'Knowledge compilation failed with ${issues.length} issue(s):\n$summary',
      );
    }

    if (writeOutput) {
      packFile.parent.createSync(recursive: true);
      packFile.writeAsStringSync(compiled);
      stdout.writeln('Compiled ${entries.length} entries to ${packFile.path}.');
    } else {
      stdout.writeln('Knowledge corpus and generated pack are in sync.');
    }
  }

  List<Map<String, dynamic>> _readObjects(
    Directory directory,
    List<CompilerIssue> issues,
  ) {
    if (!directory.existsSync()) {
      issues.add(CompilerIssue('missing_directory', null, directory.path));
      return [];
    }
    final records = <Map<String, dynamic>>[];
    final seen = <String>{};
    final files =
        directory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      try {
        final record = _readObject(file);
        final id = '${record['id'] ?? ''}';
        final expectedName = '$id.json';
        if (_basename(file.path) != expectedName) {
          issues.add(CompilerIssue('filename_id_mismatch', id, file.path));
        }
        if (!seen.add(id)) {
          issues.add(CompilerIssue('duplicate_id', id, directory.path));
        }
        records.add(record);
      } catch (error) {
        issues.add(CompilerIssue('invalid_json', null, '${file.path}: $error'));
      }
    }
    return records;
  }

  void _validateRegistry({
    required List<Map<String, dynamic>> records,
    required List<Map<String, dynamic>> registered,
    required String entity,
    required List<CompilerIssue> issues,
    bool kindIsFrozen = false,
  }) {
    final recordsById = {
      for (final record in records) '${record['id']}': record,
    };
    final registryById = <String, Map<String, dynamic>>{};
    for (final item in registered) {
      final id = '${item['id'] ?? ''}';
      if (registryById.containsKey(id)) {
        issues.add(CompilerIssue('duplicate_registry_id', id, entity));
      }
      registryById[id] = item;
    }
    for (final record in records) {
      final id = '${record['id'] ?? ''}';
      final frozen = registryById[id];
      if (frozen == null) {
        issues.add(CompilerIssue('unregistered_id', id, entity));
      } else if (kindIsFrozen && frozen['kind'] != record['kind']) {
        issues.add(
          CompilerIssue(
            'frozen_kind_changed',
            id,
            '${frozen['kind']} -> ${record['kind']}',
          ),
        );
      }
    }
    for (final item in registered) {
      final id = '${item['id'] ?? ''}';
      if (item['status'] == 'active' && !recordsById.containsKey(id)) {
        issues.add(CompilerIssue('active_id_missing', id, entity));
      }
    }
  }

  void _allowed(
    Map<String, dynamic> object,
    String field,
    Set<String> allowed,
    String id,
    List<CompilerIssue> issues,
  ) {
    final value = '${object[field] ?? ''}';
    if (!allowed.contains(value)) {
      issues.add(CompilerIssue('taxonomy_drift', id, '$field=$value'));
    }
  }

  void _validateId(String id, String entity, List<CompilerIssue> issues) {
    final valid = RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9_]*)+$');
    if (!valid.hasMatch(id)) {
      issues.add(CompilerIssue('invalid_id', id, entity));
    }
  }

  void _writeReport({
    required Map<String, dynamic> manifest,
    required int entries,
    required int sources,
    required int paths,
    required List<CompilerIssue> issues,
  }) {
    _writeJson(reportFile, {
      'compilerVersion': compilerVersion,
      'packVersion': manifest['packVersion'],
      'status': issues.isEmpty ? 'ok' : 'failed',
      'counts': {'entries': entries, 'sources': sources, 'paths': paths},
      'issues': issues.map((issue) => issue.toJson()).toList(),
    });
  }
}

class CompilerIssue {
  const CompilerIssue(this.code, this.id, this.message);

  final String code;
  final String? id;
  final String message;

  Map<String, dynamic> toJson() => {
    'code': code,
    if (id != null) 'id': id,
    'message': message,
  };
}

class KnowledgeCompilerException implements Exception {
  const KnowledgeCompilerException(this.message);
  final String message;
}

Map<String, dynamic> _readObject(File file) {
  if (!file.existsSync()) {
    throw KnowledgeCompilerException('Missing file: ${file.path}');
  }
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw KnowledgeCompilerException(
      '${file.path} must contain a JSON object.',
    );
  }
  return decoded;
}

List<Map<String, dynamic>> _objectList(
  dynamic value,
  String field, {
  bool optional = false,
}) {
  if (value == null && optional) return [];
  if (value is! List) {
    throw KnowledgeCompilerException('$field must be a JSON array.');
  }
  return value.map((item) {
    if (item is! Map<String, dynamic>) {
      throw KnowledgeCompilerException('$field contains a non-object value.');
    }
    return item;
  }).toList();
}

Set<String> _stringSet(dynamic value) {
  if (value is! List) {
    throw KnowledgeCompilerException('Taxonomy values must be JSON arrays.');
  }
  return value.map((item) => item.toString()).toSet();
}

String _requiredString(
  Map<String, dynamic> object,
  String field,
  String owner,
) {
  final value = object[field];
  if (value is! String || value.trim().isEmpty) {
    throw KnowledgeCompilerException('$owner requires a non-empty $field.');
  }
  return value;
}

int _byId(Map<String, dynamic> a, Map<String, dynamic> b) =>
    '${a['id']}'.compareTo('${b['id']}');

String _prettyJson(Object value) =>
    '${const JsonEncoder.withIndent('  ').convert(value)}\n';

void _writeJson(File file, Object value) {
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(_prettyJson(value));
}

String _join(String left, String right, [String? third]) {
  final separator = Platform.pathSeparator;
  return third == null
      ? '$left$separator$right'
      : '$left$separator$right$separator$third';
}

String _basename(String path) => path.split(Platform.pathSeparator).last;
