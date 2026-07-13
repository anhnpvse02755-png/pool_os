import 'package:flutter/material.dart';
import 'package:pool_os/features/player/domain/models/player.dart';
import 'package:pool_os/features/player/domain/player_profile_service.dart';
import 'package:pool_os/features/player/presentation/player_profile_provider.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/equipment/presentation/equipment_screen.dart';
import 'package:pool_os/features/equipment/domain/cue_role_resolver.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 05: display-mode section widgets for the career profile. Kept in one
/// place so the screen file stays readable. All read-only except Equipment,
/// which navigates to the Equipment screen.

Widget _sectionCard(BuildContext context, String title, IconData icon, List<Widget> children) {
  final theme = Theme.of(context);
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
}

Widget _kv(BuildContext context, String k, String v) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(k, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ),
        Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    ),
  );
}

Widget _chips(BuildContext context, List<String> labels, Color color) {
  if (labels.isEmpty) {
    return Text('—', style: TextStyle(color: Colors.grey[600]));
  }
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: labels
        .map((l) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withAlpha(28),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withAlpha(90)),
              ),
              child: Text(l, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ))
        .toList(),
  );
}

Widget profileSection(BuildContext c, Player p, String locale, AppLocalizations n) {
  final vi = locale == 'vi';
  return _sectionCard(c, vi ? 'Hồ sơ cơ thủ' : 'Player profile', Icons.badge, [
    if (p.rank != null) _kv(c, vi ? 'Hạng' : 'Rank', p.rank!),
    if (p.mainGame != null) _kv(c, vi ? 'Game chính' : 'Main game', p.mainGame!),
    if (p.goal != null && p.goal!.isNotEmpty) _kv(c, vi ? 'Mục tiêu' : 'Goal', p.goal!),
    if (p.age != null) _kv(c, vi ? 'Tuổi' : 'Age', '${p.age}'),
    if (p.gender != null && p.gender!.isNotEmpty) _kv(c, vi ? 'Giới tính' : 'Gender', p.gender!),
    _kv(c, vi ? 'Tay thuận' : 'Dominant hand', p.dominantHand),
    if (p.clubRegion != null && p.clubRegion!.isNotEmpty)
      _kv(c, vi ? 'CLB/Khu vực' : 'Club/Region', p.clubRegion!),
  ]);
}

Widget stylesSection(BuildContext c, Player p, String locale, AppLocalizations n) {
  final vi = locale == 'vi';
  return _sectionCard(c, vi ? 'Phong cách thi đấu' : 'Play style', Icons.sports_martial_arts, [
    _chips(c, p.playStyles.map((s) => PlayStyles.label(s, locale)).toList(), Colors.deepPurple),
  ]);
}

Widget goalsSection(BuildContext c, Player p, String locale, AppLocalizations n) {
  final vi = locale == 'vi';
  return _sectionCard(c, vi ? 'Mục tiêu luyện tập' : 'Training goals', Icons.flag, [
    _chips(c, p.trainingGoals.map((g) => TrainingGoals.label(g, locale)).toList(), Colors.teal),
  ]);
}

Widget experienceSection(BuildContext c, Player p, String locale, AppLocalizations n) {
  final vi = locale == 'vi';
  final months = p.monthsPlaying;
  return _sectionCard(c, vi ? 'Kinh nghiệm' : 'Experience', Icons.timeline, [
    if (months != null)
      _kv(c, vi ? 'Thời gian chơi' : 'Playing for',
          vi ? '$months tháng' : '$months months'),
    _kv(c, vi ? 'Đã thi đấu giải' : 'Competed',
        p.hasCompeted ? (vi ? 'Rồi' : 'Yes') : (vi ? 'Chưa' : 'No')),
    if (p.hoursPerWeek != null)
      _kv(c, vi ? 'Giờ / tuần' : 'Hours / week', '${p.hoursPerWeek}'),
  ]);
}

Widget equipmentSection(
    BuildContext c, PlayerProfileState s, String locale, AppLocalizations n) {
  final vi = locale == 'vi';
  Widget row(String role, Cue? cue, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withAlpha(28),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color),
            ),
            child: Text(CueRole.label(role, locale),
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(cue?.name ?? (vi ? 'Chưa chọn' : 'Not set'),
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: cue == null ? Colors.grey : null)),
          ),
        ],
      ),
    );
  }

  return _sectionCard(c, vi ? 'Thiết bị đang dùng' : 'Equipment in use', Icons.sports_bar, [
    row(CueRole.playing, s.playingCue, Colors.green),
    row(CueRole.breakRole, s.breakCue, Colors.orange),
    row(CueRole.jump, s.jumpCue, Colors.blue),
    const SizedBox(height: 4),
    Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(c).push(
            MaterialPageRoute(builder: (_) => const EquipmentScreen()),
          );
        },
        icon: const Icon(Icons.tune, size: 16),
        label: Text(vi ? 'Quản lý thiết bị' : 'Manage equipment'),
      ),
    ),
  ]);
}

Widget achievementsSection(
    BuildContext c, ProfileAchievements? a, String locale, AppLocalizations n) {
  final vi = locale == 'vi';
  final theme = Theme.of(c);
  final tiles = <Widget>[];
  void tile(IconData icon, String label, String value) {
    tiles.add(Container(
      width: 104,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    ));
  }

  if (a == null || a.isEmpty) {
    return _sectionCard(c, vi ? 'Thành tích' : 'Achievements', Icons.emoji_events, [
      Text(vi ? 'Chưa có dữ liệu thi đấu.' : 'No match data yet.',
          style: TextStyle(color: Colors.grey[600])),
    ]);
  }

  tile(Icons.trending_up, vi ? 'Best Run' : 'Best Run', '${a.bestRun}');
  tile(Icons.bolt, vi ? 'Break & Run' : 'Break & Run', '${a.breakAndRun}');
  tile(Icons.local_fire_department, vi ? 'Chuỗi thắng' : 'Win streak', '${a.longestWinStreak}');
  tile(Icons.sports, vi ? 'Tổng Match' : 'Total Matches', '${a.totalMatches}');

  return _sectionCard(c, vi ? 'Thành tích' : 'Achievements', Icons.emoji_events, [
    Wrap(spacing: 10, runSpacing: 10, children: tiles),
  ]);
}

Widget timelineSection(
    BuildContext c, List<TimelineEntry> entries, String locale, AppLocalizations n) {
  final vi = locale == 'vi';
  final theme = Theme.of(c);
  if (entries.isEmpty) {
    return _sectionCard(c, vi ? 'Hành trình' : 'Timeline', Icons.route, [
      Text(vi ? 'Hành trình của bạn sẽ xuất hiện khi bạn chơi.' : 'Your journey appears as you play.',
          style: TextStyle(color: Colors.grey[600])),
    ]);
  }

  String ym(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.year}';

  final rows = <Widget>[];
  for (var i = 0; i < entries.length; i++) {
    final e = entries[i];
    rows.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            if (i != entries.length - 1)
              Container(width: 2, height: 34, color: theme.colorScheme.primary.withAlpha(80)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ym(e.date), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                Text(e.label(locale), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  return _sectionCard(c, vi ? 'Hành trình' : 'Timeline', Icons.route, rows);
}
