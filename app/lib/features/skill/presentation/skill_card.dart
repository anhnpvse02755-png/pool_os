import 'package:flutter/material.dart';
import 'package:pool_os/features/skill/domain/models/skill.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class SkillCard extends StatelessWidget {
  final PlayerSkill skill;
  final VoidCallback? onTap;

  const SkillCard({
    super.key,
    required this.skill,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final categoryEnum = skill.categoryEnum;
    final displayName = categoryEnum != null
        ? l10n.get(categoryEnum.displayKey)
        : skill.category;
    final description = categoryEnum != null
        ? l10n.get(categoryEnum.descriptionKey)
        : '';

    final scoreColor = _getScoreColor(skill.score);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildScoreBadge(context, scoreColor),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(context, scoreColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTrendIndicator(context),
                  _buildConfidenceIndicator(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(BuildContext context, Color scoreColor) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.score.toString(),
            style: TextStyle(
              color: scoreColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            l10n.get('skill_confidence').substring(0, 3),
            style: TextStyle(
              color: scoreColor.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, Color scoreColor) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: skill.score / 100,
        backgroundColor: colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
        minHeight: 8,
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon;
    Color color;
    String label;

    switch (skill.trend) {
      case 'improving':
        icon = Icons.trending_up;
        color = Colors.green;
        label = l10n.get('skill_improving');
        break;
      case 'declining':
        icon = Icons.trending_down;
        color = Colors.red;
        label = l10n.get('skill_declining');
        break;
      default:
        icon = Icons.trending_flat;
        color = colorScheme.outline;
        label = l10n.get('skill_stable');
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceIndicator(BuildContext context) {
    final confidenceColor = skill.hasSufficientConfidence
        ? Colors.green
        : Colors.orange;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.analytics_outlined,
          size: 14,
          color: confidenceColor,
        ),
        const SizedBox(width: 4),
        Text(
          '${skill.confidence.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: confidenceColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.purple;
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
