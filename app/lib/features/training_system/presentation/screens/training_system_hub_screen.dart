// EPIC 03 — Training System hub screen.
//
// Lists the 7 deliverables the spec §Scope requires. Each tile navigates
// to its dedicated screen. No AI, no recommendation, no prediction.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pool_os/features/training_system/presentation/screens/coach_notes_screen.dart';
import 'package:pool_os/features/training_system/presentation/screens/drill_library_screen.dart';
import 'package:pool_os/features/training_system/presentation/screens/goal_screen.dart';
import 'package:pool_os/features/training_system/presentation/screens/lesson_screen.dart';
import 'package:pool_os/features/training_system/presentation/screens/practice_session_screen.dart';
import 'package:pool_os/features/training_system/presentation/screens/progress_screen.dart';
import 'package:pool_os/features/training_system/presentation/screens/program_screen.dart';

class TrainingSystemHubScreen extends ConsumerWidget {
  const TrainingSystemHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = <_HubTile>[
      const _HubTile(
        title: 'Drill Library',
        subtitle: 'Built-in drill catalog',
        icon: Icons.library_books,
        screen: DrillLibraryScreen(),
      ),
      const _HubTile(
        title: 'Practice Session',
        subtitle: 'Record drills and reps',
        icon: Icons.fitness_center,
        screen: PracticeSessionScreen(),
      ),
      const _HubTile(
        title: 'Goals',
        subtitle: 'Not started / Active / Completed / Archived',
        icon: Icons.flag,
        screen: GoalScreen(),
      ),
      const _HubTile(
        title: 'Progress',
        subtitle: 'Historical aggregates only',
        icon: Icons.show_chart,
        screen: ProgressScreen(),
      ),
      const _HubTile(
        title: 'Personal Training Program',
        subtitle: 'Beginner / Intermediate / Advanced / Custom',
        icon: Icons.view_module,
        screen: ProgramScreen(),
      ),
      const _HubTile(
        title: 'Lessons',
        subtitle: 'Static learning content',
        icon: Icons.menu_book,
        screen: LessonScreen(),
      ),
      const _HubTile(
        title: 'Coach Notes',
        subtitle: 'Manual notes — no AI',
        icon: Icons.note_alt,
        screen: CoachNotesScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Training System')),
      body: ListView.separated(
        itemCount: tiles.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, i) => ListTile(
          leading: Icon(tiles[i].icon),
          title: Text(tiles[i].title),
          subtitle: Text(tiles[i].subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => tiles[i].screen,
            ),
          ),
        ),
      ),
    );
  }
}

class _HubTile {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget screen;
  const _HubTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screen,
  });
}
