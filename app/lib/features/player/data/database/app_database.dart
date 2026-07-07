import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pool_os/shared/constants/app_constants.dart';
import 'dart:io';

part 'app_database.g.dart';

@DriftDatabase(tables: [Players, Cues, Sessions, Matches, Racks, Shots, Events, Conversations, Messages, Skills, SkillHistoryTable, DailyGoals, DrillSessions, TrainingProgramProgress, PracticeShots, PracticeSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          await _migrateToV3();
        }
        if (from < 4) {
          await _migrateToV4();
        }
        if (from < 5) {
          await _migrateToV5();
        }
        if (from < 6) {
          await _migrateToV6();
        }
        if (from < 7) {
          await _migrateToV7();
        }
        if (from < 8) {
          await _migrateToV8();
        }
        if (from < 9) {
          await _migrateToV9();
        }
        if (from < 10) {
          await _migrateToV10();
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _migrateToV3() async {
    await customStatement('PRAGMA foreign_keys = OFF');
    
    await customStatement('''
      CREATE TABLE IF NOT EXISTS matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        match_number INTEGER NOT NULL,
        game_type TEXT NOT NULL,
        race_to INTEGER,
        opponent TEXT,
        partner TEXT,
        team_mode TEXT,
        winner TEXT,
        result TEXT,
        start_time INTEGER,
        end_time INTEGER,
        match_objective TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await customStatement('''
      INSERT INTO matches (session_id, match_number, game_type, created_at)
      SELECT s.id, 1, COALESCE(s.session_type, 'practice'), s.created_at
      FROM sessions s
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS racks_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        match_id INTEGER NOT NULL,
        rack_number INTEGER NOT NULL,
        result INTEGER NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await customStatement('''
      INSERT INTO racks_new (id, match_id, rack_number, result, notes, created_at)
      SELECT r.id, 
             m.id,
             (SELECT COUNT(*) FROM racks r2 WHERE r2.id <= r.id) as rack_number,
             r.result, r.notes, r.created_at
      FROM racks r
      JOIN matches m ON m.session_id = r.session_id
    ''');

    await customStatement('DROP TABLE racks');
    await customStatement('ALTER TABLE racks_new RENAME TO racks');

    await customStatement('ALTER TABLE shots ADD COLUMN shot_number INTEGER DEFAULT 1');
    await customStatement('ALTER TABLE shots ADD COLUMN difficulty TEXT DEFAULT \'medium\'');
    await customStatement('ALTER TABLE shots ADD COLUMN decision TEXT');
    await customStatement('ALTER TABLE shots ADD COLUMN confidence TEXT');
    await customStatement('ALTER TABLE shots ADD COLUMN player_note TEXT');

    await customStatement('ALTER TABLE events ADD COLUMN category TEXT DEFAULT \'special\'');
    await customStatement('ALTER TABLE events ADD COLUMN severity TEXT');
    await customStatement('ALTER TABLE events ADD COLUMN confidence TEXT');
    await customStatement('ALTER TABLE events ADD COLUMN metadata_json TEXT');

    await customStatement('CREATE INDEX IF NOT EXISTS racks_match_id_idx ON racks(match_id)');
    
    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV4() async {
    await customStatement('PRAGMA foreign_keys = OFF');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS skills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        score REAL NOT NULL,
        confidence REAL NOT NULL,
        trend TEXT NOT NULL,
        calculated_at INTEGER NOT NULL,
        version INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS skill_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        skill_id INTEGER NOT NULL,
        session_id INTEGER NOT NULL,
        score REAL NOT NULL,
        confidence REAL NOT NULL,
        trend TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await customStatement('CREATE INDEX IF NOT EXISTS skills_player_id_idx ON skills(player_id)');
    await customStatement('CREATE INDEX IF NOT EXISTS skill_history_skill_id_idx ON skill_history(skill_id)');
    await customStatement('CREATE INDEX IF NOT EXISTS skill_history_session_id_idx ON skill_history(session_id)');

    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV5() async {
    await customStatement('PRAGMA foreign_keys = OFF');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS daily_readiness (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        sleep_hours REAL,
        energy_level INTEGER,
        focus_level INTEGER,
        confidence_level INTEGER,
        mood TEXT,
        stress_level INTEGER,
        shoulder_condition TEXT,
        arm_condition TEXT,
        equipment TEXT,
        playing_location TEXT,
        table_speed TEXT,
        today_goal TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await customStatement('CREATE INDEX IF NOT EXISTS daily_readiness_date_idx ON daily_readiness(date)');

    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV6() async {
    await customStatement('PRAGMA foreign_keys = OFF');

    await customStatement('ALTER TABLE players ADD COLUMN is_active INTEGER DEFAULT 1');
    await customStatement('ALTER TABLE players ADD COLUMN skill_level TEXT');
    await customStatement('ALTER TABLE players ADD COLUMN default_equipment TEXT');
    await customStatement('ALTER TABLE players ADD COLUMN avatar TEXT');

    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV7() async {
    await customStatement('PRAGMA foreign_keys = OFF');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS daily_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        title_vi TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        target_value INTEGER NOT NULL,
        current_value INTEGER NOT NULL DEFAULT 0,
        unit TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        completed_at INTEGER,
        target_date TEXT,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        recurrence TEXT
      )
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS drill_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        drill_id INTEGER NOT NULL,
        drill_name TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        completed_at INTEGER,
        current_score INTEGER NOT NULL DEFAULT 0,
        target_score INTEGER NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        successful_attempts INTEGER NOT NULL DEFAULT 0,
        rating TEXT,
        notes TEXT
      )
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS training_program_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        program_id INTEGER NOT NULL,
        current_week INTEGER NOT NULL DEFAULT 1,
        current_session INTEGER NOT NULL DEFAULT 0,
        completed_sessions INTEGER NOT NULL DEFAULT 0,
        total_sessions INTEGER NOT NULL,
        overall_progress REAL NOT NULL DEFAULT 0.0,
        started_at INTEGER NOT NULL,
        completed_at INTEGER,
        completed_session_ids TEXT NOT NULL DEFAULT ''
      )
    ''');

    await customStatement('CREATE INDEX IF NOT EXISTS daily_goals_category_idx ON daily_goals(category)');
    await customStatement('CREATE INDEX IF NOT EXISTS drill_sessions_drill_id_idx ON drill_sessions(drill_id)');
    await customStatement('CREATE INDEX IF NOT EXISTS training_program_progress_program_id_idx ON training_program_progress(program_id)');

    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV8() async {
    await customStatement('PRAGMA foreign_keys = OFF');

    await customStatement('ALTER TABLE cues ADD COLUMN shaft_material TEXT DEFAULT \'Maple\'');
    await customStatement('ALTER TABLE cues ADD COLUMN shaft_diameter REAL DEFAULT 12.75');
    await customStatement('ALTER TABLE cues ADD COLUMN tip_brand TEXT DEFAULT \'Kamui\'');
    await customStatement('ALTER TABLE cues ADD COLUMN tip_hardness TEXT DEFAULT \'Medium\'');

    final existingCues = await customSelect(
      'SELECT id, shaft, tip FROM cues',
      readsFrom: {cues},
    ).get();

    for (final row in existingCues) {
      final id = row.read<int>('id');
      final shaft = row.read<String>('shaft');
      final tip = row.read<String>('tip');

      final shaftParts = shaft.split(' ');
      final shaftMaterial = shaftParts.isNotEmpty ? shaftParts[0] : 'Maple';
      double shaftDiameter = 12.75;
      if (shaftParts.length > 1) {
        final diameterStr = shaftParts[1].replaceAll('mm', '');
        shaftDiameter = double.tryParse(diameterStr) ?? 12.75;
      }

      final tipParts = tip.split(' ');
      final tipBrand = tipParts.isNotEmpty ? tipParts[0] : 'Kamui';
      final tipHardness = tipParts.length > 1 ? tipParts.sublist(1).join(' ') : 'Medium';

      await customStatement(
        'UPDATE cues SET shaft_material = ?, shaft_diameter = ?, tip_brand = ?, tip_hardness = ? WHERE id = ?',
        [shaftMaterial, shaftDiameter, tipBrand, tipHardness, id],
      );
    }

    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV9() async {
    await customStatement('PRAGMA foreign_keys = OFF');

    await customStatement('ALTER TABLE racks ADD COLUMN biggest_mistake TEXT');
    await customStatement('ALTER TABLE racks ADD COLUMN biggest_strength TEXT');
    await customStatement('ALTER TABLE racks ADD COLUMN confidence INTEGER');

    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV10() async {
    await customStatement('PRAGMA foreign_keys = OFF');

    // FIX-003: Add new columns to racks table for Match Mode
    await customStatement('ALTER TABLE racks ADD COLUMN balls_potted INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN largest_run INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN break_success INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN break_scratch INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN break_foul INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN easy_miss_count INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN hard_miss_count INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN scratch_error_count INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN position_error_count INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN safety_error_count INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN kick_error_count INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN jump_error_count INTEGER DEFAULT 0');
    await customStatement('ALTER TABLE racks ADD COLUMN best_strengths TEXT DEFAULT \'[]\'');
    await customStatement('ALTER TABLE racks ADD COLUMN biggest_mistakes TEXT DEFAULT \'[]\'');

    // FIX-008B: Separate tip brand/hardness and add cue type/tip size
    await customStatement('ALTER TABLE cues ADD COLUMN tip_size REAL');
    await customStatement('ALTER TABLE cues ADD COLUMN cue_type TEXT DEFAULT \'playing\'');

    // FIX-003: Create practice_shots table for Practice Mode
    await customStatement('''
      CREATE TABLE IF NOT EXISTS practice_shots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        drill_code TEXT NOT NULL,
        shot_number INTEGER NOT NULL,
        shot_type TEXT NOT NULL,
        success INTEGER NOT NULL,
        miss_type TEXT,
        cue_ball_control INTEGER DEFAULT 3,
        position INTEGER DEFAULT 3,
        difficulty INTEGER DEFAULT 3,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // FIX-003: Create practice_sessions table for Practice Mode
    await customStatement('''
      CREATE TABLE IF NOT EXISTS practice_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_id INTEGER,
        session_id INTEGER,
        drill_code TEXT NOT NULL,
        drill_name TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        completed_at INTEGER,
        notes TEXT,
        total_shots INTEGER DEFAULT 0,
        successful_shots INTEGER DEFAULT 0,
        success_rate REAL DEFAULT 0.0,
        average_difficulty REAL DEFAULT 0.0,
        longest_run INTEGER DEFAULT 0,
        shots_by_type TEXT DEFAULT '{}',
        misses_by_type TEXT DEFAULT '{}'
      )
    ''');

    await customStatement('CREATE INDEX IF NOT EXISTS practice_shots_session_id_idx ON practice_shots(session_id)');
    await customStatement('CREATE INDEX IF NOT EXISTS practice_sessions_session_id_idx ON practice_sessions(session_id)');

    await customStatement('PRAGMA foreign_keys = ON');
  }

  static QueryExecutor _openConnection() {
    if (kIsWeb) {
      throw UnsupportedError('Database not supported on web');
    }
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'pool_os.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}

class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get dominantHand => text().withDefault(Constant(AppConstants.defaultDominantHand.name))();
  TextColumn get language => text().withDefault(Constant(AppConstants.defaultLanguage.name))();
  TextColumn get measurementSystem => text().withDefault(Constant(AppConstants.defaultMeasurementSystem.name))();
  TextColumn get theme => text().withDefault(const Constant(AppConstants.themeDark))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Cues extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playerId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get shaft => text()();
  TextColumn get tip => text()();
  TextColumn get shaftMaterial => text()();
  RealColumn get shaftDiameter => real()();
  TextColumn get tipBrand => text()();
  TextColumn get tipHardness => text()();
  RealColumn get tipSize => real().nullable()();
  TextColumn get cueType => text().withDefault(const Constant('playing'))();
  RealColumn get weight => real()();
  TextColumn get balance => text()();
  TextColumn get joint => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isBreakCue => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playerId => integer().nullable()();
  TextColumn get sessionType => text()();
  TextColumn get location => text().nullable()();
  TextColumn get table => text().nullable()();
  TextColumn get cloth => text().nullable()();
  TextColumn get balls => text().nullable()();
  TextColumn get trainingGoal => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get weather => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Matches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();
  IntColumn get matchNumber => integer()();
  TextColumn get gameType => text()();
  IntColumn get raceTo => integer().nullable()();
  TextColumn get opponent => text().nullable()();
  TextColumn get partner => text().nullable()();
  TextColumn get teamMode => text().nullable()();
  TextColumn get winner => text().nullable()();
  TextColumn get result => text().nullable()();
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get matchObjective => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Racks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get matchId => integer().references(Matches, #id)();
  IntColumn get rackNumber => integer()();
  BoolColumn get result => boolean()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get biggestMistake => text().nullable()();
  TextColumn get biggestStrength => text().nullable()();
  IntColumn get confidence => integer().nullable()();
}

class Shots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rackId => integer().references(Racks, #id)();
  IntColumn get shotNumber => integer()();
  TextColumn get shotType => text()();
  TextColumn get difficulty => text()();
  TextColumn get result => text()();
  TextColumn get positionQuality => text().nullable()();
  TextColumn get decision => text().nullable()();
  TextColumn get confidence => text().nullable()();
  TextColumn get playerNote => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get shotId => integer().references(Shots, #id)();
  TextColumn get category => text()();
  TextColumn get type => text()();
  TextColumn get severity => text().nullable()();
  TextColumn get confidence => text().nullable()();
  TextColumn get metadataJson => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get lastMessage => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId => integer().references(Conversations, #id)();
  TextColumn get content => text()();
  BoolColumn get isFromUser => boolean()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Skills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playerId => integer()();
  TextColumn get category => text()();
  RealColumn get score => real()();
  RealColumn get confidence => real()();
  TextColumn get trend => text()();
  DateTimeColumn get calculatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
}

@DataClassName('SkillHistory')
class SkillHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get skillId => integer()();
  IntColumn get sessionId => integer()();
  RealColumn get score => real()();
  RealColumn get confidence => real()();
  TextColumn get trend => text()();
  DateTimeColumn get createdAt => dateTime()();
}

class DailyGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get titleVi => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()();
  TextColumn get priority => text()();
  TextColumn get status => text()();
  IntColumn get targetValue => integer()();
  IntColumn get currentValue => integer()();
  TextColumn get unit => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get targetDate => text().nullable()();
  BoolColumn get isRecurring => boolean()();
  TextColumn get recurrence => text().nullable()();
}

class DrillSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get drillId => integer()();
  TextColumn get drillName => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get currentScore => integer()();
  IntColumn get targetScore => integer()();
  IntColumn get attempts => integer()();
  IntColumn get successfulAttempts => integer()();
  TextColumn get rating => text().nullable()();
  TextColumn get notes => text().nullable()();
}

class TrainingProgramProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programId => integer()();
  IntColumn get currentWeek => integer()();
  IntColumn get currentSession => integer()();
  IntColumn get completedSessions => integer()();
  IntColumn get totalSessions => integer()();
  RealColumn get overallProgress => real()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get completedSessionIds => text()();
}

/// FIX-003: Practice Shots Table for Practice Mode
class PracticeShots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().nullable()();
  TextColumn get drillCode => text()();
  IntColumn get shotNumber => integer()();
  TextColumn get shotType => text()();
  BoolColumn get success => boolean()();
  TextColumn get missType => text().nullable()();
  IntColumn get cueBallControl => integer().withDefault(const Constant(3))();
  IntColumn get position => integer().withDefault(const Constant(3))();
  IntColumn get difficulty => integer().withDefault(const Constant(3))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// FIX-003: Practice Sessions Table for Practice Mode
class PracticeSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playerId => integer().nullable()();
  IntColumn get sessionId => integer().nullable()();
  TextColumn get drillCode => text()();
  TextColumn get drillName => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get totalShots => integer().withDefault(const Constant(0))();
  IntColumn get successfulShots => integer().withDefault(const Constant(0))();
  RealColumn get successRate => real().withDefault(const Constant(0.0))();
  RealColumn get averageDifficulty => real().withDefault(const Constant(0.0))();
  IntColumn get longestRun => integer().withDefault(const Constant(0))();
  TextColumn get shotsByType => text().withDefault(const Constant('{}'))();
  TextColumn get missesByType => text().withDefault(const Constant('{}'))();
}
