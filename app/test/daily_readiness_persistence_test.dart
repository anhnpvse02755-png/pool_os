import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/daily_readiness/data/repositories/daily_readiness_repository.dart';
import 'package:pool_os/features/daily_readiness/domain/models/daily_readiness.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('upsert updates the same date instead of creating a duplicate',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = DailyReadinessRepository(db);
    addTearDown(db.close);

    final readiness = DailyReadinessModel(
      date: '2026-07-19',
      sleepHours: 7.5,
      energyLevel: 6,
      focusLevel: 7,
      confidenceLevel: 5,
      mood: 'good',
      stressLevel: 4,
      shoulderCondition: 8,
      wristCondition: 7,
      backCondition: 6,
      playingLocation: 'club',
      tableSpeed: 'fast',
      todayGoal: 'Keep the routine stable',
      notes: 'First save',
    );

    final firstId = await repository.upsert(readiness);
    final secondId = await repository.upsert(
      readiness.copyWith(focusLevel: 9, notes: 'Updated'),
    );

    expect(secondId, firstId);
    final recent = await repository.getRecentDays(7);
    expect(recent, hasLength(1));
    expect(recent.single.focusLevel, 9);
    expect(recent.single.notes, 'Updated');
  });

  test('daily readiness survives a database restart', () async {
    final dir = await Directory.systemTemp.createTemp('daily_readiness_');
    final file = File('${dir.path}/pool_os_test.db');
    AppDatabase? db;

    try {
      db = AppDatabase.forTesting(NativeDatabase(file));
      var repository = DailyReadinessRepository(db);
      await repository.upsert(
        DailyReadinessModel(
          date: '2026-07-20',
          sleepHours: 8,
          energyLevel: 8,
          focusLevel: 7,
          confidenceLevel: 7,
          mood: 'great',
          stressLevel: 2,
          shoulderCondition: 9,
          wristCondition: 8,
          backCondition: 7,
          equipment: 'playing-cue-1',
          playingLocation: 'academy',
          tableSpeed: 'medium',
          todayGoal: 'Position play',
          notes: 'Persist me',
        ),
      );
      await db.close();

      db = AppDatabase.forTesting(NativeDatabase(file));
      repository = DailyReadinessRepository(db);
      final stored = await repository.getByDate('2026-07-20');

      expect(stored, isNotNull);
      expect(stored!.sleepHours, 8);
      expect(stored.wristCondition, 8);
      expect(stored.backCondition, 7);
      expect(stored.todayGoal, 'Position play');
      expect(stored.notes, 'Persist me');
    } finally {
      await db?.close();
      if (await dir.exists()) await dir.delete(recursive: true);
    }
  });

  test('schema v22 legacy readiness row migrates to the typed table', () async {
    final dir = await Directory.systemTemp.createTemp('daily_readiness_v22_');
    final file = File('${dir.path}/pool_os_v22.db');
    final legacy = sqlite.sqlite3.open(file.path);
    final epochSeconds = DateTime(2026, 7, 18).millisecondsSinceEpoch ~/ 1000;
    legacy.execute('''
      CREATE TABLE daily_readiness (
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
    legacy.execute(
      'INSERT INTO daily_readiness ('
      'date, sleep_hours, energy_level, focus_level, confidence_level, mood, '
      'stress_level, shoulder_condition, arm_condition, playing_location, '
      'table_speed, today_goal, notes, created_at, updated_at'
      ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        '2026-07-18',
        6.5,
        5,
        6,
        4,
        'okay',
        7,
        '8',
        '7',
        'club',
        'slow',
        'Stay composed',
        'Legacy row',
        epochSeconds,
        epochSeconds,
      ],
    );
    legacy.execute('PRAGMA user_version = 22');
    legacy.dispose();

    AppDatabase? db;
    try {
      db = AppDatabase.forTesting(NativeDatabase(file));
      final repository = DailyReadinessRepository(db);
      final stored = await repository.getByDate('2026-07-18');

      expect(stored, isNotNull);
      expect(stored!.shoulderCondition, 8);
      expect(stored.wristCondition, 7);
      expect(stored.backCondition, isNull);
      expect(stored.notes, 'Legacy row');
      expect(db.schemaVersion, 29);
    } finally {
      await db?.close();
      if (await dir.exists()) await dir.delete(recursive: true);
    }
  });
}
