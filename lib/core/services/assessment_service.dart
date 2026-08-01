import 'package:uuid/uuid.dart';
import '../models/assessment.dart';

/// Assessment service - processes answers and generates result
class AssessmentService {
  static const _uuid = Uuid();

  /// Process assessment answers and return result
  AssessmentResult processAssessment(AssessmentAnswer answers) {
    final playerLevel = _determineLevel(answers.q1Experience);
    final painResult = _detectPain(answers.q2Accuracy);
    final goalId = 'pot_first_ball'; // Sprint 1: only this goal

    return AssessmentResult(
      playerId: _uuid.v4(),
      playerLevel: playerLevel,
      painType: painResult.type,
      painIntensity: painResult.intensity,
      painConfidence: painResult.confidence,
      goalId: goalId,
      goalName: 'Pot First Ball',
      answers: answers,
    );
  }

  /// Determine player level from experience
  String _determineLevel(String experience) {
    switch (experience) {
      case 'never':
        return 'beginner';
      case 'some':
        return 'casual';
      case 'regular':
        return 'regular';
      default:
        return 'beginner';
    }
  }

  /// Detect pain from accuracy answer
  _PainResult _detectPain(String accuracy) {
    // Contract Test CT-02.3: Intensity Mapping
    int intensity;
    String type;

    switch (accuracy) {
      case '0-2':
        intensity = 8;
        type = 'miss_despite_aim';
        break;
      case '3-5':
        intensity = 6;
        type = 'miss_despite_aim';
        break;
      case '6-8':
        intensity = 4;
        type = 'inconsistent_potting';
        break;
      case '9-10':
        intensity = 2;
        type = 'inconsistent_potting';
        break;
      default:
        intensity = 6;
        type = 'miss_despite_aim';
    }

    // Contract Test CT-02.4: Pain Confidence >= 0.7
    return _PainResult(
      type: type,
      intensity: intensity,
      confidence: 0.8, // High confidence for Sprint 1
    );
  }
}

class _PainResult {
  final String type;
  final int intensity;
  final double confidence;

  const _PainResult({
    required this.type,
    required this.intensity,
    required this.confidence,
  });
}
