class Event {
  final int? id;
  final int shotId;
  final String category;
  final String type;
  final String? severity;
  final String? confidence;
  final String? metadataJson;
  final String? notes;
  final DateTime createdAt;

  Event({
    this.id,
    required this.shotId,
    required this.category,
    required this.type,
    this.severity,
    this.confidence,
    this.metadataJson,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Event copyWith({
    int? id,
    int? shotId,
    String? category,
    String? type,
    String? severity,
    String? confidence,
    String? metadataJson,
    String? notes,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      shotId: shotId ?? this.shotId,
      category: category ?? this.category,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      confidence: confidence ?? this.confidence,
      metadataJson: metadataJson ?? this.metadataJson,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class EventCategory {
  static const String stroke = 'stroke';
  static const String position = 'position';
  static const String decision = 'decision';
  static const String pattern = 'pattern';
  static const String breakShot = 'break';
  static const String mental = 'mental';
  static const String equipment = 'equipment';
  static const String training = 'training';
  static const String environment = 'environment';
  static const String special = 'special';

  static const List<String> all = [
    stroke,
    position,
    decision,
    pattern,
    breakShot,
    mental,
    equipment,
    training,
    environment,
    special,
  ];
}

class StrokeEventTypes {
  static const String strokeHitch = 'stroke_hitch';
  static const String gripTight = 'grip_tight';
  static const String gripLoose = 'grip_loose';
  static const String headLift = 'head_lift';
  static const String steering = 'steering';
  static const String bridgeUnstable = 'bridge_unstable';
  static const String followThroughShort = 'follow_through_short';

  static const List<String> all = [
    strokeHitch,
    gripTight,
    gripLoose,
    headLift,
    steering,
    bridgeUnstable,
    followThroughShort,
  ];
}

class PositionEventTypes {
  static const String naturalRoute = 'natural_route';
  static const String awkwardAngle = 'awkward_angle';
  static const String longPot = 'long_pot';
  static const String thinCut = 'thin_cut';
  static const String cannon = 'cannon';
  static const String plant = 'plant';

  static const List<String> all = [
    naturalRoute,
    awkwardAngle,
    longPot,
    thinCut,
    cannon,
    plant,
  ];
}

class DecisionEventTypes {
  static const String attack = 'attack';
  static const String safety = 'safety';
  static const String push = 'push';
  static const String rollOver = 'roll_over';
  static const String leaveTight = 'leave_tight';

  static const List<String> all = [attack, safety, push, rollOver, leaveTight];
}

class MentalEventTypes {
  static const String pressureShot = 'pressure_shot';
  static const String rushShot = 'rush_shot';
  static const String anxiousShot = 'anxious_shot';
  static const String overConfident = 'over_confident';
  static const String losingFocus = 'losing_focus';

  static const List<String> all = [
    pressureShot,
    rushShot,
    anxiousShot,
    overConfident,
    losingFocus,
  ];
}

class EquipmentEventTypes {
  static const String houseCue = 'house_cue';
  static const String newCue = 'new_cue';
  static const String tipChange = 'tip_change';
  static const String tableCondition = 'table_condition';
  static const String ballCondition = 'ball_condition';

  static const List<String> all = [
    houseCue,
    newCue,
    tipChange,
    tableCondition,
    ballCondition,
  ];
}

class TrainingEventTypes {
  static const String noSideSpin = 'no_side_spin';
  static const String drawOnly = 'draw_only';
  static const String followOnly = 'follow_only';
  static const String speedControl = 'speed_control';
  static const String positionPlay = 'position_play';

  static const List<String> all = [
    noSideSpin,
    drawOnly,
    followOnly,
    speedControl,
    positionPlay,
  ];
}

class EventSeverity {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';
  static const String critical = 'critical';

  static const List<String> all = [low, medium, high, critical];
}
