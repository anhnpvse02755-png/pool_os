import 'dart:convert';

typedef EvidenceUpcastTransform = Map<String, dynamic> Function(
  Map<String, dynamic> source,
);

class EvidenceUpcastException implements Exception {
  const EvidenceUpcastException(this.message);

  final String message;

  @override
  String toString() => 'EvidenceUpcastException: $message';
}

class EvidenceUpcasterStep {
  const EvidenceUpcasterStep({
    required this.fromVersion,
    required this.toVersion,
    required this.transform,
  });

  final int fromVersion;
  final int toVersion;
  final EvidenceUpcastTransform transform;
}

class EvidenceUpcasterChain {
  EvidenceUpcasterChain({
    required this.currentVersion,
    required List<EvidenceUpcasterStep> steps,
  }) : _steps = _validateSteps(currentVersion, steps);

  final int currentVersion;
  final Map<int, EvidenceUpcasterStep> _steps;

  Map<String, dynamic> upcast(
    Map<String, dynamic> source, {
    required int sourceVersion,
  }) {
    if (sourceVersion < 0 || sourceVersion > currentVersion) {
      throw EvidenceUpcastException(
        'Unsupported evidence source version: $sourceVersion.',
      );
    }
    var version = sourceVersion;
    var result = _copyJson(source);
    final declaredVersion = result['batchSchemaVersion'];
    final declarationMatches = sourceVersion == 0
        ? declaredVersion == null || declaredVersion == 0
        : declaredVersion == sourceVersion;
    if (!declarationMatches) {
      throw EvidenceUpcastException(
        'Evidence source version $sourceVersion does not match declared '
        'version $declaredVersion.',
      );
    }
    while (version < currentVersion) {
      final step = _steps[version];
      if (step == null) {
        throw EvidenceUpcastException(
          'Missing evidence upcaster from version $version.',
        );
      }
      result = _copyJson(step.transform(_copyJson(result)));
      if (result['batchSchemaVersion'] != step.toVersion) {
        throw EvidenceUpcastException(
          'Evidence upcaster ${step.fromVersion} -> ${step.toVersion} '
          'emitted the wrong batch schema version.',
        );
      }
      version = step.toVersion;
    }
    return result;
  }

  static Map<int, EvidenceUpcasterStep> _validateSteps(
    int currentVersion,
    List<EvidenceUpcasterStep> steps,
  ) {
    if (currentVersion < 0) {
      throw const EvidenceUpcastException(
        'Current evidence version cannot be negative.',
      );
    }
    final bySource = <int, EvidenceUpcasterStep>{};
    for (final step in steps) {
      if (step.fromVersion < 0 ||
          step.toVersion <= step.fromVersion ||
          step.toVersion > currentVersion) {
        throw EvidenceUpcastException(
          'Invalid evidence upcaster ${step.fromVersion} -> '
          '${step.toVersion}.',
        );
      }
      if (bySource.containsKey(step.fromVersion)) {
        throw EvidenceUpcastException(
          'Duplicate evidence upcaster from version ${step.fromVersion}.',
        );
      }
      bySource[step.fromVersion] = step;
    }
    return Map.unmodifiable(bySource);
  }
}

Map<String, dynamic> _copyJson(Map<String, dynamic> source) =>
    Map<String, dynamic>.from(jsonDecode(jsonEncode(source)) as Map);
