import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final root = Directory.current.absolute;
  final updateBaseline = args.contains('--update-baseline');
  final rulesFile = File(
    _join(root.path, 'architecture', 'fitness_rules.json'),
  );
  final baselineFile = File(
    _join(root.path, 'architecture', 'fitness_baseline.json'),
  );

  if (!rulesFile.existsSync()) {
    _fail('Missing architecture rules: ${rulesFile.path}');
  }

  final rules = FitnessRules.fromJson(_readObject(rulesFile));
  final scanner = ArchitectureScanner(root: root, rules: rules);
  final scan = scanner.scan();
  final violations = scan.violations..sort();
  final rulesDigest = _stableDigest(rulesFile.readAsStringSync());

  if (updateBaseline) {
    _writeJson(baselineFile, {
      'schemaVersion': 1,
      'rulesDigest': rulesDigest,
      'violations': violations.map((item) => item.toJson()).toList(),
    });
    _writeHealthReport(
      root: root,
      rulesDigest: rulesDigest,
      scan: scan,
      baselineCount: violations.length,
      added: const [],
      removed: const [],
    );
    stdout.writeln(
      'Architecture baseline updated with ${violations.length} violation(s).',
    );
    return;
  }

  if (!baselineFile.existsSync()) {
    _fail(
      'Missing architecture baseline. Review current debt, then run '
      '`dart run tool/architecture_test.dart --update-baseline`.',
    );
  }

  final baseline = _readObject(baselineFile);
  final expectedDigest = '${baseline['rulesDigest'] ?? ''}';
  if (expectedDigest != rulesDigest) {
    _fail(
      'Architecture rules changed. Review the rule change and regenerate the '
      'baseline explicitly.',
    );
  }

  final baselineViolations = (baseline['violations'] as List? ?? const [])
      .map((item) => Violation.fromJson(item as Map<String, dynamic>))
      .toSet();
  final actual = violations.toSet();
  final added = actual.difference(baselineViolations).toList()..sort();
  final removed = baselineViolations.difference(actual).toList()..sort();

  _writeHealthReport(
    root: root,
    rulesDigest: rulesDigest,
    scan: scan,
    baselineCount: baselineViolations.length,
    added: added,
    removed: removed,
  );

  if (added.isNotEmpty || removed.isNotEmpty) {
    if (added.isNotEmpty) {
      stderr.writeln('New architecture violation(s):');
      for (final violation in added) {
        stderr.writeln('  + ${violation.describe()}');
      }
    }
    if (removed.isNotEmpty) {
      stderr.writeln('Resolved baseline violation(s):');
      for (final violation in removed) {
        stderr.writeln('  - ${violation.describe()}');
      }
      stderr.writeln('Regenerate the baseline to lock in the improvement.');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Architecture fitness passed. '
    '${violations.length} known violation(s), 0 new.',
  );
}

class FitnessRules {
  FitnessRules({
    required this.sourceRoots,
    required this.ignoredPathSegments,
    required this.experienceMarkers,
    required this.domainRoots,
    required this.allowedDependencies,
    required this.forbiddenTargets,
    required this.frameworkFreeSegments,
    required this.forbiddenDomainImports,
  });

  final List<String> sourceRoots;
  final List<String> ignoredPathSegments;
  final List<String> experienceMarkers;
  final Map<String, List<String>> domainRoots;
  final Map<String, Set<String>> allowedDependencies;
  final Map<String, List<String>> forbiddenTargets;
  final List<String> frameworkFreeSegments;
  final List<String> forbiddenDomainImports;

  factory FitnessRules.fromJson(Map<String, dynamic> json) => FitnessRules(
    sourceRoots: _strings(json['sourceRoots']),
    ignoredPathSegments: _strings(json['ignoredPathSegments']),
    experienceMarkers: _strings(json['experienceMarkers']),
    domainRoots: _stringListMap(json['domains']),
    allowedDependencies: _stringListMap(
      json['allowedDomainDependencies'],
    ).map((key, value) => MapEntry(key, value.toSet())),
    forbiddenTargets: _stringListMap(json['forbiddenDirectTargetSegments']),
    frameworkFreeSegments: _strings(json['frameworkFreeSourceSegments']),
    forbiddenDomainImports: _strings(json['forbiddenDomainImportPrefixes']),
  );
}

class ArchitectureScanner {
  ArchitectureScanner({required this.root, required this.rules});

  final Directory root;
  final FitnessRules rules;

  static final _directive = RegExp(
    r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );

  ArchitectureScanResult scan() {
    final violations = <Violation>{};
    final domainEdges = <String>{};
    var filesScanned = 0;
    var directivesScanned = 0;
    for (final sourceRoot in rules.sourceRoots) {
      final directory = Directory(
        _joinParts([root.path, ...sourceRoot.split('/')]),
      );
      if (!directory.existsSync()) continue;
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = _relative(entity.path);
        if (_ignored(source)) continue;
        filesScanned++;
        final sourceDomain = _classify(source);
        final content = entity.readAsStringSync();
        for (final match in _directive.allMatches(content)) {
          directivesScanned++;
          final importUri = match.group(1)!;
          final target = _resolveImport(entity, importUri);
          final targetDomain = target == null ? null : _classify(target);

          if (sourceDomain != null && targetDomain != null) {
            if (sourceDomain != targetDomain) {
              domainEdges.add('$sourceDomain->$targetDomain');
            }
            final allowed = rules.allowedDependencies[sourceDomain] ?? const {};
            if (!allowed.contains(targetDomain)) {
              violations.add(
                Violation(
                  rule: 'domain_dependency',
                  source: source,
                  target: target ?? importUri,
                  detail: '$sourceDomain must not depend on $targetDomain',
                ),
              );
            }
          }

          if (sourceDomain != null && target != null) {
            final forbidden = rules.forbiddenTargets[sourceDomain] ?? const [];
            for (final segment in forbidden) {
              if (target.contains(segment)) {
                violations.add(
                  Violation(
                    rule: 'direct_persistence_access',
                    source: source,
                    target: target,
                    detail: '$sourceDomain must use an application port',
                  ),
                );
              }
            }
          }

          if (sourceDomain != null &&
              targetDomain != null &&
              sourceDomain != targetDomain &&
              target != null &&
              target.contains('/data/')) {
            violations.add(
              Violation(
                rule: 'cross_domain_data_import',
                source: source,
                target: target,
                detail:
                    '$sourceDomain imports $targetDomain data implementation',
              ),
            );
          }

          if (rules.frameworkFreeSegments.any(source.contains) &&
              rules.forbiddenDomainImports.any(
                (prefix) => importUri.startsWith(prefix),
              )) {
            violations.add(
              Violation(
                rule: 'domain_framework_dependency',
                source: source,
                target: importUri,
                detail: 'domain layer must remain framework-free',
              ),
            );
          }
        }
      }
    }
    return ArchitectureScanResult(
      violations: violations.toList(),
      filesScanned: filesScanned,
      directivesScanned: directivesScanned,
      domainEdges: domainEdges.toList()..sort(),
      domainCycles: _findCycles(domainEdges),
    );
  }

  String? _classify(String path) {
    if (rules.experienceMarkers.any(path.contains)) return 'experience';
    String? selected;
    var selectedLength = -1;
    for (final entry in rules.domainRoots.entries) {
      for (final candidate in entry.value) {
        if (path.startsWith(candidate) && candidate.length > selectedLength) {
          selected = entry.key;
          selectedLength = candidate.length;
        }
      }
    }
    return selected;
  }

  String? _resolveImport(File source, String importUri) {
    if (importUri.startsWith('dart:')) return null;
    if (importUri.startsWith('package:pool_os/')) {
      return 'app/lib/${importUri.substring('package:pool_os/'.length)}';
    }
    if (importUri.startsWith('package:billiard_knowledge/')) {
      return 'packages/billiard_knowledge/lib/'
          '${importUri.substring('package:billiard_knowledge/'.length)}';
    }
    if (importUri.startsWith('package:')) return null;
    final resolved = File(_join(source.parent.path, importUri)).absolute.path;
    return _relative(resolved);
  }

  String _relative(String path) {
    final normalizedRoot = _normalize(root.path);
    final normalized = _normalize(File(path).absolute.path);
    if (!normalized.startsWith('$normalizedRoot/')) return normalized;
    return normalized.substring(normalizedRoot.length + 1);
  }

  bool _ignored(String path) => rules.ignoredPathSegments.any(path.contains);
}

class ArchitectureScanResult {
  const ArchitectureScanResult({
    required this.violations,
    required this.filesScanned,
    required this.directivesScanned,
    required this.domainEdges,
    required this.domainCycles,
  });

  final List<Violation> violations;
  final int filesScanned;
  final int directivesScanned;
  final List<String> domainEdges;
  final List<List<String>> domainCycles;
}

class Violation implements Comparable<Violation> {
  const Violation({
    required this.rule,
    required this.source,
    required this.target,
    required this.detail,
  });

  final String rule;
  final String source;
  final String target;
  final String detail;

  String get fingerprint => '$rule|$source|$target';

  String describe() => '$rule: $source -> $target ($detail)';

  Map<String, dynamic> toJson() => {
    'fingerprint': fingerprint,
    'rule': rule,
    'source': source,
    'target': target,
    'detail': detail,
  };

  factory Violation.fromJson(Map<String, dynamic> json) => Violation(
    rule: json['rule'] as String,
    source: json['source'] as String,
    target: json['target'] as String,
    detail: json['detail'] as String? ?? '',
  );

  @override
  int compareTo(Violation other) => fingerprint.compareTo(other.fingerprint);

  @override
  bool operator ==(Object other) =>
      other is Violation && fingerprint == other.fingerprint;

  @override
  int get hashCode => fingerprint.hashCode;
}

void _writeHealthReport({
  required Directory root,
  required String rulesDigest,
  required ArchitectureScanResult scan,
  required int baselineCount,
  required List<Violation> added,
  required List<Violation> removed,
}) {
  final byRule = <String, int>{};
  for (final violation in scan.violations) {
    byRule[violation.rule] = (byRule[violation.rule] ?? 0) + 1;
  }
  final report = File(
    _joinParts([root.path, 'build', 'architecture', 'health.json']),
  );
  _writeJson(report, {
    'schemaVersion': 1,
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'rulesDigest': rulesDigest,
    'status': added.isEmpty && removed.isEmpty ? 'stable' : 'changed',
    'scan': {
      'dartFiles': scan.filesScanned,
      'directives': scan.directivesScanned,
      'domainEdges': scan.domainEdges,
      'domainCycles': scan.domainCycles,
    },
    'debt': {
      'baseline': baselineCount,
      'current': scan.violations.length,
      'new': added.length,
      'resolvedPendingBaselineUpdate': removed.length,
      'byRule': Map.fromEntries(
        byRule.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      ),
    },
    'coverage': {
      'importGraph': 'enabled',
      'domainDependencies': 'enabled',
      'layerViolations': 'enabled',
      'circularDomainDependencies': 'enabled',
      'contractDrift': 'not_configured',
      'knowledgeDrift': 'not_configured',
      'compilerDrift': 'not_configured',
      'packageDrift': 'partial',
    },
    'newViolations': added.map((item) => item.toJson()).toList(),
    'resolvedViolations': removed.map((item) => item.toJson()).toList(),
  });
}

List<List<String>> _findCycles(Set<String> edges) {
  final graph = <String, Set<String>>{};
  for (final edge in edges) {
    final parts = edge.split('->');
    if (parts.length != 2 || parts[0] == parts[1]) continue;
    graph.putIfAbsent(parts[0], () => <String>{}).add(parts[1]);
  }

  final cycles = <String, List<String>>{};
  for (final start in graph.keys) {
    void walk(String node, List<String> path, Set<String> active) {
      for (final next in graph[node] ?? const <String>{}) {
        if (next == start && path.length > 1) {
          final cycle = [...path, start];
          final body = cycle.sublist(0, cycle.length - 1);
          final rotations = <List<String>>[];
          for (var i = 0; i < body.length; i++) {
            rotations.add([...body.sublist(i), ...body.sublist(0, i)]);
          }
          rotations.sort((a, b) => a.join('->').compareTo(b.join('->')));
          final canonical = rotations.first;
          final key = canonical.join('->');
          cycles[key] = [...canonical, canonical.first];
          continue;
        }
        if (active.contains(next)) continue;
        walk(next, [...path, next], {...active, next});
      }
    }

    walk(start, [start], {start});
  }
  final ordered = cycles.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return ordered.map((entry) => entry.value).toList();
}

Map<String, dynamic> _readObject(File file) {
  final value = jsonDecode(file.readAsStringSync());
  if (value is! Map<String, dynamic>) {
    _fail('${file.path} must contain a JSON object.');
  }
  return value;
}

List<String> _strings(dynamic value) =>
    (value as List? ?? const []).map((item) => item.toString()).toList();

Map<String, List<String>> _stringListMap(dynamic value) {
  final map = value as Map<String, dynamic>? ?? const {};
  return map.map((key, item) => MapEntry(key, _strings(item)));
}

void _writeJson(File file, Object value) {
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n',
  );
}

String _stableDigest(String value) {
  // FNV-1a is sufficient for detecting an accidental rules/baseline mismatch.
  var hash = 0xcbf29ce484222325;
  for (final byte in utf8.encode(value)) {
    hash ^= byte;
    hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}

String _normalize(String path) => path.replaceAll('\\', '/');

String _join(String left, String right, [String? third]) {
  final separator = Platform.pathSeparator;
  return third == null
      ? '$left$separator$right'
      : '$left$separator$right$separator$third';
}

String _joinParts(List<String> parts) => parts.join(Platform.pathSeparator);

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
