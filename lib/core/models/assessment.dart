/// Assessment answers from user
class AssessmentAnswer {
  final String q1Experience; // never, some, regular
  final String q2Accuracy; // 0-2, 3-5, 6-8, 9-10
  final String q3Duration; // under_1m, 1-6m, 6-12m, over_1y
  final String q4Motivation; // fun, beat_friends, club, tournament
  final String q5Time; // 5-10m, 15-20m, 30m+

  const AssessmentAnswer({
    required this.q1Experience,
    required this.q2Accuracy,
    required this.q3Duration,
    required this.q4Motivation,
    required this.q5Time,
  });

  Map<String, dynamic> toJson() => {
        'q1Experience': q1Experience,
        'q2Accuracy': q2Accuracy,
        'q3Duration': q3Duration,
        'q4Motivation': q4Motivation,
        'q5Time': q5Time,
      };

  factory AssessmentAnswer.fromJson(Map<String, dynamic> json) => AssessmentAnswer(
        q1Experience: json['q1Experience'] as String,
        q2Accuracy: json['q2Accuracy'] as String,
        q3Duration: json['q3Duration'] as String,
        q4Motivation: json['q4Motivation'] as String,
        q5Time: json['q5Time'] as String,
      );
}

/// Assessment result after processing answers
class AssessmentResult {
  final String playerId;
  final String playerLevel; // beginner, casual, regular
  final String painType; // miss_despite_aim, inconsistent_potting
  final int painIntensity; // 1-10
  final double painConfidence; // 0.0-1.0
  final String goalId; // pot_first_ball
  final String goalName;
  final AssessmentAnswer answers;

  const AssessmentResult({
    required this.playerId,
    required this.playerLevel,
    required this.painType,
    required this.painIntensity,
    required this.painConfidence,
    required this.goalId,
    required this.goalName,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'playerLevel': playerLevel,
        'painType': painType,
        'painIntensity': painIntensity,
        'painConfidence': painConfidence,
        'goalId': goalId,
        'goalName': goalName,
        'answers': answers.toJson(),
      };

  factory AssessmentResult.fromJson(Map<String, dynamic> json) => AssessmentResult(
        playerId: json['playerId'] as String,
        playerLevel: json['playerLevel'] as String,
        painType: json['painType'] as String,
        painIntensity: json['painIntensity'] as int,
        painConfidence: (json['painConfidence'] as num).toDouble(),
        goalId: json['goalId'] as String,
        goalName: json['goalName'] as String,
        answers: AssessmentAnswer.fromJson(json['answers'] as Map<String, dynamic>),
      );
}
