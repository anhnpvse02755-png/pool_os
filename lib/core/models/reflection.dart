/// Reflection answers after session
class ReflectionResult {
  final String sessionId;
  final String difficulty; // very_easy, easy, normal, hard, very_hard
  final String enjoyment; // love, like, neutral, dislike
  final String continueReason; // definitely, yes, maybe, no
  final int enjoymentScore; // 1-5

  const ReflectionResult({
    required this.sessionId,
    required this.difficulty,
    required this.enjoyment,
    required this.continueReason,
    required this.enjoymentScore,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'difficulty': difficulty,
        'enjoyment': enjoyment,
        'continueReason': continueReason,
        'enjoymentScore': enjoymentScore,
      };

  factory ReflectionResult.fromJson(Map<String, dynamic> json) => ReflectionResult(
        sessionId: json['sessionId'] as String,
        difficulty: json['difficulty'] as String,
        enjoyment: json['enjoyment'] as String,
        continueReason: json['continueReason'] as String,
        enjoymentScore: json['enjoymentScore'] as int,
      );
}
