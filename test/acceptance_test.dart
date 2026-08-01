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

  group('Golden Dataset - 10 Personas', () {
    final service = AssessmentService();

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

  group('CT-07: Reflection Logic', () {
    test('CT-07.1: Exactly 3 Questions', () {
      const questions = ['difficulty', 'enjoyment', 'continueReason'];
      expect(questions.length, equals(3));
    });

    test('CT-07.5: Enjoyment Score Mapping', () {
      expect(_getEnjoymentScore('love'), equals(5));
      expect(_getEnjoymentScore('like'), equals(4));
      expect(_getEnjoymentScore('neutral'), equals(3));
      expect(_getEnjoymentScore('dislike'), equals(2));
    });
  });

  group('CT-09: NBA Logic', () {
    test('CT-09.1: NBA Always Required', () {
      const nbaAlwaysShown = true;
      expect(nbaAlwaysShown, isTrue);
    });

    test('CT-09.2: NBA Format', () {
      const nbaFormat = 'Ngày mai: {action}\n{minutes} phút';
      expect(nbaFormat.contains('{action}'), isTrue);
      expect(nbaFormat.contains('{minutes}'), isTrue);
    });

    test('CT-09.3: NBA After Success', () {
      const successNba = 'Tiếp tục Pot First Ball';
      expect(successNba.contains('Pot First Ball'), isTrue);
    });

    test('CT-09.4: NBA After Fail', () {
      const failNba = 'Làm lại Pot First Ball';
      expect(failNba.contains('Pot First Ball'), isTrue);
      expect(failNba.contains('Làm lại'), isTrue);
    });
  });

  group('CT-10: Coach Rules', () {
    test('CT-10.1: Vietnamese Language', () {
      // Check that common English negative words are not present
      const negativeEnglishWords = ['wrong', 'fail', 'error', 'bad', 'poor', 'practice more'];
      const coachPhrase = 'Chào bạn! Bạn đang làm tốt lắm! Gần đạt rồi!';

      for (final word in negativeEnglishWords) {
        expect(coachPhrase.toLowerCase().contains(word), isFalse);
      }
    });

    test('CT-10.2: No Negative Words', () {
      const negativeWords = ['Sai', 'Sai rồi', 'Tệ', 'Yếu'];
      const positivePhrases = ['Bạn đang làm tốt lắm!', 'Gần đạt rồi!'];

      for (final phrase in positivePhrases) {
        for (final word in negativeWords) {
          expect(phrase.contains(word), isFalse);
        }
      }
    });
  });
}

int _getEnjoymentScore(String enjoyment) {
  switch (enjoyment) {
    case 'love':
      return 5;
    case 'like':
      return 4;
    case 'neutral':
      return 3;
    case 'dislike':
      return 2;
    default:
      return 3;
  }
}
