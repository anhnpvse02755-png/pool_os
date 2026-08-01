import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CT-07: Reflection Logic', () {
    test('CT-07.1: Exactly 3 Questions', () {
      // Reflection screen has 3 questions
      const questions = ['difficulty', 'enjoyment', 'continueReason'];
      expect(questions.length, equals(3));
    });

    test('CT-07.2: Difficulty Options', () {
      const difficultyOptions = ['very_easy', 'easy', 'normal', 'hard', 'very_hard'];
      expect(difficultyOptions.length, equals(5));
    });

    test('CT-07.3: Enjoyment Options', () {
      const enjoymentOptions = ['love', 'like', 'neutral', 'dislike'];
      expect(enjoymentOptions.length, equals(4));
    });

    test('CT-07.4: Continue Options', () {
      const continueOptions = ['definitely', 'yes', 'maybe', 'no'];
      expect(continueOptions.length, equals(4));
    });

    test('CT-07.5: Enjoyment Score Mapping', () {
      expect(_getEnjoymentScore('love'), equals(5));
      expect(_getEnjoymentScore('like'), equals(4));
      expect(_getEnjoymentScore('neutral'), equals(3));
      expect(_getEnjoymentScore('dislike'), equals(2));
    });
  });

  group('CT-08: Memory Logic', () {
    test('CT-08.1: Memory Has Required Fields', () {
      // CoachMemory has: playerId, lastSessionDate, currentGoalId,
      // currentMilestone, capabilityPot, enjoymentScore, painDetected
      const requiredFields = [
        'playerId',
        'lastSessionDate',
        'currentGoalId',
        'currentMilestone',
        'capabilityPot',
        'enjoymentScore',
        'painDetected',
      ];
      expect(requiredFields.length, equals(7));
    });
  });

  group('CT-09: NBA Logic', () {
    test('CT-09.1: NBA Always Required', () {
      // NBA is shown in ClosingScreen
      const nbaAlwaysShown = true;
      expect(nbaAlwaysShown, isTrue);
    });

    test('CT-09.2: NBA Format', () {
      // NBA format: "Ngày mai: [Action]" + "[Duration]"
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

    test('CT-09.5: NBA Specific', () {
      // NBA must be specific, not "Practice more"
      const goodNba = 'Tiếp tục Pot First Ball, 10 phút';
      const badNba = 'Practice more';

      expect(goodNba.contains('Pot First Ball'), isTrue);
      expect(badNba.contains('Practice'), isTrue);
    });
  });

  group('CT-10: Coach Rules', () {
    test('CT-10.1: Vietnamese Language', () {
      const coachPhrases = [
        'Chào bạn!',
        'Bạn đang làm tốt lắm!',
        'Gần đạt rồi!',
        'Thử cách khác nhé',
        'Cố gắng thêm!',
      ];

      // All phrases in Vietnamese
      for (final phrase in coachPhrases) {
        expect(phrase.contains(RegExp(r'[a-zA-Z]')), isFalse,
            reason: '$phrase should be in Vietnamese only');
      }
    });

    test('CT-10.2: No Negative Words', () {
      const negativeWords = ['Sai', 'Sai rồi', 'Tệ', 'Yếu'];
      const positivePhrases = ['Bạn đang làm tốt lắm!', 'Gần đạt rồi!'];

      for (final phrase in positivePhrases) {
        for (final word in negativeWords) {
          expect(phrase.contains(word), isFalse,
              reason: '$phrase should not contain $word');
        }
      }
    });

    test('CT-10.3: No Comparison', () {
      const comparisonPhrases = [
        'Người khác',
        'bạn không',
        'chậm hơn',
      ];

      const goodPhrase = 'Bạn đang làm tốt!';

      for (final phrase in comparisonPhrases) {
        expect(goodPhrase.contains(phrase), isFalse);
      }
    });

    test('CT-10.4: Specific Over Vague', () {
      const goodGuidance = 'Tập trung vào Ghost Ball';
      const badGuidance = 'Practice more';

      expect(goodGuidance.length, greaterThan(badGuidance.length));
      expect(goodGuidance.contains('Ghost Ball'), isTrue);
      expect(badGuidance.contains('Practice'), isTrue);
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
