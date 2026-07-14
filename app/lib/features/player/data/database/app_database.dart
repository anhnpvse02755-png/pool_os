import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pool_os/shared/constants/app_constants.dart';
import 'dart:io';

part 'app_database.g.dart';

@DriftDatabase(tables: [Players, Cues, Sessions, Matches, Racks, Shots, Events, Conversations, Messages, Skills, SkillHistoryTable, DailyGoals, DrillSessions, TrainingProgramProgress, PracticeShots, PracticeSessions, PlayerStateLogs, MatchEquipmentSnapshots, MatchContexts, CustomDrills, TrainingCenterSessions, DrillRuns, DrillFavorites, Goals, AchievementUnlocks, Tournaments, TournamentParticipants, TournamentMatches, Clubs, ClubMembers, ClubLinks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test-only constructor: inject a custom executor (e.g. an in-memory
  /// database) so the recording pipeline can be exercised without touching the
  /// on-disk app database. Used by RFC-301 integration tests.
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 20;

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
        if (from < 11) {
          await _migrateToV11();
        }
        if (from < 12) {
          await _migrateToV12(m);
        }
        if (from < 13) {
          await _migrateToV13();
        }
        if (from < 14) {
          await _migrateToV14(m);
        }
        if (from < 15) {
          await _migrateToV15();
        }
        if (from < 16) {
          await _migrateToV16(m);
        }
        if (from < 17) {
          await _migrateToV17(m);
        }
        if (from < 18) {
          await _migrateToV18(m);
        }
        if (from < 19) {
          await _migrateToV19(m);
        }
        if (from < 20) {
          await _migrateToV20(m);
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

  Future<void> _migrateToV11() async {
    // RFC-301: The 14 Match-Mode rack columns were already added to SQLite in
    // migration v10 (see _migrateToV10). v11 only promotes them into the Drift
    // ORM (Racks table class) so they stop being smuggled through the
    // __RACK_DATA__ notes JSON blob. For databases that reached v10 the columns
    // already exist, so each ALTER is guarded and treated as idempotent — this
    // also self-heals any DB where a prior column add was skipped.
    await customStatement('PRAGMA foreign_keys = OFF');

    const columnDdl = <String>[
      'ALTER TABLE racks ADD COLUMN balls_potted INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN largest_run INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN break_success INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN break_scratch INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN break_foul INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN easy_miss_count INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN hard_miss_count INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN scratch_error_count INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN position_error_count INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN safety_error_count INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN kick_error_count INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE racks ADD COLUMN jump_error_count INTEGER NOT NULL DEFAULT 0',
      "ALTER TABLE racks ADD COLUMN best_strengths TEXT NOT NULL DEFAULT '[]'",
      "ALTER TABLE racks ADD COLUMN biggest_mistakes TEXT NOT NULL DEFAULT '[]'",
    ];

    for (final ddl in columnDdl) {
      try {
        await customStatement(ddl);
      } catch (_) {
        // Column already present (added in v10). Idempotent — ignore.
      }
    }

    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV12(Migrator m) async {
    // Player State System: add the new PlayerStateLogs history table only.
    // No existing table is touched. createTable is idempotent-safe here because
    // this branch runs only when upgrading from < 12. Mirrors the additive
    // table-creation pattern; nothing to backfill (append-only history, doc §9).
    await m.createTable(playerStateLogs);
  }

  Future<void> _migrateToV14(Migrator m) async {
    // Task 04 Equipment Intelligence: add the append-only MatchEquipmentSnapshots
    // table (additive, mirrors _migrateToV12). Also data-heal any legacy cue with
    // the now-removed cueType='support' back to 'playing' so it is not orphaned —
    // getActiveCueByType returns null for an unknown type, which would hide the
    // cue from every role lookup.
    await m.createTable(matchEquipmentSnapshots);
    await customStatement(
        "UPDATE cues SET cue_type = 'playing' WHERE cue_type = 'support'");
  }

  Future<void> _migrateToV16(Migrator m) async {
    // Task 06 Match Context: add the MatchContexts table (pre/post-match state
    // per Match). Additive, mirrors _migrateToV14 — nothing existing is touched.
    await m.createTable(matchContexts);
  }

  Future<void> _migrateToV17(Migrator m) async {
    // Task 09 Training Center: add the four hand-entered practice tables
    // (custom drills, training sessions, drill runs, favourites). Additive,
    // mirrors _migrateToV16 — nothing existing is touched, and none of these
    // relate to the LOCKED RFC-301/302 recording pipeline.
    await m.createTable(customDrills);
    await m.createTable(trainingCenterSessions);
    await m.createTable(drillRuns);
    await m.createTable(drillFavorites);
  }

  Future<void> _migrateToV18(Migrator m) async {
    // Task 10 Goal & Progress Center: add the two goal/achievement tables.
    // Additive, mirrors _migrateToV17 — nothing existing is touched, and neither
    // relates to the LOCKED RFC-301/302 recording pipeline (they only read it).
    await m.createTable(goals);
    await m.createTable(achievementUnlocks);
  }

  Future<void> _migrateToV19(Migrator m) async {
    // Task 13 Tournament & League: add the three tournament tables. Additive,
    // mirrors _migrateToV18 — nothing existing is touched. The link to a
    // recorded Match lives in TournamentMatches.matchId as a soft-ref int (NOT
    // an FK), so the LOCKED RFC-301/302 recording pipeline is neither modified
    // nor cascade-coupled to the bracket.
    await m.createTable(tournaments);
    await m.createTable(tournamentParticipants);
    await m.createTable(tournamentMatches);
  }

  Future<void> _migrateToV20(Migrator m) async {
    // Task 14 Club & Community: add the three club tables. Additive, mirrors
    // _migrateToV19 — nothing existing is touched. A Match / Training /
    // Tournament "belongs to" a club only through ClubLinks.refId, a soft-ref
    // int (NOT an FK), so the LOCKED RFC-301/302 recording pipeline, the Task 09
    // training tables and the Task 13 tournament tables are neither modified nor
    // cascade-coupled to a club.
    await m.createTable(clubs);
    await m.createTable(clubMembers);
    await m.createTable(clubLinks);
  }

  Future<void> _migrateToV15() async {
    // Task 05 Player Profile: add career-profile columns to the existing players
    // table. Additive only — every column is nullable or defaulted so existing
    // player rows keep working with no backfill. Each ALTER is guarded so re-runs
    // are idempotent (mirrors _migrateToV13).
    await customStatement('PRAGMA foreign_keys = OFF');
    const columnDdl = <String>[
      'ALTER TABLE players ADD COLUMN avatar_path TEXT',
      'ALTER TABLE players ADD COLUMN age INTEGER',
      'ALTER TABLE players ADD COLUMN gender TEXT',
      'ALTER TABLE players ADD COLUMN club_region TEXT',
      'ALTER TABLE players ADD COLUMN rank TEXT',
      'ALTER TABLE players ADD COLUMN main_game TEXT',
      'ALTER TABLE players ADD COLUMN goal TEXT',
      "ALTER TABLE players ADD COLUMN play_styles TEXT NOT NULL DEFAULT '[]'",
      "ALTER TABLE players ADD COLUMN training_goals TEXT NOT NULL DEFAULT '[]'",
      'ALTER TABLE players ADD COLUMN started_playing_at INTEGER',
      'ALTER TABLE players ADD COLUMN has_competed INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE players ADD COLUMN hours_per_week INTEGER',
    ];
    for (final ddl in columnDdl) {
      try {
        await customStatement(ddl);
      } catch (_) {
        // Column already present. Idempotent — ignore.
      }
    }
    await customStatement('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV13() async {
    // Task 02: Shot becomes a complete data unit. Add two nullable columns to
    // the existing shots table — intent (what the player meant to do) and
    // miss_reason (why it failed, null when made). Additive only; no existing
    // table/column touched, no data migrated. Each ALTER is guarded so re-runs
    // are idempotent (mirrors _migrateToV11).
    await customStatement('PRAGMA foreign_keys = OFF');
    const columnDdl = <String>[
      'ALTER TABLE shots ADD COLUMN intent TEXT',
      'ALTER TABLE shots ADD COLUMN miss_reason TEXT',
    ];
    for (final ddl in columnDdl) {
      try {
        await customStatement(ddl);
      } catch (_) {
        // Column already present. Idempotent — ignore.
      }
    }
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
  // Task 05 Player Profile (schema v15): career-profile fields. All nullable /
  // defaulted so existing player rows keep working. JSON-encoded text is used
  // for the multi-select fields (playStyles, trainingGoals).
  TextColumn get avatarPath => text().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get clubRegion => text().nullable()();
  TextColumn get rank => text().nullable()(); // H, G, F...
  TextColumn get mainGame => text().nullable()(); // 9ball / 10ball / 8ball
  TextColumn get goal => text().nullable()();
  TextColumn get playStyles => text().withDefault(const Constant('[]'))(); // JSON list
  TextColumn get trainingGoals => text().withDefault(const Constant('[]'))(); // JSON list
  DateTimeColumn get startedPlayingAt => dateTime().nullable()();
  BoolColumn get hasCompeted => boolean().withDefault(const Constant(false))();
  IntColumn get hoursPerWeek => integer().nullable()();
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
  // RFC-301: Match-Mode fields promoted from the __RACK_DATA__ notes JSON blob
  // to real columns (added in SQLite via migration v10; exposed to the ORM in v11).
  IntColumn get ballsPotted => integer().withDefault(const Constant(0))();
  IntColumn get largestRun => integer().withDefault(const Constant(0))();
  BoolColumn get breakSuccess => boolean().withDefault(const Constant(false))();
  BoolColumn get breakScratch => boolean().withDefault(const Constant(false))();
  BoolColumn get breakFoul => boolean().withDefault(const Constant(false))();
  IntColumn get easyMissCount => integer().withDefault(const Constant(0))();
  IntColumn get hardMissCount => integer().withDefault(const Constant(0))();
  IntColumn get scratchErrorCount => integer().withDefault(const Constant(0))();
  IntColumn get positionErrorCount => integer().withDefault(const Constant(0))();
  IntColumn get safetyErrorCount => integer().withDefault(const Constant(0))();
  IntColumn get kickErrorCount => integer().withDefault(const Constant(0))();
  IntColumn get jumpErrorCount => integer().withDefault(const Constant(0))();
  TextColumn get bestStrengths => text().withDefault(const Constant('[]'))();
  TextColumn get biggestMistakes => text().withDefault(const Constant('[]'))();
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
  // Task 02: a Shot is now a complete data unit. intent = what the player
  // meant to do (pot/position/safety/break/escape); missReason = why it failed
  // (null when made). This absorbs the standalone Event flow for shot causes.
  TextColumn get intent => text().nullable()();
  TextColumn get missReason => text().nullable()();
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

/// Player State System (schema v12): append-only history of self-reported
/// player-state snapshots — pre-match readiness (doc §2) and post-match /
/// post-session fatigue (doc §5). One row per event, never overwritten
/// (doc §9). The computed warm-up (§3) and endurance (§4) indices are derived
/// on demand from rack history and are deliberately NOT stored here.
class PlayerStateLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer()();
  IntColumn get matchId => integer().nullable()();
  TextColumn get kind => text()(); // pre_match | post_match | post_session
  IntColumn get readyToCompete => integer().nullable()(); // 0-10
  IntColumn get warmedUp => integer().nullable()(); // 0-10
  IntColumn get handFeel => integer().nullable()(); // 0-10
  IntColumn get fatigueLevel => integer().nullable()(); // 0-10
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Task 04 Equipment Intelligence (schema v14): immutable equipment snapshot
/// captured once at match start (doc §4). One row per match records which cue
/// filled each role (Playing / Break / Jump) at that moment, so historical
/// matches keep the cues actually used even after the player later changes
/// their default active cues. Cue ids are plain nullable ints (soft refs, NOT
/// FKs) so deleting a cue never blocks or cascades a historical snapshot; a
/// role is null when no cue was active for it. Written read-side, AFTER the
/// LOCKED RFC-301 recording pipeline creates the match — never inside it.
class MatchEquipmentSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get matchId => integer()();
  IntColumn get playingCueId => integer().nullable()();
  IntColumn get breakCueId => integer().nullable()();
  IntColumn get jumpCueId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

// Task 06 Match Context (schema v16): pre-match + post-match state for one
// Match. Data-only — no Coach/Statistics/AI reads it yet. All fields nullable
// because the two halves are entered at different times (before vs after the
// match) and either may be skipped. Multi-select fields are JSON-encoded text.
class MatchContexts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get matchId => integer()();
  // --- Pre-match ---
  TextColumn get purpose => text().nullable()(); // practice/compete/tournament/social
  TextColumn get opponent => text().nullable()(); // solo/friend/strong/even/weak
  TextColumn get tableFamiliarity => text().nullable()(); // familiar/unfamiliar
  TextColumn get roomFamiliarity => text().nullable()(); // familiar/unfamiliar
  TextColumn get lighting => text().nullable()(); // good/normal/poor
  TextColumn get warmupLevel => text().nullable()(); // none/light/full/played_hot
  TextColumn get matchGoals => text().withDefault(const Constant('[]'))(); // JSON list
  DateTimeColumn get preRecordedAt => dateTime().nullable()();
  // --- Post-match ---
  TextColumn get fatigueLevel => text().nullable()(); // none/light/tired/very_tired
  TextColumn get fatigueAreas => text().withDefault(const Constant('[]'))(); // JSON list
  TextColumn get mentalState => text().nullable()(); // very_confident/ok/normal/unsure/pressure
  IntColumn get selfRating => integer().nullable()(); // 1..5 stars
  TextColumn get biggestFactor => text().nullable()(); // break/position/easy_miss/mental/...
  TextColumn get biggestFactorNote => text().nullable()(); // free text for "other"
  DateTimeColumn get postRecordedAt => dateTime().nullable()();
}

// ---------------------------------------------------------------------------
// Task 09 — Training Center (schema v17). A self-contained, hand-entered
// practice log: pick a drill, set a rep target, record Đạt/Miss, save. These
// tables are fully separate from the LOCKED RFC-301/302 recording pipeline
// (Sessions/Matches/Racks/Shots/Events) — a TrainingCenterSession here is NOT a
// recording Session and never touches it. All additive, created via
// m.createTable in _migrateToV17 (mirrors _migrateToV16). No hard FKs: cross
// refs are soft int ids so deleting a custom drill never cascades away history.
// ---------------------------------------------------------------------------

/// Phần 3 — bài tập do người chơi tự tạo. Reusable across sessions.
class CustomDrills extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get category => text()(); // a DrillCategory code
  IntColumn get targetReps => integer().withDefault(const Constant(100))();
  TextColumn get successCriteria => text().nullable()(); // player-defined
  DateTimeColumn get createdAt => dateTime()();
}

/// Phần 2 — one buổi luyện tập. Container for one or more DrillRuns.
class TrainingCenterSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playerId => integer().nullable()(); // soft ref, not FK
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
}

/// Phần 2 — one drill executed inside a TrainingCenterSession. drillCode links a
/// built-in DrillLibrary drill; customDrillId links a CustomDrill. Exactly one
/// is set (both soft refs). drillName/category are denormalised so history
/// survives a rename/delete of the source drill.
class DrillRuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer()(); // soft ref to TrainingCenterSessions
  TextColumn get drillCode => text().nullable()();
  IntColumn get customDrillId => integer().nullable()();
  TextColumn get drillName => text()();
  TextColumn get category => text()();
  IntColumn get targetReps => integer().withDefault(const Constant(100))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get successes => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Phần 5 — favourite drills. drillKey is a built-in drill code, or
/// "custom:<id>" for a CustomDrill (see [CustomDrill.drillKey]).
class DrillFavorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get drillKey => text()();
  DateTimeColumn get createdAt => dateTime()();
}

// ---------------------------------------------------------------------------
// Task 10 — Goal & Progress Center (schema v18). A self-contained, NON-AI goal
// and achievement layer. Goals track progress against a live metric computed
// read-only from existing recorded data (matches/racks/shots + training runs);
// achievements/streaks/milestones are derived on demand and only their
// unlocked-at timestamp is persisted (so "new" badges and notifications work).
// All additive, created via m.createTable in _migrateToV18 (mirrors
// _migrateToV17). No hard FKs — never touches the LOCKED RFC-301/302 recording
// pipeline; it only reads from it.
// ---------------------------------------------------------------------------

/// Phần 1/2 — a goal the player is pursuing. [metric] names how progress is
/// computed (see GoalMetric); [targetValue] is the finish line in that metric's
/// unit. Default goals are seeded with [isDefault] = true but are otherwise
/// identical to custom goals. [baselineValue] snapshots the metric at creation
/// so "since you started this goal" progress is honest for rate-style metrics.
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playerId => integer().nullable()(); // soft ref, not FK
  TextColumn get title => text()();
  TextColumn get metric => text()(); // a GoalMetric code
  RealColumn get targetValue => real()();
  RealColumn get baselineValue => real().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  // Highest progress ratio (0..1) ever notified, so the notification layer only
  // fires once per milestone crossing instead of every recompute.
  RealColumn get lastNotifiedProgress =>
      real().withDefault(const Constant(0))();
}

/// Phần 3/4/5 — the unlocked-at timestamp for one achievement, streak, or
/// milestone. The definition + current value are computed on demand from real
/// data; only the first time it is reached is stored, so the "mới" (new) badge
/// and unlock notification can be shown exactly once. [badgeKey] matches an
/// AchievementCatalog entry code.
class AchievementUnlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get badgeKey => text()();
  DateTimeColumn get unlockedAt => dateTime()();
  BoolColumn get seen => boolean().withDefault(const Constant(false))();
}

// ---------------------------------------------------------------------------
// Task 13 — Tournament & League (schema v19). A self-contained competition
// layer. A Tournament groups recorded Matches; the ONLY coupling to the LOCKED
// RFC-301/302 recording pipeline is TournamentMatches.matchId — a soft-ref int
// (NOT an FK), so recording a match, deleting it, or editing it never cascades
// into the bracket, and the pipeline tables themselves are never modified.
// Participants are soft-ref to Players (playerId nullable) so a guest needs no
// Player row and deleting a Player never removes tournament history. All
// additive, created via m.createTable in _migrateToV19. No AI / Coach.
// ---------------------------------------------------------------------------

/// Phần 1 — a competition. [type] is a TournamentType code (fixed at creation);
/// [status] is a TournamentStatus code.
class Tournaments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // TournamentType code
  TextColumn get status =>
      text().withDefault(const Constant('upcoming'))(); // TournamentStatus code
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Phần 3 — a participant. [playerId] is a soft ref (null for a guest); [name]
/// is always stored so history survives a Player delete. [seed] orders the
/// initial bracket (null seeds sort last).
class TournamentParticipants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tournamentId => integer()(); // soft ref, not FK
  IntColumn get playerId => integer().nullable()(); // soft ref, not FK
  TextColumn get name => text()();
  IntColumn get seed => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Phần 4/5 — one fixture/bracket slot. [matchId] softly links a recorded Match
/// (null until played); participant / winner ids are soft refs to
/// TournamentParticipants. [bracketGroup] is 'M' (main), 'W' (winners) or 'L'
/// (losers, double-elim). Scores are optional racks-won for standings tiebreak.
class TournamentMatches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tournamentId => integer()(); // soft ref, not FK
  IntColumn get roundIndex => integer()();
  IntColumn get slotIndex => integer()();
  TextColumn get bracketGroup => text().withDefault(const Constant('M'))();
  IntColumn get participantAId => integer().nullable()();
  IntColumn get participantBId => integer().nullable()();
  IntColumn get winnerParticipantId => integer().nullable()();
  IntColumn get scoreA => integer().nullable()();
  IntColumn get scoreB => integer().nullable()();
  IntColumn get matchId => integer().nullable()(); // soft ref to recorded Match
  DateTimeColumn get createdAt => dateTime()();
}

// ---------------------------------------------------------------------------
// Task 14 — Club & Community (schema v20). A self-contained community layer. A
// Club groups players; a Match / Training session / Tournament "belongs to" a
// club ONLY through ClubLinks.refId — a soft-ref int (NOT an FK) discriminated
// by kind. So the LOCKED RFC-301/302 recording pipeline, the Task 09 training
// tables and the Task 13 tournament tables are neither modified nor cascade-
// coupled to a club. Members soft-ref Players (playerId nullable) so a guest
// needs no Player row. All additive, created via m.createTable in
// _migrateToV20. No AI, no chat, no online sync, no social feed.
// ---------------------------------------------------------------------------

/// Phần 1 — a club. [managerName] is denormalised free text (club info),
/// independent of the member list. [logoPath] is a local image path (no upload).
class Clubs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get managerName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Phần 2 — a club member. [playerId] is a soft ref (null for a guest/invite);
/// [name] is always stored so a member survives a Player delete. [role] is a
/// ClubRole code; [invited] marks a not-yet-confirmed invite.
class ClubMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clubId => integer()(); // soft ref, not FK
  IntColumn get playerId => integer().nullable()(); // soft ref, not FK
  TextColumn get name => text()();
  TextColumn get role => text().withDefault(const Constant('member'))();
  BoolColumn get invited => boolean().withDefault(const Constant(false))();
  DateTimeColumn get joinedAt => dateTime()();
}

/// Phần 4/5/6 — a soft-ref link: "this Match / Training / Tournament belongs to
/// this Club". [kind] is a ClubLinkKind code; [refId] softly points at the
/// source row (recorded Match id / TrainingCenterSession id / Tournament id)
/// with no FK. This is the ONLY coupling to those subsystems.
class ClubLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clubId => integer()(); // soft ref, not FK
  TextColumn get kind => text()(); // ClubLinkKind code: match | training | tournament
  IntColumn get refId => integer()(); // soft ref to the source row
  DateTimeColumn get createdAt => dateTime()();
}
