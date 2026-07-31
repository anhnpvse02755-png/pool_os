// EPIC 04 Phase 2.6 — Season skeleton screen.
//
// PO 2026-07-31: NO Season Engine. This screen is a UI shell that surfaces
// the planned "Season" feature so users see the roadmap. It does NOT
// aggregate tournaments into a season (the engine will), does NOT compute
// per-season rankings, and does NOT persist anything.

import 'package:flutter/material.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class SeasonSkeletonScreen extends StatelessWidget {
  const SeasonSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('tnmt_season_title'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_view_week, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.get('tnmt_season_skeleton_hint'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}