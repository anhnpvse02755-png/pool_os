part of 'knowledge_publication.dart';

enum PublicationCandidateStatus { published, quarantined }

enum PublicationValidationPhase { compile, artifact, review }

enum PublicationValidationCode {
  compilationFailed,
  artifactInvalid,
  reviewMissing,
  reviewRejected,
  reviewScopeMismatch,
}

enum PublicationReviewOutcome { accepted, rejected }

class PublicationValidationIssue {
  const PublicationValidationIssue({
    required this.code,
    required this.phase,
    required this.message,
  });

  factory PublicationValidationIssue.fromJson(Map<String, dynamic> json) =>
      PublicationValidationIssue(
        code: _enumByName(
          PublicationValidationCode.values,
          _requiredString(json, 'code'),
          'validation code',
        ),
        phase: _enumByName(
          PublicationValidationPhase.values,
          _requiredString(json, 'phase'),
          'validation phase',
        ),
        message: _requiredString(json, 'message'),
      );

  final PublicationValidationCode code;
  final PublicationValidationPhase phase;
  final String message;

  Map<String, dynamic> toJson() => {
        'code': code.name,
        'phase': phase.name,
        'message': message,
      };
}

class PublicationReviewDecision {
  const PublicationReviewDecision({
    required this.outcome,
    required this.candidateContentDigest,
    required this.compilerVersion,
    required this.releaseCandidateContentDigest,
    required this.reviewer,
    required this.decidedAt,
    required this.reason,
    required this.digest,
  });

  factory PublicationReviewDecision.create({
    required PublicationReviewOutcome outcome,
    required String candidateContentDigest,
    required String compilerVersion,
    String? releaseCandidateContentDigest,
    required String reviewer,
    required String decidedAt,
    String? reason,
  }) {
    if (candidateContentDigest.trim().isEmpty ||
        compilerVersion.trim().isEmpty ||
        reviewer.trim().isEmpty ||
        DateTime.tryParse(decidedAt) == null ||
        (outcome == PublicationReviewOutcome.rejected &&
            (reason == null || reason.trim().isEmpty))) {
      throw const KnowledgePublicationException(
        'Invalid publication review decision.',
      );
    }
    final payload = _reviewPayload(
      outcome: outcome,
      candidateContentDigest: candidateContentDigest,
      compilerVersion: compilerVersion,
      releaseCandidateContentDigest: releaseCandidateContentDigest,
      reviewer: reviewer,
      decidedAt: decidedAt,
      reason: reason,
    );
    return PublicationReviewDecision(
      outcome: outcome,
      candidateContentDigest: candidateContentDigest,
      compilerVersion: compilerVersion,
      releaseCandidateContentDigest: releaseCandidateContentDigest,
      reviewer: reviewer,
      decidedAt: decidedAt,
      reason: reason,
      digest: _sha256(utf8.encode(jsonEncode(payload))),
    );
  }

  factory PublicationReviewDecision.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != publicationSchemaVersion) {
      throw const KnowledgePublicationException(
        'Unsupported publication review version.',
      );
    }
    final decision = PublicationReviewDecision.create(
      outcome: _enumByName(
        PublicationReviewOutcome.values,
        _requiredString(json, 'outcome'),
        'review outcome',
      ),
      candidateContentDigest: _requiredString(
        json,
        'candidateContentDigest',
      ),
      compilerVersion: _requiredString(json, 'compilerVersion'),
      releaseCandidateContentDigest:
          json['releaseCandidateContentDigest'] as String?,
      reviewer: _requiredString(json, 'reviewer'),
      decidedAt: _requiredString(json, 'decidedAt'),
      reason: json['reason'] as String?,
    );
    if (json['digest'] != decision.digest) {
      throw const KnowledgePublicationException(
        'Publication review decision digest mismatch.',
      );
    }
    return decision;
  }

  final PublicationReviewOutcome outcome;
  final String candidateContentDigest;
  final String compilerVersion;
  final String? releaseCandidateContentDigest;
  final String reviewer;
  final String decidedAt;
  final String? reason;
  final String digest;

  Map<String, dynamic> toJson() => {
        ..._reviewPayload(
          outcome: outcome,
          candidateContentDigest: candidateContentDigest,
          compilerVersion: compilerVersion,
          releaseCandidateContentDigest: releaseCandidateContentDigest,
          reviewer: reviewer,
          decidedAt: decidedAt,
          reason: reason,
        ),
        'digest': digest,
      };
}

class PublicationQuarantineRecord {
  const PublicationQuarantineRecord({
    required this.candidateId,
    required this.candidateContentDigest,
    required this.candidateArtifactDigest,
    required this.compilerVersion,
    required this.issues,
    required this.reviewDecision,
    required this.digest,
  });

  factory PublicationQuarantineRecord.create({
    required String candidateId,
    required String? candidateContentDigest,
    required String? candidateArtifactDigest,
    required String? compilerVersion,
    required List<PublicationValidationIssue> issues,
    required PublicationReviewDecision? reviewDecision,
  }) {
    if (issues.isEmpty) {
      throw const KnowledgePublicationException(
        'Quarantine record requires at least one reason code.',
      );
    }
    final immutableIssues = List<PublicationValidationIssue>.unmodifiable(
      issues,
    );
    final payload = _quarantinePayload(
      candidateId: candidateId,
      candidateContentDigest: candidateContentDigest,
      candidateArtifactDigest: candidateArtifactDigest,
      compilerVersion: compilerVersion,
      issues: immutableIssues,
      reviewDecision: reviewDecision,
    );
    return PublicationQuarantineRecord(
      candidateId: candidateId,
      candidateContentDigest: candidateContentDigest,
      candidateArtifactDigest: candidateArtifactDigest,
      compilerVersion: compilerVersion,
      issues: immutableIssues,
      reviewDecision: reviewDecision,
      digest: _sha256(utf8.encode(jsonEncode(payload))),
    );
  }

  factory PublicationQuarantineRecord.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != publicationSchemaVersion ||
        json['issues'] is! List) {
      throw const KnowledgePublicationException(
        'Invalid publication quarantine record.',
      );
    }
    final record = PublicationQuarantineRecord.create(
      candidateId: _requiredString(json, 'candidateId'),
      candidateContentDigest: json['candidateContentDigest'] as String?,
      candidateArtifactDigest: json['candidateArtifactDigest'] as String?,
      compilerVersion: json['compilerVersion'] as String?,
      issues: [
        for (final issue in json['issues'] as List)
          PublicationValidationIssue.fromJson(
            Map<String, dynamic>.from(issue as Map),
          ),
      ],
      reviewDecision: json['reviewDecision'] == null
          ? null
          : PublicationReviewDecision.fromJson(
              Map<String, dynamic>.from(json['reviewDecision'] as Map),
            ),
    );
    if (json['digest'] != record.digest) {
      throw const KnowledgePublicationException(
        'Publication quarantine record digest mismatch.',
      );
    }
    return record;
  }

  final String candidateId;
  final String? candidateContentDigest;
  final String? candidateArtifactDigest;
  final String? compilerVersion;
  final List<PublicationValidationIssue> issues;
  final PublicationReviewDecision? reviewDecision;
  final String digest;

  Map<String, dynamic> toJson() => {
        ..._quarantinePayload(
          candidateId: candidateId,
          candidateContentDigest: candidateContentDigest,
          candidateArtifactDigest: candidateArtifactDigest,
          compilerVersion: compilerVersion,
          issues: issues,
          reviewDecision: reviewDecision,
        ),
        'digest': digest,
      };
}

class PublicationCandidateResult {
  const PublicationCandidateResult._({
    required this.status,
    this.publication,
    this.quarantine,
  });

  factory PublicationCandidateResult.published(
    KnowledgePublicationMetadata publication,
  ) =>
      PublicationCandidateResult._(
        status: PublicationCandidateStatus.published,
        publication: publication,
      );

  factory PublicationCandidateResult.quarantined(
    PublicationQuarantineRecord quarantine,
  ) =>
      PublicationCandidateResult._(
        status: PublicationCandidateStatus.quarantined,
        quarantine: quarantine,
      );

  final PublicationCandidateStatus status;
  final KnowledgePublicationMetadata? publication;
  final PublicationQuarantineRecord? quarantine;
}

extension PublicationCandidateWorkflow on KnowledgePublicationPipeline {
  PublicationCandidateResult submitCandidate({
    required String candidateId,
    required String Function() compile,
    required PublicationReviewDecision? review,
    String? releaseCandidateContentDigest,
    String? packageManifestDigest,
    bool activate = true,
  }) =>
      _withExclusiveLock(
        () => _submitCandidate(
          candidateId: candidateId,
          compile: compile,
          review: review,
          releaseCandidateContentDigest: releaseCandidateContentDigest,
          packageManifestDigest: packageManifestDigest,
          activate: activate,
        ),
      );

  List<PublicationQuarantineRecord> quarantineRecords(String candidateId) =>
      _withExclusiveLock(() {
        _validateCandidateId(candidateId);
        final directory = Directory(
          _join(storeRoot.path, 'quarantine', candidateId),
        );
        if (!directory.existsSync()) return const [];
        final files = directory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));
        return List.unmodifiable(
          files.map(
            (file) => PublicationQuarantineRecord.fromJson(
              _readObject(file),
            ),
          ),
        );
      });

  PublicationCandidateResult _submitCandidate({
    required String candidateId,
    required String Function() compile,
    required PublicationReviewDecision? review,
    required String? releaseCandidateContentDigest,
    required String? packageManifestDigest,
    required bool activate,
  }) {
    _validateCandidateId(candidateId);
    late final String compiled;
    try {
      compiled = compile();
    } on ExecutableKnowledgeException catch (error) {
      return _quarantineCandidate(
        candidateId: candidateId,
        issues: [
          PublicationValidationIssue(
            code: PublicationValidationCode.compilationFailed,
            phase: PublicationValidationPhase.compile,
            message: error.message,
          ),
        ],
        review: review,
      );
    }

    late final KnowledgeArtifactIdentity pack;
    final normalized = _normalizeNewlines(compiled);
    final bytes = utf8.encode(normalized);
    final artifactDigest = _sha256(bytes);
    try {
      pack = _artifactReader(normalized);
    } on ExecutableKnowledgeException catch (error) {
      return _quarantineCandidate(
        candidateId: candidateId,
        candidateArtifactDigest: artifactDigest,
        issues: [
          PublicationValidationIssue(
            code: PublicationValidationCode.artifactInvalid,
            phase: PublicationValidationPhase.artifact,
            message: error.message,
          ),
        ],
        review: review,
      );
    } catch (error) {
      return _quarantineCandidate(
        candidateId: candidateId,
        candidateArtifactDigest: artifactDigest,
        issues: [
          PublicationValidationIssue(
            code: PublicationValidationCode.artifactInvalid,
            phase: PublicationValidationPhase.artifact,
            message: '$error',
          ),
        ],
        review: review,
      );
    }

    final candidateArtifact = File(
      _joinMany(
        storeRoot.path,
        ['candidates', pack.contentDigest, 'package.json'],
      ),
    );
    _publishImmutable(
      candidateArtifact,
      bytes,
      expectedDigest: artifactDigest,
    );

    final reviewIssues = <PublicationValidationIssue>[];
    if (review == null) {
      reviewIssues.add(
        const PublicationValidationIssue(
          code: PublicationValidationCode.reviewMissing,
          phase: PublicationValidationPhase.review,
          message: 'Publication candidate has no review decision.',
        ),
      );
    } else if (review.candidateContentDigest != pack.contentDigest ||
        review.compilerVersion != pack.compilerVersion ||
        review.releaseCandidateContentDigest != releaseCandidateContentDigest) {
      reviewIssues.add(
        const PublicationValidationIssue(
          code: PublicationValidationCode.reviewScopeMismatch,
          phase: PublicationValidationPhase.review,
          message: 'Review decision does not match candidate provenance.',
        ),
      );
    } else if (review.outcome == PublicationReviewOutcome.rejected) {
      reviewIssues.add(
        PublicationValidationIssue(
          code: PublicationValidationCode.reviewRejected,
          phase: PublicationValidationPhase.review,
          message: review.reason!,
        ),
      );
    }

    if (reviewIssues.isNotEmpty) {
      return _quarantineCandidate(
        candidateId: candidateId,
        candidateContentDigest: pack.contentDigest,
        candidateArtifactDigest: artifactDigest,
        compilerVersion: pack.compilerVersion,
        issues: reviewIssues,
        review: review,
      );
    }
    return PublicationCandidateResult.published(
      _publish(
        normalized,
        reviewDecision: review!,
        releaseCandidateContentDigest: releaseCandidateContentDigest,
        packageManifestDigest: packageManifestDigest,
        activate: activate,
      ),
    );
  }

  PublicationCandidateResult _quarantineCandidate({
    required String candidateId,
    String? candidateContentDigest,
    String? candidateArtifactDigest,
    String? compilerVersion,
    required List<PublicationValidationIssue> issues,
    required PublicationReviewDecision? review,
  }) {
    final record = PublicationQuarantineRecord.create(
      candidateId: candidateId,
      candidateContentDigest: candidateContentDigest,
      candidateArtifactDigest: candidateArtifactDigest,
      compilerVersion: compilerVersion,
      issues: issues,
      reviewDecision: review,
    );
    final target = File(
      _joinMany(
        storeRoot.path,
        ['quarantine', candidateId, '${record.digest}.json'],
      ),
    );
    final bytes = utf8.encode(_prettyJson(record.toJson()));
    _publishImmutable(target, bytes, expectedDigest: _sha256(bytes));
    return PublicationCandidateResult.quarantined(record);
  }
}

Map<String, dynamic> _reviewPayload({
  required PublicationReviewOutcome outcome,
  required String candidateContentDigest,
  required String compilerVersion,
  required String? releaseCandidateContentDigest,
  required String reviewer,
  required String decidedAt,
  required String? reason,
}) =>
    {
      'schemaVersion': publicationSchemaVersion,
      'outcome': outcome.name,
      'candidateContentDigest': candidateContentDigest,
      'compilerVersion': compilerVersion,
      if (releaseCandidateContentDigest != null)
        'releaseCandidateContentDigest': releaseCandidateContentDigest,
      'reviewer': reviewer,
      'decidedAt': decidedAt,
      'reason': reason,
    };

Map<String, dynamic> _quarantinePayload({
  required String candidateId,
  required String? candidateContentDigest,
  required String? candidateArtifactDigest,
  required String? compilerVersion,
  required List<PublicationValidationIssue> issues,
  required PublicationReviewDecision? reviewDecision,
}) =>
    {
      'schemaVersion': publicationSchemaVersion,
      'candidateId': candidateId,
      'candidateContentDigest': candidateContentDigest,
      'candidateArtifactDigest': candidateArtifactDigest,
      'compilerVersion': compilerVersion,
      'issues': issues.map((issue) => issue.toJson()).toList(),
      'reviewDecision': reviewDecision?.toJson(),
    };

void _validateCandidateId(String candidateId) {
  if (!RegExp(r'^[a-z0-9][a-z0-9._-]*$').hasMatch(candidateId)) {
    throw const KnowledgePublicationException(
      'Publication candidate ID is invalid.',
    );
  }
}

T _enumByName<T extends Enum>(
  List<T> values,
  String name,
  String label,
) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw KnowledgePublicationException('Unsupported $label: $name.');
}
