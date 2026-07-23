import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/domain/shared/coordinate_value.dart';
import 'package:pool_os/domain/shared/entity_ids.dart';
import 'package:pool_os/domain/shared/enum_value.dart';
import 'package:pool_os/domain/shared/scalar_values.dart';
import 'package:pool_os/domain/shared/temporal_values.dart';

enum TestPrimitive { first, second }

void main() {
  group('entity identifiers', () {
    test('are typed, stable, comparable value objects', () {
      final first = MatchId('match-1');
      final replay = MatchId('match-1');
      final player = PlayerId('match-1');

      expect(first, replay);
      expect(first, isNot(player));
      expect(first.canonical, 'entity.match:match-1');
      expect(SessionId('session-1').namespace, 'entity.session');
      expect(GenericEntityId('entity-1').value, 'entity-1');
    });

    test('reject malformed identity values', () {
      expect(() => MatchId(''), throwsArgumentError);
      expect(() => PlayerId('white space'), throwsArgumentError);
    });
  });

  group('scalar values', () {
    test('NonEmptyString canonicalizes surrounding whitespace', () {
      expect(NonEmptyString('  Pool OS  ').value, 'Pool OS');
      expect(NonEmptyString('Pool OS'), NonEmptyString(' Pool OS '));
      expect(() => NonEmptyString('   '), throwsArgumentError);
      expect(() => NonEmptyString('x\u0000y'), throwsArgumentError);
    });

    test('PositiveInteger and VersionNumber reject non-positive values', () {
      expect(PositiveInteger(1).value, 1);
      expect(() => PositiveInteger(0), throwsArgumentError);
      expect(VersionNumber(3).next(), VersionNumber(4));
      expect(() => VersionNumber(-1), throwsArgumentError);
    });

    test('Percentage is finite and bounded', () {
      expect(Percentage(25).fraction, 0.25);
      expect(Percentage(0).compareTo(Percentage(100)), lessThan(0));
      expect(() => Percentage(-0.1), throwsArgumentError);
      expect(() => Percentage(100.1), throwsArgumentError);
      expect(() => Percentage(double.nan), throwsArgumentError);
      expect(() => Percentage(double.infinity), throwsArgumentError);
    });

    test('ScoreValue is non-negative without adding game rules', () {
      expect(ScoreValue(0).value, 0);
      expect(ScoreValue(7), ScoreValue(7));
      expect(() => ScoreValue(-1), throwsArgumentError);
    });
  });

  group('temporal values', () {
    test('UtcTimestamp requires UTC and compares by instant', () {
      final value = DateTime.utc(2026, 7, 23, 1, 2, 3);
      expect(UtcTimestamp(value), UtcTimestamp(value));
      expect(UtcTimestamp(value).microsecondsSinceEpoch,
          value.microsecondsSinceEpoch);
      expect(() => UtcTimestamp(DateTime(2026, 7, 23)), throwsArgumentError);
    });

    test('NonNegativeDuration accepts zero and rejects negative', () {
      expect(NonNegativeDuration(Duration.zero).value, Duration.zero);
      expect(
        NonNegativeDuration(const Duration(seconds: 1))
            .compareTo(NonNegativeDuration(const Duration(seconds: 2))),
        lessThan(0),
      );
      expect(
        () => NonNegativeDuration(const Duration(microseconds: -1)),
        throwsArgumentError,
      );
    });
  });

  test('CoordinateValue requires finite coordinates and has value equality',
      () {
    expect(
      CoordinateValue(x: 1.5, y: -2),
      CoordinateValue(x: 1.5, y: -2),
    );
    expect(
      () => CoordinateValue(x: double.infinity, y: 0),
      throwsArgumentError,
    );
    expect(
      () => CoordinateValue(x: 0, y: double.nan),
      throwsArgumentError,
    );
  });

  test('EnumValue preserves typed enumerated identity', () {
    const value = EnumValue(TestPrimitive.first);
    expect(value.name, 'first');
    expect(value, const EnumValue(TestPrimitive.first));
    expect(value, isNot(const EnumValue(TestPrimitive.second)));
  });
}
