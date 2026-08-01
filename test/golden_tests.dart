import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/core/models/assessment.dart';
import 'package:pool_os/core/services/assessment_service.dart';

void main() {
  final service = AssessmentService();

  group('Golden Dataset Tests - Personas', () {
    test('P01: Complete Beginner', () {
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
      expect(result.painIntensity, equals(8));
      expect(result.goalId, equals('pot_first_ball'));
    });

    test('P02: Casual Player', () {
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
      expect(result.painIntensity, equals(6));
      expect(result.goalId, equals('pot_first_ball'));
    });

    test('P03: Club Player', () {
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
      expect(result.painIntensity, equals(4));
      expect(result.goalId, equals('pot_first_ball'));
    });

    test('P04: Competitive Newbie', () {
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'some',
          q2Accuracy: '3-5',
          q3Duration: '1-6m',
          q4Motivation: 'tournament',
          q5Time: '15-20m',
        ),
      );

      expect(result.painType, equals('miss_despite_aim'));
      expect(result.painIntensity, equals(6));
      expect(result.goalId, equals('pot_first_ball'));
    });

    test('P05: Social Player', () {
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'regular',
          q2Accuracy: '6-8',
          q3Duration: 'over_1y',
          q4Motivation: 'fun',
          q5Time: '5-10m',
        ),
      );

      expect(result.painType, equals('inconsistent_potting'));
      expect(result.painIntensity, equals(4));
      expect(result.goalId, equals('pot_first_ball'));
    });

    test('P06: Time Constrained', () {
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'some',
          q2Accuracy: '0-2',
          q3Duration: '1-6m',
          q4Motivation: 'beat_friends',
          q5Time: '5-10m',
        ),
      );

      expect(result.painType, equals('miss_despite_aim'));
      expect(result.painIntensity, equals(8));
      expect(result.goalId, equals('pot_first_ball'));
    });

    test('P07: Improvement Seeker', () {
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'regular',
          q2Accuracy: '3-5',
          q3Duration: '6-12m',
          q4Motivation: 'beat_friends',
          q5Time: '15-20m',
        ),
      );

      expect(result.painType, equals('miss_despite_aim'));
      expect(result.painIntensity, equals(6));
      expect(result.goalId, equals('pot_first_ball'));
    });

    test('P08: Tournament Hopeful', () {
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'regular',
          q2Accuracy: '6-8',
          q3Duration: 'over_1y',
          q4Motivation: 'tournament',
          q5Time: '30m+',
        ),
      );

      expect(result.painType, equals('inconsistent_potting'));
      expect(result.painIntensity, equals(4));
      expect(result.goalId, equals('pot_first_ball'));
    });

    test('P09: Returning Player', () {
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'some',
          q2Accuracy: '0-2',
          q3Duration: 'over_1y',
          q4Motivation: 'fun',
          q5Time: '15-20m',
        ),
      );

      expect(result.painType, equals('miss_despite_aim'));
      expect(result.painIntensity, equals(8));
      expect(result.goalId, equals('pot_first_ball'));
    });

    test('P10: Frustrated Player', () {
      final result = service.processAssessment(
        const AssessmentAnswer(
          q1Experience: 'regular',
          q2Accuracy: '0-2',
          q3Duration: '1-6m',
          q4Motivation: 'beat_friends',
          q5Time: '15-20m',
        ),
      );

      expect(result.painType, equals('miss_despite_aim'));
      expect(result.painIntensity, equals(8));
      expect(result.goalId, equals('pot_first_ball'));
    });
  });
}
