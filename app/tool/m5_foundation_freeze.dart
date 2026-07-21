import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const manifestPath = 'architecture/milestones/m5_freeze/contract_manifest.json';
const proofPath = 'architecture/milestones/m5_freeze/proof_record.json';
const contractPaths = [
  'app/lib/contracts/prompt_assembly_contracts.dart',
  'app/lib/contracts/prompt_rendering_contracts.dart',
  'app/lib/contracts/ai_capability_registry_v2_contracts.dart',
  'app/lib/contracts/tool_invocation_contracts.dart',
  'app/lib/contracts/ai_provider_request_contracts.dart',
  'app/lib/contracts/ai_provider_request_v2_contracts.dart',
  'app/lib/contracts/ai_response_processing_contracts.dart',
  'app/lib/contracts/ai_response_processing_v2_contracts.dart',
  'app/lib/contracts/ai_conversation_memory_contracts.dart',
  'app/lib/contracts/ai_tool_result_projection_contracts.dart',
  'app/lib/contracts/ai_observability_projection_contracts.dart',
  'app/lib/contracts/ai_production_activation_contracts.dart',
];
const foundationTests = [
  'app/test/prompt_assembly_builder_foundation_test.dart',
  'app/test/prompt_rendering_foundation_test.dart',
  'app/test/ai_capability_registry_v2_alignment_test.dart',
  'app/test/tool_invocation_foundation_test.dart',
  'app/test/ai_provider_request_foundation_test.dart',
  'app/test/ai_tool_identity_v2_alignment_test.dart',
  'app/test/ai_response_processing_foundation_test.dart',
  'app/test/ai_conversation_memory_foundation_test.dart',
  'app/test/ai_tool_result_projection_foundation_test.dart',
  'app/test/ai_observability_foundation_test.dart',
  'app/test/ai_production_activation_foundation_test.dart',
];

void main(List<String> args) {
  final root = Directory(_arg(args, '--root') ?? '..').absolute;
  final update = args.contains('--update');
  final manifestFile = File(_join(root.path, manifestPath));
  if (update) _writeManifest(root, manifestFile);
  final result = validateM5FoundationFreeze(root, manifestFile: manifestFile);
  final proof = File(_join(root.path, proofPath));
  proof.parent.createSync(recursive: true);
  proof.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(result));
  stdout.writeln(
      'M5 Foundation Freeze PASS: ${result['contractCount']} contracts, '
      '${result['foundationTestCount']} suites, 0 cycles.');
}

Map<String, dynamic> validateM5FoundationFreeze(
  Directory root, {
  File? manifestFile,
}) {
  final file = manifestFile ?? File(_join(root.path, manifestPath));
  if (!file.existsSync()) {
    throw StateError('Missing M5 manifest.');
  }
  final manifest = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  if (manifest['schemaVersion'] != 1 ||
      manifest['milestone'] != 'M5' ||
      manifest['freezePolicyVersion'] != 'm5-foundation-freeze/1.0.0') {
    throw StateError('M5 manifest metadata is incompatible.');
  }
  final expected = manifest['manifestDigest'];
  if (expected != _manifestDigest(manifest)) {
    throw StateError('M5 manifest digest drift.');
  }
  final contracts =
      (manifest['contractFiles'] as List).cast<Map<String, dynamic>>();
  final symbols = <String, String>{};
  final edges = <String>{};
  for (final item in contracts) {
    final path = '${item['path']}';
    final file = File(_join(root.path, path));
    if (!file.existsSync()) {
      throw StateError('Missing M5 contract: $path');
    }
    final source = _normalize(file.readAsStringSync());
    final digest = sha256.convert(utf8.encode(source)).toString();
    if (digest != item['sha256']) throw StateError('Contract drift: $path');
    for (final symbol in _publicSymbols(source)) {
      if (symbols.containsKey(symbol)) {
        throw StateError('Duplicate M5 public symbol: $symbol');
      }
      symbols[symbol] = path;
    }
    for (final uri in _imports(source)) {
      if (uri.startsWith('package:pool_os/contracts/')) {
        final target =
            'app/lib/contracts/${uri.substring('package:pool_os/contracts/'.length)}';
        edges.add('$path->$target');
      }
    }
    if (source.contains('DateTime.now') || source.contains('Random(')) {
      throw StateError('Hidden nondeterministic state: $path');
    }
    if (!RegExp(r'const\s+[A-Za-z0-9_]*(?:Contract)?Version\s*=')
        .hasMatch(source)) {
      throw StateError('Missing M5 contract version binding: $path');
    }
  }
  final cycles = _cycles(edges);
  if (cycles.isNotEmpty) {
    throw StateError('M5 dependency cycle: ${cycles.first}');
  }
  for (final test in (manifest['foundationTests'] as List).cast<String>()) {
    if (!File(_join(root.path, test)).existsSync()) {
      throw StateError('Missing M5 foundation test: $test');
    }
  }
  _validateProtectedFreeze(
    root,
    'architecture/milestones/m3_freeze/contract_manifest.json',
  );
  _validateProtectedFreeze(
    root,
    'architecture/milestones/m4_freeze/contract_manifest.json',
  );
  return {
    'schemaVersion': 1,
    'milestone': 'M5 Foundation Freeze',
    'status': 'PASS',
    'manifestDigest': manifest['manifestDigest'],
    'contractSetDigest': _digest(
        contracts.map((e) => '${e['path']}:${e['sha256']}').toList()..sort()),
    'contractCount': contracts.length,
    'foundationTestCount': (manifest['foundationTests'] as List).length,
    'publicSymbolCount': symbols.length,
    'dependencyEdges': edges.toList()..sort(),
    'dependencyCycles': const [],
    'contractDrift': 'PASS',
    'versionBindings': 'PASS',
    'hiddenState': 'PASS',
    'protectedArtifactsChanged': false,
  };
}

void _validateProtectedFreeze(Directory root, String path) {
  final manifest = jsonDecode(
    File(_join(root.path, path)).readAsStringSync(),
  ) as Map<String, dynamic>;
  final expectedDigest = manifest['milestone'] == 'M4'
      ? _legacyManifestDigest(manifest)
      : _manifestDigest(manifest);
  if (manifest['manifestDigest'] != expectedDigest) {
    throw StateError('Protected freeze manifest drift: $path');
  }
  for (final item
      in (manifest['contractFiles'] as List).cast<Map<String, dynamic>>()) {
    final contractPath = '${item['path']}';
    final source = _normalize(
      File(_join(root.path, contractPath)).readAsStringSync(),
    );
    if (sha256.convert(utf8.encode(source)).toString() != item['sha256']) {
      throw StateError('Protected contract drift: $contractPath');
    }
  }
}

String _legacyManifestDigest(Map<String, dynamic> manifest) {
  final unsigned = Map<String, dynamic>.from(manifest)..['manifestDigest'] = '';
  return sha256.convert(utf8.encode(jsonEncode(unsigned))).toString();
}

void _writeManifest(Directory root, File file) {
  final entries = <Map<String, dynamic>>[];
  for (final path in contractPaths) {
    final source = _normalize(File(_join(root.path, path)).readAsStringSync());
    entries.add({
      'path': path,
      'sha256': sha256.convert(utf8.encode(source)).toString()
    });
  }
  entries.sort((a, b) => '${a['path']}'.compareTo('${b['path']}'));
  final manifest = {
    'schemaVersion': 1,
    'milestone': 'M5',
    'freezePolicyVersion': 'm5-foundation-freeze/1.0.0',
    'contractFiles': entries,
    'foundationTests': [...foundationTests]..sort(),
  };
  manifest['manifestDigest'] = _manifestDigest(manifest);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest));
}

String _manifestDigest(Map<String, dynamic> manifest) {
  final copy = Map<String, dynamic>.from(manifest)..remove('manifestDigest');
  return sha256.convert(utf8.encode(_canonicalJson(copy))).toString();
}

String _canonicalJson(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => '$key').toList()..sort();
    return '{${keys.map((key) => '${jsonEncode(key)}:${_canonicalJson(value[key])}').join(',')}}';
  }
  if (value is List) {
    return '[${value.map(_canonicalJson).join(',')}]';
  }
  return jsonEncode(value);
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
String _normalize(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
Iterable<String> _imports(String source) =>
    RegExp(r"import '([^']+)'").allMatches(source).map((m) => m.group(1)!);
Iterable<String> _publicSymbols(String source) =>
    RegExp(r'\b(?:class|enum|abstract class)\s+([A-Z][A-Za-z0-9_]*)')
        .allMatches(source)
        .map((m) => m.group(1)!);

List<String> _cycles(Set<String> edges) {
  final graph = <String, List<String>>{};
  for (final edge in edges) {
    final parts = edge.split('->');
    (graph[parts[0]] ??= []).add(parts[1]);
  }
  final visiting = <String>{};
  final visited = <String>{};
  final found = <String>[];
  bool visit(String node) {
    if (visiting.contains(node)) return true;
    if (!visited.add(node)) return false;
    visiting.add(node);
    for (final next in graph[node] ?? const []) {
      if (visit(next)) return true;
    }
    visiting.remove(node);
    return false;
  }

  for (final node in graph.keys) {
    if (visit(node)) found.add(node);
  }
  return found;
}

String? _arg(List<String> args, String name) {
  final index = args.indexOf(name);
  return index >= 0 && index + 1 < args.length ? args[index + 1] : null;
}

String _join(String a, String b) => '$a${Platform.pathSeparator}$b';
