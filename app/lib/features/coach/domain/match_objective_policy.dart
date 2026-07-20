enum CoachMatchObjective {
  win,
  training,
  mixed;

  static CoachMatchObjective parse(String? code) => switch (code) {
        'win' => CoachMatchObjective.win,
        'training' => CoachMatchObjective.training,
        _ => CoachMatchObjective.mixed,
      };
}

class MatchObjectiveEvaluation {
  final CoachMatchObjective objective;
  final double resultWeight;
  final double executionWeight;
  final double resultRate;
  final double executionRate;
  final double score;

  const MatchObjectiveEvaluation({
    required this.objective,
    required this.resultWeight,
    required this.executionWeight,
    required this.resultRate,
    required this.executionRate,
    required this.score,
  });
}

class MatchObjectivePolicy {
  static MatchObjectiveEvaluation evaluate({
    required String? objectiveCode,
    required double resultRate,
    required double executionRate,
  }) {
    final objective = CoachMatchObjective.parse(objectiveCode);
    final (resultWeight, executionWeight) = switch (objective) {
      CoachMatchObjective.win => (0.70, 0.30),
      CoachMatchObjective.training => (0.20, 0.80),
      CoachMatchObjective.mixed => (0.50, 0.50),
    };
    final normalizedResult = resultRate.clamp(0.0, 1.0);
    final normalizedExecution = executionRate.clamp(0.0, 1.0);
    return MatchObjectiveEvaluation(
      objective: objective,
      resultWeight: resultWeight,
      executionWeight: executionWeight,
      resultRate: normalizedResult,
      executionRate: normalizedExecution,
      score: resultWeight * normalizedResult +
          executionWeight * normalizedExecution,
    );
  }
}
