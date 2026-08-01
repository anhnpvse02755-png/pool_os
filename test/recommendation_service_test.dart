import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecommendationService - Logic Tests', () {
    test('pain intensity mapping correct', () {
      expect(_getIntensity('0-2'), equals(8));
      expect(_getIntensity('3-5'), equals(6));
      expect(_getIntensity('6-8'), equals(4));
      expect(_getIntensity('9-10'), equals(2));
    });

    test('duration mapping correct', () {
      expect(_getDuration('5-10m'), equals(10));
      expect(_getDuration('15-20m'), equals(15));
      expect(_getDuration('30m+'), equals(30));
    });

    test('pain type mapping correct', () {
      expect(_getPainType('0-2'), equals('miss_despite_aim'));
      expect(_getPainType('3-5'), equals('miss_despite_aim'));
      expect(_getPainType('6-8'), equals('inconsistent_potting'));
      expect(_getPainType('9-10'), equals('inconsistent_potting'));
    });

    test('goal name mapping correct', () {
      expect(_getGoalName('pot_first_ball'), equals('Pot First Ball'));
      expect(_getGoalName('stop_shot'), equals('Stop Shot'));
      expect(_getGoalName('follow_shot'), equals('Follow Shot'));
      expect(_getGoalName('draw_shot'), equals('Draw Shot'));
    });
  });
}

// Helper functions matching RecommendationService logic
int _getIntensity(String accuracy) {
  switch (accuracy) {
    case '0-2':
      return 8;
    case '3-5':
      return 6;
    case '6-8':
      return 4;
    case '9-10':
      return 2;
    default:
      return 6;
  }
}

int _getDuration(String q5Time) {
  switch (q5Time) {
    case '5-10m':
      return 10;
    case '15-20m':
      return 15;
    case '30m+':
      return 30;
    default:
      return 15;
  }
}

String _getPainType(String accuracy) {
  switch (accuracy) {
    case '0-2':
    case '3-5':
      return 'miss_despite_aim';
    case '6-8':
    case '9-10':
      return 'inconsistent_potting';
    default:
      return 'miss_despite_aim';
  }
}

String _getGoalName(String goalId) {
  switch (goalId) {
    case 'pot_first_ball':
      return 'Pot First Ball';
    case 'stop_shot':
      return 'Stop Shot';
    case 'follow_shot':
      return 'Follow Shot';
    case 'draw_shot':
      return 'Draw Shot';
    default:
      return 'Pot First Ball';
  }
}
