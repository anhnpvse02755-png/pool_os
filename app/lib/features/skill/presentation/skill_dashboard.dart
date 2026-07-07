import 'package:flutter/material.dart';
import 'package:pool_os/features/skill/domain/models/skill.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';
import 'skill_card.dart';
import 'skill_radar_chart.dart';

class SkillDashboard extends StatelessWidget {
  final List<PlayerSkill> skills;
  final bool isLoading;
  final VoidCallback? onRecalculate;
  final void Function(PlayerSkill)? onSkillTap;

  const SkillDashboard({
    super.key,
    required this.skills,
    this.isLoading = false,
    this.onRecalculate,
    this.onSkillTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (skills.isEmpty && !isLoading) {
      return _buildEmptyState(context, l10n);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, l10n),
          const SizedBox(height: 24),
          _buildRadarSection(context, l10n),
          const SizedBox(height: 24),
          _buildSkillsSection(context, l10n),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.get('no_skills_yet'),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRecalculate != null)
              FilledButton.icon(
                onPressed: onRecalculate,
                icon: const Icon(Icons.calculate),
                label: Text(l10n.get('calculate_skills')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.get('skill_overview'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.get('last_updated'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (onRecalculate != null)
          IconButton(
            onPressed: onRecalculate,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.get('calculate_skills'),
          ),
      ],
    );
  }

  Widget _buildRadarSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('skill_radar'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SkillRadarChart(
                skills: skills,
                size: MediaQuery.of(context).size.width - 100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    final sortedSkills = List<PlayerSkill>.from(skills)
      ..sort((a, b) {
        if (a.hasSufficientConfidence != b.hasSufficientConfidence) {
          return a.hasSufficientConfidence ? -1 : 1;
        }
        return b.score.compareTo(a.score);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('skill_cards'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedSkills.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final skill = sortedSkills[index];
            return SkillCard(
              skill: skill,
              onTap: onSkillTap != null ? () => onSkillTap!(skill) : null,
            );
          },
        ),
      ],
    );
  }
}
