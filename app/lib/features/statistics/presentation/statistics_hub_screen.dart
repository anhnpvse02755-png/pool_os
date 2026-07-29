// EPIC 02 — Statistics & Analytics — Revision 2.
//
// `StatisticsHubScreen` is the new entry point of the `/statistics`
// route. It composes the four new detail screens as tabs so the
// existing nav graph already wired into `app_router.dart` resolves
// to the new aggregator-driven surface instead of the legacy
// 3-tab `StatisticsScreen`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'equipment_statistics_screen.dart';
import 'match_statistics_screen.dart';
import 'performance_screen.dart';
import 'player_statistics_screen.dart';
import 'session_statistics_screen.dart';
import 'trend_screen.dart';

class StatisticsHubScreen extends ConsumerStatefulWidget {
  const StatisticsHubScreen({super.key});

  @override
  ConsumerState<StatisticsHubScreen> createState() =>
      _StatisticsHubScreenState();
}

class _StatisticsHubScreenState extends ConsumerState<StatisticsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Match'),
            Tab(text: 'Equipment'),
            Tab(text: 'Player'),
            Tab(text: 'Session'),
            Tab(text: 'Performance'),
            Tab(text: 'Trend'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          MatchStatisticsScreen(),
          EquipmentStatisticsScreen(),
          PlayerStatisticsScreen(),
          SessionStatisticsScreen(),
          StatisticsPerformanceScreen(),
          TrendScreen(),
        ],
      ),
    );
  }
}
