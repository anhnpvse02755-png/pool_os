// EPIC 01 — Match Engine — Phase 1: GameType enumeration.
//
// The Match Engine is rule-agnostic. The active game type is decided
// at Match creation time and held inside the Match value object.
// Real rule logic for each GameType lives in a future Epic Rule
// System; in EPIC 01 only placeholder implementations are provided
// so the engine can run end-to-end.

import 'package:meta/meta.dart';

/// Type of pool game being played. Extensible; new values may be added
/// without modifying the Match Engine (Strategy Pattern).
@immutable
class GameType {
  const GameType._(this.value, this.label);

  /// Identifier used for persistence and telemetry. Must remain
  /// stable across releases.
  final String value;

  /// Human-readable label for UI surfaces.
  final String label;

  static const eightBall = GameType._('eight_ball', 'Eight Ball');
  static const nineBall = GameType._('nine_ball', 'Nine Ball');
  static const tenBall = GameType._('ten_ball', 'Ten Ball');

  /// Placeholder for tests and integration scenarios.
  static const placeholder = GameType._('placeholder', 'Placeholder');

  static const List<GameType> all = [
    eightBall,
    nineBall,
    tenBall,
    placeholder,
  ];

  static GameType fromValue(String value) {
    for (final t in all) {
      if (t.value == value) return t;
    }
    throw ArgumentError.value(value, 'value', 'Unknown GameType');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is GameType && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'GameType($value)';
}
