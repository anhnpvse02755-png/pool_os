import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/domain/models/player.dart';
import 'package:pool_os/features/player/domain/player_profile_service.dart';
import 'package:pool_os/features/player/presentation/player_profile_provider.dart';
import 'package:pool_os/features/player/presentation/player_profile_edit_sheet.dart';
import 'package:pool_os/features/player/presentation/player_profile_sections.dart'
    as sections;
import 'package:pool_os/features/player_model/presentation/player_progress_section.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 05: the "career profile" — not a settings screen. A hero header, the
/// cue-sport identity (rank, main game, styles, goals, experience), the cues in
/// use (read-only, tap to open Equipment), achievements, and a development
/// timeline. All persisted; editable through a bottom sheet.
class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final state = ref.watch(playerProfileProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final player = state.player;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(playerProfileProvider.notifier).load(),
        child: CustomScrollView(
          slivers: [
            _buildHeroHeader(context, ref, player, locale, l10n),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (player == null)
                      _buildCreatePrompt(context, ref, l10n)
                    else ...[
                      _buildProfileCard(context, player, locale, l10n),
                      const SizedBox(height: 16),
                      _buildStylesCard(context, player, locale, l10n),
                      const SizedBox(height: 16),
                      _buildGoalsCard(context, player, locale, l10n),
                      const SizedBox(height: 16),
                      _buildExperienceCard(context, player, locale, l10n),
                      const SizedBox(height: 16),
                      const PlayerProgressSection(),
                      const SizedBox(height: 16),
                    ],
                    _buildEquipmentCard(context, state, locale, l10n),
                    const SizedBox(height: 16),
                    _buildAchievementsCard(
                        context, state.achievements, locale, l10n),
                    const SizedBox(height: 16),
                    _buildTimelineCard(context, state.timeline, locale, l10n),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: player == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEdit(context, ref, player),
              icon: const Icon(Icons.edit),
              label: Text(l10n.get('edit')),
            ),
    );
  }

  void _openEdit(BuildContext context, WidgetRef ref, Player? player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => PlayerProfileEditSheet(player: player),
    );
  }

  // ---- Hero header: the "athlete card" identity band ----
  Widget _buildHeroHeader(BuildContext context, WidgetRef ref, Player? player,
      String locale, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final vi = locale == 'vi';
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      title: Text(vi ? 'Hồ sơ cơ thủ' : 'Player Profile'),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withAlpha(160),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white.withAlpha(230),
                        child: Text(
                          player?.initials ?? 'P',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player?.name ??
                                  (vi ? 'Chưa có hồ sơ' : 'No profile yet'),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (player?.rank != null ||
                                player?.mainGame != null)
                              Text(
                                [
                                  if (player?.rank != null)
                                    '${vi ? 'Hạng' : 'Rank'} ${player!.rank}',
                                  if (player?.mainGame != null)
                                    player!.mainGame,
                                ].join('  ·  '),
                                style: TextStyle(
                                    color: Colors.white.withAlpha(230)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePrompt(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final vi = locale == 'vi';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.badge_outlined,
                size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(vi ? 'Tạo hồ sơ cơ thủ của bạn' : 'Create your player profile',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _openEdit(context, ref, null),
              icon: const Icon(Icons.add),
              label: Text(vi ? 'Tạo hồ sơ' : 'Create profile'),
            ),
          ],
        ),
      ),
    );
  }

  // Display-section widgets live in player_profile_sections.dart to keep this
  // file focused on layout.
  Widget _buildProfileCard(
          BuildContext c, Player p, String l, AppLocalizations n) =>
      sections.profileSection(c, p, l, n);
  Widget _buildStylesCard(
          BuildContext c, Player p, String l, AppLocalizations n) =>
      sections.stylesSection(c, p, l, n);
  Widget _buildGoalsCard(
          BuildContext c, Player p, String l, AppLocalizations n) =>
      sections.goalsSection(c, p, l, n);
  Widget _buildExperienceCard(
          BuildContext c, Player p, String l, AppLocalizations n) =>
      sections.experienceSection(c, p, l, n);
  Widget _buildEquipmentCard(
          BuildContext c, PlayerProfileState s, String l, AppLocalizations n) =>
      sections.equipmentSection(c, s, l, n);
  Widget _buildAchievementsCard(BuildContext c, ProfileAchievements? a,
          String l, AppLocalizations n) =>
      sections.achievementsSection(c, a, l, n);
  Widget _buildTimelineCard(BuildContext c, List<TimelineEntry> t, String l,
          AppLocalizations n) =>
      sections.timelineSection(c, t, l, n);
}
