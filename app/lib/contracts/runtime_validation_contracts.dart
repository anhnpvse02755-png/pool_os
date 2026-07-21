import 'dart:convert';
import 'package:crypto/crypto.dart';

const runtimeValidationContractVersion = 1;
const runtimeValidationPolicyVersion = 'runtime-validation/1.0.0';

class RuntimeValidationIssue {
  const RuntimeValidationIssue({required this.code, required this.message});
  final String code;
  final String message;
  Map<String, dynamic> toJson() => {'code': code, 'message': message};
}

class RuntimeValidationSummary {
  const RuntimeValidationSummary({required this.checked, required this.failed});
  final int checked;
  final int failed;
  Map<String, dynamic> toJson() => {'checked': checked, 'failed': failed};
}

class RuntimeValidationContract {
  const RuntimeValidationContract._({required this.id, required this.artifactDigests, required this.issues, required this.summary, required this.digest});
  factory RuntimeValidationContract.create({required Map<String, String> artifactDigests, required List<RuntimeValidationIssue> issues}) {
    if (artifactDigests.length != 5 || artifactDigests.values.any((value) => value.trim().isEmpty)) throw ArgumentError('Runtime validation artifacts are incomplete.');
    final ordered = artifactDigests.keys.toList()..sort();
    final payload = {'schemaVersion': runtimeValidationContractVersion, 'policyVersion': runtimeValidationPolicyVersion, 'artifactDigests': {for (final key in ordered) key: artifactDigests[key]}, 'issues': issues.map((issue) => issue.toJson()).toList(), 'summary': {'checked': 5, 'failed': issues.length}};
    final digest = _digest(payload);
    return RuntimeValidationContract._(id: 'runtime-validation.${digest.substring(0, 16)}', artifactDigests: Map.unmodifiable({for (final key in ordered) key: artifactDigests[key]!}), issues: List.unmodifiable(issues), summary: RuntimeValidationSummary(checked: 5, failed: issues.length), digest: digest);
  }
  final String id;
  final Map<String, String> artifactDigests;
  final List<RuntimeValidationIssue> issues;
  final RuntimeValidationSummary summary;
  final String digest;
  Map<String, dynamic> toJson() => {'schemaVersion': runtimeValidationContractVersion, 'policyVersion': runtimeValidationPolicyVersion, 'id': id, 'artifactDigests': artifactDigests, 'issues': issues.map((issue) => issue.toJson()).toList(), 'summary': summary.toJson(), 'digest': digest};
}

class RuntimeValidator {
  const RuntimeValidator();
  RuntimeValidationContract validate({required Map<String, String> artifactDigests, Map<String, String> expectedDigests = const {}}) {
    final issues = <RuntimeValidationIssue>[];
    for (final entry in expectedDigests.entries) { if (artifactDigests[entry.key] != entry.value) issues.add(RuntimeValidationIssue(code: 'stale-artifact', message: entry.key)); }
    return RuntimeValidationContract.create(artifactDigests: artifactDigests, issues: issues);
  }
}

String _digest(Object value) => sha256.convert(utf8.encode(jsonEncode(value))).toString();
