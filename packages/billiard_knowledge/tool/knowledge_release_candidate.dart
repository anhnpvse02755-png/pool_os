import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'knowledge_compiler_v0.dart' as compiler;

const releaseCandidateSchemaVersion = 1;

enum EntryCandidateReviewOutcome { accepted, rejected }

enum EntryCandidateQuarantineCode {
  reviewMissing,
  reviewRejected,
  reviewScopeMismatch,
  dependencyUnavailable,
}

class KnowledgeGeneralizationException implements Exception {
  const KnowledgeGeneralizationException(this.message);

  final String message;

  @override
  String toString() => 'KnowledgeGeneralizationException: $message';
}

class KnowledgeEntryCandidate {
  const KnowledgeEntryCandidate._({
    required this.entryId,
    required this.knowledgeVersion,
    required this.compilerVersion,
    required this.canonicalEntryJson,
    required this.contentDigest,
    required this.dependencies,
    required this.candidateDigest,
  });

  factory KnowledgeEntryCandidate.fromCompiledSource(
    compiler.CompiledKnowledgeEntrySource source, {
    String compilerVersion = compiler.compilerVersion,
  }) {
    final entry = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(source.entry)) as Map,
    );
    entry['capabilities'] = _sortedStrings(entry['capabilities']);
    entry['relations'] = _sortedStrings(entry['relations']);
    final dependencies = <String>{...entry['relations'] as List<String>};
    final payload = entry['payload'];
    if (payload is Map<String, dynamic>) {
      final recommendation = payload['nextRecommendation'];
      if (recommendation is Map<String, dynamic> &&
          recommendation['targetType'] == 'knowledge' &&
          recommendation['id'] is String) {
        dependencies.add(recommendation['id'] as String);
      }
    }
    final canonicalEntryJson = jsonEncode(_canonicalize(entry));
    final contentDigest = _sha256(canonicalEntryJson);
    final canonicalDependencies = dependencies.toList()..sort();
    final candidatePayload = <String, dynamic>{
      'schemaVersion': releaseCandidateSchemaVersion,
      'compilerVersion': compilerVersion,
      'knowledgeVersion': source.knowledgeVersion,
      'entryId': source.id,
      'contentDigest': contentDigest,
      'dependencies': canonicalDependencies,
    };
    return KnowledgeEntryCandidate._(
      entryId: source.id,
      knowledgeVersion: source.knowledgeVersion,
      compilerVersion: compilerVersion,
      canonicalEntryJson: canonicalEntryJson,
      contentDigest: contentDigest,
      dependencies: List.unmodifiable(canonicalDependencies),
      candidateDigest: _sha256(jsonEncode(candidatePayload)),
    );
  }

  final String entryId;
  final String knowledgeVersion;
  final String compilerVersion;
  final String canonicalEntryJson;
  final String contentDigest;
  final List<String> dependencies;
  final String candidateDigest;

  Map<String, dynamic> get canonicalEntry =>
      Map<String, dynamic>.from(jsonDecode(canonicalEntryJson) as Map);
}

class EntryCandidateReviewDecision {
  const EntryCandidateReviewDecision._({
    required this.entryId,
    required this.candidateDigest,
    required this.outcome,
    required this.reviewer,
    required this.decidedAt,
    required this.reason,
    required this.digest,
  });

  factory EntryCandidateReviewDecision.create({
    required String entryId,
    required String candidateDigest,
    required EntryCandidateReviewOutcome outcome,
    required String reviewer,
    required String decidedAt,
    String? reason,
  }) {
    if (entryId.isEmpty ||
        candidateDigest.isEmpty ||
        reviewer.isEmpty ||
        DateTime.tryParse(decidedAt) == null ||
        (outcome == EntryCandidateReviewOutcome.rejected &&
            (reason == null || reason.isEmpty))) {
      throw const KnowledgeGeneralizationException(
        'Invalid entry candidate review decision.',
      );
    }
    final payload = <String, dynamic>{
      'entryId': entryId,
      'candidateDigest': candidateDigest,
      'outcome': outcome.name,
      'reviewer': reviewer,
      'decidedAt': decidedAt,
      'reason': reason,
    };
    return EntryCandidateReviewDecision._(
      entryId: entryId,
      candidateDigest: candidateDigest,
      outcome: outcome,
      reviewer: reviewer,
      decidedAt: decidedAt,
      reason: reason,
      digest: _sha256(jsonEncode(payload)),
    );
  }

  final String entryId;
  final String candidateDigest;
  final EntryCandidateReviewOutcome outcome;
  final String reviewer;
  final String decidedAt;
  final String? reason;
  final String digest;
}

class QuarantinedEntryCandidate {
  QuarantinedEntryCandidate({
    required this.candidate,
    required this.code,
    required List<String> details,
    this.reviewDecisionDigest,
  }) : details = List.unmodifiable(details);

  final KnowledgeEntryCandidate candidate;
  final EntryCandidateQuarantineCode code;
  final List<String> details;
  final String? reviewDecisionDigest;
}

class ResolvedKnowledgeDependency {
  const ResolvedKnowledgeDependency({
    required this.entryId,
    required this.dependencyId,
    required this.resolvedDependencyContentDigest,
  });

  final String entryId;
  final String dependencyId;
  final String resolvedDependencyContentDigest;

  Map<String, dynamic> toJson() => {
        'entryId': entryId,
        'dependencyId': dependencyId,
        'resolvedDependencyContentDigest': resolvedDependencyContentDigest,
      };
}

class ReleaseCandidateSnapshot {
  const ReleaseCandidateSnapshot._({
    required this.schemaVersion,
    required this.compilerVersion,
    required this.knowledgeVersion,
    required this.entries,
    required this.resolvedDependencies,
    required this.contentDigest,
  });

  factory ReleaseCandidateSnapshot.create({
    int schemaVersion = releaseCandidateSchemaVersion,
    required String compilerVersion,
    required String knowledgeVersion,
    required List<KnowledgeEntryCandidate> entries,
    required List<ResolvedKnowledgeDependency> resolvedDependencies,
  }) {
    if (schemaVersion < 1) {
      throw const KnowledgeGeneralizationException(
        'RC schema version must be positive.',
      );
    }
    final canonicalEntries = [...entries]
      ..sort((left, right) => left.entryId.compareTo(right.entryId));
    final canonicalDependencies = [...resolvedDependencies]
      ..sort((left, right) {
        final byEntry = left.entryId.compareTo(right.entryId);
        return byEntry != 0
            ? byEntry
            : left.dependencyId.compareTo(right.dependencyId);
      });
    final payload = _releaseCandidatePayload(
      schemaVersion: schemaVersion,
      compilerVersion: compilerVersion,
      knowledgeVersion: knowledgeVersion,
      entries: canonicalEntries,
      resolvedDependencies: canonicalDependencies,
    );
    return ReleaseCandidateSnapshot._(
      schemaVersion: schemaVersion,
      compilerVersion: compilerVersion,
      knowledgeVersion: knowledgeVersion,
      entries: List.unmodifiable(canonicalEntries),
      resolvedDependencies: List.unmodifiable(canonicalDependencies),
      contentDigest: _sha256(jsonEncode(payload)),
    );
  }

  final int schemaVersion;
  final String compilerVersion;
  final String knowledgeVersion;
  final List<KnowledgeEntryCandidate> entries;
  final List<ResolvedKnowledgeDependency> resolvedDependencies;
  final String contentDigest;

  Map<String, dynamic> toJson() => {
        ..._releaseCandidatePayload(
          schemaVersion: schemaVersion,
          compilerVersion: compilerVersion,
          knowledgeVersion: knowledgeVersion,
          entries: entries,
          resolvedDependencies: resolvedDependencies,
        ),
        'contentDigest': contentDigest,
      };
}

class KnowledgeGeneralizationResult {
  const KnowledgeGeneralizationResult({
    required this.releaseCandidate,
    required this.eligible,
    required this.quarantined,
  });

  final ReleaseCandidateSnapshot releaseCandidate;
  final List<KnowledgeEntryCandidate> eligible;
  final List<QuarantinedEntryCandidate> quarantined;
}

class KnowledgeReleaseCandidateBuilder {
  const KnowledgeReleaseCandidateBuilder();

  KnowledgeGeneralizationResult build({
    required List<KnowledgeEntryCandidate> candidates,
    required Map<String, EntryCandidateReviewDecision> reviewsByEntryId,
  }) {
    if (candidates.isEmpty) {
      throw const KnowledgeGeneralizationException(
        'Release Candidate requires at least one entry candidate.',
      );
    }
    final byId = <String, KnowledgeEntryCandidate>{};
    for (final candidate in candidates) {
      if (byId.containsKey(candidate.entryId)) {
        throw KnowledgeGeneralizationException(
          'Duplicate entry candidate: ${candidate.entryId}.',
        );
      }
      byId[candidate.entryId] = candidate;
    }
    final versions = candidates.map((item) => item.knowledgeVersion).toSet();
    final compilers = candidates.map((item) => item.compilerVersion).toSet();
    if (versions.length != 1 || compilers.length != 1) {
      throw const KnowledgeGeneralizationException(
        'RC candidates must share one knowledge and compiler version.',
      );
    }

    final eligible = <String, KnowledgeEntryCandidate>{};
    final quarantined = <String, QuarantinedEntryCandidate>{};
    final ordered = [...candidates]
      ..sort((left, right) => left.entryId.compareTo(right.entryId));
    for (final candidate in ordered) {
      final review = reviewsByEntryId[candidate.entryId];
      if (review == null) {
        quarantined[candidate.entryId] = QuarantinedEntryCandidate(
          candidate: candidate,
          code: EntryCandidateQuarantineCode.reviewMissing,
          details: const [],
        );
      } else if (review.entryId != candidate.entryId ||
          review.candidateDigest != candidate.candidateDigest) {
        quarantined[candidate.entryId] = QuarantinedEntryCandidate(
          candidate: candidate,
          code: EntryCandidateQuarantineCode.reviewScopeMismatch,
          details: const [],
          reviewDecisionDigest: review.digest,
        );
      } else if (review.outcome == EntryCandidateReviewOutcome.rejected) {
        quarantined[candidate.entryId] = QuarantinedEntryCandidate(
          candidate: candidate,
          code: EntryCandidateQuarantineCode.reviewRejected,
          details: [review.reason!],
          reviewDecisionDigest: review.digest,
        );
      } else {
        eligible[candidate.entryId] = candidate;
      }
    }

    var changed = true;
    while (changed) {
      changed = false;
      for (final candidate in [...eligible.values]) {
        final unavailable = candidate.dependencies
            .where((dependency) => !eligible.containsKey(dependency))
            .toList()
          ..sort();
        if (unavailable.isEmpty) continue;
        eligible.remove(candidate.entryId);
        quarantined[candidate.entryId] = QuarantinedEntryCandidate(
          candidate: candidate,
          code: EntryCandidateQuarantineCode.dependencyUnavailable,
          details: List.unmodifiable(unavailable),
          reviewDecisionDigest: reviewsByEntryId[candidate.entryId]?.digest,
        );
        changed = true;
      }
    }
    if (eligible.isEmpty) {
      throw const KnowledgeGeneralizationException(
        'No eligible entry candidates remain for the RC.',
      );
    }

    final resolvedDependencies = <ResolvedKnowledgeDependency>[];
    for (final candidate in eligible.values) {
      for (final dependencyId in candidate.dependencies) {
        resolvedDependencies.add(
          ResolvedKnowledgeDependency(
            entryId: candidate.entryId,
            dependencyId: dependencyId,
            resolvedDependencyContentDigest:
                eligible[dependencyId]!.contentDigest,
          ),
        );
      }
    }
    final snapshot = ReleaseCandidateSnapshot.create(
      compilerVersion: compilers.single,
      knowledgeVersion: versions.single,
      entries: eligible.values.toList(),
      resolvedDependencies: resolvedDependencies,
    );
    final canonicalEligible = [...eligible.values]
      ..sort((left, right) => left.entryId.compareTo(right.entryId));
    final canonicalQuarantined = [...quarantined.values]..sort(
        (left, right) =>
            left.candidate.entryId.compareTo(right.candidate.entryId),
      );
    return KnowledgeGeneralizationResult(
      releaseCandidate: snapshot,
      eligible: List.unmodifiable(canonicalEligible),
      quarantined: List.unmodifiable(canonicalQuarantined),
    );
  }
}

class PublishedKnowledgeVersionRegistry {
  PublishedKnowledgeVersionRegistry([
    Map<String, String> published = const {},
  ]) : _published = Map.of(published);

  final Map<String, String> _published;

  void register({
    required String knowledgeVersion,
    required String releaseCandidateContentDigest,
  }) {
    final existing = _published[knowledgeVersion];
    if (existing != null && existing != releaseCandidateContentDigest) {
      throw KnowledgeGeneralizationException(
        'Published knowledgeVersion $knowledgeVersion is already mapped to '
        'a different RC Content Digest.',
      );
    }
    _published[knowledgeVersion] = releaseCandidateContentDigest;
  }

  String? contentDigestFor(String knowledgeVersion) =>
      _published[knowledgeVersion];
}

Map<String, dynamic> _releaseCandidatePayload({
  required int schemaVersion,
  required String compilerVersion,
  required String knowledgeVersion,
  required List<KnowledgeEntryCandidate> entries,
  required List<ResolvedKnowledgeDependency> resolvedDependencies,
}) =>
    {
      'schemaVersion': schemaVersion,
      'compilerVersion': compilerVersion,
      'knowledgeVersion': knowledgeVersion,
      'entries': [
        for (final entry in entries)
          {
            'entryId': entry.entryId,
            'contentDigest': entry.contentDigest,
            'candidateDigest': entry.candidateDigest,
            'canonicalEntry': entry.canonicalEntry,
          },
      ],
      'resolvedDependencies': [
        for (final dependency in resolvedDependencies) dependency.toJson(),
      ],
    };

List<String> _sortedStrings(dynamic value) {
  if (value is! List || value.any((item) => item is! String)) {
    throw const KnowledgeGeneralizationException(
      'Candidate capability and relation values must be string arrays.',
    );
  }
  return value.cast<String>().toList()..sort();
}

dynamic _canonicalize(dynamic value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return <String, dynamic>{
      for (final key in keys) key: _canonicalize(value[key]),
    };
  }
  if (value is List) return value.map(_canonicalize).toList(growable: false);
  return value;
}

String _sha256(String value) => sha256.convert(utf8.encode(value)).toString();
