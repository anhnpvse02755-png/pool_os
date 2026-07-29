// EPIC 03 — Training System seed data.
//
// Static seed content for Lessons + Personal Training Programs.
// Loaded into Drift on first run via `seedTrainingSystem`; not authored
// by the player. Custom player programs are inserted through the
// repository and coexist with seeds.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/training_system/data/repositories/training_system_repository.dart';
import 'package:pool_os/features/training_system/domain/models/training_system_models.dart';

class LessonSeed {
  final String code;
  final String title;
  final String description;
  final List<String> objectives;
  final List<String> requiredDrills;
  final List<String> references;
  final String difficulty;
  final String skillLevel;
  final int orderIndex;

  const LessonSeed({
    required this.code,
    required this.title,
    required this.description,
    required this.objectives,
    required this.requiredDrills,
    required this.references,
    required this.difficulty,
    required this.skillLevel,
    required this.orderIndex,
  });
}

class ProgramSeed {
  final String code;
  final String title;
  final String description;
  final ProgramDifficulty difficulty;
  final TrainingProgramHierarchy hierarchy;

  const ProgramSeed({
    required this.code,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.hierarchy,
  });
}

const List<LessonSeed> lessonSeeds = [
  LessonSeed(
    code: 'lesson_stroke_basics',
    title: 'Stroke Fundamentals',
    description:
        'A beginner lesson on cue grip, stance, bridge, and pendulum stroke.',
    objectives: [
      'Establish a relaxed, repeatable grip.',
      'Build a straight pendulum stroke.',
      'Hit the cue ball center 9 times out of 10.',
    ],
    requiredDrills: ['stopShot', 'followShot'],
    references: ['BEA — Billiard Education Association Level 1 handbook'],
    difficulty: 'beginner',
    skillLevel: 'beginner',
    orderIndex: 1,
  ),
  LessonSeed(
    code: 'lesson_position_play',
    title: 'Position Play Basics',
    description:
        'Plan two shots ahead. Place the cue ball naturally for the next shot.',
    objectives: [
      'Identify natural angle paths.',
      'Use center, follow, and draw to control distance.',
      'Choose the easiest zone for the next ball.',
    ],
    requiredDrills: ['positionPlay', 'stopShot', 'followShot'],
    references: ['Robert Byrne — Standard Book of Pool, ch. 4'],
    difficulty: 'intermediate',
    skillLevel: 'intermediate',
    orderIndex: 2,
  ),
  LessonSeed(
    code: 'lesson_safety',
    title: 'Safety Play 101',
    description:
        'When you cannot run out, leave your opponent without a shot.',
    objectives: [
      'Recognize defensive situations.',
      'Leave the cue ball in the kitchen or snookered.',
      'Maintain ball-in-hand control.',
    ],
    requiredDrills: ['safety'],
    references: ['Mizerak — Pocket Billiards with the Wizard'],
    difficulty: 'intermediate',
    skillLevel: 'intermediate',
    orderIndex: 3,
  ),
];

/// 4-week Beginner Program: stop shot → follow → draw → position play.
/// Drills are wired to drillLibrary codes (see drill.dart).
const ProgramSeed beginnerProgram = ProgramSeed(
  code: 'program_beginner',
  title: 'Beginner Program',
  description:
      'Four-week foundation program covering stroke, follow, draw, '
      'and basic position play. Three short sessions per week.',
  difficulty: ProgramDifficulty.beginner,
  hierarchy: TrainingProgramHierarchy(
    weeks: [
      ProgramWeek(
        weekIndex: 1,
        title: 'Stroke + Stop Shot',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Stroke fundamentals',
            drills: [ProgramDrill(drillCode: 'stopShot', targetReps: 30)],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Repeat',
            drills: [ProgramDrill(drillCode: 'stopShot', targetReps: 30)],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Combo',
            drills: [
              ProgramDrill(drillCode: 'stopShot', targetReps: 20),
              ProgramDrill(drillCode: 'followShot', targetReps: 20),
            ],
          ),
        ],
      ),
      ProgramWeek(
        weekIndex: 2,
        title: 'Follow Shot',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Long follow',
            drills: [ProgramDrill(drillCode: 'followShot', targetReps: 30)],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Repeat',
            drills: [ProgramDrill(drillCode: 'followShot', targetReps: 30)],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Combo',
            drills: [
              ProgramDrill(drillCode: 'stopShot', targetReps: 15),
              ProgramDrill(drillCode: 'followShot', targetReps: 30),
            ],
          ),
        ],
      ),
      ProgramWeek(
        weekIndex: 3,
        title: 'Draw Shot',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Short draw',
            drills: [ProgramDrill(drillCode: 'drawShot', targetReps: 30)],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Repeat',
            drills: [ProgramDrill(drillCode: 'drawShot', targetReps: 30)],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Combo',
            drills: [
              ProgramDrill(drillCode: 'stopShot', targetReps: 15),
              ProgramDrill(drillCode: 'drawShot', targetReps: 25),
            ],
          ),
        ],
      ),
      ProgramWeek(
        weekIndex: 4,
        title: 'Position Play',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Two-shot planning',
            drills: [ProgramDrill(drillCode: 'positionPlay', targetReps: 20)],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Repeat',
            drills: [ProgramDrill(drillCode: 'positionPlay', targetReps: 20)],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Final test',
            drills: [
              ProgramDrill(drillCode: 'positionPlay', targetReps: 15),
              ProgramDrill(drillCode: 'cutShot', targetReps: 15),
            ],
          ),
        ],
      ),
    ],
  ),
);

const ProgramSeed intermediateProgram = ProgramSeed(
  code: 'program_intermediate',
  title: 'Intermediate Program',
  description:
      'Four-week program adding cut shots, banks, and pattern play.',
  difficulty: ProgramDifficulty.intermediate,
  hierarchy: TrainingProgramHierarchy(
    weeks: [
      ProgramWeek(
        weekIndex: 1,
        title: 'Cut Shots',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Cut practice',
            drills: [ProgramDrill(drillCode: 'cutShot', targetReps: 25)],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Cut practice',
            drills: [ProgramDrill(drillCode: 'cutShot', targetReps: 25)],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Cut practice',
            drills: [ProgramDrill(drillCode: 'cutShot', targetReps: 25)],
          ),
        ],
      ),
      ProgramWeek(
        weekIndex: 2,
        title: 'Bank Shots',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Bank practice',
            drills: [ProgramDrill(drillCode: 'bankShot', targetReps: 20)],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Bank practice',
            drills: [ProgramDrill(drillCode: 'bankShot', targetReps: 20)],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Bank practice',
            drills: [ProgramDrill(drillCode: 'bankShot', targetReps: 20)],
          ),
        ],
      ),
      ProgramWeek(
        weekIndex: 3,
        title: 'Pattern Play',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Pattern drill',
            drills: [ProgramDrill(drillCode: 'patternPlay', targetReps: 10)],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Pattern drill',
            drills: [ProgramDrill(drillCode: 'patternPlay', targetReps: 10)],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Pattern drill',
            drills: [ProgramDrill(drillCode: 'patternPlay', targetReps: 10)],
          ),
        ],
      ),
      ProgramWeek(
        weekIndex: 4,
        title: 'Mixed',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Mixed review',
            drills: [
              ProgramDrill(drillCode: 'cutShot', targetReps: 10),
              ProgramDrill(drillCode: 'bankShot', targetReps: 10),
              ProgramDrill(drillCode: 'positionPlay', targetReps: 10),
            ],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Mixed review',
            drills: [
              ProgramDrill(drillCode: 'cutShot', targetReps: 10),
              ProgramDrill(drillCode: 'bankShot', targetReps: 10),
              ProgramDrill(drillCode: 'positionPlay', targetReps: 10),
            ],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Mixed review',
            drills: [
              ProgramDrill(drillCode: 'cutShot', targetReps: 10),
              ProgramDrill(drillCode: 'bankShot', targetReps: 10),
              ProgramDrill(drillCode: 'positionPlay', targetReps: 10),
            ],
          ),
        ],
      ),
    ],
  ),
);

const ProgramSeed advancedProgram = ProgramSeed(
  code: 'program_advanced',
  title: 'Advanced Program',
  description:
      'Four-week advanced program adding kick shots, break shot, and safety.',
  difficulty: ProgramDifficulty.advanced,
  hierarchy: TrainingProgramHierarchy(
    weeks: [
      ProgramWeek(
        weekIndex: 1,
        title: 'Kick Shots',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Kick practice',
            drills: [ProgramDrill(drillCode: 'kickShot', targetReps: 15)],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Kick practice',
            drills: [ProgramDrill(drillCode: 'kickShot', targetReps: 15)],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Kick practice',
            drills: [ProgramDrill(drillCode: 'kickShot', targetReps: 15)],
          ),
        ],
      ),
      ProgramWeek(
        weekIndex: 2,
        title: 'Break Shot',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Break practice',
            drills: [ProgramDrill(drillCode: 'breakShot', targetReps: 20)],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Break practice',
            drills: [ProgramDrill(drillCode: 'breakShot', targetReps: 20)],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Break practice',
            drills: [ProgramDrill(drillCode: 'breakShot', targetReps: 20)],
          ),
        ],
      ),
      ProgramWeek(
        weekIndex: 3,
        title: 'Safety',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Safety practice',
            drills: [ProgramDrill(drillCode: 'safety', targetReps: 15)],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Safety practice',
            drills: [ProgramDrill(drillCode: 'safety', targetReps: 15)],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Safety practice',
            drills: [ProgramDrill(drillCode: 'safety', targetReps: 15)],
          ),
        ],
      ),
      ProgramWeek(
        weekIndex: 4,
        title: 'Mixed advanced',
        days: [
          ProgramDay(
            dayIndex: 1,
            title: 'Advanced review',
            drills: [
              ProgramDrill(drillCode: 'kickShot', targetReps: 8),
              ProgramDrill(drillCode: 'breakShot', targetReps: 10),
              ProgramDrill(drillCode: 'safety', targetReps: 10),
            ],
          ),
          ProgramDay(
            dayIndex: 2,
            title: 'Advanced review',
            drills: [
              ProgramDrill(drillCode: 'kickShot', targetReps: 8),
              ProgramDrill(drillCode: 'breakShot', targetReps: 10),
              ProgramDrill(drillCode: 'safety', targetReps: 10),
            ],
          ),
          ProgramDay(
            dayIndex: 3,
            title: 'Advanced review',
            drills: [
              ProgramDrill(drillCode: 'kickShot', targetReps: 8),
              ProgramDrill(drillCode: 'breakShot', targetReps: 10),
              ProgramDrill(drillCode: 'safety', targetReps: 10),
            ],
          ),
        ],
      ),
    ],
  ),
);

const List<ProgramSeed> programSeeds = [
  beginnerProgram,
  intermediateProgram,
  advancedProgram,
];

/// Loads seed lessons + programs into the DB if missing. Idempotent —
/// inserts only rows whose unique `code` is absent.
Future<void> seedTrainingSystem(TrainingSystemRepository repo) async {
  for (final l in lessonSeeds) {
    final existing = await repo.getLessonByCode(l.code);
    if (existing != null) continue;
    await repo.upsertCustomProgram(TrainingProgram(
      code: '__seed_lesson_${l.code}',
      title: l.title,
      description: l.description,
      isSeed: true,
      createdAt: DateTime.now(),
    ));
  }
  for (final p in programSeeds) {
    final existing = await repo.getProgramByCode(p.code);
    if (existing != null) continue;
    await repo.upsertCustomProgram(TrainingProgram(
      code: p.code,
      title: p.title,
      description: p.description,
      difficulty: p.difficulty,
      weekCount: p.hierarchy.weeks.length,
      hierarchy: p.hierarchy,
      isSeed: true,
      createdAt: DateTime.now(),
    ));
  }
}

final seedTrainingSystemProvider = Provider<Future<void> Function()>((ref) {
  final repo = ref.watch(trainingSystemRepositoryProvider);
  return () => seedTrainingSystem(repo);
});