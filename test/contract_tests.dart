import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/core/models/assessment.dart';
import 'package:pool_os/core/services/assessment_service.dart';

void main() {
  group('CT-01: Assessment Logic', () {
    test('CT-01.1: Beginner Detection - Q1 = never', () {
      final service = AssessmentService();
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'never',
          q2Accuracy: '0-2',
          q3Duration: 'under_1m',
          q4Motivation: 'fun',
          q5Time: '5-10m',
        ),
      );
      expect(result.playerLevel, equals('beginner'));
    });

    test('CT-01.2: Casual Detection - Q1 = some', () {
      final service = AssessmentService();
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'some',
          q2Accuracy: '3-5',
          q3Duration: '1-6m',
          q4Motivation: 'beat_friends',
          q5Time: '15-20m',
        ),
      );
      expect(result.playerLevel, equals('casual'));
    });

    test('CT-01.3: Regular Detection - Q1 = regular', () {
      final service = AssessmentService();
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'regular',
          q2Accuracy: '6-8',
          q3Duration: '6-12m',
          q4Motivation: 'club',
          q5Time: '30m+',
        ),
      );
      expect(result.playerLevel, equals('regular'));
    });
  });

  group('CT-02: Pain Logic', () {
    test('CT-02.1: Miss Despite Aim - Q2 = 0-2', () {
      final service = AssessmentService();
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'never',
          q2Accuracy: '0-2',
          q3Duration: 'under_1m',
          q4Motivation: 'fun',
          q5Time: '5-10m',
        ),
      );
      expect(result.painType, equals('miss_despite_aim'));
    });

    test('CT-02.2: Miss Despite Aim - Q2 = 3-5', () {
      final service = AssessmentService();
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'some',
          q2Accuracy: '3-5',
          q3Duration: '1-6m',
          q4Motivation: 'beat_friends',
          q5Time: '15-20m',
        ),
      );
      expect(result.painType, equals('miss_despite_aim'));
    });

    test('CT-02.3: Inconsistent Potting - Q2 = 6-8', () {
      final service = AssessmentService();
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'regular',
          q2Accuracy: '6-8',
          q3Duration: '6-12m',
          q4Motivation: 'club',
          q5Time: '30m+',
        ),
      );
      expect(result.painType, equals('inconsistent_potting'));
    });

    test('CT-02.4: Inconsistent Potting - Q2 = 9-10', () {
      final service = AssessmentService();
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'regular',
          q2Accuracy: '9-10',
          q3Duration: 'over_1y',
          q4Motivation: 'tournament',
          q5Time: '30m+',
        ),
      );
      expect(result.painType, equals('inconsistent_potting'));
    });

    test('CT-02.5: Pain Intensity Mapping', () {
      final service = AssessmentService();

      // 0-2 → intensity = 8
      var result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'never',
          q2Accuracy: '0-2',
          q3Duration: 'under_1m',
          q4Motivation: 'fun',
          q5Time: '5-10m',
        ),
      );
      expect(result.painIntensity, equals(8));

      // 3-5 → intensity = 6
      result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'some',
          q2Accuracy: '3-5',
          q3Duration: '1-6m',
          q4Motivation: 'beat_friends',
          q5Time: '15-20m',
        ),
      );
      expect(result.painIntensity, equals(6));

      // 6-8 → intensity = 4
      result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'regular',
          q2Accuracy: '6-8',
          q3Duration: '6-12m',
          q4Motivation: 'club',
          q5Time: '30m+',
        ),
      );
      expect(result.painIntensity, equals(4));

      // 9-10 → intensity = 2
      result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'regular',
          q2Accuracy: '9-10',
          q3Duration: 'over_1y',
          q4Motivation: 'tournament',
          q5Time: '30m+',
        ),
      );
      expect(result.painIntensity, equals(2));
    });

    test('CT-02.6: Pain Confidence >= 0.7', () {
      final service = AssessmentService();
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'never',
          q2Accuracy: '0-2',
          q3Duration: 'under_1m',
          q4Motivation: 'fun',
          q5Time: '5-10m',
        ),
      );
      expect(result.painConfidence, greaterThanOrEqualTo(0.7));
    });
  });

  group('CT-03: Goal Logic', () {
    test('CT-03.1: Only Pot First Ball for Sprint 1', () {
      final service = AssessmentService();
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'never',
          q2Accuracy: '0-2',
          q3Duration: 'under_1m',
          q4Motivation: 'fun',
          q5Time: '5-10m',
        ),
      );
      expect(result.goalId, equals('pot_first_ball'));
      expect(result.goalName, equals('Pot First Ball'));
    });
  });
}
